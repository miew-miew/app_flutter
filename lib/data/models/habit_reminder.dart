import 'package:hive/hive.dart';

part 'habit_reminder.g.dart';

@HiveType(typeId: 2)
class HabitReminder {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String habitId;

  // "HH:mm"
  @HiveField(2)
  final String time;

  @HiveField(3)
  final bool enabled;

  // Si le rappel ne s'applique que certains jours
  @HiveField(4)
  final List<int>? daysOfWeek;

  @HiveField(5)
  final String? notificationChannelId;

  @HiveField(6)
  final bool? sound;

  @HiveField(7)
  final bool? vibrate;

  const HabitReminder({
    required this.id,
    required this.habitId,
    required this.time,
    this.enabled = true,
    this.daysOfWeek,
    this.notificationChannelId,
    this.sound,
    this.vibrate,
  });
}