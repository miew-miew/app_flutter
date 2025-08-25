import 'package:hive/hive.dart';

part 'enums.g.dart';

@HiveType(typeId: 6)
enum ScheduleType {
  @HiveField(0)
  daily,
  @HiveField(1)
  weekdays,
  @HiveField(2)
  customDays, // ex: [1,3,5]
  @HiveField(3)
  intervalN, // ex: tous les N jours
  @HiveField(4)
  specificDates, // dates précises
}

@HiveType(typeId: 7)
enum HabitStatus {
  @HiveField(0)
  done,
  @HiveField(1)
  skipped,
  @HiveField(2)
  missed,
}

@HiveType(typeId: 8)
enum AppThemeMode {
  @HiveField(0)
  system,
  @HiveField(1)
  light,
  @HiveField(2)
  dark,
}

@HiveType(typeId: 9)
enum TrackingType {
  @HiveField(0)
  task, // Tâche simple
  @HiveField(1)
  quantity, // Quantité
  @HiveField(2)
  time, // Temps
}
