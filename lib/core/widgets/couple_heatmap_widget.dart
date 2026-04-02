import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../painters/diagonal_cell_painter.dart';
import '../extensions/context_extensions.dart';

/// Heatmap widget that shows diagonal-split cells for couple goals.
/// Each cell shows the user's level on the top-left triangle and
/// the partner's level on the bottom-right triangle.
class CoupleHeatmapWidget extends StatelessWidget {
  /// Map of DateTime (date only) → int level (0-4) for the user.
  final Map<DateTime, int> userLevels;

  /// Map of DateTime (date only) → int level (0-4) for the partner.
  final Map<DateTime, int> partnerLevels;

  /// How many weeks to display.
  final int weeks;

  /// Cell size in pixels.
  final double cellSize;

  /// Gap between cells in pixels.
  final double cellGap;

  const CoupleHeatmapWidget({
    super.key,
    required this.userLevels,
    required this.partnerLevels,
    this.weeks = 15,
    this.cellSize = 14,
    this.cellGap = 3,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    final today = DateTime.now();
    final todayKey = DateTime(today.year, today.month, today.day);
    const cellTotal = 14.0 + 3.0; // cellSize + cellGap

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Heatmap grid
        LayoutBuilder(
          builder: (context, constraints) {
            final maxColumns = (constraints.maxWidth / cellTotal).floor().clamp(1, weeks);
            final columnCount = maxColumns;
            final DateTime gridStart = today.subtract(Duration(days: (columnCount - 1) * 7 + 6));

            return AspectRatio(
              aspectRatio: columnCount / 7,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: List.generate(columnCount, (colIndex) {
                  return Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: List.generate(7, (dayIndex) {
                        final date = gridStart.add(Duration(days: colIndex * 7 + dayIndex));
                        final dateKey = DateTime(date.year, date.month, date.day);
                        final isAfterToday = dateKey.isAfter(todayKey);

                        // If it's a future day, show empty cell
                        if (isAfterToday) {
                          return Expanded(
                            child: Container(
                              margin: const EdgeInsets.all(1.5),
                              decoration: BoxDecoration(
                                color: Colors.transparent,
                                borderRadius: BorderRadius.circular(3),
                              ),
                            ),
                          );
                        }

                        final userLevel = userLevels[dateKey] ?? 0;
                        final partnerLevel = partnerLevels[dateKey] ?? 0;

                        final uColor = _getUserColor(userLevel, isDark);
                        final pColor = _getPartnerColor(partnerLevel, isDark);

                        Widget cellWidget;
                        if (userLevel > 0 && partnerLevel == 0) {
                          // Only user deposited
                          cellWidget = Container(
                            decoration: BoxDecoration(
                              color: uColor,
                              borderRadius: BorderRadius.circular(3),
                            ),
                          );
                        } else if (partnerLevel > 0 && userLevel == 0) {
                          // Only partner deposited
                          cellWidget = Container(
                            decoration: BoxDecoration(
                              color: pColor,
                              borderRadius: BorderRadius.circular(3),
                            ),
                          );
                        } else {
                          // Both deposited (or neither, in which case both are level 0 and empty colors will paint)
                          cellWidget = CustomPaint(
                            painter: DiagonalCellPainter(
                              userColor: uColor,
                              partnerColor: pColor,
                              borderRadius: 3,
                            ),
                          );
                        }

                        return Expanded(
                          child: Container(
                            margin: const EdgeInsets.all(1.5),
                            child: cellWidget,
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
          children: [
            _LegendItem(label: 'You', color: _getUserColor(3, isDark)),
            const SizedBox(width: 12),
            _LegendItem(label: 'Partner', color: _getPartnerColor(3, isDark)),
          ],
        ),
      ],
    );
  }

  /// User colors: green palette (same as regular heatmap).
  Color _getUserColor(int level, bool isDark) {
    if (isDark) {
      return switch (level) {
        0 => AppColors.heatmapDark0,
        1 => AppColors.heatmapDark1,
        2 => AppColors.heatmapDark2,
        3 => AppColors.heatmapDark3,
        _ => AppColors.heatmapDark4,
      };
    }
    return switch (level) {
      0 => AppColors.heatmapLight0,
      1 => AppColors.heatmapLight1,
      2 => AppColors.heatmapLight2,
      3 => AppColors.heatmapLight3,
      _ => AppColors.heatmapLight4,
    };
  }

  /// Partner colors: pink/rose palette.
  Color _getPartnerColor(int level, bool isDark) {
    if (isDark) {
      return switch (level) {
        0 => AppColors.heatmapPartnerDark0,
        1 => AppColors.heatmapPartnerDark1,
        2 => AppColors.heatmapPartnerDark2,
        3 => AppColors.heatmapPartnerDark3,
        _ => AppColors.heatmapPartnerDark4,
      };
    }
    return switch (level) {
      0 => AppColors.heatmapPartnerLight0,
      1 => AppColors.heatmapPartnerLight1,
      2 => AppColors.heatmapPartnerLight2,
      3 => AppColors.heatmapPartnerLight3,
      _ => AppColors.heatmapPartnerLight4,
    };
  }
}

class _LegendItem extends StatelessWidget {
  final String label;
  final Color color;

  const _LegendItem({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}
