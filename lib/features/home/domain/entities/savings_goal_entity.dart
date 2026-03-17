import '../../../../core/constants/saving_methods.dart';

enum GoalStatus { active, paused, completed, abandoned }

class SavingsGoalEntity {
  final String id;
  final String userId;
  final String name;
  final double targetAmount;
  final SavingMethod method;
  final MethodConfig methodConfig;
  final String colorHex;
  final String iconName;
  final DateTime startDate;
  final DateTime? endDate;
  final GoalStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;

  const SavingsGoalEntity({
    required this.id,
    required this.userId,
    required this.name,
    required this.targetAmount,
    required this.method,
    required this.methodConfig,
    required this.colorHex,
    required this.iconName,
    required this.startDate,
    this.endDate,
    this.status = GoalStatus.active,
    required this.createdAt,
    required this.updatedAt,
  });

  SavingsGoalEntity copyWith({
    String? name,
    double? targetAmount,
    GoalStatus? status,
    DateTime? endDate,
    DateTime? updatedAt,
  }) {
    return SavingsGoalEntity(
      id: id,
      userId: userId,
      name: name ?? this.name,
      targetAmount: targetAmount ?? this.targetAmount,
      method: method,
      methodConfig: methodConfig,
      colorHex: colorHex,
      iconName: iconName,
      startDate: startDate,
      endDate: endDate ?? this.endDate,
      status: status ?? this.status,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
