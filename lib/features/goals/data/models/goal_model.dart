import 'package:hive/hive.dart';
import '../../domain/entities/goal.dart';

part 'goal_model.g.dart';

@HiveType(typeId: 1)
class GoalModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String emoji;

  @HiveField(3)
  final double targetAmount;

  @HiveField(4)
  final double savedAmount;

  @HiveField(5)
  final DateTime deadline;

  @HiveField(6)
  final int statusIndex;

  @HiveField(7)
  final DateTime createdAt;

  GoalModel({
    required this.id,
    required this.title,
    required this.emoji,
    required this.targetAmount,
    required this.savedAmount,
    required this.deadline,
    required this.statusIndex,
    required this.createdAt,
  });

  factory GoalModel.fromEntity(Goal g) => GoalModel(
        id: g.id,
        title: g.title,
        emoji: g.emoji,
        targetAmount: g.targetAmount,
        savedAmount: g.savedAmount,
        deadline: g.deadline,
        statusIndex: g.status.index,
        createdAt: g.createdAt,
      );

  Goal toEntity() => Goal(
        id: id,
        title: title,
        emoji: emoji,
        targetAmount: targetAmount,
        savedAmount: savedAmount,
        deadline: deadline,
        status: GoalStatus.values[statusIndex],
        createdAt: createdAt,
      );
}
// TODO Implement this library.