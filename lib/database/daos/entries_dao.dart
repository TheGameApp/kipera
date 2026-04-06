import 'dart:convert';
import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/saving_entries_table.dart';

part 'entries_dao.g.dart';

@DriftAccessor(tables: [SavingEntries])
class EntriesDao extends DatabaseAccessor<AppDatabase> with _$EntriesDaoMixin {
  EntriesDao(super.db);

  Future<List<SavingEntry>> getEntriesForGoal(String goalId) =>
      (select(savingEntries)
            ..where((t) => t.goalId.equals(goalId))
            ..orderBy([(t) => OrderingTerm.asc(t.date)]))
          .get();

  Stream<List<SavingEntry>> watchEntriesForGoal(String goalId) =>
      (select(savingEntries)
            ..where((t) => t.goalId.equals(goalId))
            ..orderBy([(t) => OrderingTerm.asc(t.date)]))
          .watch();

  /// Get entries for a specific user within a goal (for couple goals).
  Future<List<SavingEntry>> getEntriesForGoalUser(String goalId, String userId) =>
      (select(savingEntries)
            ..where((t) => t.goalId.equals(goalId) & t.userId.equals(userId))
            ..orderBy([(t) => OrderingTerm.asc(t.date)]))
          .get();

  /// Watch entries from a partner (not the current user) — for couple heatmap/history.
  Stream<List<SavingEntry>> watchPartnerEntries(String goalId, String currentUserId) =>
      (select(savingEntries)
            ..where((t) =>
                t.goalId.equals(goalId) &
                t.userId.isNotNull() &
                t.userId.equals(currentUserId).not())
            ..orderBy([(t) => OrderingTerm.asc(t.date)]))
          .watch();

  Future<SavingEntry?> getEntryForDate(String goalId, DateTime date) {
    final dateOnly = DateTime(date.year, date.month, date.day);
    return (select(savingEntries)
          ..where((t) =>
              t.goalId.equals(goalId) &
              t.date.isBetweenValues(
                dateOnly,
                dateOnly.add(const Duration(days: 1)),
              )))
        .getSingleOrNull();
  }

  /// Check if a specific user already checked in for a goal on a date.
  Future<SavingEntry?> getEntryForDateAndUser(
    String goalId,
    String userId,
    DateTime date,
  ) {
    final dateOnly = DateTime(date.year, date.month, date.day);
    return (select(savingEntries)
          ..where((t) =>
              t.goalId.equals(goalId) &
              t.userId.equals(userId) &
              t.date.isBetweenValues(
                dateOnly,
                dateOnly.add(const Duration(days: 1)),
              )))
        .getSingleOrNull();
  }

  Future<void> upsertEntry(SavingEntriesCompanion entry, {bool enqueueSync = true}) async {
    final userId = entry.userId.present ? entry.userId.value : null;

    // 1. Check if ID already exists (e.g., pulling from remote)
    SavingEntry? existing;
    if (entry.id.present) {
      existing = await (select(savingEntries)
            ..where((t) => t.id.equals(entry.id.value)))
          .getSingleOrNull();
    }

    // 2. Check by goalId + userId + date (couple-aware unique)
    existing ??= await (select(savingEntries)
          ..where((t) {
            var condition = t.goalId.equals(entry.goalId.value) &
                t.date.equals(entry.date.value);
            if (userId != null) {
              condition = condition & t.userId.equals(userId);
            }
            return condition;
          }))
        .getSingleOrNull();

    final now = DateTime.now();

    if (existing != null) {
      await (update(savingEntries)..where((t) => t.id.equals(existing!.id)))
          .write(SavingEntriesCompanion(
        actualAmount: entry.actualAmount,
        isCompleted: entry.isCompleted,
        note: entry.note,
        userId: entry.userId,
        updatedAt: Value(entry.updatedAt.present ? entry.updatedAt.value : now),
      ));
    } else {
      await into(savingEntries).insert(entry.copyWith(
        updatedAt: entry.updatedAt.present ? entry.updatedAt : Value(now),
      ));
    }

    if (enqueueSync) {
      // Enqueue for sync
      final recordId = existing?.id ?? entry.id.value;
      await db.syncQueueDao.enqueue(
        table: 'saving_entries',
        recordId: recordId,
        action: existing != null ? 'update' : 'insert',
        payload: jsonEncode({
          'id': recordId,
          'goal_id': entry.goalId.value,
          'user_id': userId,
          'date': entry.date.value.toIso8601String(),
          'expected_amount': entry.expectedAmount.value,
          'actual_amount': entry.actualAmount.value,
          'is_completed': entry.isCompleted.value,
          'note': entry.note.present ? entry.note.value : null,
          'created_at': entry.createdAt.value.toIso8601String(),
          'updated_at': now.toIso8601String(),
        }),
      );
    }
  }

  /// Delete all entries for a goal (local only, no sync queue).
  Future<void> deleteEntriesForGoal(String goalId) =>
      (delete(savingEntries)..where((t) => t.goalId.equals(goalId))).go();

  Future<List<SavingEntry>> getCompletedEntriesForGoal(String goalId) =>
      (select(savingEntries)
            ..where((t) =>
                t.goalId.equals(goalId) & t.isCompleted.equals(true))
            ..orderBy([(t) => OrderingTerm.desc(t.date)]))
          .get();

  Future<double> getTotalSavedForGoal(String goalId) async {
    final entries = await (select(savingEntries)
          ..where((t) =>
              t.goalId.equals(goalId) & t.isCompleted.equals(true)))
        .get();
    double total = 0;
    for (final e in entries) {
      total += e.actualAmount;
    }
    return total;
  }

  Future<double> getTotalSavedForUser(String userId) async {
    final query = customSelect(
      'SELECT SUM(e.actual_amount) as total FROM saving_entries e '
      'INNER JOIN savings_goals g ON e.goal_id = g.id '
      'LEFT JOIN goal_members gm ON g.id = gm.goal_id AND gm.user_id = ? AND gm.status = \'accepted\' '
      'WHERE (g.user_id = ? OR gm.id IS NOT NULL) AND e.is_completed = 1',
      variables: [Variable.withString(userId), Variable.withString(userId)],
      readsFrom: {savingEntries},
    );
    final result = await query.getSingle();
    return result.data['total'] as double? ?? 0.0;
  }

  Stream<List<SavingEntry>> watchTodayEntries(String userId) {
    final today = DateTime.now();
    final start = DateTime(today.year, today.month, today.day);
    final end = start.add(const Duration(days: 1));
    return customSelect(
      'SELECT DISTINCT e.* FROM saving_entries e '
      'INNER JOIN savings_goals g ON e.goal_id = g.id '
      'LEFT JOIN goal_members gm ON g.id = gm.goal_id AND gm.user_id = ? AND gm.status = \'accepted\' '
      'WHERE (g.user_id = ? OR gm.id IS NOT NULL) AND e.date >= ? AND e.date < ?',
      variables: [
        Variable.withString(userId),
        Variable.withString(userId),
        Variable.withDateTime(start),
        Variable.withDateTime(end),
      ],
      readsFrom: {savingEntries},
    ).watch().map((rows) => rows
        .map((row) => SavingEntry(
              id: row.read<String>('id'),
              goalId: row.read<String>('goal_id'),
              userId: row.readNullable<String>('user_id'),
              date: row.read<DateTime>('date'),
              expectedAmount: row.read<double>('expected_amount'),
              actualAmount: row.read<double>('actual_amount'),
              isCompleted: row.read<bool>('is_completed'),
              note: row.readNullable<String>('note'),
              createdAt: row.read<DateTime>('created_at'),
            ))
        .toList());
  }
}
