import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/goal_members_table.dart';

part 'goal_members_dao.g.dart';

@DriftAccessor(tables: [GoalMembers])
class GoalMembersDao extends DatabaseAccessor<AppDatabase> with _$GoalMembersDaoMixin {
  GoalMembersDao(super.db);

  /// Get all accepted members for a goal.
  Future<List<GoalMember>> getMembersForGoal(String goalId) =>
      (select(goalMembers)
            ..where((t) => t.goalId.equals(goalId) & t.status.equals('accepted')))
          .get();

  /// Watch members for a goal (reactive).
  Stream<List<GoalMember>> watchMembersForGoal(String goalId) =>
      (select(goalMembers)
            ..where((t) => t.goalId.equals(goalId) & t.status.equals('accepted')))
          .watch();

  /// Get partner member (not the owner) for a goal.
  Future<GoalMember?> getPartner(String goalId, String currentUserId) =>
      (select(goalMembers)
            ..where((t) =>
                t.goalId.equals(goalId) &
                t.status.equals('accepted') &
                t.userId.equals(currentUserId).not()))
          .getSingleOrNull();

  /// Insert or update a member.
  Future<void> upsertMember(GoalMembersCompanion member) =>
      into(goalMembers).insertOnConflictUpdate(member);

  /// Delete all members for a goal.
  Future<void> deleteMembersForGoal(String goalId) =>
      (delete(goalMembers)..where((t) => t.goalId.equals(goalId))).go();
}
