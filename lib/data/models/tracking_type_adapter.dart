import 'package:hive/hive.dart';

import 'enums.dart';

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
}
