// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'class_schedule_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TimeOfDayModelAdapter extends TypeAdapter<TimeOfDayModel> {
  @override
  final int typeId = 2;

  @override
  TimeOfDayModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TimeOfDayModel(
      hour: fields[0] as int,
      minute: fields[1] as int,
    );
  }

  @override
  void write(BinaryWriter writer, TimeOfDayModel obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.hour)
      ..writeByte(1)
      ..write(obj.minute);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TimeOfDayModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ClassScheduleAdapter extends TypeAdapter<ClassSchedule> {
  @override
  final int typeId = 3;

  @override
  ClassSchedule read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ClassSchedule(
      id: fields[0] as String,
      courseId: fields[1] as String,
      dayOfWeek: fields[2] as DayOfWeek,
      startTime: fields[3] as TimeOfDayModel,
      endTime: fields[4] as TimeOfDayModel,
      location: fields[5] as String?,
      professor: fields[6] as String?,
      isRecurrent: fields[7] as bool,
      createdAt: fields[8] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, ClassSchedule obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.courseId)
      ..writeByte(2)
      ..write(obj.dayOfWeek)
      ..writeByte(3)
      ..write(obj.startTime)
      ..writeByte(4)
      ..write(obj.endTime)
      ..writeByte(5)
      ..write(obj.location)
      ..writeByte(6)
      ..write(obj.professor)
      ..writeByte(7)
      ..write(obj.isRecurrent)
      ..writeByte(8)
      ..write(obj.createdAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ClassScheduleAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class DayOfWeekAdapter extends TypeAdapter<DayOfWeek> {
  @override
  final int typeId = 1;

  @override
  DayOfWeek read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return DayOfWeek.monday;
      case 1:
        return DayOfWeek.tuesday;
      case 2:
        return DayOfWeek.wednesday;
      case 3:
        return DayOfWeek.thursday;
      case 4:
        return DayOfWeek.friday;
      case 5:
        return DayOfWeek.saturday;
      case 6:
        return DayOfWeek.sunday;
      default:
        return DayOfWeek.monday;
    }
  }

  @override
  void write(BinaryWriter writer, DayOfWeek obj) {
    switch (obj) {
      case DayOfWeek.monday:
        writer.writeByte(0);
        break;
      case DayOfWeek.tuesday:
        writer.writeByte(1);
        break;
      case DayOfWeek.wednesday:
        writer.writeByte(2);
        break;
      case DayOfWeek.thursday:
        writer.writeByte(3);
        break;
      case DayOfWeek.friday:
        writer.writeByte(4);
        break;
      case DayOfWeek.saturday:
        writer.writeByte(5);
        break;
      case DayOfWeek.sunday:
        writer.writeByte(6);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DayOfWeekAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
