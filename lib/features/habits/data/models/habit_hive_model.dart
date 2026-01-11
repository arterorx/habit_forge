import 'package:hive/hive.dart';

part 'habit_hive_model.g.dart';

@HiveType(typeId: 1)
class HabitHiveModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  List<int> activeWeekdays;

  @HiveField(3)
  List<String> completedDays; // Hive не любит Set напрямую, храним List

  @HiveField(4)
  DateTime createdAt;

  HabitHiveModel({
    required this.id,
    required this.title,
    required this.activeWeekdays,
    required this.completedDays,
    required this.createdAt,
  });
}
