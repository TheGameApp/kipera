import 'package:drift/drift.dart';
import 'savings_goals_table.dart';

class SavingEntries extends Table {
  TextColumn get id => text()();
  TextColumn get goalId => text().references(SavingsGoals, #id)();
  TextColumn get userId => text().nullable()(); // FK to user who made the check-in (nullable for migration compat)
  DateTimeColumn get date => dateTime()();
  RealColumn get expectedAmount => real()();
  RealColumn get actualAmount => real().withDefault(const Constant(0))();
  BoolColumn get isCompleted => boolean().withDefault(const Constant(false))();
  TextColumn get note => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<Set<Column>> get uniqueKeys => [
        {goalId, userId, date}, // Includes userId so both partners can check-in same day
      ];
}
