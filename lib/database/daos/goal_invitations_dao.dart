import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/goal_invitations_table.dart';

part 'goal_invitations_dao.g.dart';

@DriftAccessor(tables: [GoalInvitations])
class GoalInvitationsDao extends DatabaseAccessor<AppDatabase> with _$GoalInvitationsDaoMixin {
  GoalInvitationsDao(super.db);

  /// Get pending invitations received by this user's email.
  Future<List<GoalInvitation>> getPendingForEmail(String email) =>
      (select(goalInvitations)
            ..where((t) =>
                t.inviteeEmail.equals(email) & t.status.equals('pending'))
            ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
          .get();

  /// Watch pending invitations for an email (reactive for badge count).
  Stream<List<GoalInvitation>> watchPendingForEmail(String email) =>
      (select(goalInvitations)
            ..where((t) =>
                t.inviteeEmail.equals(email) & t.status.equals('pending'))
            ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
          .watch();

  /// Get invitations sent by the current user.
  Future<List<GoalInvitation>> getSentByUser(String userId) =>
      (select(goalInvitations)
            ..where((t) => t.inviterId.equals(userId))
            ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
          .get();

  /// Insert or update an invitation.
  Future<void> upsertInvitation(GoalInvitationsCompanion invitation) =>
      into(goalInvitations).insertOnConflictUpdate(invitation);

  /// Delete invitations for a goal.
  Future<void> deleteForGoal(String goalId) =>
      (delete(goalInvitations)..where((t) => t.goalId.equals(goalId))).go();
}
