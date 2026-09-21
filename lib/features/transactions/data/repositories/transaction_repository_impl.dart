import '../../domain/entities/transaction.dart';
import '../../domain/repositories/transaction_repository.dart';
import '../datasources/transaction_hive_datasource.dart';
import '../models/transaction_model.dart';

class TransactionRepositoryImpl implements TransactionRepository {
  final TransactionHiveDatasource datasource;

  TransactionRepositoryImpl({
    required this.datasource,
  });

  @override
  Future<List<Transaction>> getAllTransactions() async {
    final models = await datasource.getAll();

    return models
        .map((model) => model.toEntity())
        .toList();
  }

  @override
  Future<Transaction?> getTransactionById(String id) async {
    final model = await datasource.getById(id);

    return model?.toEntity();
  }

  @override
  Future<void> addTransaction(Transaction transaction) async {
    await datasource.add(
      TransactionModel.fromEntity(transaction),
    );
  }

  @override
  Future<void> updateTransaction(Transaction transaction) async {
    await datasource.update(
      TransactionModel.fromEntity(transaction),
    );
  }

  @override
  Future<void> deleteTransaction(String id) async {
    await datasource.delete(id);
  }

  @override
  Future<double> getTotalBalance() async {
    final transactions = await getAllTransactions();

    return transactions.fold<double>(
      0.0,
      (sum, transaction) {
        return transaction.isIncome
            ? sum + transaction.amount
            : sum - transaction.amount;
      },
    );
  }

  @override
  Future<double> getTotalIncome() async {
    final transactions = await getAllTransactions();

    return transactions
        .where((transaction) => transaction.isIncome)
        .fold<double>(
          0.0,
          (sum, transaction) => sum + transaction.amount,
        );
  }

  @override
  Future<double> getTotalExpenses() async {
    final transactions = await getAllTransactions();

    return transactions
        .where((transaction) => transaction.isExpense)
        .fold<double>(
          0.0,
          (sum, transaction) => sum + transaction.amount,
        );
  }
}