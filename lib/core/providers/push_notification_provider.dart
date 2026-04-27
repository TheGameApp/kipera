import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../router/app_router.dart';
import '../services/notification_service.dart';
import '../services/push_notification_service.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';

/// Singleton [PushNotificationService] bound to the current GoRouter and the
/// shared local notifications service.
final pushNotificationServiceProvider = Provider<PushNotificationService>((ref) {
  final client = ref.watch(supabaseClientProvider);
  final router = ref.watch(routerProvider);
  final service = PushNotificationService(
    supabase: client,
    localNotifications: NotificationService(),
    router: router,
  );
  ref.onDispose(() => service.dispose());
  return service;
});

/// Reactive provider that wires push-notification lifecycle to auth state:
/// - login → request permission, register FCM token
/// - logout → delete this device's token
///
/// Watch this once at app startup (e.g. inside HomeShell) to keep it alive.
final pushNotificationLifecycleProvider = Provider<void>((ref) {
  final user = ref.watch(currentUserProvider);
  final service = ref.watch(pushNotificationServiceProvider);

  if (user != null) {
    debugPrint('📬 [PushLifecycle] user logged in — initForUser');
    service.initForUser(user.id);
    ref.onDispose(() {
      debugPrint('📬 [PushLifecycle] disposing — removing token');
      service.removeTokenForUser(user.id);
    });
  }
});
