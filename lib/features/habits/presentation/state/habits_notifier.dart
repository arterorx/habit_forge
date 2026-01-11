import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../domain/entities/habit.dart';
import '../../domain/repositories/habits_repository.dart';
import 'habits_providers.dart';

class HabitsNotifier extends AsyncNotifier<List<Habit>> {
  late final HabitsRepository _repo;

  @override
  Future<List<Habit>> build() async {
    _repo = ref.watch(habitsRepositoryProvider);
    return _repo
        .getAll(); // или getAll/getHabits — смотри как у тебя называется
  }

  Future<void> addHabit({
    required String title,
    required List<int> activeWeekdays,
  }) async {
    final current = state.value ?? [];

    final habit = Habit(
      id: const Uuid().v4(),
      title: title,
      activeWeekdays: activeWeekdays,
      completedDays: <String>{},
      createdAt: DateTime.now(),
    );

    // optimistic update (UI реагирует сразу)
    state = AsyncData([habit, ...current]);

    try {
      await _repo.save(habit);
      // гарантируем синхронизацию с БД
      state = AsyncData(await _repo.getAll());
    } catch (e, st) {
      // откат
      state = AsyncError(e, st);
    }
  }

  Future<void> toggleToday(Habit habit) async {
    final today = _toDayKey(DateTime.now());
    final set = {...habit.completedDays};

    if (set.contains(today)) {
      set.remove(today);
    } else {
      set.add(today);
    }

    final updated = habit.copyWith(completedDays: set);

    // обновляем список в памяти
    final list = [...(state.value ?? <Habit>[])];
    final idx = list.indexWhere((h) => h.id == habit.id);
    if (idx != -1) list[idx] = updated;
    state = AsyncData(list);

    try {
      await _repo.save(updated);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> deleteHabit(String id) async {
    final list = [...(state.value ?? <Habit>[])];
    list.removeWhere((h) => h.id == id);
    state = AsyncData(list);

    try {
      await _repo.delete(id);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  String _toDayKey(DateTime dt) {
    // YYYY-MM-DD — ты уже это выбрал в Domain (это правильно)
    final y = dt.year.toString().padLeft(4, '0');
    final m = dt.month.toString().padLeft(2, '0');
    final d = dt.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }
}
