// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'habit_schedule.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class HabitScheduleAdapter extends TypeAdapter<HabitSchedule> {
  @override
  final int typeId = 1;

  @override
  HabitSchedule read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return HabitSchedule(
      id: fields[0] as String,
      type: fields[1] as ScheduleType,
      daysOfWeek: (fields[2] as List?)?.cast<int>(),
      times: (fields[3] as List?)?.cast<String>(),
      timezone: fields[4] as String?,
      startDate: fields[5] as DateTime?,
      endDate: fields[6] as DateTime?,
      intervalN: fields[7] as int?,
      specificDates: (fields[8] as List?)?.cast<DateTime>(),
    );
  }

  @override
  void write(BinaryWriter writer, HabitSchedule obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.type)
      ..writeByte(2)
      ..write(obj.daysOfWeek)
      ..writeByte(3)
      ..write(obj.times)
      ..writeByte(4)
      ..write(obj.timezone)
      ..writeByte(5)
      ..write(obj.startDate)
      ..writeByte(6)
      ..write(obj.endDate)
      ..writeByte(7)
      ..write(obj.intervalN)
      ..writeByte(8)
      ..write(obj.specificDates);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HabitScheduleAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
