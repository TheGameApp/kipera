import 'dart:async';
import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../database/app_database.dart';
import 'connectivity_service.dart';
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

  /// Invoked after a realtime-triggered sync finishes. Used by the UI layer
  /// to refresh dependent surfaces (e.g. the home-screen widget) when a
  /// partner's check-in arrives.
  Future<void> Function()? onRemoteChange;

  StreamSubscription<bool>? _connectivitySub;
  RealtimeChannel? _realtimeChannel;
  final ValueNotifier<SyncState> stateNotifier = ValueNotifier(SyncState.idle);

  /// Coalescing flag: set when syncAll() is called while another sync is
  /// already running. After the current sync finishes we run one more pass so
  /// that mutations enqueued during the in-flight sync (e.g. a check-in) are
  /// not left stranded in sync_queue.
  bool _pendingResync = false;

  static const _kLastSyncKey = 'kipera_last_sync_at';
  static const _kDiscardLogKey = 'kipera_sync_discards';
  static const _kDiscardLogMax = 100;

  /// Persisted via SharedPreferences. null = nunca sincronizado → descarga todo.
  DateTime? _lastSyncAt;

  SyncService({
    required AppDatabase db,
    required SupabaseService supabase,
    required ConnectivityService connectivity,
  })  : _db = db,
        _supabase = supabase,
        _connectivity = connectivity;

  /// Carga el timestamp del último sync desde disco y arranca el listener de conectividad.
  Future<void> init() async {
    await _loadLastSyncAt();

    // Detect stale cursor: if lastSyncAt exists but local DB is empty
    // (e.g. app was reinstalled), reset to force a full download.
    if (_lastSyncAt != null) {
      final localGoals = await _db.goalsDao.getActiveGoals('');
      if (localGoals.isEmpty) {
        debugPrint('⚠️ [SyncService] lastSyncAt set but DB is empty — resetting for full sync');
        _lastSyncAt = null;
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove(_kLastSyncKey);
      }
    }

    // Listen for realtime connectivity changes
    _connectivitySub = _connectivity.onConnectivityChanged.listen((online) {
      if (online) {
        debugPrint('🔄 [SyncService] Back online — triggering sync');
        syncAll();
      }
    });

    // Listen for real-time changes directly from Supabase DB to update UI live
    _realtimeChannel = _supabase.client
        .channel('public:saving_entries')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'saving_entries',
          callback: (payload) async {
            debugPrint('⚡ [Realtime] Payload received from Supabase! Triggering sync...');
            await syncAll();
            debugPrint('⚡ [Realtime] syncAll finished — invoking onRemoteChange');
            await onRemoteChange?.call();
            debugPrint('⚡ [Realtime] onRemoteChange completed');
          },
        )
        .subscribe();
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
      // Another sync is in-flight. Flag a follow-up run so any mutations
      // queued in the meantime get pushed as soon as the current pass ends.
      _pendingResync = true;
      debugPrint('⏳ [SyncService] Already syncing — queued follow-up');
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
      // Use UTC so the ISO string carries a 'Z' suffix. Supabase compares
      // against `server_updated_at` (timestamptz); without the Z, a naive
      // local time is (mis)interpreted as UTC and shifts the cursor by the
      // device's timezone offset — causing the same entries to be pulled
      // every sync.
      final now = DateTime.now().toUtc();
      _lastSyncAt = now;
      await _saveLastSyncAt(now);          // 💾 persiste en disco
      stateNotifier.value = SyncState.idle;
      debugPrint('✅ [SyncService] Sync completed at $_lastSyncAt');
    } catch (e) {
      debugPrint('❌ [SyncService] Sync error: $e');
      stateNotifier.value = SyncState.error;
    }

    // Coalesced follow-up: if someone called syncAll() while we were busy,
    // run exactly one more pass to flush whatever was enqueued.
    if (_pendingResync) {
      _pendingResync = false;
      debugPrint('🔁 [SyncService] Running coalesced follow-up sync');
      unawaited(syncAll());
    }
  }

  /// Lightweight sync for a single goal. Used by screens that only care about
  /// one goal (goal detail, check-in) so they don't pay the cost of pulling
  /// every goal/entry/member the user has access to.
  ///
  /// Semantics:
  /// * Pushes only the queue items related to [goalId] (goal row + its entries)
  /// * Pulls all entries for that goal (bounded set, usually <100)
  /// * Pulls members + owner profile for that goal if it's a couple goal
  Future<void> syncGoal(String goalId) async {
    if (stateNotifier.value == SyncState.syncing) {
      // Reuse the same coalescing flag as syncAll — the follow-up will be a
      // full sync, which is a safe superset of what we'd need here.
      _pendingResync = true;
      debugPrint('⏳ [SyncService] Already syncing — queued follow-up (from syncGoal)');
      return;
    }

    final connected = await _connectivity.isConnected;
    if (!connected) {
      debugPrint('📴 [SyncService] No connection — skipping syncGoal');
      return;
    }

    stateNotifier.value = SyncState.syncing;
    debugPrint('🔄 [SyncService] Starting syncGoal($goalId)...');

    try {
      await _pushLocalChangesForGoal(goalId);
      await _pullEntriesForGoal(goalId);
      await _pullMembersForGoal(goalId);
      stateNotifier.value = SyncState.idle;
      debugPrint('✅ [SyncService] syncGoal($goalId) completed');
    } catch (e) {
      debugPrint('❌ [SyncService] syncGoal error: $e');
      stateNotifier.value = SyncState.error;
    }

    if (_pendingResync) {
      _pendingResync = false;
      debugPrint('🔁 [SyncService] Running coalesced follow-up sync (from syncGoal)');
      unawaited(syncAll());
    }
  }

  /// Forces a complete re-download of all data from Supabase.
  /// Useful when permissions change (e.g. accepting a couple goal invitation)
  /// and we need to fetch past records that were previously blocked by RLS.
  Future<void> forceFullSync() async {
    debugPrint('🔄 [SyncService] Forcing FULL sync (resetting cursor)...');
    _lastSyncAt = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kLastSyncKey);
    await syncAll();
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
    final since = _lastSyncAt ?? DateTime.utc(2000);
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
            startDate: Value(_parseDateOnly(remote['start_date'] as String)),
            endDate: Value(remote['end_date'] != null
                ? _parseDateOnly(remote['end_date'] as String)
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
    final since = _lastSyncAt ?? DateTime.utc(2000);
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
          date: Value(_parseDateOnly(remote['date'] as String)),
          expectedAmount: Value((remote['expected_amount'] as num).toDouble()),
          actualAmount: Value((remote['actual_amount'] as num).toDouble()),
          isCompleted: Value(remote['is_completed'] as bool? ?? false),
          note: Value(remote['note'] as String?),
          createdAt: Value(DateTime.parse(remote['created_at'] as String)),
          updatedAt: Value(remote['updated_at'] != null
              ? DateTime.parse(remote['updated_at'] as String)
              : null),
        ),
        enqueueSync: false,
      );
      // Partner check-in notifications are delivered via FCM push from the
      // `send-push-notification` Edge Function — firing a local notification
      // here would double up (and also replay on every sync-pull).
    }
  }

  Future<void> _pullMembers() async {
    // Use empty userId to get ALL local active goals — we need to find couple
    // goals regardless of ownership, because goal_members rows haven't been
    // downloaded yet (chicken-and-egg: we need members to filter by user,
    // but we're here to download members).
    final allGoals = await _db.goalsDao.getActiveGoals('');
    final coupleGoals = allGoals.where((g) => g.isCoupleGoal).toList();
    if (coupleGoals.isEmpty) return;

    final coupleIds = coupleGoals.map((g) => g.id).toList();

    // 1️⃣ Single batch query for ALL couple-goal members (includes partner
    // profiles via the embedded select). Previously this loop made N HTTP
    // requests, one per goal.
    final remoteMembers = await _supabase.fetchMembersForGoals(coupleIds);
    debugPrint(
      '⬇️ [SyncService] Pulled ${remoteMembers.length} members for '
      '${coupleGoals.length} couple goals (batched)',
    );

    final now = DateTime.now();
    for (final member in remoteMembers) {
      final userId = member['user_id'] as String;
      await _db.goalMembersDao.upsertMember(GoalMembersCompanion(
        id: Value(member['id'] as String),
        goalId: Value(member['goal_id'] as String),
        userId: Value(userId),
        role: Value(member['role'] as String),
        status: Value(member['status'] as String),
        joinedAt: Value(member['joined_at'] != null
            ? DateTime.parse(member['joined_at'] as String)
            : null),
      ));

      final profile = member['profiles'] as Map<String, dynamic>?;
      if (profile != null) {
        await _db.usersDao.upsertUser(UsersCompanion(
          id: Value(userId),
          email: Value(profile['email'] as String? ?? ''),
          displayName: Value(profile['display_name'] as String?),
          createdAt: Value(now),
          updatedAt: Value(now),
        ));
      }
    }

    // 2️⃣ Owners don't appear in goal_members, so their profile isn't embedded
    // in the batch above. Figure out which owners still need a profile locally
    // and fetch them in a single query.
    final ownerIds = coupleGoals.map((g) => g.userId).toSet().toList();
    final missingOwnerIds = <String>[];
    for (final ownerId in ownerIds) {
      final ownerInDb = await _db.usersDao.getUserById(ownerId);
      if (ownerInDb == null || ownerInDb.displayName == null) {
        missingOwnerIds.add(ownerId);
      }
    }

    if (missingOwnerIds.isNotEmpty) {
      final ownerProfiles =
          await _supabase.fetchProfilesByIds(missingOwnerIds);
      debugPrint(
        '⬇️ [SyncService] Pulled ${ownerProfiles.length} owner profiles (batched)',
      );
      for (final profile in ownerProfiles) {
        await _db.usersDao.upsertUser(UsersCompanion(
          id: Value(profile['id'] as String),
          email: Value(profile['email'] as String? ?? ''),
          displayName: Value(profile['display_name'] as String?),
          createdAt: Value(now),
          updatedAt: Value(now),
        ));
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
  // Per-goal helpers (used by syncGoal)
  // ---------------------------------------------------------------------------

  /// Pull all entries for a single goal and upsert them locally.
  /// Doesn't use the global cursor: a single goal's entries are a bounded set
  /// (usually <100) and we want the freshest data for the screen the user is
  /// looking at.
  Future<void> _pullEntriesForGoal(String goalId) async {
    final remoteEntries = await _supabase.fetchEntriesForGoal(goalId);
    debugPrint(
      '⬇️ [SyncService] Pulled ${remoteEntries.length} entries for goal $goalId',
    );

    for (final remote in remoteEntries) {
      await _db.entriesDao.upsertEntry(
        SavingEntriesCompanion(
          id: Value(remote['id'] as String),
          goalId: Value(remote['goal_id'] as String),
          userId: Value(remote['user_id'] as String),
          date: Value(_parseDateOnly(remote['date'] as String)),
          expectedAmount: Value((remote['expected_amount'] as num).toDouble()),
          actualAmount: Value((remote['actual_amount'] as num).toDouble()),
          isCompleted: Value(remote['is_completed'] as bool? ?? false),
          note: Value(remote['note'] as String?),
          createdAt: Value(DateTime.parse(remote['created_at'] as String)),
          updatedAt: Value(remote['updated_at'] != null
              ? DateTime.parse(remote['updated_at'] as String)
              : null),
        ),
        enqueueSync: false,
      );
      // Partner check-in notifications are delivered via FCM push — see note
      // in `_pullEntries` above.
    }
  }

  /// Pull members + owner profile for a single goal. 1-2 HTTP calls max.
  Future<void> _pullMembersForGoal(String goalId) async {
    final goal = await _db.goalsDao.getGoalById(goalId);
    if (goal == null || !goal.isCoupleGoal) return;

    final remoteMembers = await _supabase.fetchGoalMembers(goalId);
    debugPrint(
      '⬇️ [SyncService] Pulled ${remoteMembers.length} members for goal $goalId',
    );

    final now = DateTime.now();
    for (final member in remoteMembers) {
      final userId = member['user_id'] as String;
      await _db.goalMembersDao.upsertMember(GoalMembersCompanion(
        id: Value(member['id'] as String),
        goalId: Value(member['goal_id'] as String),
        userId: Value(userId),
        role: Value(member['role'] as String),
        status: Value(member['status'] as String),
        joinedAt: Value(member['joined_at'] != null
            ? DateTime.parse(member['joined_at'] as String)
            : null),
      ));

      final profile = member['profiles'] as Map<String, dynamic>?;
      if (profile != null) {
        await _db.usersDao.upsertUser(UsersCompanion(
          id: Value(userId),
          email: Value(profile['email'] as String? ?? ''),
          displayName: Value(profile['display_name'] as String?),
          createdAt: Value(now),
          updatedAt: Value(now),
        ));
      }
    }

    // Ensure the owner's profile is cached (owner has no goal_members row).
    final ownerInDb = await _db.usersDao.getUserById(goal.userId);
    if (ownerInDb == null || ownerInDb.displayName == null) {
      final ownerProfile = await _supabase.getProfile(goal.userId);
      if (ownerProfile != null) {
        await _db.usersDao.upsertUser(UsersCompanion(
          id: Value(goal.userId),
          email: Value(ownerProfile['email'] as String? ?? ''),
          displayName: Value(ownerProfile['display_name'] as String?),
          createdAt: Value(now),
          updatedAt: Value(now),
        ));
      }
    }
  }

  /// Push only the sync_queue items related to [goalId]. Covers:
  /// * `savings_goals` rows where recordId == goalId
  /// * `saving_entries` rows whose payload carries this goalId
  ///
  /// Mirrors the error handling of [pushLocalChanges] (including the silent
  /// discard of 23503/23505 with a persistent log) so behavior stays
  /// consistent between global and per-goal pushes.
  Future<void> _pushLocalChangesForGoal(String goalId) async {
    final pending = await _db.syncQueueDao.getPending();

    final filtered = pending.where((item) {
      if (item.syncTableName == 'savings_goals') {
        return item.recordId == goalId;
      }
      if (item.syncTableName == 'saving_entries') {
        try {
          final payload = jsonDecode(item.payload) as Map<String, dynamic>;
          final itemGoalId = payload['goal_id'] ?? payload['goalId'];
          return itemGoalId == goalId;
        } catch (_) {
          return false;
        }
      }
      return false;
    }).toList();

    debugPrint(
      '⬆️ [SyncService] Processing ${filtered.length} pending items for goal $goalId',
    );

    for (final item in filtered) {
      try {
        final payload = jsonDecode(item.payload) as Map<String, dynamic>;
        switch (item.syncTableName) {
          case 'savings_goals':
            await _pushGoal(item.action, payload);
            break;
          case 'saving_entries':
            await _pushEntry(item.action, payload);
            break;
        }
        await _db.syncQueueDao.markSynced(item.id);
      } catch (e) {
        debugPrint('❌ [SyncService] Failed to push item ${item.id}: $e');

        final isUnrecoverable = e.toString().contains('23503') ||
            e.toString().contains('23505');
        if (isUnrecoverable) {
          debugPrint('🗑️ [SyncService] Discarding unrecoverable item ${item.id}');
          await _logDiscard(item, e);
          await _db.syncQueueDao.markSynced(item.id);
        }
      }
    }

    await _db.syncQueueDao.clearSynced();
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

        // Discard items with unrecoverable errors (e.g. orphaned foreign key)
        // so they don't retry forever on every sync.
        final isUnrecoverable = e.toString().contains('23503') || // FK violation
            e.toString().contains('23505');                        // unique violation
        if (isUnrecoverable) {
          debugPrint('🗑️ [SyncService] Discarding unrecoverable item ${item.id}');
          await _logDiscard(item, e);
          await _db.syncQueueDao.markSynced(item.id);
        }
      }
    }

    // Cleanup synced items
    await _db.syncQueueDao.clearSynced();
  }

  /// Persistent log of items discarded due to unrecoverable errors (FK/unique
  /// violations). Capped to the last [_kDiscardLogMax] entries.
  Future<void> _logDiscard(SyncQueueData item, Object error) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final existing = prefs.getStringList(_kDiscardLogKey) ?? const [];

      String? recordId;
      try {
        final payload = jsonDecode(item.payload) as Map<String, dynamic>;
        recordId = payload['id']?.toString();
      } catch (_) {}

      final entry = jsonEncode({
        'timestamp': DateTime.now().toIso8601String(),
        'queue_id': item.id,
        'table': item.syncTableName,
        'action': item.action,
        'record_id': recordId,
        'payload': item.payload,
        'error': error.toString(),
      });

      final updated = [...existing, entry];
      final trimmed = updated.length > _kDiscardLogMax
          ? updated.sublist(updated.length - _kDiscardLogMax)
          : updated;

      await prefs.setStringList(_kDiscardLogKey, trimmed);
    } catch (e) {
      debugPrint('⚠️ [SyncService] Failed to persist discard log: $e');
    }
  }

  /// Returns the persisted discard log, newest last. Each entry is a JSON
  /// object with timestamp, queue_id, table, action, record_id, payload, error.
  Future<List<Map<String, dynamic>>> getDiscardLog() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_kDiscardLogKey) ?? const [];
    return raw
        .map((s) {
          try {
            return jsonDecode(s) as Map<String, dynamic>;
          } catch (_) {
            return <String, dynamic>{'raw': s};
          }
        })
        .toList();
  }

  /// Clears the persisted discard log.
  Future<void> clearDiscardLog() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kDiscardLogKey);
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
  // Date helpers
  // ---------------------------------------------------------------------------

  /// Parses a date string from Supabase and returns a local DateTime with
  /// only the date component (midnight local). Avoids timezone shifting by
  /// extracting YYYY-MM-DD directly from the string.
  static DateTime _parseDateOnly(String dateStr) {
    final dateOnly = dateStr.substring(0, 10); // "2026-04-02"
    final parts = dateOnly.split('-');
    return DateTime(int.parse(parts[0]), int.parse(parts[1]), int.parse(parts[2]));
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
      'updated_at': local['updated_at'] ?? local['updatedAt'] ?? DateTime.now().toIso8601String(),
    };
  }

  // ---------------------------------------------------------------------------
  // Lifecycle
  // ---------------------------------------------------------------------------

  void dispose() {
    _connectivitySub?.cancel();
    if (_realtimeChannel != null) {
      _supabase.client.removeChannel(_realtimeChannel!);
    }
    stateNotifier.dispose();
  }
}
