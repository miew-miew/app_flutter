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

  const HabitReminder({
    required this.id,
    required this.habitId,
    required this.time,
    this.enabled = true,
  });
}
