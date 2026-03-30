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
    final startDate = today.subtract(Duration(days: (weeks * 7) - 1));

    // Build columns (weeks) of 7 rows (days)
    final columns = <Widget>[];

    for (int week = 0; week < weeks; week++) {
      final cells = <Widget>[];

      for (int day = 0; day < 7; day++) {
        final date = startDate.add(Duration(days: (week * 7) + day));
        final dateOnly = DateTime(date.year, date.month, date.day);

        if (date.isAfter(today)) {
          // Future — empty cell
          cells.add(SizedBox(width: cellSize, height: cellSize));
        } else {
          final userLevel = userLevels[dateOnly] ?? 0;
          final partnerLevel = partnerLevels[dateOnly] ?? 0;

          cells.add(
            SizedBox(
              width: cellSize,
              height: cellSize,
              child: CustomPaint(
                painter: DiagonalCellPainter(
                  userColor: _getUserColor(userLevel, isDark),
                  partnerColor: _getPartnerColor(partnerLevel, isDark),
                  borderRadius: 3,
                ),
              ),
            ),
          );
        }
      }

      columns.add(
        Padding(
          padding: EdgeInsets.only(right: cellGap),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: cells
                .map((c) => Padding(
                      padding: EdgeInsets.only(bottom: cellGap),
                      child: c,
                    ))
                .toList(),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Legend
        Row(
          children: [
            _LegendItem(label: 'You', color: _getUserColor(3, isDark)),
            const SizedBox(width: 12),
            _LegendItem(label: 'Partner', color: _getPartnerColor(3, isDark)),
          ],
        ),
        const SizedBox(height: 8),
        // Heatmap grid
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: columns,
          ),
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
