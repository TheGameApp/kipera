extension DateExtensions on DateTime {
  String toDateString() =>
      '${year.toString().padLeft(4, '0')}-${month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}';

  DateTime get dateOnly => DateTime(year, month, day);

  bool isSameDay(DateTime other) =>
      year == other.year && month == other.month && day == other.day;

  int daysDifference(DateTime other) =>
      dateOnly.difference(other.dateOnly).inDays;

  bool get isToday => isSameDay(DateTime.now());
  bool get isYesterday =>
      isSameDay(DateTime.now().subtract(const Duration(days: 1)));
}
