import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/utils/heatmap_utils.dart';
import '../../../../core/widgets/heatmap_widget.dart';
import 'package:intl/intl.dart';
import '../../../home/presentation/providers/home_provider.dart';

class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key});

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  late DateTime _selectedMonth;

  @override
  void initState() {
    super.initState();
    _selectedMonth = DateTime(DateTime.now().year, DateTime.now().month);
  }

  @override
  Widget build(BuildContext context) {
    final goalsAsync = ref.watch(activeGoalsProvider);

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              context.l10n.calendar,
              style: context.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),

            // Month selector
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  onPressed: () {
                    setState(() {
                      _selectedMonth = DateTime(
                        _selectedMonth.year,
                        _selectedMonth.month - 1,
                      );
                      debugPrint('📱 [Calendar] navigated to previous month — ${DateFormat.MMMM(context.l10n.localeName).format(_selectedMonth)} ${_selectedMonth.year}');
                    });
                  },
                  icon: const Icon(Icons.chevron_left),
                ),
                Text(
                  DateFormat.yMMMM(context.l10n.localeName).format(_selectedMonth),
                  style: context.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                IconButton(
                  onPressed: () {
                    setState(() {
                      _selectedMonth = DateTime(
                        _selectedMonth.year,
                        _selectedMonth.month + 1,
                      );
                      debugPrint('📱 [Calendar] navigated to next month — ${DateFormat.MMMM(context.l10n.localeName).format(_selectedMonth)} ${_selectedMonth.year}');
                    });
                  },
                  icon: const Icon(Icons.chevron_right),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Calendar grid
            _buildCalendarGrid(context),
            const SizedBox(height: 24),

            // Per goal heatmaps
            goalsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Text(context.l10n.errorPrefix(e.toString())),
              data: (goals) {
                return Column(
                  children: goals.map((goal) {
                    final entriesAsync =
                        ref.watch(entriesForGoalProvider(goal.id));
                    return GestureDetector(
                      onTap: () => context.push('/goal/${goal.id}'),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  goal.name,
                                  style: context.textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              Icon(
                                Icons.chevron_right,
                                size: 20,
                                color: AppColors.textSecondary,
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          entriesAsync.when(
                            loading: () =>
                                const LinearProgressIndicator(),
                            error: (_, __) => const SizedBox.shrink(),
                            data: (entries) {
                              final data = <DateTime, int>{};
                              for (final e in entries) {
                                final ratio = e.expectedAmount > 0
                                    ? e.actualAmount / e.expectedAmount
                                    : 0.0;
                                data[e.date] =
                                    HeatmapUtils.intensityLevel(ratio);
                              }
                              return HeatmapWidget(
                                data: data,
                                startDate: goal.startDate,
                              );
                            },
                          ),
                          const SizedBox(height: 16),
                        ],
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCalendarGrid(BuildContext context) {
    final daysInMonth = DateUtils.getDaysInMonth(
      _selectedMonth.year,
      _selectedMonth.month,
    );
    final firstDay = DateTime(_selectedMonth.year, _selectedMonth.month, 1);
    final startWeekday = firstDay.weekday % 7; // 0 = Sunday

    final dayLabels = DateFormat.E(context.l10n.localeName).dateSymbols.NARROWWEEKDAYS;

    return Column(
      children: [
        Row(
          children: dayLabels
              .map((d) => Expanded(
                    child: Center(
                      child: Text(
                        d,
                        style: context.textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ))
              .toList(),
        ),
        const SizedBox(height: 8),
        ...List.generate(6, (week) {
          return Row(
            children: List.generate(7, (day) {
              final dayIndex = week * 7 + day - startWeekday + 1;
              if (dayIndex < 1 || dayIndex > daysInMonth) {
                return const Expanded(child: SizedBox(height: 40));
              }
              final date = DateTime(
                _selectedMonth.year,
                _selectedMonth.month,
                dayIndex,
              );
              final isToday = DateUtils.isSameDay(date, DateTime.now());

              return Expanded(
                child: Container(
                  height: 40,
                  margin: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: isToday
                        ? AppColors.primary.withValues(alpha: 0.1)
                        : null,
                    borderRadius: BorderRadius.circular(8),
                    border: isToday
                        ? Border.all(color: AppColors.primary)
                        : null,
                  ),
                  child: Center(
                    child: Text(
                      '$dayIndex',
                      style: context.textTheme.bodySmall?.copyWith(
                        fontWeight: isToday ? FontWeight.bold : null,
                        color: isToday ? AppColors.primary : null,
                      ),
                    ),
                  ),
                ),
              );
            }),
          );
        }),
      ],
    );
  }

}
