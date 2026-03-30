class HeatmapUtils {
  const HeatmapUtils._();

  /// Returns intensity level (0-4) based on completion percentage
  static int intensityLevel(double completionRatio) {
    if (completionRatio <= 0) return 0;
    if (completionRatio < 0.25) return 1;
    if (completionRatio < 0.75) return 2;
    if (completionRatio < 1.0) return 3;
    return 4;
  }

  /// Generates a map of date -> intensity for heatmap display
  static Map<DateTime, int> buildHeatmapData(
    Map<DateTime, double> completionByDate,
  ) {
    return completionByDate.map(
      (date, ratio) => MapEntry(date, intensityLevel(ratio)),
    );
  }

  /// Calculate current streak from a list of dates (sorted desc)
  static int calculateStreak(List<DateTime> completedDates) {
    if (completedDates.isEmpty) return 0;

    final sorted = [...completedDates]..sort((a, b) => b.compareTo(a));
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);

    final firstDate = DateTime(sorted[0].year, sorted[0].month, sorted[0].day);
    final diff = todayDate.difference(firstDate).inDays;
    if (diff > 1) return 0;

    int streak = 1;
    for (int i = 1; i < sorted.length; i++) {
      final current = DateTime(sorted[i].year, sorted[i].month, sorted[i].day);
      final previous = DateTime(sorted[i - 1].year, sorted[i - 1].month, sorted[i - 1].day);
      if (previous.difference(current).inDays == 1) {
        streak++;
      } else {
        break;
      }
    }

    return streak;
  }

  /// Build separate heatmap data for couple goals.
  /// Returns (userLevels, partnerLevels).
  static ({Map<DateTime, int> userLevels, Map<DateTime, int> partnerLevels})
      buildCoupleHeatmapData({
    required Map<DateTime, double> userCompletionByDate,
    required Map<DateTime, double> partnerCompletionByDate,
  }) {
    return (
      userLevels: buildHeatmapData(userCompletionByDate),
      partnerLevels: buildHeatmapData(partnerCompletionByDate),
    );
  }

  /// Calculate combined streak for couple goals.
  /// A day counts if EITHER partner completed.
  static int combinedStreak(
    List<DateTime> userDates,
    List<DateTime> partnerDates,
  ) {
    final allDates = <DateTime>{};
    for (final d in userDates) {
      allDates.add(DateTime(d.year, d.month, d.day));
    }
    for (final d in partnerDates) {
      allDates.add(DateTime(d.year, d.month, d.day));
    }
    return calculateStreak(allDates.toList());
  }
}
