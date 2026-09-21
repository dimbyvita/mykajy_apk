import 'package:hive/hive.dart';
import '../models/transaction_model.dart';

abstract class TransactionHiveDatasource {
  Future<List<TransactionModel>> getAll();
  Future<TransactionModel?> getById(String id);
  Future<void> add(TransactionModel model);
  Future<void> update(TransactionModel model);
  Future<void> delete(String id);
}

class TransactionHiveDatasourceImpl implements TransactionHiveDatasource {
  static const String _boxName = 'transactions';

  Future<Box<TransactionModel>> get _box async =>
      Hive.isBoxOpen(_boxName)
          ? Hive.box<TransactionModel>(_boxName)
          : await Hive.openBox<TransactionModel>(_boxName);

  @override
  Future<List<TransactionModel>> getAll() async {
    final box = await _box;
    return box.values.toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  @override
  Future<TransactionModel?> getById(String id) async {
    final box = await _box;
    try {
      return box.values.firstWhere((t) => t.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> add(TransactionModel model) async {
    final box = await _box;
    await box.put(model.id, model);
  }

  @override
  Future<void> update(TransactionModel model) async {
    final box = await _box;
    await box.put(model.id, model);
  }

  @override
  Future<void> delete(String id) async {
    final box = await _box;
    await box.delete(id);
  }
}
// TODO Implement this library.