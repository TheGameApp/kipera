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

  Future<void> upsertEntry(SavingEntriesCompanion entry) async {
    // Use goal_id + date unique constraint instead of primary key
    final existing = await (select(savingEntries)
          ..where((t) =>
              t.goalId.equals(entry.goalId.value) &
              t.date.equals(entry.date.value)))
        .getSingleOrNull();

    if (existing != null) {
      await (update(savingEntries)..where((t) => t.id.equals(existing.id)))
          .write(SavingEntriesCompanion(
        actualAmount: entry.actualAmount,
        isCompleted: entry.isCompleted,
        note: entry.note,
      ));
    } else {
      await into(savingEntries).insert(entry);
    }
  }

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
      'WHERE g.user_id = ? AND e.is_completed = 1',
      variables: [Variable.withString(userId)],
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
      'SELECT e.* FROM saving_entries e '
      'INNER JOIN savings_goals g ON e.goal_id = g.id '
      'WHERE g.user_id = ? AND e.date >= ? AND e.date < ?',
      variables: [
        Variable.withString(userId),
        Variable.withDateTime(start),
        Variable.withDateTime(end),
      ],
      readsFrom: {savingEntries},
    ).watch().map((rows) => rows
        .map((row) => SavingEntry(
              id: row.read<String>('id'),
              goalId: row.read<String>('goal_id'),
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
