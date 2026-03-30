import 'dart:convert';
import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/savings_goals_table.dart';

import '../tables/goal_members_table.dart';

part 'goals_dao.g.dart';

@DriftAccessor(tables: [SavingsGoals, GoalMembers])
class GoalsDao extends DatabaseAccessor<AppDatabase> with _$GoalsDaoMixin {
  GoalsDao(super.db);

  Stream<List<SavingsGoal>> watchActiveGoals(String userId) {
    final memberGoalIds = selectOnly(goalMembers)
      ..addColumns([goalMembers.goalId])
      ..where(goalMembers.userId.equals(userId) & goalMembers.status.equals('accepted'));

    return (select(savingsGoals)
          ..where((t) =>
              (t.userId.equals(userId) | t.id.isInQuery(memberGoalIds)) &
              t.status.equals('active'))
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
        .watch();
  }

  Future<List<SavingsGoal>> getActiveGoals(String userId) {
    if (userId.isEmpty) return (select(savingsGoals)..where((t) => t.status.equals('active'))).get();
    
    final memberGoalIds = selectOnly(goalMembers)
      ..addColumns([goalMembers.goalId])
      ..where(goalMembers.userId.equals(userId) & goalMembers.status.equals('accepted'));

    return (select(savingsGoals)
          ..where((t) =>
              (t.userId.equals(userId) | t.id.isInQuery(memberGoalIds)) &
              t.status.equals('active')))
        .get();
  }

  /// Get all goals for a user (any status) — used by sync.
  Future<List<SavingsGoal>> getAllGoals(String userId) {
    if (userId.isEmpty) return select(savingsGoals).get();

    final memberGoalIds = selectOnly(goalMembers)
      ..addColumns([goalMembers.goalId])
      ..where(goalMembers.userId.equals(userId) & goalMembers.status.equals('accepted'));

    return (select(savingsGoals)
          ..where((t) => t.userId.equals(userId) | t.id.isInQuery(memberGoalIds)))
        .get();
  }

  Future<SavingsGoal?> getGoalById(String id) =>
      (select(savingsGoals)..where((t) => t.id.equals(id))).getSingleOrNull();

  Stream<SavingsGoal?> watchGoal(String id) =>
      (select(savingsGoals)..where((t) => t.id.equals(id))).watchSingleOrNull();

  Future<void> insertGoal(SavingsGoalsCompanion goal, {bool enqueueSync = true}) async {
    await into(savingsGoals).insertOnConflictUpdate(goal);

    if (enqueueSync) {
      // Enqueue for sync — safely handle absent values with defaults
      await db.syncQueueDao.enqueue(
        table: 'savings_goals',
        recordId: goal.id.value,
        action: 'insert',
        payload: jsonEncode({
          'id': goal.id.value,
          'user_id': goal.userId.value,
          'name': goal.name.value,
          'target_amount': goal.targetAmount.value,
          'method': goal.method.value,
          'method_config': goal.methodConfig.value,
          'color_hex': goal.colorHex.value,
          'icon_name': goal.iconName.value,
          'start_date': goal.startDate.value.toIso8601String(),
          'end_date': goal.endDate.present ? goal.endDate.value?.toIso8601String() : null,
          'status': goal.status.present ? goal.status.value : 'active',
          'is_couple_goal': goal.isCoupleGoal.present ? goal.isCoupleGoal.value : false,
          'created_at': goal.createdAt.value.toIso8601String(),
          'updated_at': goal.updatedAt.value.toIso8601String(),
        }),
      );
    }
  }

  Future<void> updateGoal(String id, SavingsGoalsCompanion companion, {bool enqueueSync = true}) async {
    await (update(savingsGoals)..where((t) => t.id.equals(id))).write(companion);

    if (enqueueSync) {
      // Fetch full record for sync payload
      final updated = await getGoalById(id);
      if (updated != null) {
        await db.syncQueueDao.enqueue(
          table: 'savings_goals',
          recordId: id,
          action: 'update',
          payload: jsonEncode({
            'id': updated.id,
            'user_id': updated.userId,
            'name': updated.name,
            'target_amount': updated.targetAmount,
            'method': updated.method,
            'method_config': updated.methodConfig,
            'color_hex': updated.colorHex,
            'icon_name': updated.iconName,
            'start_date': updated.startDate.toIso8601String(),
            'end_date': updated.endDate?.toIso8601String(),
            'status': updated.status,
            'is_couple_goal': updated.isCoupleGoal,
            'created_at': updated.createdAt.toIso8601String(),
            'updated_at': updated.updatedAt.toIso8601String(),
          }),
        );
      }
    }
  }

  Future<void> deleteGoal(String id) async {
    await db.syncQueueDao.enqueue(
      table: 'savings_goals',
      recordId: id,
      action: 'delete',
      payload: jsonEncode({'id': id}),
    );
    await (delete(savingsGoals)..where((t) => t.id.equals(id))).go();
  }

  /// Deletes a goal locally WITHOUT enqueuing a delete command to Supabase.
  /// Useful when an invitee "leaves" a shared goal.
  Future<void> deleteGoalRemoteOnly(String id) async {
    // We only delete the goal locally. Drift handles cascading locally if set up,
    // or we can just rely on the fact that leaving a goal means we no longer need local records.
    await (delete(savingsGoals)..where((t) => t.id.equals(id))).go();
  }

  Stream<List<SavingsGoal>> watchAllGoals(String userId) {
    if (userId.isEmpty) return select(savingsGoals).watch();

    final memberGoalIds = selectOnly(goalMembers)
      ..addColumns([goalMembers.goalId])
      ..where(goalMembers.userId.equals(userId) & goalMembers.status.equals('accepted'));

    return (select(savingsGoals)
          ..where((t) => t.userId.equals(userId) | t.id.isInQuery(memberGoalIds))
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
        .watch();
  }
}
