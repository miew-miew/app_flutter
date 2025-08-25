import 'package:hive/hive.dart';
import 'enums.dart';

part 'habit_log.g.dart';

@HiveType(typeId: 3)
class HabitLog {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String habitId;

  // Date "du jour" (00:00 local) pour agréger les occurrences
  @HiveField(2)
  final DateTime date;

  // Moment exact de l'action
  @HiveField(3)
  final DateTime eventTime;

  @HiveField(4)
  final HabitStatus status;

  // 1er, 2e, 3e évènement du jour
  @HiveField(5)
  final int countIndex;

  @HiveField(6)
  final int? durationMinutes;

  @HiveField(7)
  final String? note;

  const HabitLog({
    required this.id,
    required this.habitId,
    required this.date,
    required this.eventTime,
    required this.status,
    required this.countIndex,
    this.durationMinutes,
    this.note,
  });
}