import 'dart:math';
import '../constants/saving_methods.dart';

class SavingCalculator {
  const SavingCalculator._();

  /// Calculate the amount to save on a given day for a method
  static double amountForDay({
    required SavingMethod method,
    required MethodConfig config,
    required int dayNumber,
    List<int>? shuffledSequence,
  }) {
    return switch (method) {
      SavingMethod.progressive => dayNumber.toDouble(),
      SavingMethod.fixedDaily => config.fixedAmount ?? 10,
      SavingMethod.reverseProgressive => _reverseProgressiveAmount(config, dayNumber),
      SavingMethod.weeklyChallenge => _weeklyChallengeAmount(dayNumber),
      SavingMethod.randomEnvelopes => _envelopeAmount(config, dayNumber, shuffledSequence),
      SavingMethod.multiplier => _multiplierAmount(config, dayNumber),
      SavingMethod.biWeeklySteps => _biWeeklyAmount(config, dayNumber),
      SavingMethod.penalty => config.penaltyAmount ?? 5,
    };
  }

  /// Calculate total days needed to reach target amount
  static int estimatedDays({
    required SavingMethod method,
    required double targetAmount,
    required MethodConfig config,
  }) {
    return switch (method) {
      SavingMethod.progressive => _progressiveDays(targetAmount),
      SavingMethod.fixedDaily => _fixedDays(targetAmount, config.fixedAmount ?? 10),
      SavingMethod.reverseProgressive => _progressiveDays(targetAmount),
      SavingMethod.weeklyChallenge => _weeklyChallengeDays(targetAmount),
      SavingMethod.randomEnvelopes => _progressiveDays(targetAmount),
      SavingMethod.multiplier => _multiplierDays(targetAmount, config),
      SavingMethod.biWeeklySteps => _biWeeklyDays(targetAmount, config),
      SavingMethod.penalty => 0, // Variable
    };
  }

  /// Calculate the total amount that will be saved over N days
  static double totalForDays({
    required SavingMethod method,
    required MethodConfig config,
    required int days,
  }) {
    return switch (method) {
      SavingMethod.progressive => days * (days + 1) / 2,
      SavingMethod.fixedDaily => (config.fixedAmount ?? 10) * days,
      SavingMethod.reverseProgressive => days * (days + 1) / 2,
      SavingMethod.weeklyChallenge => _weeklyTotal(days),
      SavingMethod.randomEnvelopes => days * (days + 1) / 2,
      SavingMethod.multiplier => _multiplierTotal(config, days),
      SavingMethod.biWeeklySteps => _biWeeklyTotal(config, days),
      SavingMethod.penalty => (config.penaltyAmount ?? 5) * days,
    };
  }

  /// Generate shuffled sequence for envelope method
  static List<int> generateEnvelopeSequence(int totalDays) {
    final sequence = List.generate(totalDays, (i) => i + 1);
    sequence.shuffle(Random());
    return sequence;
  }

  // --- Private helpers ---

  static double _reverseProgressiveAmount(MethodConfig config, int dayNumber) {
    final totalDays = config.totalDays ?? 45;
    return (totalDays - dayNumber + 1).toDouble();
  }

  static double _weeklyChallengeAmount(int dayNumber) {
    final weekNumber = ((dayNumber - 1) ~/ 7) + 1;
    return weekNumber.toDouble();
  }

  static double _envelopeAmount(MethodConfig config, int dayNumber, List<int>? sequence) {
    if (sequence != null && dayNumber <= sequence.length) {
      return sequence[dayNumber - 1].toDouble();
    }
    return dayNumber.toDouble();
  }

  static double _multiplierAmount(MethodConfig config, int dayNumber) {
    final base = config.baseAmount ?? 1;
    final factor = config.multiplierFactor ?? 1.05;
    final cap = config.maxAmount ?? 20;
    return min(base * pow(factor, dayNumber - 1), cap).toDouble();
  }

  static double _biWeeklyAmount(MethodConfig config, int dayNumber) {
    final base = config.baseAmount ?? 5;
    final step = ((dayNumber - 1) ~/ 14);
    return base + (step * (config.fixedAmount ?? 5));
  }

  static int _progressiveDays(double target) {
    // n(n+1)/2 >= target => n >= (-1 + sqrt(1 + 8*target)) / 2
    return ((-1 + sqrt(1 + 8 * target)) / 2).ceil();
  }

  static int _fixedDays(double target, double dailyAmount) {
    return (target / dailyAmount).ceil();
  }

  static int _weeklyChallengeDays(double target) {
    double sum = 0;
    int week = 1;
    while (sum < target) {
      sum += week * 7;
      week++;
    }
    return (week - 1) * 7;
  }

  static double _weeklyTotal(int days) {
    double total = 0;
    for (int d = 1; d <= days; d++) {
      total += ((d - 1) ~/ 7) + 1;
    }
    return total;
  }

  static int _multiplierDays(double target, MethodConfig config) {
    final base = config.baseAmount ?? 1;
    final factor = config.multiplierFactor ?? 1.05;
    final cap = config.maxAmount ?? 20;
    double sum = 0;
    int day = 0;
    while (sum < target) {
      day++;
      sum += min(base * pow(factor, day - 1), cap);
    }
    return day;
  }

  static double _multiplierTotal(MethodConfig config, int days) {
    final base = config.baseAmount ?? 1;
    final factor = config.multiplierFactor ?? 1.05;
    final cap = config.maxAmount ?? 20;
    double sum = 0;
    for (int d = 1; d <= days; d++) {
      sum += min(base * pow(factor, d - 1), cap);
    }
    return sum;
  }

  static int _biWeeklyDays(double target, MethodConfig config) {
    double sum = 0;
    int day = 0;
    while (sum < target) {
      day++;
      sum += _biWeeklyAmount(config, day);
    }
    return day;
  }

  static double _biWeeklyTotal(MethodConfig config, int days) {
    double sum = 0;
    for (int d = 1; d <= days; d++) {
      sum += _biWeeklyAmount(config, d);
    }
    return sum;
  }
}
