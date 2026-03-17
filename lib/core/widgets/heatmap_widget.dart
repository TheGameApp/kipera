import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_sizes.dart';
import '../theme/app_theme.dart';

class HeatmapWidget extends StatelessWidget {
  final Map<DateTime, int> data;
  final int weeks;

  const HeatmapWidget({
    super.key,
    required this.data,
    this.weeks = 16,
  });

  @override
  Widget build(BuildContext context) {
    final kiperaColors = Theme.of(context).extension<KiperaColors>();
    final colors = kiperaColors?.heatmapColors ??
        [
          AppColors.heatmapLight0,
          AppColors.heatmapLight1,
          AppColors.heatmapLight2,
          AppColors.heatmapLight3,
          AppColors.heatmapLight4,
        ];

    final today = DateTime.now();
    const cellTotal = AppSizes.heatmapCellSize + AppSizes.heatmapCellSpacing;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            final columnCount = (constraints.maxWidth / cellTotal).floor().clamp(1, weeks);

            return SizedBox(
              height: 7 * cellTotal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(columnCount, (colIndex) {
                  // colIndex 0 = oldest visible week, colIndex last = current week
                  final weekIndex = columnCount - 1 - colIndex;
                  return Column(
                    children: List.generate(7, (dayIndex) {
                      final date = today.subtract(
                        Duration(days: weekIndex * 7 + (6 - dayIndex)),
                      );
                      final dateKey = DateTime(date.year, date.month, date.day);
                      final todayKey = DateTime(today.year, today.month, today.day);
                      final isAfterToday = dateKey.isAfter(todayKey);
                      final level = data[dateKey] ?? 0;

                      return Container(
                        width: AppSizes.heatmapCellSize,
                        height: AppSizes.heatmapCellSize,
                        margin: EdgeInsets.all(AppSizes.heatmapCellSpacing / 2),
                        decoration: BoxDecoration(
                          color: isAfterToday
                              ? Colors.transparent
                              : colors[level.clamp(0, 4)],
                          borderRadius: BorderRadius.circular(3),
                        ),
                      );
                    }),
                  );
                }),
              ),
            );
          },
        ),
        const SizedBox(height: 8),
        // Legend
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              'Less',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: 10,
                  ),
            ),
            const SizedBox(width: 4),
            ...List.generate(5, (i) {
              return Container(
                width: 12,
                height: 12,
                margin: const EdgeInsets.symmetric(horizontal: 1),
                decoration: BoxDecoration(
                  color: colors[i],
                  borderRadius: BorderRadius.circular(2),
                ),
              );
            }),
            const SizedBox(width: 4),
            Text(
              'More',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: 10,
                  ),
            ),
          ],
        ),
      ],
    );
  }
}
