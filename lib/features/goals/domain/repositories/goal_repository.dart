import '../entities/goal.dart';

abstract class GoalRepository {
  Future<List<Goal>> getAllGoals();
  Future<void> addGoal(Goal goal);
  Future<void> updateGoal(Goal goal);
  Future<void> deleteGoal(String id);
  Future<void> addSavings(String goalId, double amount);
}
// TODO Implement this library.