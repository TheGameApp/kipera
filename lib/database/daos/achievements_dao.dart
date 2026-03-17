import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/achievements_table.dart';

part 'achievements_dao.g.dart';

@DriftAccessor(tables: [Achievements, UserAchievements])
class AchievementsDao extends DatabaseAccessor<AppDatabase>
    with _$AchievementsDaoMixin {
  AchievementsDao(super.db);

  Future<List<Achievement>> getAllAchievements() => select(achievements).get();

  Future<List<UserAchievement>> getUserAchievements(String userId) =>
      (select(userAchievements)
            ..where((t) => t.userId.equals(userId))
            ..orderBy([(t) => OrderingTerm.desc(t.unlockedAt)]))
          .get();

  Future<Set<String>> getUnlockedKeys(String userId) async {
    final query = customSelect(
      'SELECT a.key FROM user_achievements ua '
      'INNER JOIN achievements a ON ua.achievement_id = a.id '
      'WHERE ua.user_id = ?',
      variables: [Variable.withString(userId)],
      readsFrom: {userAchievements, achievements},
    );
    final results = await query.get();
    return results.map((r) => r.read<String>('key')).toSet();
  }

  Future<void> unlockAchievement(UserAchievementsCompanion achievement) =>
      into(userAchievements).insert(
        achievement,
        mode: InsertMode.insertOrIgnore,
      );

  Future<Achievement?> getAchievementByKey(String key) =>
      (select(achievements)..where((t) => t.key.equals(key)))
          .getSingleOrNull();

  Stream<List<UserAchievement>> watchUserAchievements(String userId) =>
      (select(userAchievements)
            ..where((t) => t.userId.equals(userId))
            ..orderBy([(t) => OrderingTerm.desc(t.unlockedAt)]))
          .watch();
}
