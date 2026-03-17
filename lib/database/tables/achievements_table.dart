import 'package:drift/drift.dart';

class Achievements extends Table {
  TextColumn get id => text()();
  TextColumn get key => text().unique()();
  TextColumn get title => text()();
  TextColumn get description => text()();
  TextColumn get iconName => text()();
  TextColumn get category => text()(); // streak, milestone, special

  @override
  Set<Column> get primaryKey => {id};
}

class UserAchievements extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text()();
  TextColumn get achievementId => text()();
  TextColumn get goalId => text().nullable()();
  DateTimeColumn get unlockedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<Set<Column>> get uniqueKeys => [
        {userId, achievementId, goalId},
      ];
}
