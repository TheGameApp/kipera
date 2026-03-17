import 'dart:convert';
import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/saving_methods.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/extensions/num_extensions.dart';
import '../../../../core/utils/heatmap_utils.dart';
import '../../../../core/utils/saving_calculator.dart';
import '../../../../core/widgets/kipera_back_button.dart';
import '../../../../core/widgets/kipera_snackbar.dart';
import '../../../home/presentation/providers/home_provider.dart';
import '../../../../core/widgets/heatmap_widget.dart';
import '../../../../core/widgets/progress_ring.dart';
import '../../../../core/services/notification_service.dart';
import '../../../../database/app_database.dart';

class GoalDetailScreen extends ConsumerWidget {
  final String goalId;

  const GoalDetailScreen({super.key, required this.goalId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    debugPrint('[GoalDetail] screen loaded — goalId: $goalId');
    final goalAsync = ref.watch(goalDetailProvider(goalId));
    final totalSavedAsync = ref.watch(totalSavedForGoalProvider(goalId));
    final entriesAsync = ref.watch(entriesForGoalProvider(goalId));

    return Scaffold(
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 12),
          child: SizedBox(
            height: 52,
            child: ElevatedButton(
              onPressed: () {
                debugPrint('[GoalDetail] check-in FAB tapped — goalId: $goalId');
                context.push('/check-in/$goalId');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.purple,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 24),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.add, size: 20),
                  const SizedBox(width: 8),
                  Text(context.l10n.checkIn),
                ],
              ),
            ),
          ),
        ),
      ),
      body: goalAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (goal) {
          if (goal == null) return const Center(child: Text('Goal not found'));

          return SafeArea(
            child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top bar with back button and edit icon
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const KiperaBackButton(),
                    IconButton(
                      icon: const Icon(Icons.edit_outlined),
                      onPressed: () => _showEditSheet(context, ref, goal),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Header
                Center(
                  child: Column(
                    children: [
                      Text(
                        goal.name,
                        style: context.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        goal.method.replaceAll('_', ' ').toUpperCase(),
                        style: context.textTheme.bodyMedium?.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Progress Ring
                totalSavedAsync.when(
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (_, __) => const SizedBox.shrink(),
                  data: (totalSaved) {
                    final progress = goal.targetAmount > 0
                        ? (totalSaved / goal.targetAmount).clamp(0.0, 1.0)
                        : 0.0;

                    return Center(
                      child: ProgressRing(
                        progress: progress,
                        size: 180,
                        strokeWidth: 14,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              totalSaved.toCurrency(),
                              style: context.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'of ${goal.targetAmount.toCurrency()}',
                              style: context.textTheme.bodySmall?.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 20),

                // Days remaining banner
                entriesAsync.when(
                  loading: () => const SizedBox.shrink(),
                  error: (_, __) => const SizedBox.shrink(),
                  data: (entries) {
                    final method = SavingMethod.values.firstWhere(
                      (m) => m.name == goal.method,
                      orElse: () => SavingMethod.progressive,
                    );
                    final config = MethodConfig.fromJson(
                      jsonDecode(goal.methodConfig) as Map<String, dynamic>,
                    );
                    final totalEstimatedDays = SavingCalculator.estimatedDays(
                      method: method,
                      targetAmount: goal.targetAmount,
                      config: config,
                    );
                    final completedDays = entries.where((e) => e.isCompleted).length;
                    final daysLeft = (totalEstimatedDays - completedDays).clamp(0, totalEstimatedDays);

                    return Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.purple.withValues(alpha: 0.15),
                            AppColors.pink.withValues(alpha: 0.1),
                          ],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppColors.purple.withValues(alpha: 0.25),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            daysLeft == 0
                                ? Icons.emoji_events_rounded
                                : Icons.rocket_launch_rounded,
                            color: AppColors.purple,
                            size: 28,
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                RichText(
                                  text: TextSpan(
                                    style: context.textTheme.bodyMedium?.copyWith(
                                      color: context.isDarkMode
                                          ? AppColors.textDark
                                          : AppColors.textLight,
                                    ),
                                    children: daysLeft > 0
                                        ? [
                                            TextSpan(
                                              text: '$daysLeft ',
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 20,
                                                color: AppColors.purple,
                                              ),
                                            ),
                                            TextSpan(
                                              text: daysLeft == 1
                                                  ? 'day left to reach your goal'
                                                  : 'days left to reach your goal',
                                            ),
                                          ]
                                        : [
                                            TextSpan(
                                              text: 'Goal reached! ',
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: AppColors.purple,
                                              ),
                                            ),
                                            const TextSpan(text: 'Congratulations!'),
                                          ],
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Day $completedDays of $totalEstimatedDays',
                                  style: context.textTheme.bodySmall?.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),

                // Stats Row
                entriesAsync.when(
                  loading: () => const SizedBox.shrink(),
                  error: (_, __) => const SizedBox.shrink(),
                  data: (entries) {
                    final completedDates = entries
                        .where((e) => e.isCompleted)
                        .map((e) => e.date)
                        .toList();
                    final streak =
                        HeatmapUtils.calculateStreak(completedDates);
                    final totalDays = entries.length;
                    final completedDays =
                        entries.where((e) => e.isCompleted).length;

                    return Row(
                      children: [
                        _StatCard(
                          icon: Icons.local_fire_department,
                          label: context.l10n.streak,
                          value: '$streak',
                          color: Colors.orange,
                        ),
                        const SizedBox(width: 12),
                        _StatCard(
                          icon: Icons.calendar_today,
                          label: context.l10n.days,
                          value: '$completedDays/$totalDays',
                          color: AppColors.info,
                        ),
                        const SizedBox(width: 12),
                        _StatCard(
                          icon: Icons.trending_up,
                          label: context.l10n.remaining,
                          value: totalSavedAsync.whenOrNull(
                                data: (saved) =>
                                    (goal.targetAmount - saved).toCurrency(),
                              ) ??
                              '...',
                          color: AppColors.success,
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 24),

                // Heatmap
                Text(
                  context.l10n.progress,
                  style: context.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                entriesAsync.when(
                  loading: () => const SizedBox.shrink(),
                  error: (_, __) => const SizedBox.shrink(),
                  data: (entries) {
                    final heatmapData = <DateTime, int>{};
                    for (final entry in entries) {
                      final ratio = entry.expectedAmount > 0
                          ? entry.actualAmount / entry.expectedAmount
                          : 0.0;
                      heatmapData[entry.date] =
                          HeatmapUtils.intensityLevel(ratio);
                    }
                    return HeatmapWidget(data: heatmapData);
                  },
                ),
                const SizedBox(height: 24),

                // All activity
                Text(
                  'Activity',
                  style: context.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                entriesAsync.when(
                  loading: () => const CircularProgressIndicator(),
                  error: (_, __) => const SizedBox.shrink(),
                  data: (entries) {
                    final recent = entries.reversed.toList();
                    return ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: recent.length,
                      itemBuilder: (context, index) {
                        final entry = recent[index];
                        return ListTile(
                          leading: Icon(
                            entry.isCompleted
                                ? Icons.check_circle
                                : Icons.circle_outlined,
                            color: entry.isCompleted
                                ? AppColors.success
                                : AppColors.textSecondary,
                          ),
                          title: Text(entry.actualAmount.toCurrency()),
                          subtitle: Text(
                            '${entry.date.month}/${entry.date.day}/${entry.date.year}',
                          ),
                          trailing: entry.isCompleted
                              ? null
                              : Text(
                                  'Expected: ${entry.expectedAmount.toCurrency()}',
                                  style: context.textTheme.bodySmall,
                                ),
                        );
                      },
                    );
                  },
                ),
                const SizedBox(height: 100),
              ],
            ),
          ),
          );
        },
      ),
    );
  }

  void _showEditSheet(BuildContext context, WidgetRef ref, SavingsGoal goal) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        final isDark = Theme.of(sheetContext).brightness == Brightness.dark;
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Handle bar
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.borderDark : Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 16),
                ListTile(
                  leading: const Icon(Icons.access_time_rounded, color: AppColors.primary),
                  title: const Text('Edit Reminder Time'),
                  subtitle: Text(
                    _currentReminderText(goal),
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                  onTap: () {
                    Navigator.pop(sheetContext);
                    _editReminderTime(context, ref, goal);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.edit_outlined, color: AppColors.primary),
                  title: const Text('Edit Goal Name'),
                  subtitle: Text(
                    goal.name,
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                  onTap: () {
                    Navigator.pop(sheetContext);
                    _editGoalName(context, ref, goal);
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.delete_outline, color: Colors.red),
                  title: const Text(
                    'Delete Goal',
                    style: TextStyle(color: Colors.red),
                  ),
                  subtitle: const Text(
                    'This action cannot be undone',
                    style: TextStyle(color: Colors.red),
                  ),
                  onTap: () {
                    Navigator.pop(sheetContext);
                    _confirmDeleteGoal(context, ref, goal);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _currentReminderText(SavingsGoal goal) {
    try {
      final config = MethodConfig.fromJson(
        jsonDecode(goal.methodConfig) as Map<String, dynamic>,
      );
      if (config.reminderHour != null && config.reminderMinute != null) {
        final time = TimeOfDay(hour: config.reminderHour!, minute: config.reminderMinute!);
        final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
        final minute = time.minute.toString().padLeft(2, '0');
        final period = time.period == DayPeriod.am ? 'AM' : 'PM';
        return 'Currently $hour:$minute $period';
      }
    } catch (_) {}
    return 'Not set';
  }

  Future<void> _editReminderTime(
    BuildContext context,
    WidgetRef ref,
    SavingsGoal goal,
  ) async {
    TimeOfDay initial = const TimeOfDay(hour: 8, minute: 0);
    try {
      final config = MethodConfig.fromJson(
        jsonDecode(goal.methodConfig) as Map<String, dynamic>,
      );
      if (config.reminderHour != null && config.reminderMinute != null) {
        initial = TimeOfDay(hour: config.reminderHour!, minute: config.reminderMinute!);
      }
    } catch (_) {}

    final picked = await showTimePicker(
      context: context,
      initialTime: initial,
    );
    if (picked == null) return;

    final configJson = jsonDecode(goal.methodConfig) as Map<String, dynamic>;
    configJson['reminderHour'] = picked.hour;
    configJson['reminderMinute'] = picked.minute;

    final db = ref.read(databaseProvider);
    await db.goalsDao.updateGoal(
      goal.id,
      SavingsGoalsCompanion(
        methodConfig: Value(jsonEncode(configJson)),
        updatedAt: Value(DateTime.now()),
      ),
    );

    // Reschedule notification with new time
    final notifService = NotificationService();
    await notifService.scheduleDailyReminder(
      goalId: goal.id,
      hour: picked.hour,
      minute: picked.minute,
      title: 'Time to save!',
      body: 'Don\'t forget your "${goal.name}" goal today.',
    );
    debugPrint('🔔 [GoalDetail] notification rescheduled to ${picked.hour}:${picked.minute}');

    // Invalidate so the UI reflects the new time
    ref.invalidate(goalDetailProvider(goal.id));

    if (context.mounted) {
      final hour = picked.hourOfPeriod == 0 ? 12 : picked.hourOfPeriod;
      final minute = picked.minute.toString().padLeft(2, '0');
      final period = picked.period == DayPeriod.am ? 'AM' : 'PM';
      KiperaSnackBar.show(
        context,
        message: 'Reminder updated to $hour:$minute $period',
        type: KiperaSnackType.success,
        icon: Icons.access_time_rounded,
      );
    }
  }

  Future<void> _editGoalName(
    BuildContext context,
    WidgetRef ref,
    SavingsGoal goal,
  ) async {
    final controller = TextEditingController(text: goal.name);

    final newName = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text('Edit Goal Name'),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: const InputDecoration(
              hintText: 'Goal name',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                final text = controller.text.trim();
                if (text.isNotEmpty) {
                  Navigator.pop(dialogContext, text);
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );

    controller.dispose();

    if (newName != null && newName != goal.name) {
      final db = ref.read(databaseProvider);
      await db.goalsDao.updateGoal(
        goal.id,
        SavingsGoalsCompanion(
          name: Value(newName),
          updatedAt: Value(DateTime.now()),
        ),
      );
      ref.invalidate(goalDetailProvider(goal.id));
      if (context.mounted) {
        KiperaSnackBar.show(
          context,
          message: 'Goal renamed to "$newName"',
          type: KiperaSnackType.success,
          icon: Icons.edit_outlined,
        );
      }
    }
  }

  Future<void> _confirmDeleteGoal(
    BuildContext context,
    WidgetRef ref,
    SavingsGoal goal,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text('Delete Goal'),
          content: Text(
            'Are you sure you want to delete "${goal.name}"? This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmed == true && context.mounted) {
      final db = ref.read(databaseProvider);
      await db.goalsDao.deleteGoal(goal.id);
      // Cancel the notification for this goal
      await NotificationService().cancelGoalReminder(goal.id);
      debugPrint('🔔 [GoalDetail] notification cancelled for deleted goal: ${goal.id}');
      if (context.mounted) {
        KiperaSnackBar.show(
          context,
          message: '"${goal.name}" has been deleted.',
          type: KiperaSnackType.info,
          icon: Icons.delete_outline,
        );
        context.pop();
      }
    }
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 4),
            Text(
              value,
              style: context.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              label,
              style: context.textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
