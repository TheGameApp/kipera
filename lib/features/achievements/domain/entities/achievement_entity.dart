class AchievementEntity {
  final String id;
  final String key;
  final String title;
  final String description;
  final String iconName;
  final String category;
  final DateTime? unlockedAt;
  final String? goalId;

  const AchievementEntity({
    required this.id,
    required this.key,
    required this.title,
    required this.description,
    required this.iconName,
    required this.category,
    this.unlockedAt,
    this.goalId,
  });

  bool get isUnlocked => unlockedAt != null;
}
