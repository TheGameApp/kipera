import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

import 'tables/users_table.dart';
import 'tables/savings_goals_table.dart';
import 'tables/saving_entries_table.dart';
import 'tables/achievements_table.dart';
import 'daos/goals_dao.dart';
import 'daos/entries_dao.dart';
import 'daos/achievements_dao.dart';
import 'daos/users_dao.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [Users, SavingsGoals, SavingEntries, Achievements, UserAchievements],
  daos: [GoalsDao, EntriesDao, AchievementsDao, UsersDao],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  AppDatabase.forTesting(super.e);

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {
          await m.createAll();
          await _seedAchievements();
        },
      );

  Future<void> _seedAchievements() async {
    final achievementData = [
      ('first_step', 'First Step', 'Complete your first saving', 'emoji_events', 'milestone'),
      ('streak_3', '3-Day Streak', 'Save for 3 days in a row', 'local_fire_department', 'streak'),
      ('weekly_warrior', 'Weekly Warrior', 'Save for 7 days in a row', 'military_tech', 'streak'),
      ('biweekly_champion', 'Biweekly Champion', 'Save for 14 days in a row', 'workspace_premium', 'streak'),
      ('monthly_master', 'Monthly Master', 'Save for 30 days in a row', 'star', 'streak'),
      ('centurion', 'Centurion', 'Save for 100 days in a row', 'shield', 'streak'),
      ('quarter_way', '25% There', 'Reach 25% of your goal', 'looks_one', 'milestone'),
      ('half_way', 'Halfway!', 'Reach 50% of your goal', 'looks_two', 'milestone'),
      ('almost_there', 'Almost There!', 'Reach 75% of your goal', 'looks_3', 'milestone'),
      ('goal_achieved', 'Goal Achieved!', 'Complete 100% of your goal', 'emoji_events', 'milestone'),
      ('club_100', '\$100 Club', 'Save \$100 in total', 'savings', 'milestone'),
      ('club_1000', '\$1,000 Club', 'Save \$1,000 in total', 'diamond', 'milestone'),
      ('perfect_week', 'Perfect Week', 'Save every day for a full week', 'calendar_today', 'special'),
      ('perfect_month', 'Perfect Month', 'Save every day for a full month', 'calendar_month', 'special'),
      ('comeback', 'Triumphant Return', 'Resume saving after 3+ days off', 'undo', 'special'),
    ];

    for (final (key, title, description, icon, category) in achievementData) {
      await into(achievements).insert(AchievementsCompanion.insert(
        id: 'achievement_$key',
        key: key,
        title: title,
        description: description,
        iconName: icon,
        category: category,
      ));
    }
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, 'kipera.db'));
    return NativeDatabase.createInBackground(file);
  });
}
