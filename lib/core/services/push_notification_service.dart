import 'dart:async';
import 'dart:io' show Platform;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import 'notification_service.dart';

/// Top-level background message handler required by FCM.
/// Fires when the app is terminated or fully backgrounded and a push arrives.
/// For now we just log — displaying the notification UI is handled by the
/// system when the payload has a `notification` block.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint('📬 [PushBG] background message — id: ${message.messageId}, data: ${message.data}');
}

/// Fire-and-forget helper to invoke the `send-push-notification` Edge Function.
/// Failures are swallowed and logged — a push dropping should never break the
/// user-facing flow that triggered it (check-in, invitation, etc.).
Future<void> sendPushEvent(
  SupabaseClient client, {
  required String eventType,
  required String goalId,
  required String senderUserId,
  String? invitationId,
  Map<String, dynamic>? extra,
}) async {
  try {
    final body = <String, dynamic>{
      'event_type': eventType,
      'goal_id': goalId,
      'sender_user_id': senderUserId,
      if (invitationId != null) 'invitation_id': invitationId,
      if (extra != null) 'extra': extra,
    };
    debugPrint('📤 [PushInvoke] $eventType — goalId: $goalId');
    await client.functions.invoke('send-push-notification', body: body);
  } catch (e) {
    debugPrint('⚠️ [PushInvoke] $eventType failed: $e');
  }
}

/// Handles Firebase Cloud Messaging token registration, permission prompts,
/// foreground notifications and navigation on notification tap.
///
/// Lifecycle is driven by [pushNotificationProvider], which calls
/// [initForUser] on login and [removeTokenForUser] on logout.
class PushNotificationService {
  static const _deviceIdKey = 'kipera.push.device_id';

  final SupabaseClient _supabase;
  final NotificationService _localNotifications;
  final GoRouter _router;

  StreamSubscription<RemoteMessage>? _onMessageSub;
  StreamSubscription<RemoteMessage>? _onOpenedSub;
  StreamSubscription<String>? _onTokenRefreshSub;
  String? _currentUserId;
  String? _deviceId;

  PushNotificationService({
    required SupabaseClient supabase,
    required NotificationService localNotifications,
    required GoRouter router,
  })  : _supabase = supabase,
        _localNotifications = localNotifications,
        _router = router;

  Future<void> initForUser(String userId) async {
    _currentUserId = userId;
    debugPrint('📬 [Push] initForUser — userId: $userId');

    final messaging = FirebaseMessaging.instance;

    // TODO(UX): currently the iOS dialog already fired during bootstrap via
    // NotificationService.init(). When we move to a contextual prompt, this
    // call should only run after the user has confirmed intent (e.g. after
    // they accept the pre-prompt on first couple goal).
    final settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    debugPrint('📬 [Push] permission status: ${settings.authorizationStatus}');
    if (settings.authorizationStatus == AuthorizationStatus.denied) {
      debugPrint('📬 [Push] permission denied — skipping token registration');
      return;
    }

    if (Platform.isIOS) {
      // APNs token is required before FCM can issue a token on iOS.
      // It may take a few seconds to arrive after requesting permission.
      final apns = await messaging.getAPNSToken();
      debugPrint('📬 [Push] APNs token: ${apns == null ? "null (retrying)" : "received"}');
    }

    final token = await messaging.getToken();
    if (token != null) {
      await _registerToken(userId, token);
    } else {
      debugPrint('📬 [Push] getToken returned null — will rely on onTokenRefresh');
    }

    await _onTokenRefreshSub?.cancel();
    _onTokenRefreshSub = messaging.onTokenRefresh.listen((newToken) {
      debugPrint('📬 [Push] token refreshed');
      if (_currentUserId != null) {
        _registerToken(_currentUserId!, newToken);
      }
    });

    await _onMessageSub?.cancel();
    _onMessageSub = FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    await _onOpenedSub?.cancel();
    _onOpenedSub = FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpened);

    // App launched from a terminated state via notification tap.
    final initial = await messaging.getInitialMessage();
    if (initial != null) {
      debugPrint('📬 [Push] app launched from notification tap');
      _handleMessageOpened(initial);
    }
  }

  Future<void> removeTokenForUser(String userId) async {
    debugPrint('📬 [Push] removeTokenForUser — userId: $userId');
    final deviceId = await _getOrCreateDeviceId();
    try {
      await _supabase
          .from('device_tokens')
          .delete()
          .eq('user_id', userId)
          .eq('device_id', deviceId);
      debugPrint('📬 [Push] token removed from device_tokens');
    } catch (e) {
      debugPrint('❌ [Push] removeTokenForUser error: $e');
    }
    await _teardownListeners();
    _currentUserId = null;
  }

  Future<void> dispose() async {
    await _teardownListeners();
  }

  Future<void> _teardownListeners() async {
    await _onMessageSub?.cancel();
    await _onOpenedSub?.cancel();
    await _onTokenRefreshSub?.cancel();
    _onMessageSub = null;
    _onOpenedSub = null;
    _onTokenRefreshSub = null;
  }

  Future<void> _registerToken(String userId, String fcmToken) async {
    final deviceId = await _getOrCreateDeviceId();
    final platform = Platform.isIOS ? 'ios' : 'android';
    debugPrint('📬 [Push] registering token — platform: $platform, deviceId: $deviceId');
    try {
      await _supabase.from('device_tokens').upsert({
        'user_id': userId,
        'fcm_token': fcmToken,
        'platform': platform,
        'device_id': deviceId,
        'updated_at': DateTime.now().toUtc().toIso8601String(),
      }, onConflict: 'user_id,device_id');
      debugPrint('✅ [Push] token registered');
    } catch (e) {
      debugPrint('❌ [Push] _registerToken error: $e');
    }
  }

  Future<String> _getOrCreateDeviceId() async {
    if (_deviceId != null) return _deviceId!;
    final prefs = await SharedPreferences.getInstance();
    var id = prefs.getString(_deviceIdKey);
    if (id == null) {
      id = const Uuid().v4();
      await prefs.setString(_deviceIdKey, id);
      debugPrint('📬 [Push] generated new deviceId: $id');
    }
    _deviceId = id;
    return id;
  }

  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    debugPrint('📬 [Push] foreground message — data: ${message.data}, notification: ${message.notification?.title}');
    final title = message.notification?.title ?? message.data['title'] ?? 'Kipera';
    final body = message.notification?.body ?? message.data['body'] ?? '';
    if (body.isEmpty) return;
    await _localNotifications.showAchievementNotification(title: title, body: body);
  }

  void _handleMessageOpened(RemoteMessage message) {
    final data = message.data;
    debugPrint('📬 [Push] notification tapped — data: $data');
    final eventType = data['event_type'] as String?;
    final goalId = data['goal_id'] as String?;

    // Deep-link navigation: always anchor the stack at `/home` first, then
    // push the destination on top. This guarantees a predictable back-stack
    // regardless of whether the app was cold-started, backgrounded, or
    // already foreground. GoRouter.go() REPLACES the stack (not additive),
    // so there's no risk of duplicating `/home` when the user is already there.
    if (eventType == 'invitation_sent' || eventType == 'invitation_received') {
      _router.go('/home');
      _router.push('/invitations');
      return;
    }
    if (goalId != null && goalId.isNotEmpty) {
      _router.go('/home');
      _router.push('/goal/$goalId');
    }
  }
}
