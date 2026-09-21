import 'package:hive_flutter/hive_flutter.dart';
import '../models/goal_model.dart';

class GoalHiveDatasource {
  static const _boxName = 'goals';

  Future<Box<GoalModel>> get _box async => Hive.isBoxOpen(_boxName)
      ? Hive.box<GoalModel>(_boxName)
      : await Hive.openBox<GoalModel>(_boxName);

  Future<List<GoalModel>> getAll() async {
    final box = await _box;
    return box.values.toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  Future<void> put(GoalModel model) async {
    final box = await _box;
    await box.put(model.id, model);
  }

  Future<void> delete(String id) async {
    final box = await _box;
    await box.delete(id);
  }
}
// TODO Implement this library.