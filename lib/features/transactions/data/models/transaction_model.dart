import 'package:hive/hive.dart';
import '../../domain/entities/transaction.dart';

part 'transaction_model.g.dart';

@HiveType(typeId: 0)
class TransactionModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final double amount;

  @HiveField(3)
  final int typeIndex; // 0 = income, 1 = expense

  @HiveField(4)
  final DateTime date;

  @HiveField(5)
  final String? category;

  @HiveField(6)
  final String? note;

  TransactionModel({
    required this.id,
    required this.title,
    required this.amount,
    required this.typeIndex,
    required this.date,
    this.category,
    this.note,
  });

  factory TransactionModel.fromEntity(Transaction entity) {
    return TransactionModel(
      id: entity.id,
      title: entity.title,
      amount: entity.amount,
      typeIndex: entity.type.index,
      date: entity.date,
      category: entity.category,
      note: entity.note,
    );
  }

  Transaction toEntity() {
    return Transaction(
      id: id,
      title: title,
      amount: amount,
      type: TransactionType.values[typeIndex],
      date: date,
      category: category,
      note: note,
    );
  }
}
// TODO Implement this library.