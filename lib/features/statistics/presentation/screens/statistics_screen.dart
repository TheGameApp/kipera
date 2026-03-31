import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/widgets/currency_text.dart';
import '../../../home/presentation/providers/home_provider.dart';

import '../../../../core/widgets/kipera_back_button.dart';

class StatisticsScreen extends ConsumerWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    debugPrint('💾 [Statistics] screen build');
    final goalsAsync = ref.watch(activeGoalsProvider);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Row(
                children: [
                  const KiperaBackButton(),
                  const SizedBox(width: 12),
                  Text(
                    context.l10n.statistics,
                    style: context.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
            goalsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Text(context.l10n.errorPrefix(e.toString())),
              data: (goals) {
                if (goals.isEmpty) {
                  return Center(
                    child: Column(
                      children: [
                        const SizedBox(height: 80),
                        Icon(Icons.bar_chart,
                            size: 64,
                            color: context.isDarkMode
                                ? AppColors.primaryDark
                                : AppColors.primaryContainer),
                        const SizedBox(height: 16),
                        Text(context.l10n.noGoalsYet,
                            style: context.textTheme.titleMedium),
                      ],
                    ),
                  );
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Overview cards
                    Row(
                      children: [
                        _OverviewCard(
                          label: context.l10n.activeGoalsLabel,
                          value: goals.length.toString(),
                          icon: Icons.flag,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 12),
                        _OverviewCard(
                          label: context.l10n.totalTargetLabel,
                          valueWidget: CurrencyText(
                            amount: goals.fold(0.0, (s, g) => s + g.targetAmount),
                            style: context.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          icon: Icons.savings,
                          color: AppColors.success,
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Chart
                    Text(
                      context.l10n.goalsProgress,
                      style: context.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 200,
                      child: BarChart(
                        BarChartData(
                          alignment: BarChartAlignment.spaceAround,
                          maxY: goals
                              .map((g) => g.targetAmount)
                              .reduce((a, b) => a > b ? a : b),
                          barGroups: goals.asMap().entries.map((entry) {
                            return BarChartGroupData(
                              x: entry.key,
                              barRods: [
                                BarChartRodData(
                                  toY: entry.value.targetAmount,
                                  color: context.isDarkMode
                                      ? AppColors.primaryDark
                                      : AppColors.primaryContainer,
                                  width: 20,
                                  borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(4),
                                  ),
                                ),
                              ],
                            );
                          }).toList(),
                          titlesData: FlTitlesData(
                            leftTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            rightTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            topTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (value, meta) {
                                  final idx = value.toInt();
                                  if (idx < goals.length) {
                                    return Text(
                                      goals[idx].name.length > 6
                                          ? '${goals[idx].name.substring(0, 6)}...'
                                          : goals[idx].name,
                                      style: context.textTheme.bodySmall,
                                    );
                                  }
                                  return const SizedBox.shrink();
                                },
                              ),
                            ),
                          ),
                          borderData: FlBorderData(show: false),
                          gridData: const FlGridData(show: false),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Per-goal stats
                    Text(
                      context.l10n.byGoal,
                      style: context.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...goals.map((goal) {
                      final totalAsync =
                          ref.watch(totalSavedForGoalProvider(goal.id));
                      return GestureDetector(
                        onTap: () => context.push('/goal/${goal.id}'),
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: context.colorScheme.surface,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  goal.name,
                                  style: context.textTheme.titleSmall,
                                ),
                              ),
                              totalAsync.when(
                                loading: () => const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                ),
                                error: (_, __) => const Text('-'),
                                data: (saved) => Row(
                                   mainAxisSize: MainAxisSize.min,
                                   children: [
                                     CurrencyText(
                                       amount: saved,
                                       style: context.textTheme.bodySmall,
                                     ),
                                     Text(
                                       ' / ',
                                       style: context.textTheme.bodySmall,
                                     ),
                                     CurrencyText(
                                       amount: goal.targetAmount,
                                       style: context.textTheme.bodySmall,
                                     ),
                                   ],
                                 ),
                              ),
                              const SizedBox(width: 8),
                              Icon(
                                Icons.chevron_right,
                                color: AppColors.textSecondary,
                                size: 20,
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                  ],
                );
              },
            ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OverviewCard extends StatelessWidget {
  final String label;
  final String? value;
  final Widget? valueWidget;
  final IconData icon;
  final Color color;

  const _OverviewCard({
    required this.label,
    this.value,
    this.valueWidget,
    required this.icon,
    required this.color,
  }) : assert(value != null || valueWidget != null);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color),
            const SizedBox(height: 8),
            DefaultTextStyle(
              style: context.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ) ??
                  const TextStyle(),
              child: valueWidget ?? Text(value!),
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
