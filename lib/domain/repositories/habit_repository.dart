import 'package:app_flutter/data/models/habit.dart';
import 'package:app_flutter/data/models/habit_schedule.dart';

abstract class HabitRepository {
  Future<List<Habit>> getAllHabits();
  Future<Habit?> getHabitById(String id);
  Future<void> createHabit(Habit habit);
  Future<void> updateHabit(Habit habit);
  Future<void> deleteHabit(String id);
  Future<List<HabitSchedule>> getAllSchedules();
  Future<void> createHabitSchedule(HabitSchedule schedule);
}
