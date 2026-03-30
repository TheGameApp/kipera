import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/sync_queue_table.dart';

part 'sync_queue_dao.g.dart';

@DriftAccessor(tables: [SyncQueue])
class SyncQueueDao extends DatabaseAccessor<AppDatabase> with _$SyncQueueDaoMixin {
  SyncQueueDao(super.db);

  /// Enqueue a change for later sync to Supabase.
  Future<void> enqueue({
    required String table,
    required String recordId,
    required String action,
    required String payload,
  }) =>
      into(syncQueue).insert(SyncQueueCompanion.insert(
        syncTableName: table,
        recordId: recordId,
        action: action,
        payload: payload,
        createdAt: DateTime.now(),
      ));

  /// Get all pending (unsynced) items, ordered oldest first.
  Future<List<SyncQueueData>> getPending() =>
      (select(syncQueue)
            ..where((t) => t.synced.equals(false))
            ..orderBy([(t) => OrderingTerm.asc(t.createdAt)]))
          .get();

  /// Mark a single item as synced.
  Future<void> markSynced(int id) =>
      (update(syncQueue)..where((t) => t.id.equals(id)))
          .write(const SyncQueueCompanion(synced: Value(true)));

  /// Delete all already-synced items (cleanup).
  Future<void> clearSynced() =>
      (delete(syncQueue)..where((t) => t.synced.equals(true))).go();

  /// Count of pending items (for UI badges).
  Future<int> pendingCount() async {
    final count = countAll();
    final query = selectOnly(syncQueue)
      ..where(syncQueue.synced.equals(false))
      ..addColumns([count]);
    final result = await query.getSingle();
    return result.read(count) ?? 0;
  }
}
