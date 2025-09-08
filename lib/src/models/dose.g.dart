// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dose.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DoseAdapter extends TypeAdapter<Dose> {
  @override
  final int typeId = 2;

  @override
  Dose read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Dose(
      scheduledTime: fields[0] as DateTime,
      takenTime: fields[1] as DateTime?,
      status: fields[2] as DoseStatus,
    );
  }

  @override
  void write(BinaryWriter writer, Dose obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.scheduledTime)
      ..writeByte(1)
      ..write(obj.takenTime)
      ..writeByte(2)
      ..write(obj.status);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DoseAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class DoseStatusAdapter extends TypeAdapter<DoseStatus> {
  @override
  final int typeId = 3;

  @override
  DoseStatus read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return DoseStatus.pending;
      case 1:
        return DoseStatus.taken;
      case 2:
        return DoseStatus.skipped;
      default:
        return DoseStatus.pending;
    }
  }

  @override
  void write(BinaryWriter writer, DoseStatus obj) {
    switch (obj) {
      case DoseStatus.pending:
        writer.writeByte(0);
        break;
      case DoseStatus.taken:
        writer.writeByte(1);
        break;
      case DoseStatus.skipped:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DoseStatusAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
