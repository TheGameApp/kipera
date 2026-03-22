import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../database/app_database.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../home/presentation/providers/home_provider.dart';

final allAchievementsProvider = FutureProvider<List<Achievement>>((ref) {
  final db = ref.watch(databaseProvider);
  return db.achievementsDao.getAllAchievements();
});

final userAchievementsProvider =
    StreamProvider<List<UserAchievement>>((ref) {
  final user = ref.watch(currentUserProvider);
  if (user == null) return Stream.value([]);
  final db = ref.watch(databaseProvider);
  return db.achievementsDao.watchUserAchievements(user.id);
});

class AchievementsScreen extends ConsumerWidget {
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allAsync = ref.watch(allAchievementsProvider);
    final userAsync = ref.watch(userAchievementsProvider);

    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.achievements)),
      body: allAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (allAchievements) {
          final unlockedIds = userAsync.valueOrNull
                  ?.map((ua) => ua.achievementId)
                  .toSet() ??
              {};

          return GridView.builder(
            padding: const EdgeInsets.all(20),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 0.8,
            ),
            itemCount: allAchievements.length,
            itemBuilder: (context, index) {
              final achievement = allAchievements[index];
              final isUnlocked = unlockedIds.contains(achievement.id);

              return _AchievementCard(
                achievement: achievement,
                isUnlocked: isUnlocked,
              );
            },
          );
        },
      ),
    );
  }
}

class _AchievementCard extends StatelessWidget {
  final Achievement achievement;
  final bool isUnlocked;

  const _AchievementCard({
    required this.achievement,
    required this.isUnlocked,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isUnlocked
            ? AppColors.primaryContainer.withValues(alpha: 0.5)
            : context.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: isUnlocked
            ? Border.all(color: AppColors.primary, width: 2)
            : Border.all(
                color: context.isDarkMode
                    ? AppColors.borderDark
                    : AppColors.borderLight,
              ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _iconFromName(achievement.iconName),
            size: 32,
            color: isUnlocked
                ? AppColors.primary
                : (context.isDarkMode ? Colors.grey.shade600 : Colors.grey.shade400),
          ),
          const SizedBox(height: 8),
          Text(
            achievement.title,
            style: context.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: isUnlocked
                  ? null
                  : (context.isDarkMode ? Colors.grey.shade600 : Colors.grey.shade400),
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          if (!isUnlocked)
            Icon(Icons.lock, size: 14,
                color: context.isDarkMode ? Colors.grey.shade600 : Colors.grey.shade400),
        ],
      ),
    );
  }

  IconData _iconFromName(String name) {
    return switch (name) {
      'emoji_events' => Icons.emoji_events,
      'local_fire_department' => Icons.local_fire_department,
      'military_tech' => Icons.military_tech,
      'workspace_premium' => Icons.workspace_premium,
      'star' => Icons.star,
      'shield' => Icons.shield,
      'looks_one' => Icons.looks_one,
      'looks_two' => Icons.looks_two,
      'looks_3' => Icons.looks_3,
      'savings' => Icons.savings,
      'diamond' => Icons.diamond,
      'calendar_today' => Icons.calendar_today,
      'calendar_month' => Icons.calendar_month,
      'undo' => Icons.undo,
      _ => Icons.emoji_events,
    };
  }
}
