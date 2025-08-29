import 'package:hive/hive.dart';
import 'enums.dart';

part 'habit.g.dart';

@HiveType(typeId: 0)
class Habit {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(3)
  final String? iconEmoji;

  @HiveField(5)
  final String scheduleId;

  @HiveField(6)
  final int targetPerDay;

  @HiveField(7)
  final int? targetDurationSeconds;

  @HiveField(8)
  final bool isArchived;

  @HiveField(9)
  final DateTime createdAt;

  @HiveField(10)
  final DateTime updatedAt;

  @HiveField(13)
  final TrackingType? trackingType;

  @HiveField(14)
  final String? frequency;

  @HiveField(15)
  final List<int>? weeklyDays;

  @HiveField(17)
  final String? reminderTime;

  const Habit({
    required this.id,
    required this.title,
    this.iconEmoji,
    required this.scheduleId,
    this.targetPerDay = 1,
    this.targetDurationSeconds,
    this.isArchived = false,
    required this.createdAt,
    required this.updatedAt,
    this.trackingType,
    this.frequency,
    this.weeklyDays,
    this.reminderTime,
  });
}
