import 'package:hive/hive.dart';

part 'app_settings_hive_model.g.dart';

@HiveType(typeId: 10)
class AppSettingsHiveModel extends HiveObject {
  @HiveField(0)
  bool notificationsEnabled;

  AppSettingsHiveModel({required this.notificationsEnabled});
}
