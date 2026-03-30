import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/connectivity_service.dart';
import '../services/notification_hook.dart';
import '../services/supabase_service.dart';
import '../services/sync_service.dart';
import '../../features/home/presentation/providers/home_provider.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';

/// Singleton connectivity service.
final connectivityServiceProvider = Provider<ConnectivityService>((ref) {
  final service = ConnectivityService();
  ref.onDispose(() => service.dispose());
  return service;
});

/// Singleton Supabase data service.
final supabaseServiceProvider = Provider<SupabaseService>((ref) {
  return SupabaseService(Supabase.instance.client);
});

/// Notification hook (no-op by default; swap for FCM implementation later).
final notificationHookProvider = Provider<NotificationHook>((ref) {
  return const NoOpNotificationHook();
});

/// Singleton sync service — depends on DB, Supabase, and connectivity.
final syncServiceProvider = Provider<SyncService>((ref) {
  final db = ref.watch(databaseProvider);
  final supabase = ref.watch(supabaseServiceProvider);
  final connectivity = ref.watch(connectivityServiceProvider);
  final notificationHook = ref.watch(notificationHookProvider);

  final service = SyncService(
    db: db,
    supabase: supabase,
    connectivity: connectivity,
    notificationHook: notificationHook,
  );
  unawaited(service.init());
  ref.onDispose(() => service.dispose());
  return service;
});

/// Reactive sync state for UI (syncing indicator, error badge, etc).
final syncStateProvider = Provider<SyncState>((ref) {
  final syncService = ref.watch(syncServiceProvider);
  return syncService.stateNotifier.value;
});

/// Auto-sync provider: triggers full sync when user is logged in.
/// Watch this in the home screen to ensure sync starts on app open.
final autoSyncProvider = FutureProvider<void>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return;

  final syncService = ref.read(syncServiceProvider);

  debugPrint('🔄 [AutoSync] User logged in — triggering initial sync');
  await syncService.syncAll();
});
