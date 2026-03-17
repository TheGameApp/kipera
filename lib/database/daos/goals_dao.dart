import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/savings_goals_table.dart';

part 'goals_dao.g.dart';

@DriftAccessor(tables: [SavingsGoals])
class GoalsDao extends DatabaseAccessor<AppDatabase> with _$GoalsDaoMixin {
  GoalsDao(super.db);

  Stream<List<SavingsGoal>> watchActiveGoals(String userId) =>
      (select(savingsGoals)
            ..where((t) => t.userId.equals(userId) & t.status.equals('active'))
            ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
          .watch();

  Future<List<SavingsGoal>> getActiveGoals(String userId) =>
      (select(savingsGoals)
            ..where((t) => t.userId.equals(userId) & t.status.equals('active')))
          .get();

  Future<SavingsGoal?> getGoalById(String id) =>
      (select(savingsGoals)..where((t) => t.id.equals(id))).getSingleOrNull();

  Stream<SavingsGoal?> watchGoal(String id) =>
      (select(savingsGoals)..where((t) => t.id.equals(id))).watchSingleOrNull();

  Future<void> insertGoal(SavingsGoalsCompanion goal) =>
      into(savingsGoals).insert(goal);

  Future<void> updateGoal(String id, SavingsGoalsCompanion companion) =>
      (update(savingsGoals)..where((t) => t.id.equals(id))).write(companion);

  Future<void> deleteGoal(String id) =>
      (delete(savingsGoals)..where((t) => t.id.equals(id))).go();

  Stream<List<SavingsGoal>> watchAllGoals(String userId) =>
      (select(savingsGoals)
            ..where((t) => t.userId.equals(userId))
            ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
          .watch();
}
