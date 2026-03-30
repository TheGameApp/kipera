import 'package:drift/drift.dart';
import 'users_table.dart';

class SavingsGoals extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text().references(Users, #id)();
  TextColumn get name => text()();
  RealColumn get targetAmount => real()();
  TextColumn get method => text()();
  TextColumn get methodConfig => text()(); // JSON
  TextColumn get colorHex => text()();
  TextColumn get iconName => text()();
  DateTimeColumn get startDate => dateTime()();
  DateTimeColumn get endDate => dateTime().nullable()();
  TextColumn get status => text().withDefault(const Constant('active'))();
  BoolColumn get isCoupleGoal => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
