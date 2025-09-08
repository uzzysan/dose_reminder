// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'medicine.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MedicineAdapter extends TypeAdapter<Medicine> {
  @override
  final int typeId = 0;

  @override
  Medicine read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Medicine(
      name: fields[0] as String,
      photoPath: fields[1] as String?,
      frequencyType: fields[2] as FrequencyType,
      timesPerDay: fields[3] as int?,
      everyXDays: fields[4] as int?,
      weeklyFrequency: (fields[5] as List?)?.cast<int>(),
      durationInDays: fields[6] as int,
      startDateTime: fields[7] as DateTime,
      preferredStartHour: fields[8] as int,
      preferredEndHour: fields[9] as int,
    )..doseHistory = (fields[10] as HiveList?)?.castHiveList();
  }

  @override
  void write(BinaryWriter writer, Medicine obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.photoPath)
      ..writeByte(2)
      ..write(obj.frequencyType)
      ..writeByte(3)
      ..write(obj.timesPerDay)
      ..writeByte(4)
      ..write(obj.everyXDays)
      ..writeByte(5)
      ..write(obj.weeklyFrequency)
      ..writeByte(6)
      ..write(obj.durationInDays)
      ..writeByte(7)
      ..write(obj.startDateTime)
      ..writeByte(8)
      ..write(obj.preferredStartHour)
      ..writeByte(9)
      ..write(obj.preferredEndHour)
      ..writeByte(10)
      ..write(obj.doseHistory);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MedicineAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class FrequencyTypeAdapter extends TypeAdapter<FrequencyType> {
  @override
  final int typeId = 1;

  @override
  FrequencyType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return FrequencyType.daily;
      case 1:
        return FrequencyType.everyXDays;
      case 2:
        return FrequencyType.weekly;
      default:
        return FrequencyType.daily;
    }
  }

  @override
  void write(BinaryWriter writer, FrequencyType obj) {
    switch (obj) {
      case FrequencyType.daily:
        writer.writeByte(0);
        break;
      case FrequencyType.everyXDays:
        writer.writeByte(1);
        break;
      case FrequencyType.weekly:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FrequencyTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
