// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_settings_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AppSettingsAdapter extends TypeAdapter<AppSettings> {
  @override
  final int typeId = 12;

  @override
  AppSettings read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AppSettings(
      themeMode: fields[0] as ThemeMode,
      notificationsEnabled: fields[1] as bool,
      widgetEnabled: fields[2] as bool,
      language: fields[3] as String,
      lastUpdated: fields[4] as DateTime?,
      showSaturday: fields[5] as bool,
      showSunday: fields[6] as bool,
      userName: fields[7] as String?,
      dailySummaryEnabled: fields[8] as bool,
      criticalWeekEnabled: fields[9] as bool,
      classReminderEnabled: fields[10] as bool,
      lowGradeAlertEnabled: fields[11] as bool,
      hasSeenTour: fields[12] as bool,
      gradeMinValue: fields[13] as double,
      gradeMaxValue: fields[14] as double,
      gradePassingValue: fields[15] as double,
    );
  }

  @override
  void write(BinaryWriter writer, AppSettings obj) {
    writer
      ..writeByte(16)
      ..writeByte(0)
      ..write(obj.themeMode)
      ..writeByte(1)
      ..write(obj.notificationsEnabled)
      ..writeByte(2)
      ..write(obj.widgetEnabled)
      ..writeByte(3)
      ..write(obj.language)
      ..writeByte(4)
      ..write(obj.lastUpdated)
      ..writeByte(5)
      ..write(obj.showSaturday)
      ..writeByte(6)
      ..write(obj.showSunday)
      ..writeByte(7)
      ..write(obj.userName)
      ..writeByte(8)
      ..write(obj.dailySummaryEnabled)
      ..writeByte(9)
      ..write(obj.criticalWeekEnabled)
      ..writeByte(10)
      ..write(obj.classReminderEnabled)
      ..writeByte(11)
      ..write(obj.lowGradeAlertEnabled)
      ..writeByte(12)
      ..write(obj.hasSeenTour)
      ..writeByte(13)
      ..write(obj.gradeMinValue)
      ..writeByte(14)
      ..write(obj.gradeMaxValue)
      ..writeByte(15)
      ..write(obj.gradePassingValue);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppSettingsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ThemeModeAdapter extends TypeAdapter<ThemeMode> {
  @override
  final int typeId = 11;

  @override
  ThemeMode read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return ThemeMode.light;
      case 1:
        return ThemeMode.dark;
      case 2:
        return ThemeMode.system;
      default:
        return ThemeMode.light;
    }
  }

  @override
  void write(BinaryWriter writer, ThemeMode obj) {
    switch (obj) {
      case ThemeMode.light:
        writer.writeByte(0);
        break;
      case ThemeMode.dark:
        writer.writeByte(1);
        break;
      case ThemeMode.system:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ThemeModeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
