class Habit {
  final String id;
  final String title;

  /// 0..6 (пн..вс) — так проще работать с расписанием
  final List<int> activeWeekdays;

  /// Список дней, когда привычка выполнена.
  /// Храним как YYYY-MM-DD, чтобы не мучаться с таймзонами и временем.
  final Set<String> completedDays;

  final DateTime createdAt;

  const Habit({
    required this.id,
    required this.title,
    required this.activeWeekdays,
    required this.completedDays,
    required this.createdAt,
  });

  Habit copyWith({
    String? title,
    List<int>? activeWeekdays,
    Set<String>? completedDays,
  }) {
    return Habit(
      id: id,
      title: title ?? this.title,
      activeWeekdays: activeWeekdays ?? this.activeWeekdays,
      completedDays: completedDays ?? this.completedDays,
      createdAt: createdAt,
    );
  }
}
