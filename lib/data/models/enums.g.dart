// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'enums.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ScheduleTypeAdapter extends TypeAdapter<ScheduleType> {
  @override
  final int typeId = 6;

  @override
  ScheduleType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return ScheduleType.daily;
      case 2:
        return ScheduleType.customDays;
      default:
        return ScheduleType.daily;
    }
  }

  @override
  void write(BinaryWriter writer, ScheduleType obj) {
    switch (obj) {
      case ScheduleType.daily:
        writer.writeByte(0);
        break;
      case ScheduleType.customDays:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ScheduleTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class HabitStatusAdapter extends TypeAdapter<HabitStatus> {
  @override
  final int typeId = 7;

  @override
  HabitStatus read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return HabitStatus.done;
      case 1:
        return HabitStatus.missed;
      case 2:
        return HabitStatus.running;
      default:
        return HabitStatus.done;
    }
  }

  @override
  void write(BinaryWriter writer, HabitStatus obj) {
    switch (obj) {
      case HabitStatus.done:
        writer.writeByte(0);
        break;
      case HabitStatus.missed:
        writer.writeByte(1);
        break;
      case HabitStatus.running:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HabitStatusAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class TrackingTypeAdapter extends TypeAdapter<TrackingType> {
  @override
  final int typeId = 9;

  @override
  TrackingType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return TrackingType.task;
      case 1:
        return TrackingType.quantity;
      case 2:
        return TrackingType.time;
      default:
        return TrackingType.task;
    }
  }

  @override
  void write(BinaryWriter writer, TrackingType obj) {
    switch (obj) {
      case TrackingType.task:
        writer.writeByte(0);
        break;
      case TrackingType.quantity:
        writer.writeByte(1);
        break;
      case TrackingType.time:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TrackingTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
