import 'package:drift/drift.dart';
import 'savings_goals_table.dart';
import 'users_table.dart';

/// Tracks members (owner + partner) of a shared/couple savings goal.
/// Mirrors the Supabase `goal_members` table for offline access.
class GoalMembers extends Table {
  TextColumn get id => text()();
  TextColumn get goalId => text().references(SavingsGoals, #id)();
  TextColumn get userId => text().references(Users, #id)();
  TextColumn get role => text()(); // 'owner', 'partner'
  TextColumn get status => text().withDefault(const Constant('pending'))(); // 'pending', 'accepted', 'rejected'
  DateTimeColumn get joinedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
