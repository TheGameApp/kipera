import 'package:drift/drift.dart';
import 'savings_goals_table.dart';
import 'users_table.dart';

/// Tracks partner invitations for couple goals.
/// Mirrors the Supabase `goal_invitations` table for offline access.
class GoalInvitations extends Table {
  TextColumn get id => text()();
  TextColumn get goalId => text().references(SavingsGoals, #id)();
  TextColumn get inviterId => text().references(Users, #id)();
  TextColumn get inviteeEmail => text()();
  TextColumn get status => text().withDefault(const Constant('pending'))(); // 'pending', 'accepted', 'rejected', 'expired'
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get respondedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
