import 'package:hive/hive.dart';
import 'package:equatable/equatable.dart';

part 'app_settings_model.g.dart';

@HiveType(typeId: 11)
enum ThemeMode {
  @HiveField(0)
  light,
  @HiveField(1)
  dark,
  @HiveField(2)
  system,
}

@HiveType(typeId: 12)
class AppSettings extends Equatable {
  @HiveField(0)
  final ThemeMode themeMode;

  @HiveField(1)
  final bool notificationsEnabled;

  @HiveField(2)
  final bool widgetEnabled;

  @HiveField(3)
  final String language;

  @HiveField(4)
  final DateTime? lastUpdated;

  @HiveField(5)
  final bool showSaturday;

  @HiveField(6)
  final bool showSunday;

  @HiveField(7)
  final String? userName;

  @HiveField(8)
  final bool dailySummaryEnabled;

  @HiveField(9)
  final bool criticalWeekEnabled;

  @HiveField(10)
  final bool classReminderEnabled;

  @HiveField(11)
  final bool lowGradeAlertEnabled;

  @HiveField(12)
  final bool hasSeenTour;

  @HiveField(13)
  final double gradeMinValue;

  @HiveField(14)
  final double gradeMaxValue;

  @HiveField(15)
  final double gradePassingValue;

  @HiveField(16)
  final String? activeSemesterId;

  const AppSettings({
    this.themeMode = ThemeMode.system,
    this.notificationsEnabled = true,
    this.widgetEnabled = true,
    this.language = 'es',
    this.lastUpdated,
    this.showSaturday = true,
    this.showSunday = true,
    this.userName,
    this.dailySummaryEnabled = true,
    this.criticalWeekEnabled = true,
    this.classReminderEnabled = true,
    this.lowGradeAlertEnabled = true,
    this.hasSeenTour = false,
    this.gradeMinValue = 1.0,
    this.gradeMaxValue = 7.0,
    this.gradePassingValue = 4.0,
    this.activeSemesterId,
  });

  AppSettings copyWith({
    ThemeMode? themeMode,
    bool? notificationsEnabled,
    bool? widgetEnabled,
    String? language,
    DateTime? lastUpdated,
    bool? showSaturday,
    bool? showSunday,
    String? userName,
    bool? dailySummaryEnabled,
    bool? criticalWeekEnabled,
    bool? classReminderEnabled,
    bool? lowGradeAlertEnabled,
    bool? hasSeenTour,
    double? gradeMinValue,
    double? gradeMaxValue,
    double? gradePassingValue,
    String? activeSemesterId,
  }) {
    return AppSettings(
      themeMode: themeMode ?? this.themeMode,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      widgetEnabled: widgetEnabled ?? this.widgetEnabled,
      language: language ?? this.language,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      showSaturday: showSaturday ?? this.showSaturday,
      showSunday: showSunday ?? this.showSunday,
      userName: userName ?? this.userName,
      dailySummaryEnabled: dailySummaryEnabled ?? this.dailySummaryEnabled,
      criticalWeekEnabled: criticalWeekEnabled ?? this.criticalWeekEnabled,
      classReminderEnabled: classReminderEnabled ?? this.classReminderEnabled,
      lowGradeAlertEnabled: lowGradeAlertEnabled ?? this.lowGradeAlertEnabled,
      hasSeenTour: hasSeenTour ?? this.hasSeenTour,
      gradeMinValue: gradeMinValue ?? this.gradeMinValue,
      gradeMaxValue: gradeMaxValue ?? this.gradeMaxValue,
      gradePassingValue: gradePassingValue ?? this.gradePassingValue,
      activeSemesterId: activeSemesterId ?? this.activeSemesterId,
    );
  }

  AppSettings copyWithNullableActiveSemester(String? activeSemesterId) {
    return AppSettings(
      themeMode: themeMode,
      notificationsEnabled: notificationsEnabled,
      widgetEnabled: widgetEnabled,
      language: language,
      lastUpdated: lastUpdated,
      showSaturday: showSaturday,
      showSunday: showSunday,
      userName: userName,
      dailySummaryEnabled: dailySummaryEnabled,
      criticalWeekEnabled: criticalWeekEnabled,
      classReminderEnabled: classReminderEnabled,
      lowGradeAlertEnabled: lowGradeAlertEnabled,
      hasSeenTour: hasSeenTour,
      gradeMinValue: gradeMinValue,
      gradeMaxValue: gradeMaxValue,
      gradePassingValue: gradePassingValue,
      activeSemesterId: activeSemesterId,
    );
  }

  @override
  List<Object?> get props => [
        themeMode,
        notificationsEnabled,
        widgetEnabled,
        language,
        lastUpdated,
        showSaturday,
        showSunday,
        userName,
        dailySummaryEnabled,
        criticalWeekEnabled,
        classReminderEnabled,
        lowGradeAlertEnabled,
        hasSeenTour,
        gradeMinValue,
        gradeMaxValue,
        gradePassingValue,
        activeSemesterId,
      ];
}
