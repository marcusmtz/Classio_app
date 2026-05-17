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

  const AppSettings({
    this.themeMode = ThemeMode.system,
    this.notificationsEnabled = true,
    this.widgetEnabled = true,
    this.language = 'es',
    this.lastUpdated,
    this.showSaturday = true,
    this.showSunday = true,
  });

  AppSettings copyWith({
    ThemeMode? themeMode,
    bool? notificationsEnabled,
    bool? widgetEnabled,
    String? language,
    DateTime? lastUpdated,
    bool? showSaturday,
    bool? showSunday,
  }) {
    return AppSettings(
      themeMode: themeMode ?? this.themeMode,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      widgetEnabled: widgetEnabled ?? this.widgetEnabled,
      language: language ?? this.language,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      showSaturday: showSaturday ?? this.showSaturday,
      showSunday: showSunday ?? this.showSunday,
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
      ];
}
