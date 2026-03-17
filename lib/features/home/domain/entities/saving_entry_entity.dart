class SavingEntryEntity {
  final String id;
  final String goalId;
  final DateTime date;
  final double expectedAmount;
  final double actualAmount;
  final bool isCompleted;
  final String? note;
  final DateTime createdAt;

  const SavingEntryEntity({
    required this.id,
    required this.goalId,
    required this.date,
    required this.expectedAmount,
    this.actualAmount = 0,
    this.isCompleted = false,
    this.note,
    required this.createdAt,
  });

  SavingEntryEntity copyWith({
    double? actualAmount,
    bool? isCompleted,
    String? note,
  }) {
    return SavingEntryEntity(
      id: id,
      goalId: goalId,
      date: date,
      expectedAmount: expectedAmount,
      actualAmount: actualAmount ?? this.actualAmount,
      isCompleted: isCompleted ?? this.isCompleted,
      note: note ?? this.note,
      createdAt: createdAt,
    );
  }
}
