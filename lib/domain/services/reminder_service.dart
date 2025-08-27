import 'dart:async';

import 'package:app_flutter/data/models/habit.dart';
import 'package:app_flutter/data/models/habit_schedule.dart';
import 'package:app_flutter/data/models/enums.dart';
import 'package:app_flutter/domain/repositories/habit_repository.dart';

class ReminderEvent {
  final Habit habit;
  final DateTime scheduledFor;
  ReminderEvent({required this.habit, required this.scheduledFor});
}

/// Simple in-app reminder service for desktop/web: checks every minute and emits events.
class ReminderService {
  final HabitRepository _habitRepository;
  final StreamController<ReminderEvent> _controller = StreamController.broadcast();
  Timer? _timer;
  // Avoid duplicate events within the same minute per habit
  final Set<String> _emittedKeys = <String>{};

  ReminderService(this._habitRepository) {
    _start();
  }

  Stream<ReminderEvent> get events => _controller.stream;

  void _start() {
    // Start immediately, then check frequently so user sees it quickly
    _checkNow();
    _timer = Timer.periodic(const Duration(seconds: 15), (_) => _checkNow());
  }

  Future<void> _checkNow() async {
    final DateTime now = DateTime.now();
    final DateTime minuteKey = DateTime(now.year, now.month, now.day, now.hour, now.minute);
    final String hh = now.hour.toString().padLeft(2, '0');
    final String mm = now.minute.toString().padLeft(2, '0');
    final String hhmm = '$hh:$mm';

    final List<Habit> habits = await _habitRepository.getAllHabits();
    if (habits.isEmpty) return;
    final List<HabitSchedule> schedules = await _habitRepository.getAllSchedules();
    final Map<String, HabitSchedule> scheduleById = {for (final s in schedules) s.id: s};

    final int weekday = now.weekday; // 1=lundi..7=dimanche

    // debug logging removed

    for (final habit in habits.where((h) => !h.isArchived)) {
      final HabitSchedule? schedule = scheduleById[habit.scheduleId];
      final bool scheduledToday = _isScheduledToday(schedule, habit, now, weekday);
      if (!scheduledToday) continue;

      // Determine candidate reminder times: schedule.times or habit.reminderTime
      final List<String> candidateTimes = <String>[];
      final List<String>? times = schedule?.times;
      if (times != null && times.isNotEmpty) {
        candidateTimes.addAll(times);
      }
      if ((times == null || times.isEmpty) && (habit.reminderTime != null && habit.reminderTime!.trim().isNotEmpty)) {
        candidateTimes.add(habit.reminderTime!.trim());
      }
      if (candidateTimes.isEmpty) continue;

      if (!candidateTimes.contains(hhmm)) continue;

      final String key = '${habit.id}_${minuteKey.toIso8601String()}';
      if (_emittedKeys.contains(key)) continue;
      _emittedKeys.add(key);
      _controller.add(ReminderEvent(habit: habit, scheduledFor: minuteKey));
    }

    // Cleanup old keys (keep last 500 to avoid unbounded growth)
    if (_emittedKeys.length > 500) {
      _emittedKeys.clear();
    }
  }

  bool _isScheduledToday(
    HabitSchedule? schedule,
    Habit habit,
    DateTime date,
    int weekday,
  ) {
    // Default: if no schedule, consider daily starting from createdAt
    if (schedule == null) {
      final DateTime dayKey = _dayKey(date);
      final DateTime startKey = _dayKey(habit.createdAt);
      return !dayKey.isBefore(startKey);
    }

    // Respect start/end
    if (_isOutsideRange(schedule, date)) return false;

    switch (schedule.type) {
      case ScheduleType.daily:
        return true;
      case ScheduleType.weekdays:
        return weekday >= 1 && weekday <= 5;
      case ScheduleType.customDays:
        final List<int>? days = schedule.daysOfWeek;
        if (days == null || days.isEmpty) return false;
        return days.contains(weekday);
      case ScheduleType.intervalN:
        if (schedule.intervalN == null) return false;
        final int daysSinceStart = date.difference(_dayKey(schedule.startDate)).inDays;
        return daysSinceStart % schedule.intervalN! == 0;
      case ScheduleType.specificDates:
        final List<DateTime>? specific = schedule.specificDates;
        if (specific == null) return false;
        final DateTime dateKey = _dayKey(date);
        return specific.any((d) => _dayKey(d).isAtSameMomentAs(dateKey));
    }
  }

  bool _isOutsideRange(HabitSchedule schedule, DateTime date) {
    final DateTime dayKey = _dayKey(date);
    final DateTime startKey = _dayKey(schedule.startDate);
    if (dayKey.isBefore(startKey)) return true;
    if (schedule.endDate != null) {
      final DateTime endKey = _dayKey(schedule.endDate!);
      if (dayKey.isAfter(endKey)) return true;
    }
    return false;
  }

  DateTime _dayKey(DateTime d) => DateTime(d.year, d.month, d.day);

  void dispose() {
    _timer?.cancel();
    _controller.close();
  }
}


