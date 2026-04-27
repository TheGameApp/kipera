import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;

    debugPrint('🔔 [Notifications] initializing...');
    tz.initializeTimeZones();

    // Detect device timezone and set it as local
    try {
      final tzInfo = await FlutterTimezone.getLocalTimezone();
      debugPrint('🔔 [Notifications] device timezone: ${tzInfo.identifier}');
      tz.setLocalLocation(tz.getLocation(tzInfo.identifier));
    } catch (e) {
      debugPrint('⚠️ [Notifications] could not detect timezone: $e — using UTC');
    }
    final localTz = tz.local;
    debugPrint('🔔 [Notifications] using timezone: ${localTz.name}');

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
      // Show notifications even when the app is in the foreground
      defaultPresentAlert: true,
      defaultPresentSound: true,
      defaultPresentBadge: true,
      defaultPresentBanner: true,
      defaultPresentList: true,
    );
    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );
    await _plugin.initialize(
      settings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        debugPrint('🔔 [Notifications] tapped — payload: ${response.payload}');
      },
    );
    _initialized = true;

    // TODO(UX): defer the iOS permission prompt to a contextual moment
    // (e.g. first couple goal creation) with an explanatory pre-prompt,
    // instead of asking at app launch. iOS shows this dialog only once per
    // install — denial requires the user to go to Settings to reverse.
    final iosPlugin = _plugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >();
    if (iosPlugin != null) {
      await iosPlugin.requestPermissions(alert: true, badge: true, sound: true);
      debugPrint('🔔 [Notifications] iOS permissions requested');
    }

    // Request permissions on Android 13+
    await _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestNotificationsPermission();

    debugPrint('✅ [Notifications] initialized and permissions requested');
  }

  /// Schedules a daily recurring notification for a goal at the given time.
  /// Uses [goalId] hashCode as notification ID so each goal has its own notification.
  Future<void> scheduleDailyReminder({
    required String goalId,
    required int hour,
    required int minute,
    required String title,
    required String body,
  }) async {
    if (!_initialized) {
      debugPrint('❌ [Notifications] not initialized — skipping schedule');
      return;
    }

    final notificationId = goalId.hashCode.abs() % 100000;
    debugPrint(
      '🔔 [Notifications] scheduling daily reminder — goalId: $goalId, id: $notificationId, time: $hour:$minute',
    );

    const androidDetails = AndroidNotificationDetails(
      'daily_reminders',
      'Daily Reminders',
      channelDescription: 'Daily saving reminders for your goals',
      importance: Importance.high,
      priority: Priority.high,
    );
    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );
    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    // If the time has already passed today, schedule for tomorrow
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    debugPrint('🔔 [Notifications] next fire: $scheduledDate');

    try {
      await _plugin.zonedSchedule(
        notificationId,
        title,
        body,
        scheduledDate,
        details,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
      );
      debugPrint(
        '✅ [Notifications] scheduled successfully for $hour:$minute daily',
      );
    } catch (e) {
      debugPrint('❌ [Notifications] error scheduling: $e');
    }
  }

  /// Cancels the notification for a specific goal.
  Future<void> cancelGoalReminder(String goalId) async {
    final notificationId = goalId.hashCode.abs() % 100000;
    debugPrint(
      '🔔 [Notifications] cancelling reminder for goalId: $goalId (id: $notificationId)',
    );
    await _plugin.cancel(notificationId);
  }

  Future<void> showAchievementNotification({
    required String title,
    required String body,
  }) async {
    debugPrint('🔔 [Notifications] showing achievement: $title');
    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        'achievements',
        'Achievements',
        channelDescription: 'Achievement notifications',
        importance: Importance.high,
        priority: Priority.high,
      ),
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );
    await _plugin.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      details,
    );
  }

  /// Lists all pending notifications (for debugging).
  Future<void> debugListPending() async {
    final pending = await _plugin.pendingNotificationRequests();
    debugPrint('🔔 [Notifications] pending count: ${pending.length}');
    for (final n in pending) {
      debugPrint('  📋 id: ${n.id}, title: ${n.title}, body: ${n.body}');
    }
  }

  /// Fires a test notification immediately (for debugging).
  Future<void> debugFireTestNotification() async {
    debugPrint('🔔 [Notifications] firing test notification NOW');
    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        'daily_reminders',
        'Daily Reminders',
        channelDescription: 'Daily saving reminders for your goals',
        importance: Importance.high,
        priority: Priority.high,
      ),
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );
    await _plugin.show(
      99999,
      'Kipera Test',
      'If you see this, notifications are working!',
      details,
    );
    debugPrint('✅ [Notifications] test notification fired');
  }

  Future<void> cancelAll() async {
    debugPrint('🔔 [Notifications] cancelling all');
    await _plugin.cancelAll();
  }
}
