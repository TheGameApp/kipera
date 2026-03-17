class AchievementKey {
  static const firstStep = 'first_step';
  static const streak3 = 'streak_3';
  static const weeklyWarrior = 'weekly_warrior';
  static const biweeklyChampion = 'biweekly_champion';
  static const monthlyMaster = 'monthly_master';
  static const centurion = 'centurion';
  static const quarterWay = 'quarter_way';
  static const halfWay = 'half_way';
  static const almostThere = 'almost_there';
  static const goalAchieved = 'goal_achieved';
  static const club100 = 'club_100';
  static const club1000 = 'club_1000';
  static const perfectWeek = 'perfect_week';
  static const perfectMonth = 'perfect_month';
  static const comeback = 'comeback';
}

class AchievementChecker {
  const AchievementChecker._();

  static List<String> check({
    required int currentStreak,
    required double totalSaved,
    required double goalProgress,
    required int consecutiveDaysInWeek,
    required int consecutiveDaysInMonth,
    required int daysSinceLastSave,
    required bool isFirstEntry,
    required Set<String> alreadyUnlocked,
  }) {
    final newAchievements = <String>[];

    void tryUnlock(String key, bool condition) {
      if (condition && !alreadyUnlocked.contains(key)) {
        newAchievements.add(key);
      }
    }

    tryUnlock(AchievementKey.firstStep, isFirstEntry);
    tryUnlock(AchievementKey.streak3, currentStreak >= 3);
    tryUnlock(AchievementKey.weeklyWarrior, currentStreak >= 7);
    tryUnlock(AchievementKey.biweeklyChampion, currentStreak >= 14);
    tryUnlock(AchievementKey.monthlyMaster, currentStreak >= 30);
    tryUnlock(AchievementKey.centurion, currentStreak >= 100);
    tryUnlock(AchievementKey.quarterWay, goalProgress >= 0.25);
    tryUnlock(AchievementKey.halfWay, goalProgress >= 0.50);
    tryUnlock(AchievementKey.almostThere, goalProgress >= 0.75);
    tryUnlock(AchievementKey.goalAchieved, goalProgress >= 1.0);
    tryUnlock(AchievementKey.club100, totalSaved >= 100);
    tryUnlock(AchievementKey.club1000, totalSaved >= 1000);
    tryUnlock(AchievementKey.perfectWeek, consecutiveDaysInWeek >= 7);
    tryUnlock(AchievementKey.perfectMonth, consecutiveDaysInMonth >= 28);
    tryUnlock(AchievementKey.comeback, daysSinceLastSave >= 3 && !isFirstEntry);

    return newAchievements;
  }
}
