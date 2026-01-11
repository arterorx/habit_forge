import 'package:hive/hive.dart';
import '../models/habit_hive_model.dart';

class HabitsLocalDatasource {
  static const String boxName = 'habitsBox';

  Future<Box<HabitHiveModel>> _box() async {
    return Hive.openBox<HabitHiveModel>(boxName);
  }

  Future<List<HabitHiveModel>> getAll() async {
    final box = await _box();
    return box.values.toList();
  }

  Future<void> upsert(HabitHiveModel model) async {
    final box = await _box();
    await box.put(model.id, model);
  }

  Future<void> delete(String id) async {
    final box = await _box();
    await box.delete(id);
  }

  Future<void> clear() async {
    final box = await _box();
    await box.clear();
  }
}
