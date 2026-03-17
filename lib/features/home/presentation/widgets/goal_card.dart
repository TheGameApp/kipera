import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/extensions/num_extensions.dart';
import '../../../../database/app_database.dart';
import '../providers/home_provider.dart';

class GoalCard extends ConsumerWidget {
  final SavingsGoal goal;
  final int colorIndex;
  final VoidCallback onTap;
  final VoidCallback onCheckIn;

  const GoalCard({
    super.key,
    required this.goal,
    required this.colorIndex,
    required this.onTap,
    required this.onCheckIn,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final totalSavedAsync = ref.watch(totalSavedForGoalProvider(goal.id));
    final bgColor = context.isDarkMode
        ? Theme.of(context).extension<dynamic>() != null
            ? AppColors.goalColors[colorIndex].withValues(alpha: 0.15)
            : Colors.white.withValues(alpha: 0.05)
        : AppColors.goalColors[colorIndex];

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.7),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        _getIconData(goal.iconName),
                        color: AppColors.primary,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          goal.name,
                          style: context.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          goal.method.replaceAll('_', ' '),
                          style: context.textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                IconButton(
                  onPressed: onCheckIn,
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.add, color: Colors.white, size: 18),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            totalSavedAsync.when(
              loading: () => const LinearProgressIndicator(),
              error: (_, __) => const LinearProgressIndicator(value: 0),
              data: (totalSaved) {
                final progress = goal.targetAmount > 0
                    ? (totalSaved / goal.targetAmount).clamp(0.0, 1.0)
                    : 0.0;
                return Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          totalSaved.toCurrency(),
                          style: context.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          goal.targetAmount.toCurrency(),
                          style: context.textTheme.bodyMedium?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 8,
                        backgroundColor: Colors.white.withValues(alpha: 0.5),
                        valueColor: const AlwaysStoppedAnimation(AppColors.primary),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        '${(progress * 100).toStringAsFixed(0)}%',
                        style: context.textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  IconData _getIconData(String name) {
    return switch (name) {
      'flight' => Icons.flight,
      'laptop' => Icons.laptop,
      'home' => Icons.home,
      'school' => Icons.school,
      'car_rental' => Icons.car_rental,
      'shopping_bag' => Icons.shopping_bag,
      'sports_esports' => Icons.sports_esports,
      'celebration' => Icons.celebration,
      'beach_access' => Icons.beach_access,
      'pets' => Icons.pets,
      'favorite' => Icons.favorite,
      'diamond' => Icons.diamond,
      _ => Icons.savings,
    };
  }
}
