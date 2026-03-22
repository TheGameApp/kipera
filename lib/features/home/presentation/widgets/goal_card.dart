import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/saving_methods.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/extensions/num_extensions.dart';
import '../../../../database/app_database.dart';
import '../providers/home_provider.dart';

class GoalCard extends ConsumerWidget {
  final SavingsGoal goal;
  final VoidCallback onTap;
  final VoidCallback onCheckIn;

  const GoalCard({
    super.key,
    required this.goal,
    required this.onTap,
    required this.onCheckIn,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final totalSavedAsync = ref.watch(totalSavedForGoalProvider(goal.id));
    final goalColor = Color(int.parse(goal.colorHex, radix: 16));
    final isDark = context.isDarkMode;
    final bgColor = isDark
        ? Colors.white.withValues(alpha: 0.05)
        : goalColor;
    final iconBgColor = isDark
        ? goalColor.withValues(alpha: 0.28)
        : Colors.white.withValues(alpha: 0.7);
    final iconColor = isDark ? goalColor : AppColors.primary;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(20),
          border: isDark
              ? Border.all(
                  color: goalColor.withValues(alpha: 0.18),
                  width: 1,
                )
              : null,
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
                        color: iconBgColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        _getIconData(goal.iconName),
                        color: iconColor,
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
                        Row(
                          children: [
                            Text(
                              goal.method.replaceAll('_', ' '),
                              style: context.textTheme.bodySmall?.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                            if (_reminderText(goal) != null) ...[
                              const SizedBox(width: 8),
                              Icon(
                                Icons.access_time_rounded,
                                size: 12,
                                color: AppColors.textSecondary.withValues(alpha: 0.6),
                              ),
                              const SizedBox(width: 2),
                              Text(
                                _reminderText(goal)!,
                                style: context.textTheme.bodySmall?.copyWith(
                                  color: AppColors.textSecondary.withValues(alpha: 0.6),
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ],
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

  String? _reminderText(SavingsGoal goal) {
    try {
      final config = MethodConfig.fromJson(
        jsonDecode(goal.methodConfig) as Map<String, dynamic>,
      );
      if (config.reminderHour != null && config.reminderMinute != null) {
        final time = TimeOfDay(hour: config.reminderHour!, minute: config.reminderMinute!);
        final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
        final minute = time.minute.toString().padLeft(2, '0');
        final period = time.period == DayPeriod.am ? 'AM' : 'PM';
        return '$hour:$minute $period';
      }
    } catch (_) {}
    return null;
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
