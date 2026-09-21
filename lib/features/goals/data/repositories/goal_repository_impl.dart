import '../../domain/entities/goal.dart';
import '../../domain/repositories/goal_repository.dart';
import '../datasources/goal_hive_datasource.dart';
import '../models/goal_model.dart';

class GoalRepositoryImpl implements GoalRepository {
  final GoalHiveDatasource datasource;

  GoalRepositoryImpl({required this.datasource});

  @override
  Future<List<Goal>> getAllGoals() async {
    final models = await datasource.getAll();
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<void> addGoal(Goal goal) async {
    await datasource.put(GoalModel.fromEntity(goal));
  }

  @override
  Future<void> updateGoal(Goal goal) async {
    await datasource.put(GoalModel.fromEntity(goal));
  }

  @override
  Future<void> deleteGoal(String id) async {
    await datasource.delete(id);
  }

  @override
  Future<void> addSavings(String goalId, double amount) async {
    final all = await datasource.getAll();
    final model = all.firstWhere((m) => m.id == goalId);
    final updated = GoalModel(
      id: model.id,
      title: model.title,
      emoji: model.emoji,
      targetAmount: model.targetAmount,
      savedAmount: (model.savedAmount + amount).clamp(0, model.targetAmount),
      deadline: model.deadline,
      statusIndex: model.savedAmount + amount >= model.targetAmount
          ? 1 // completed
          : model.statusIndex,
      createdAt: model.createdAt,
    );
    await datasource.put(updated);
  }
}
// TODO Implement this library.