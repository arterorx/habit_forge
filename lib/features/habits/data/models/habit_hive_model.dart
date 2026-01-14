import 'package:hive/hive.dart';

part 'habit_hive_model.g.dart';

@HiveType(typeId: 0)
class HabitHiveModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  List<int> activeWeekdays;

  @HiveField(3)
  List<String> completedDays;

  @HiveField(4)
  DateTime createdAt;

  @HiveField(5)
  bool? remindersEnabled;

  @HiveField(6)
  int? reminderHour;

  @HiveField(7)
  int? reminderMinute;

  HabitHiveModel({
    required this.id,
    required this.title,
    required this.activeWeekdays,
    required this.completedDays,
    required this.createdAt,
    this.remindersEnabled,
    this.reminderHour,
    this.reminderMinute,
  });
}
