import 'dart:async';
import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../database/app_database.dart';
import 'connectivity_service.dart';
import 'notification_hook.dart';
import 'supabase_service.dart';

/// Sync state enum for UI display.
enum SyncState { idle, syncing, error }

/// Bidirectional sync service between local Drift/SQLite and Supabase.
///
/// Strategy: offline-first, last-write-wins by updated_at.
/// Flow: verify connectivity → pull remote → merge → push local → cleanup.
class SyncService {
  final AppDatabase _db;
  final SupabaseService _supabase;
  final ConnectivityService _connectivity;
  final NotificationHook _notificationHook;

  StreamSubscription<bool>? _connectivitySub;
  final ValueNotifier<SyncState> stateNotifier = ValueNotifier(SyncState.idle);

  static const _kLastSyncKey = 'kipera_last_sync_at';

  /// Persisted via SharedPreferences. null = nunca sincronizado → descarga todo.
  DateTime? _lastSyncAt;

  SyncService({
    required AppDatabase db,
    required SupabaseService supabase,
    required ConnectivityService connectivity,
    NotificationHook notificationHook = const NoOpNotificationHook(),
  })  : _db = db,
        _supabase = supabase,
        _connectivity = connectivity,
        _notificationHook = notificationHook;

  /// Carga el timestamp del último sync desde disco y arranca el listener de conectividad.
  Future<void> init() async {
    await _loadLastSyncAt();
    _connectivitySub = _connectivity.onConnectivityChanged.listen((online) {
      if (online) {
        debugPrint('🔄 [SyncService] Back online — triggering sync');
        syncAll();
      }
    });
  }

  /// Lee _lastSyncAt de SharedPreferences.
  Future<void> _loadLastSyncAt() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString(_kLastSyncKey);
    if (stored != null) {
      _lastSyncAt = DateTime.tryParse(stored);
      debugPrint('📅 [SyncService] Loaded lastSyncAt: $_lastSyncAt');
    } else {
      debugPrint('📅 [SyncService] No stored lastSyncAt — will pull everything');
    }
  }

  /// Guarda _lastSyncAt en SharedPreferences.
  Future<void> _saveLastSyncAt(DateTime ts) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kLastSyncKey, ts.toIso8601String());
    debugPrint('💾 [SyncService] Saved lastSyncAt: $ts');
  }

  /// Full sync: pull remote changes then push local queue.
  Future<void> syncAll() async {
    if (stateNotifier.value == SyncState.syncing) {
      debugPrint('⏳ [SyncService] Already syncing — skipping');
      return;
    }

    final connected = await _connectivity.isConnected;
    if (!connected) {
      debugPrint('📴 [SyncService] No connection — skipping sync');
      return;
    }

    stateNotifier.value = SyncState.syncing;
    debugPrint('🔄 [SyncService] Starting full sync...');

    try {
      // 1. PUSH: Send local mutations to the server first
      await pushLocalChanges();
      
      // 2. PULL: Fetch server's final state
      await pullRemoteChanges();
      final now = DateTime.now();
      _lastSyncAt = now;
      await _saveLastSyncAt(now);          // 💾 persiste en disco
      stateNotifier.value = SyncState.idle;
      debugPrint('✅ [SyncService] Sync completed at $_lastSyncAt');
    } catch (e) {
      debugPrint('❌ [SyncService] Sync error: $e');
      stateNotifier.value = SyncState.error;
    }
  }

  // ---------------------------------------------------------------------------
  // Pull: Remote → Local
  // ---------------------------------------------------------------------------

  /// Pull changes from Supabase and merge into local DB.
  Future<void> pullRemoteChanges() async {
    debugPrint('⬇️ [SyncService] Pulling remote changes...');

    await _pullGoals();
    await _pullEntries();
    await _pullMembers();
    await _pullInvitations();
  }

  Future<void> _pullGoals() async {
    final since = _lastSyncAt ?? DateTime(2000);
    final remoteGoals = await _supabase.fetchGoalsSince(since);
    debugPrint('⬇️ [SyncService] Pulled ${remoteGoals.length} goals');

    for (final remote in remoteGoals) {
      final localGoal = await _db.goalsDao.getGoalById(remote['id'] as String);
      final remoteUpdatedAt = DateTime.parse(remote['updated_at'] as String);

      if (localGoal == null || remoteUpdatedAt.isAfter(localGoal.updatedAt)) {
        // Remote is newer or doesn't exist locally → upsert
        await _db.goalsDao.insertGoal(
          SavingsGoalsCompanion(
            id: Value(remote['id'] as String),
            userId: Value(remote['user_id'] as String),
            name: Value(remote['name'] as String),
            targetAmount: Value((remote['target_amount'] as num).toDouble()),
            method: Value(remote['method'] as String),
            methodConfig: Value(jsonEncode(remote['method_config'])),
            colorHex: Value(remote['color_hex'] as String),
            iconName: Value(remote['icon_name'] as String),
            startDate: Value(DateTime.parse(remote['start_date'] as String)),
            endDate: Value(remote['end_date'] != null
                ? DateTime.parse(remote['end_date'] as String)
                : null),
            status: Value(remote['status'] as String),
            isCoupleGoal: Value(remote['is_couple_goal'] as bool? ?? false),
            createdAt: Value(DateTime.parse(remote['created_at'] as String)),
            updatedAt: Value(remoteUpdatedAt),
          ),
          enqueueSync: false,
        );

        // If the goal already existed, update instead of insert
        if (localGoal != null) {
          await _db.goalsDao.updateGoal(
            remote['id'] as String,
            SavingsGoalsCompanion(
              name: Value(remote['name'] as String),
              targetAmount: Value((remote['target_amount'] as num).toDouble()),
              status: Value(remote['status'] as String),
              isCoupleGoal: Value(remote['is_couple_goal'] as bool? ?? false),
              updatedAt: Value(remoteUpdatedAt),
            ),
            enqueueSync: false,
          );
        }
      }
    }
  }

  Future<void> _pullEntries() async {
    final since = _lastSyncAt ?? DateTime(2000);
    final remoteEntries = await _supabase.fetchEntriesSince(since);
    debugPrint('⬇️ [SyncService] Pulled ${remoteEntries.length} entries');

    for (final remote in remoteEntries) {
      final goalId = remote['goal_id'] as String;
      final userId = remote['user_id'] as String;

      await _db.entriesDao.upsertEntry(
        SavingEntriesCompanion(
          id: Value(remote['id'] as String),
          goalId: Value(goalId),
          userId: Value(userId),
          date: Value(DateTime.parse(remote['date'] as String)),
          expectedAmount: Value((remote['expected_amount'] as num).toDouble()),
          actualAmount: Value((remote['actual_amount'] as num).toDouble()),
          isCompleted: Value(remote['is_completed'] as bool? ?? false),
          note: Value(remote['note'] as String?),
          createdAt: Value(DateTime.parse(remote['created_at'] as String)),
        ),
        enqueueSync: false,
      );

      // 🔔 Notification hook: partner check-in from remote
      // If this entry doesn't belong to the goal owner, it's a partner's entry
      final goal = await _db.goalsDao.getGoalById(goalId);
      if (goal != null && goal.userId != userId && goal.isCoupleGoal) {
        await _notificationHook.onPartnerCheckIn(
          goalId,
          userId,
          (remote['actual_amount'] as num).toDouble(),
        );
      }
    }
  }

  Future<void> _pullMembers() async {
    // Pull members for all local couple goals
    final allGoals = await _db.goalsDao.getActiveGoals(
      // We need the current user's ID, but since this is called from providers
      // that already have the user context, we pull for all local goals
      '', // This will be overridden — see below
    );

    // For couple goals, fetch their members
    for (final goal in allGoals) {
      if (goal.isCoupleGoal) {
        final remoteMembers = await _supabase.fetchGoalMembers(goal.id);
        for (final member in remoteMembers) {
          await _db.goalMembersDao.upsertMember(GoalMembersCompanion(
            id: Value(member['id'] as String),
            goalId: Value(member['goal_id'] as String),
            userId: Value(member['user_id'] as String),
            role: Value(member['role'] as String),
            status: Value(member['status'] as String),
            joinedAt: Value(member['joined_at'] != null
                ? DateTime.parse(member['joined_at'] as String)
                : null),
          ));
        }
      }
    }
  }

  Future<void> _pullInvitations() async {
    // Invitations are fetched on-demand via InvitationService
    // They don't need periodic pull since they're checked when the
    // invitations screen opens
    debugPrint('⬇️ [SyncService] Invitations pulled on-demand (skip)');
  }

  // ---------------------------------------------------------------------------
  // Push: Local → Remote
  // ---------------------------------------------------------------------------

  /// Process the sync queue and push pending changes to Supabase.
  Future<void> pushLocalChanges() async {
    final pending = await _db.syncQueueDao.getPending();
    debugPrint('⬆️ [SyncService] Processing ${pending.length} pending items');

    for (final item in pending) {
      try {
        final payload = jsonDecode(item.payload) as Map<String, dynamic>;

        switch (item.syncTableName) {
          case 'savings_goals':
            await _pushGoal(item.action, payload);
            break;
          case 'saving_entries':
            await _pushEntry(item.action, payload);
            break;
          default:
            debugPrint('⚠️ [SyncService] Unknown table: ${item.syncTableName}');
        }

        await _db.syncQueueDao.markSynced(item.id);
      } catch (e) {
        debugPrint('❌ [SyncService] Failed to push item ${item.id}: $e');
        // Don't mark as synced — will retry on next sync
      }
    }

    // Cleanup synced items
    await _db.syncQueueDao.clearSynced();
  }

  Future<void> _pushGoal(String action, Map<String, dynamic> payload) async {
    switch (action) {
      case 'insert':
      case 'update':
        await _supabase.upsertGoal(_toSupabaseGoal(payload));
        break;
      case 'delete':
        await _supabase.deleteGoal(payload['id'] as String);
        break;
    }
  }

  Future<void> _pushEntry(String action, Map<String, dynamic> payload) async {
    switch (action) {
      case 'insert':
      case 'update':
        await _supabase.upsertEntry(_toSupabaseEntry(payload));
        break;
    }
  }

  // ---------------------------------------------------------------------------
  // Data converters: Drift companion JSON → Supabase JSON
  // ---------------------------------------------------------------------------

  Map<String, dynamic> _toSupabaseGoal(Map<String, dynamic> local) {
    return {
      'id': local['id'],
      'user_id': local['user_id'] ?? local['userId'],
      'name': local['name'],
      'target_amount': local['target_amount'] ?? local['targetAmount'],
      'method': local['method'],
      'method_config': local['method_config'] != null
          ? (local['method_config'] is String
              ? jsonDecode(local['method_config'] as String)
              : local['method_config'])
          : local['methodConfig'] != null
              ? (local['methodConfig'] is String
                  ? jsonDecode(local['methodConfig'] as String)
                  : local['methodConfig'])
              : {},
      'color_hex': local['color_hex'] ?? local['colorHex'],
      'icon_name': local['icon_name'] ?? local['iconName'],
      'start_date': local['start_date'] ?? local['startDate'],
      'end_date': local['end_date'] ?? local['endDate'],
      'status': local['status'] ?? 'active',
      'is_couple_goal': local['is_couple_goal'] ?? local['isCoupleGoal'] ?? false,
      'created_at': local['created_at'] ?? local['createdAt'],
      'updated_at': local['updated_at'] ?? local['updatedAt'] ?? DateTime.now().toIso8601String(),
    };
  }

  Map<String, dynamic> _toSupabaseEntry(Map<String, dynamic> local) {
    return {
      'id': local['id'],
      'goal_id': local['goal_id'] ?? local['goalId'],
      'user_id': local['user_id'] ?? local['userId'],
      'date': local['date'],
      'expected_amount': local['expected_amount'] ?? local['expectedAmount'],
      'actual_amount': local['actual_amount'] ?? local['actualAmount'] ?? 0,
      'is_completed': local['is_completed'] ?? local['isCompleted'] ?? false,
      'note': local['note'],
      'created_at': local['created_at'] ?? local['createdAt'],
    };
  }

  // ---------------------------------------------------------------------------
  // Lifecycle
  // ---------------------------------------------------------------------------

  void dispose() {
    _connectivitySub?.cancel();
    stateNotifier.dispose();
  }
}
