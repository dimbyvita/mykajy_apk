import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/transaction.dart';
import '../../domain/repositories/transaction_repository.dart';

class TransactionController extends GetxController {
  final TransactionRepository repository;

  TransactionController({required this.repository});

  final RxList<Transaction> transactions = <Transaction>[].obs;
  final RxDouble totalBalance = 0.0.obs;
  final RxDouble totalIncome = 0.0.obs;
  final RxDouble totalExpenses = 0.0.obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadData();
  }

  Future<void> loadData() async {
    isLoading.value = true;
    try {
      final results = await Future.wait([
        repository.getAllTransactions(),
        repository.getTotalBalance(),
        repository.getTotalIncome(),
        repository.getTotalExpenses(),
      ]);
      transactions.assignAll(results[0] as List<Transaction>);
      totalBalance.value = results[1] as double;
      totalIncome.value = results[2] as double;
      totalExpenses.value = results[3] as double;
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load transactions: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> addTransaction({
    required String title,
    required double amount,
    required TransactionType type,
    required DateTime date,
    String? category,
    String? note,
  }) async {
    final transaction = Transaction(
      id: const Uuid().v4(),
      title: title,
      amount: amount,
      type: type,
      date: date,
      category: category,
      note: note,
    );
    await repository.addTransaction(transaction);
    await loadData();
  }

  Future<void> deleteTransaction(String id) async {
    await repository.deleteTransaction(id);
    await loadData();
  }

  Future<void> updateTransaction(Transaction transaction) async {
    await repository.updateTransaction(transaction);
    await loadData();
  }

  List<Transaction> get recentTransactions =>
      transactions.take(10).toList();
}
// TODO Implement this library.