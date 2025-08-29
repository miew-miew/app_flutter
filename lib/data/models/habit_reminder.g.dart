// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'habit_reminder.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class HabitReminderAdapter extends TypeAdapter<HabitReminder> {
  @override
  final int typeId = 2;

  @override
  HabitReminder read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return HabitReminder(
      id: fields[0] as String,
      habitId: fields[1] as String,
      time: fields[2] as String,
      enabled: fields[3] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, HabitReminder obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.habitId)
      ..writeByte(2)
      ..write(obj.time)
      ..writeByte(3)
      ..write(obj.enabled);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HabitReminderAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
