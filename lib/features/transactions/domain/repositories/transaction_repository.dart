import '../entities/transaction.dart';

abstract class TransactionRepository {
  Future<List<Transaction>> getAllTransactions();
  Future<Transaction?> getTransactionById(String id);
  Future<void> addTransaction(Transaction transaction);
  Future<void> updateTransaction(Transaction transaction);
  Future<void> deleteTransaction(String id);
  Future<double> getTotalBalance();
  Future<double> getTotalIncome();
  Future<double> getTotalExpenses();
}
// TODO Implement this library.