// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'habit_hive_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class HabitHiveModelAdapter extends TypeAdapter<HabitHiveModel> {
  @override
  final int typeId = 0;

  @override
  HabitHiveModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return HabitHiveModel(
      id: fields[0] as String,
      title: fields[1] as String,
      activeWeekdays: (fields[2] as List).cast<int>(),
      completedDays: (fields[3] as List).cast<String>(),
      createdAt: fields[4] as DateTime,
      remindersEnabled: fields[5] as bool?,
      reminderHour: fields[6] as int?,
      reminderMinute: fields[7] as int?,
    );
  }

  @override
  void write(BinaryWriter writer, HabitHiveModel obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.activeWeekdays)
      ..writeByte(3)
      ..write(obj.completedDays)
      ..writeByte(4)
      ..write(obj.createdAt)
      ..writeByte(5)
      ..write(obj.remindersEnabled)
      ..writeByte(6)
      ..write(obj.reminderHour)
      ..writeByte(7)
      ..write(obj.reminderMinute);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HabitHiveModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
