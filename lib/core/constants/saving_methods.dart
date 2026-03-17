enum SavingMethod {
  progressive,
  fixedDaily,
  reverseProgressive,
  weeklyChallenge,
  randomEnvelopes,
  multiplier,
  biWeeklySteps,
  penalty;

  bool get isFree => switch (this) {
        progressive || fixedDaily || weeklyChallenge => true,
        _ => false,
      };

  String get iconName => switch (this) {
        progressive => 'trending_up',
        fixedDaily => 'attach_money',
        reverseProgressive => 'trending_down',
        weeklyChallenge => 'calendar_month',
        randomEnvelopes => 'shuffle',
        multiplier => 'rocket_launch',
        biWeeklySteps => 'stacked_line_chart',
        penalty => 'gavel',
      };
}

class MethodConfig {
  final double? fixedAmount;
  final double? baseAmount;
  final double? multiplierFactor;
  final double? maxAmount;
  final double? penaltyAmount;
  final int? totalDays;
  final int? reminderHour;
  final int? reminderMinute;

  const MethodConfig({
    this.fixedAmount,
    this.baseAmount,
    this.multiplierFactor,
    this.maxAmount,
    this.penaltyAmount,
    this.totalDays,
    this.reminderHour,
    this.reminderMinute,
  });

  Map<String, dynamic> toJson() => {
        if (fixedAmount != null) 'fixedAmount': fixedAmount,
        if (baseAmount != null) 'baseAmount': baseAmount,
        if (multiplierFactor != null) 'multiplierFactor': multiplierFactor,
        if (maxAmount != null) 'maxAmount': maxAmount,
        if (penaltyAmount != null) 'penaltyAmount': penaltyAmount,
        if (totalDays != null) 'totalDays': totalDays,
        if (reminderHour != null) 'reminderHour': reminderHour,
        if (reminderMinute != null) 'reminderMinute': reminderMinute,
      };

  factory MethodConfig.fromJson(Map<String, dynamic> json) => MethodConfig(
        fixedAmount: (json['fixedAmount'] as num?)?.toDouble(),
        baseAmount: (json['baseAmount'] as num?)?.toDouble(),
        multiplierFactor: (json['multiplierFactor'] as num?)?.toDouble(),
        maxAmount: (json['maxAmount'] as num?)?.toDouble(),
        penaltyAmount: (json['penaltyAmount'] as num?)?.toDouble(),
        totalDays: json['totalDays'] as int?,
        reminderHour: json['reminderHour'] as int?,
        reminderMinute: json['reminderMinute'] as int?,
      );
}
