import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_sizes.dart';
import '../theme/app_theme.dart';
import 'couple_heatmap_widget.dart';

class HeatmapWidget extends StatelessWidget {
  final Map<DateTime, int> data;
  final int weeks;
  final DateTime? startDate;

  /// Optional: partner heatmap data for couple goals.
  /// When provided, renders a diagonal-split heatmap instead.
  final Map<DateTime, int>? partnerData;

  const HeatmapWidget({
    super.key,
    required this.data,
    this.weeks = 16,
    this.startDate,
    this.partnerData,
  });

  @override
  Widget build(BuildContext context) {
    // Delegate to couple heatmap if partner data is provided
    if (partnerData != null) {
      return CoupleHeatmapWidget(
        userLevels: data,
        partnerLevels: partnerData!,
        weeks: weeks,
      );
    }

    final kiperaColors = Theme.of(context).extension<KiperaColors>();
    final colors =
        kiperaColors?.heatmapColors ??
        [
          AppColors.heatmapLight0,
          AppColors.heatmapLight1,
          AppColors.heatmapLight2,
          AppColors.heatmapLight3,
          AppColors.heatmapLight4,
        ];

    final today = DateTime.now();
    final todayKey = DateTime(today.year, today.month, today.day);
    const cellTotal = AppSizes.heatmapCellSize + AppSizes.heatmapCellSpacing;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            final maxColumns = (constraints.maxWidth / cellTotal).floor().clamp(
              1,
              weeks,
            );

            final columnCount = maxColumns;
            final DateTime gridStart = startDate != null
                ? DateTime(startDate!.year, startDate!.month, startDate!.day)
                : today.subtract(Duration(days: (columnCount - 1) * 7 + 6));

            return AspectRatio(
              aspectRatio: columnCount / 7,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: List.generate(columnCount, (colIndex) {
                  return Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: List.generate(7, (dayIndex) {
                        final date = gridStart.add(
                          Duration(days: colIndex * 7 + dayIndex),
                        );
                        final dateKey = DateTime(
                          date.year,
                          date.month,
                          date.day,
                        );
                        final isAfterToday = dateKey.isAfter(todayKey);
                        final level = data[dateKey] ?? 0;

                        // Future days within the goal show as empty (level 0),
                        // not transparent, so the full grid is always visible.
                        final cellColor = startDate != null
                            ? colors[isAfterToday ? 0 : level.clamp(0, 4)]
                            : (isAfterToday
                                  ? Colors.transparent
                                  : colors[level.clamp(0, 4)]);

                        return Expanded(
                          child: Container(
                            margin: EdgeInsets.all(
                              AppSizes.heatmapCellSpacing / 2,
                            ),
                            decoration: BoxDecoration(
                              color: cellColor,
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                        );
                      }),
                    ),
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
