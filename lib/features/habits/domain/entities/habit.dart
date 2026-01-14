class Habit {
  final String id;
  final String title;

  final List<int> activeWeekdays;

  final Set<String> completedDays;

  final DateTime createdAt;

  final bool remindersEnabled;
  final int reminderHour;
  final int reminderMinute;

  const Habit({
    required this.id,
    required this.title,
    required this.activeWeekdays,
    required this.completedDays,
    required this.createdAt,
    required this.remindersEnabled,
    required this.reminderHour,
    required this.reminderMinute,
  });

  Habit copyWith({
    String? title,
    List<int>? activeWeekdays,
    Set<String>? completedDays,
    bool? remindersEnabled,
    int? reminderHour,
    int? reminderMinute,
  }) {
    return Habit(
      id: id,
      title: title ?? this.title,
      activeWeekdays: activeWeekdays ?? this.activeWeekdays,
      completedDays: completedDays ?? this.completedDays,
      createdAt: createdAt,
      remindersEnabled: remindersEnabled ?? this.remindersEnabled,
      reminderHour: reminderHour ?? this.reminderHour,
      reminderMinute: reminderMinute ?? this.reminderMinute,
    );
  }
}
