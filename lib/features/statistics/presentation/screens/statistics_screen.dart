import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/extensions/num_extensions.dart';
import '../../../home/presentation/providers/home_provider.dart';

class StatisticsScreen extends ConsumerWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    debugPrint('💾 [Statistics] screen build');
    final goalsAsync = ref.watch(activeGoalsProvider);

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              context.l10n.statistics,
              style: context.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            goalsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Text('Error: $e'),
              data: (goals) {
                if (goals.isEmpty) {
                  return Center(
                    child: Column(
                      children: [
                        const SizedBox(height: 80),
                        Icon(Icons.bar_chart,
                            size: 64, color: AppColors.primaryContainer),
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
                          label: 'Active Goals',
                          value: goals.length.toString(),
                          icon: Icons.flag,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 12),
                        _OverviewCard(
                          label: 'Total Target',
                          value: goals
                              .fold(0.0, (s, g) => s + g.targetAmount)
                              .toCompactCurrency(),
                          icon: Icons.savings,
                          color: AppColors.success,
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Chart
                    Text(
                      'Goals Progress',
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
                                  color: AppColors.primaryContainer,
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
                      'By Goal',
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
                                data: (saved) => Text(
                                  '${saved.toCurrency()} / ${goal.targetAmount.toCurrency()}',
                                  style: context.textTheme.bodySmall,
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
    );
  }
}

class _OverviewCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _OverviewCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

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
            Text(
              value,
              style: context.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
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
