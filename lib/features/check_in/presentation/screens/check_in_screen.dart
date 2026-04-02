import 'dart:convert';
import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/saving_methods.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/widgets/currency_text.dart';
import '../../../../core/widgets/kipera_snackbar.dart';
import '../../../../core/utils/achievement_checker.dart';
import '../../../../core/utils/heatmap_utils.dart';
import '../../../../core/utils/saving_calculator.dart';
import '../../../../database/app_database.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../home/presentation/providers/home_provider.dart';
import '../../../../core/providers/sync_provider.dart';

class CheckInScreen extends ConsumerStatefulWidget {
  final String goalId;

  const CheckInScreen({super.key, required this.goalId});

  @override
  ConsumerState<CheckInScreen> createState() => _CheckInScreenState();
}

class _CheckInScreenState extends ConsumerState<CheckInScreen> {
  bool _saving = false;

  Future<void> _checkIn() async {
    if (_saving) return;
    debugPrint('💾 [CheckIn] check-in attempt — goalId: ${widget.goalId}');
    setState(() => _saving = true);

    final db = ref.read(databaseProvider);
    final goal = await db.goalsDao.getGoalById(widget.goalId);
    if (goal == null) {
      if (mounted) {
        KiperaSnackBar.show(
          context,
          message: context.l10n.checkInGoalNotFound,
          type: KiperaSnackType.error,
        );
        context.pop();
      }
      return;
    }

    final user = ref.read(currentUserProvider);
    if (user == null) return;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final entries = await db.entriesDao.getEntriesForGoal(widget.goalId);

    // Couple-aware check: verify this specific user hasn't checked in today
    final alreadyToday = entries.any((e) {
      final eDate = DateTime(e.date.year, e.date.month, e.date.day);
      return eDate == today && (e.userId == null || e.userId == user.id);
    });
    if (alreadyToday) {
      debugPrint('⚠️ [CheckIn] already checked in today — skipping');
      if (mounted) {
        setState(() => _saving = false);
        KiperaSnackBar.show(
          context,
          message: context.l10n.alreadyCheckedIn,
          type: KiperaSnackType.info,
          icon: Icons.calendar_today,
        );
      }
      return;
    }

    final userEntries = entries.where((e) => e.userId == null || e.userId == user.id).toList();
    final dayNumber = userEntries.length + 1;

    final method = SavingMethod.values.firstWhere(
      (m) => m.name == goal.method,
      orElse: () => SavingMethod.progressive,
    );
    final config = MethodConfig.fromJson(
      jsonDecode(goal.methodConfig) as Map<String, dynamic>,
    );

    final amount = SavingCalculator.amountForDay(
      method: method,
      config: config,
      dayNumber: dayNumber,
    );

    debugPrint('💾 [CheckIn] saving entry — dayNumber: $dayNumber, amount: $amount, method: ${method.name}');

    await db.entriesDao.upsertEntry(SavingEntriesCompanion(
      id: Value(const Uuid().v4()),
      goalId: Value(widget.goalId),
      userId: Value(user.id),
      date: Value(today),
      expectedAmount: Value(amount),
      actualAmount: Value(amount),
      isCompleted: const Value(true),
      createdAt: Value(now),
    ));

    // Check achievements
    final totalSaved = await db.entriesDao.getTotalSavedForGoal(widget.goalId);
    final completedEntries =
        await db.entriesDao.getCompletedEntriesForGoal(widget.goalId);
    final completedDates = completedEntries.map((e) => e.date).toList();
    final streak = HeatmapUtils.calculateStreak(completedDates);
    final progress =
        goal.targetAmount > 0 ? totalSaved / goal.targetAmount : 0.0;

    final unlockedKeys = await db.achievementsDao.getUnlockedKeys(user.id);
    final newAchievements = AchievementChecker.check(
      currentStreak: streak,
      totalSaved: totalSaved,
      goalProgress: progress,
      consecutiveDaysInWeek: streak.clamp(0, 7),
      consecutiveDaysInMonth: streak.clamp(0, 31),
      daysSinceLastSave: completedDates.length > 1
          ? today
              .difference(DateTime(completedDates[completedDates.length - 2].year,
                  completedDates[completedDates.length - 2].month,
                  completedDates[completedDates.length - 2].day))
              .inDays
          : 0,
      isFirstEntry: entries.isEmpty,
      alreadyUnlocked: unlockedKeys,
    );

    for (final key in newAchievements) {
      final achievement = await db.achievementsDao.getAchievementByKey(key);
      if (achievement != null) {
        await db.achievementsDao.unlockAchievement(
          UserAchievementsCompanion(
            id: Value(const Uuid().v4()),
            userId: Value(user.id),
            achievementId: Value(achievement.id),
            goalId: Value(widget.goalId),
            unlockedAt: Value(now),
          ),
        );
      }
    }

    if (progress >= 1.0) {
      await db.goalsDao.updateGoal(
        widget.goalId,
        SavingsGoalsCompanion(
          status: const Value('completed'),
          endDate: Value(now),
          updatedAt: Value(now),
        ),
      );
      // Goal completed or achievement celebration
    }

    debugPrint('✅ [CheckIn] check-in success — streak: $streak, progress: ${(progress * 100).toStringAsFixed(1)}%, newAchievements: $newAchievements');

    // Invalidate providers so UI refreshes
    ref.invalidate(totalSavedForGoalProvider(widget.goalId));
    ref.invalidate(entriesForGoalProvider(widget.goalId));
    ref.invalidate(goalDetailProvider(widget.goalId));

    // Force background sync to push this entry to partner immediately
    ref.read(syncServiceProvider).syncAll().ignore();

    if (mounted) {
      setState(() => _saving = false);
      if (newAchievements.isNotEmpty) {
        debugPrint('✅ [CheckIn] achievements unlocked: $newAchievements');
      }
      _showSuccessDialog(amount, streak, newAchievements, progress >= 1.0);
    }
  }

  void _showSuccessDialog(
    double amount,
    int streak,
    List<String> newAchievements,
    bool goalCompleted,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          goalCompleted
              ? context.l10n.goalCompleted
              : context.l10n.congratulations,
          textAlign: TextAlign.center,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              goalCompleted ? Icons.emoji_events : Icons.check_circle,
              size: 64,
              color: goalCompleted ? Colors.amber : AppColors.success,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('${context.l10n.todaysSaving}: '),
                CurrencyText(
                  amount: amount,
                  style: context.textTheme.titleMedium,
                ),
              ],
            ),
            if (streak > 1) ...[
              const SizedBox(height: 8),
              Text(
                '${context.l10n.streak}: $streak ${context.l10n.days}',
                style: context.textTheme.bodyLarge?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
            if (newAchievements.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                context.l10n.achievementUnlocked,
                style: context.textTheme.titleSmall?.copyWith(
                  color: AppColors.secondary,
                ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              context.pop();
            },
            child: Text(context.l10n.ok),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final goalAsync = ref.watch(goalDetailProvider(widget.goalId));
    final totalSavedAsync =
        ref.watch(totalSavedForGoalProvider(widget.goalId));

    return Scaffold(
          appBar: AppBar(title: Text(context.l10n.checkIn)),
          body: goalAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text(context.l10n.errorPrefix(e.toString()))),
            data: (goal) {
              if (goal == null) {
                return Center(child: Text(context.l10n.goalNotFound));
              }

              final method = SavingMethod.values.firstWhere(
                (m) => m.name == goal.method,
                orElse: () => SavingMethod.progressive,
              );

              return Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: AppColors.primaryContainer.withValues(alpha: 0.3),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.savings,
                        size: 80,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 32),
                    Text(
                      goal.name,
                      style: context.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    totalSavedAsync.when(
                      loading: () => const SizedBox.shrink(),
                      error: (_, __) => const SizedBox.shrink(),
                      data: (totalSaved) {
                        final entries = ref
                            .watch(entriesForGoalProvider(widget.goalId))
                            .valueOrNull;
                        final user = ref.watch(currentUserProvider);
                        final userEntries = entries?.where((e) => e.userId == null || e.userId == user?.id).toList() ?? [];
                        final dayNumber = userEntries.length + 1;
                        final config = MethodConfig.fromJson(
                          jsonDecode(goal.methodConfig)
                              as Map<String, dynamic>,
                        );
                        final todayAmount = SavingCalculator.amountForDay(
                          method: method,
                          config: config,
                          dayNumber: dayNumber,
                        );

                        return Column(
                          children: [
                            CurrencyText(
                              amount: todayAmount,
                              style: context.textTheme.displaySmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${context.l10n.todaysSaving} (${context.l10n.dayLabel(dayNumber)})',
                              style: context.textTheme.bodyMedium?.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  '${context.l10n.totalSaved}: ',
                                  style: context.textTheme.bodyLarge,
                                ),
                                CurrencyText(
                                  amount: totalSaved,
                                  style: context.textTheme.bodyLarge,
                                ),
                                Text(
                                  ' / ',
                                  style: context.textTheme.bodyLarge,
                                ),
                                CurrencyText(
                                  amount: goal.targetAmount,
                                  style: context.textTheme.bodyLarge,
                                ),
                              ],
                            ),
                          ],
                        );
                      },
                    ),
                    const Spacer(),
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton.icon(
                        onPressed: _saving ? null : _checkIn,
                        icon: _saving
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.check),
                        label: Text(context.l10n.markAsSaved),
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              );
            },
          ),
        );
  }
}
