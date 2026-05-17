import 'package:hive/hive.dart';
import 'package:equatable/equatable.dart';

part 'user_settings_model.g.dart';

@HiveType(typeId: 10)
class UserSettings extends Equatable {
  @HiveField(0)
  final int criticalWeekThreshold;

  @HiveField(1)
  final bool enableNotifications;

  @HiveField(2)
  final int defaultReminderHour;

  @HiveField(3)
  final int defaultReminderMinute;

  @HiveField(4)
  final double passingGrade;

  @HiveField(5)
  final String gradeScale;

  @HiveField(6)
  final bool isDarkMode;

  const UserSettings({
    this.criticalWeekThreshold = 5,
    this.enableNotifications = true,
    this.defaultReminderHour = 20,
    this.defaultReminderMinute = 0,
    this.passingGrade = 10.5,
    this.gradeScale = '0-20',
    this.isDarkMode = false,
  });

  UserSettings copyWith({
    int? criticalWeekThreshold,
    bool? enableNotifications,
    int? defaultReminderHour,
    int? defaultReminderMinute,
    double? passingGrade,
    String? gradeScale,
    bool? isDarkMode,
  }) {
    return UserSettings(
      criticalWeekThreshold:
          criticalWeekThreshold ?? this.criticalWeekThreshold,
      enableNotifications: enableNotifications ?? this.enableNotifications,
      defaultReminderHour: defaultReminderHour ?? this.defaultReminderHour,
      defaultReminderMinute:
          defaultReminderMinute ?? this.defaultReminderMinute,
      passingGrade: passingGrade ?? this.passingGrade,
      gradeScale: gradeScale ?? this.gradeScale,
      isDarkMode: isDarkMode ?? this.isDarkMode,
    );
  }

  @override
  List<Object?> get props => [
        criticalWeekThreshold,
        enableNotifications,
        defaultReminderHour,
        defaultReminderMinute,
        passingGrade,
        gradeScale,
        isDarkMode,
      ];
}
