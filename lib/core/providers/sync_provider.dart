import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/connectivity_service.dart';
import '../services/supabase_service.dart';
import '../services/sync_service.dart';
import '../services/widget_service.dart';
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

/// Singleton sync service — depends on DB, Supabase, and connectivity.
final syncServiceProvider = Provider<SyncService>((ref) {
  final db = ref.watch(databaseProvider);
  final supabase = ref.watch(supabaseServiceProvider);
  final connectivity = ref.watch(connectivityServiceProvider);

  final service = SyncService(
    db: db,
    supabase: supabase,
    connectivity: connectivity,
  );

  // Refresh the home-screen widget whenever a realtime sync completes
  // (e.g. partner check-in). The local check-in flow already refreshes
  // the widget inline, so this specifically covers remote-triggered updates.
  service.onRemoteChange = () async {
    final user = ref.read(currentUserProvider);
    if (user == null) {
      debugPrint('📱 [SyncProvider] onRemoteChange skipped — no current user');
      return;
    }
    debugPrint('📱 [SyncProvider] onRemoteChange → refreshing widget for user ${user.id}');
    final widgetService = ref.read(widgetServiceProvider);
    await widgetService.refreshWidgetFromSelectedGoal(user.id);
    debugPrint('📱 [SyncProvider] Widget refresh requested');
  };

  unawaited(service.init());
  ref.onDispose(() => service.dispose());
  return service;
});

/// Singleton widget service — updates iOS/Android home screen widgets.
final widgetServiceProvider = Provider<WidgetService>((ref) {
  final db = ref.watch(databaseProvider);
  final service = WidgetService(db);
  unawaited(service.init());
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

  // Update home screen widget with the selected (or first) goal
  final widgetService = ref.read(widgetServiceProvider);
  await widgetService.refreshWidgetFromSelectedGoal(user.id);
});
