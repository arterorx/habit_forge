import 'package:hive/hive.dart';
import 'app_settings_hive_model.dart';

class AppSettingsLocalDatasource {
  static const boxName = 'appSettingsBox';
  static const key = 'settings';

  Future<Box<AppSettingsHiveModel>> _box() async {
    return Hive.openBox<AppSettingsHiveModel>(boxName);
  }

  Future<AppSettingsHiveModel> get() async {
    final box = await _box();
    final existing = box.get(key);
    if (existing != null) return existing;

    final fresh = AppSettingsHiveModel(notificationsEnabled: true);
    await box.put(key, fresh);
    return fresh;
  }

  Future<void> save(AppSettingsHiveModel settings) async {
    final box = await _box();
    await box.put(key, settings);
  }
}
