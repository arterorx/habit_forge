import 'dart:io';
import 'package:hive/hive.dart';
import '../models/habit_hive_model.dart';

class HabitsLocalDatasource {
  static const boxName = 'habitsBox';

  Future<Box<HabitHiveModel>> _box() async {
    try {
      return await Hive.openBox<HabitHiveModel>(boxName);
    } on HiveError {
      // 1) если бокс частично/ранее открыт — закрываем
      if (Hive.isBoxOpen(boxName)) {
        await Hive.box(boxName).close();
      }

      // 2) удаляем с диска только если бокс существует
      final exists = await Hive.boxExists(boxName);
      if (exists) {
        try {
          await Hive.deleteBoxFromDisk(boxName);
        } on FileSystemException {
          // macOS: lock-файл может отсутствовать — игнорируем
        } catch (_) {
          // на всякий — тоже не валим приложение
        }
      }

      // 3) пробуем открыть заново уже "чистый" бокс
      return await Hive.openBox<HabitHiveModel>(boxName);
    }
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
}
