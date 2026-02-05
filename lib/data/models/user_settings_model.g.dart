// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_settings_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UserSettingsAdapter extends TypeAdapter<UserSettings> {
  @override
  final int typeId = 10;

  @override
  UserSettings read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserSettings(
      criticalWeekThreshold: fields[0] as int,
      enableNotifications: fields[1] as bool,
      defaultReminderHour: fields[2] as int,
      defaultReminderMinute: fields[3] as int,
      passingGrade: fields[4] as double,
      gradeScale: fields[5] as String,
      isDarkMode: fields[6] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, UserSettings obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.criticalWeekThreshold)
      ..writeByte(1)
      ..write(obj.enableNotifications)
      ..writeByte(2)
      ..write(obj.defaultReminderHour)
      ..writeByte(3)
      ..write(obj.defaultReminderMinute)
      ..writeByte(4)
      ..write(obj.passingGrade)
      ..writeByte(5)
      ..write(obj.gradeScale)
      ..writeByte(6)
      ..write(obj.isDarkMode);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserSettingsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
