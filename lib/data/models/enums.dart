import 'package:hive/hive.dart';

part 'enums.g.dart';

@HiveType(typeId: 6)
enum ScheduleType {
  @HiveField(0)
  daily,
  @HiveField(2)
  customDays,
}

@HiveType(typeId: 7)
enum HabitStatus {
  @HiveField(0)
  done,
  @HiveField(1)
  missed,
  @HiveField(2)
  running,
}

@HiveType(typeId: 9)
enum TrackingType {
  @HiveField(0)
  task, 
  @HiveField(1)
  quantity, 
  @HiveField(2)
  time, 
}
