class Habit {
  final String id;
  final String title;

  final List<int> activeWeekdays;

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
