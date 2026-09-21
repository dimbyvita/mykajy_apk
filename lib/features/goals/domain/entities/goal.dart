enum GoalStatus { active, completed, cancelled }

class Goal {
  final String id;
  final String title;
  final String emoji;
  final double targetAmount;
  final double savedAmount;
  final DateTime deadline;
  final GoalStatus status;
  final DateTime createdAt;

  const Goal({
    required this.id,
    required this.title,
    required this.emoji,
    required this.targetAmount,
    required this.savedAmount,
    required this.deadline,
    this.status = GoalStatus.active,
    required this.createdAt,
  });

  double get progressPercent =>
      targetAmount == 0 ? 0 : (savedAmount / targetAmount).clamp(0.0, 1.0);

  double get remainingAmount => (targetAmount - savedAmount).clamp(0.0, double.infinity);

  bool get isCompleted => savedAmount >= targetAmount;

  int get daysLeft => deadline.difference(DateTime.now()).inDays;

  bool get isOverdue => daysLeft < 0 && !isCompleted;

  Goal copyWith({
    String? title,
    String? emoji,
    double? targetAmount,
    double? savedAmount,
    DateTime? deadline,
    GoalStatus? status,
  }) {
    return Goal(
      id: id,
      title: title ?? this.title,
      emoji: emoji ?? this.emoji,
      targetAmount: targetAmount ?? this.targetAmount,
      savedAmount: savedAmount ?? this.savedAmount,
      deadline: deadline ?? this.deadline,
      status: status ?? this.status,
      createdAt: createdAt,
    );
  }
}
// TODO Implement this library.