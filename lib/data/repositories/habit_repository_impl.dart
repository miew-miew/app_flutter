import 'package:app_flutter/data/boxes.dart';
import 'package:app_flutter/data/models/habit.dart';
import 'package:app_flutter/data/models/habit_schedule.dart';
import 'package:app_flutter/domain/repositories/habit_repository.dart';
import 'package:hive_flutter/hive_flutter.dart';

class HabitRepositoryImpl implements HabitRepository {
  @override
  Future<List<Habit>> getAllHabits() async {
    final box = Hive.box<Habit>(Boxes.habits);
    return box.values.toList();
  }

  @override
  Future<Habit?> getHabitById(String id) async {
    final box = Hive.box<Habit>(Boxes.habits);
    return box.get(id);
  }

  @override
  Future<void> createHabit(Habit habit) async {
    final box = Hive.box<Habit>(Boxes.habits);
    await box.put(habit.id, habit);
  }

  @override
  Future<void> updateHabit(Habit habit) async {
    final box = Hive.box<Habit>(Boxes.habits);
    await box.put(habit.id, habit);
  }

  @override
  Future<void> deleteHabit(String id) async {
    final box = Hive.box<Habit>(Boxes.habits);
    return box.delete(id);
  }

  @override
  Future<List<HabitSchedule>> getAllSchedules() async {
    final box = Hive.box<HabitSchedule>(Boxes.habitSchedules);
    return box.values.toList();
  }

  @override
  Future<void> createHabitSchedule(HabitSchedule schedule) async {
    final box = Hive.box<HabitSchedule>(Boxes.habitSchedules);
    await box.put(schedule.id, schedule);
  }
}
