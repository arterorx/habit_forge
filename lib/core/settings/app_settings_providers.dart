import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app_settings_local_datasource.dart';
import 'app_settings_hive_model.dart';

final appSettingsDatasourceProvider = Provider((ref) {
  return AppSettingsLocalDatasource();
});

final appSettingsNotifierProvider =
    AsyncNotifierProvider<AppSettingsNotifier, AppSettingsHiveModel>(
      AppSettingsNotifier.new,
    );

class AppSettingsNotifier extends AsyncNotifier<AppSettingsHiveModel> {
  late final AppSettingsLocalDatasource _ds;

  @override
  Future<AppSettingsHiveModel> build() async {
    _ds = ref.watch(appSettingsDatasourceProvider);
    return _ds.get();
  }

  Future<void> setNotificationsEnabled(bool enabled) async {
    final current = state.value;
    if (current == null) return;

    final updated = AppSettingsHiveModel(notificationsEnabled: enabled);
    state = AsyncData(updated);
    await _ds.save(updated);
  }
}
