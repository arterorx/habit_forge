import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habit_forge/core/analytics/firebase_providers.dart';
import 'package:habit_forge/core/notifications/notification_service.dart';
import 'package:habit_forge/core/notifications/notifications_providers.dart';
import 'package:habit_forge/core/settings/app_settings_providers.dart';
import 'package:habit_forge/core/utils/date_key.dart';
import 'package:uuid/uuid.dart';

import '../../domain/entities/habit.dart';
import '../../domain/repositories/habits_repository.dart';
import 'habits_providers.dart';

class HabitsNotifier extends AsyncNotifier<List<Habit>> {
  HabitsRepository get _repo => ref.read(habitsRepositoryProvider);
  NotificationService get _notifications =>
      ref.read(notificationServiceProvider);

  FirebaseAnalytics get _analytics => ref.read(firebaseAnalyticsProvider);
  FirebaseCrashlytics get _crashlytics => ref.read(crashlyticsProvider);

  @override
  Future<List<Habit>> build() async {
    // ❗️Никаких late final присваиваний. build может вызываться много раз.
    return _repo.getAll();
  }

  Future<void> addHabit({
    required String title,
    required List<int> activeWeekdays,
    required bool remindersEnabled,
    required int reminderHour,
    required int reminderMinute,
  }) async {
    final current = state.value ?? [];

    final habit = Habit(
      id: const Uuid().v4(),
      title: title,
      activeWeekdays: activeWeekdays,
      completedDays: <String>{},
      createdAt: DateTime.now(),
      remindersEnabled: remindersEnabled,
      reminderHour: reminderHour,
      reminderMinute: reminderMinute,
    );

    // optimistic UI
    state = AsyncData([habit, ...current]);

    try {
      await _repo.save(habit);
      await _analytics.logEvent(
        name: 'habit_created',
        parameters: {
          'habit_id': habit.id,
          'weekday_count': habit.activeWeekdays.length,
          'reminders_enabled': habit.remindersEnabled ? 1 : 0,
        },
      );

      final settings = ref.read(appSettingsNotifierProvider).value;

      if (habit.remindersEnabled && (settings?.notificationsEnabled ?? true)) {
        final ok = await _notifications.requestPermissions();
        if (ok) {
          await _notifications.scheduleWeeklyHabit(
            habitId: habit.id,
            title: habit.title,
            activeWeekdays: habit.activeWeekdays,
            hour: habit.reminderHour,
            minute: habit.reminderMinute,
          );
          await _analytics.logEvent(
            name: 'notification_enabled',
            parameters: {
              'habit_id': habit.id,
              'hour': habit.reminderHour,
              'minute': habit.reminderMinute,
              'weekday_count': habit.activeWeekdays.length,
            },
          );
        }
      }

      state = AsyncData(await _repo.getAll());
    } catch (e, st) {
      await _crashlytics.recordError(e, st, reason: 'addHabit failed');
      state = AsyncError(e, st);
    }
  }

  Future<void> toggleToday(Habit habit) async {
    final today = dateKey(DateTime.now());
    final set = {...habit.completedDays};

    final wasDone = set.contains(today);
    if (wasDone) {
      set.remove(today);
    } else {
      set.add(today);
    }

    final updated = habit.copyWith(completedDays: set);

    // optimistic UI: обновляем список сразу
    final list = [...(state.value ?? <Habit>[])];
    final idx = list.indexWhere((h) => h.id == habit.id);
    if (idx != -1) list[idx] = updated;
    state = AsyncData(list);

    try {
      await _repo.save(updated);

      final isDoneNow = set.contains(today);
      await _analytics.logEvent(
        name: 'habit_completed',
        parameters: {'habit_id': habit.id, 'completed': isDoneNow ? 1 : 0},
      );
    } catch (e, st) {
      await _crashlytics.recordError(e, st, reason: 'toggleToday failed');
      state = AsyncError(e, st);
    }
  }

  Future<void> deleteHabit(String id) async {
    final list = [...(state.value ?? <Habit>[])];
    list.removeWhere((h) => h.id == id);
    state = AsyncData(list);

    try {
      await _notifications.cancelHabit(id);
      await _repo.delete(id);
    } catch (e, st) {
      await _crashlytics.recordError(e, st, reason: 'deleteHabit failed');
      state = AsyncError(e, st);
    }
  }

  Future<void> updateReminders(Habit habit) async {
    try {
      // 1) всегда отменяем старые
      await _notifications.cancelHabit(habit.id);

      final settings = ref.read(appSettingsNotifierProvider).value;

      // 2) если включено — пересоздаём
      if (habit.remindersEnabled && (settings?.notificationsEnabled ?? true)) {
        final ok = await _notifications.requestPermissions();
        if (ok) {
          await _notifications.scheduleWeeklyHabit(
            habitId: habit.id,
            title: habit.title,
            activeWeekdays: habit.activeWeekdays,
            hour: habit.reminderHour,
            minute: habit.reminderMinute,
          );
        }
      }

      await _repo.save(habit);
      state = AsyncData(await _repo.getAll());
    } catch (e, st) {
      await _crashlytics.recordError(e, st, reason: 'updateReminders failed');
      state = AsyncError(e, st);
    }
  }
}
