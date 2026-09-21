import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/goal.dart';
import '../../domain/repositories/goal_repository.dart';

class GoalController extends GetxController {
  final GoalRepository repository;
  GoalController({required this.repository});

  final goals = <Goal>[].obs;
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadGoals();
  }

  Future<void> loadGoals() async {
    isLoading.value = true;
    try {
      goals.assignAll(await repository.getAllGoals());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> addGoal({
    required String title,
    required String emoji,
    required double targetAmount,
    required DateTime deadline,
  }) async {
    final goal = Goal(
      id: const Uuid().v4(),
      title: title,
      emoji: emoji,
      targetAmount: targetAmount,
      savedAmount: 0,
      deadline: deadline,
      createdAt: DateTime.now(),
    );
    await repository.addGoal(goal);
    await loadGoals();
  }

  Future<void> addSavings(String goalId, double amount) async {
    await repository.addSavings(goalId, amount);
    await loadGoals();
  }

  Future<void> deleteGoal(String id) async {
    await repository.deleteGoal(id);
    await loadGoals();
  }

  List<Goal> get activeGoals =>
      goals.where((g) => g.status == GoalStatus.active).toList();

  List<Goal> get completedGoals =>
      goals.where((g) => g.status == GoalStatus.completed).toList();

  double get totalSaved =>
      goals.fold(0.0, (s, g) => s + g.savedAmount);

  double get totalTarget =>
      goals.fold(0.0, (s, g) => s + g.targetAmount);
}
// TODO Implement this library.