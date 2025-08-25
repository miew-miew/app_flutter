import 'package:hive/hive.dart';
import 'enums.dart';

part 'habit_schedule.g.dart';

@HiveType(typeId: 1)
class HabitSchedule {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final ScheduleType type;

  // 1 = Monday ... 7 = Sunday (ISO-8601)
  @HiveField(2)
  final List<int>? daysOfWeek;

  // Heures souhaitées au format "HH:mm" (ex: "20:30")
  @HiveField(3)
  final List<String>? times;

  @HiveField(4)
  final String? timezone;

  @HiveField(5)
  final DateTime startDate;

  @HiveField(6)
  final DateTime? endDate;

  @HiveField(7)
  final int? intervalN; // si type == intervalN

  @HiveField(8)
  final List<DateTime>? specificDates; // si type == specificDates

  const HabitSchedule({
    required this.id,
    required this.type,
    this.daysOfWeek,
    this.times,
    this.timezone,
    required this.startDate,
    this.endDate,
    this.intervalN,
    this.specificDates,
  });
}