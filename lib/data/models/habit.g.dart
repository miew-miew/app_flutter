// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'habit.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class HabitAdapter extends TypeAdapter<Habit> {
  @override
  final int typeId = 0;

  @override
  Habit read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Habit(
      id: fields[0] as String,
      title: fields[1] as String,
      iconEmoji: fields[3] as String?,
      scheduleId: fields[5] as String,
      targetPerDay: fields[6] as int,
      targetDurationSeconds: fields[7] as int?,
      isArchived: fields[8] as bool,
      createdAt: fields[9] as DateTime,
      updatedAt: fields[10] as DateTime,
      trackingType: fields[13] as TrackingType?,
      frequency: fields[14] as String?,
      weeklyDays: (fields[15] as List?)?.cast<int>(),
      reminderTime: fields[17] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, Habit obj) {
    writer
      ..writeByte(13)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(3)
      ..write(obj.iconEmoji)
      ..writeByte(5)
      ..write(obj.scheduleId)
      ..writeByte(6)
      ..write(obj.targetPerDay)
      ..writeByte(7)
      ..write(obj.targetDurationSeconds)
      ..writeByte(8)
      ..write(obj.isArchived)
      ..writeByte(9)
      ..write(obj.createdAt)
      ..writeByte(10)
      ..write(obj.updatedAt)
      ..writeByte(13)
      ..write(obj.trackingType)
      ..writeByte(14)
      ..write(obj.frequency)
      ..writeByte(15)
      ..write(obj.weeklyDays)
      ..writeByte(17)
      ..write(obj.reminderTime);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HabitAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
