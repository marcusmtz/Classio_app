import 'package:hive/hive.dart';
import '../models/app_settings_model.dart';

class AppSettingsRepository {
  static const String _boxName = 'app_settings';
  static const String _settingsKey = 'settings';

  Box<AppSettings>? _box;

  Future<void> init() async {
    _box = await Hive.openBox<AppSettings>(_boxName);
  }

  AppSettings getSettings() {
    if (_box == null) {
      return const AppSettings();
    }
    return _box!.get(_settingsKey, defaultValue: const AppSettings())!;
  }

  Future<void> saveSettings(AppSettings settings) async {
    if (_box == null) {
      await init();
    }
    await _box!.put(_settingsKey, settings);
  }

  Future<void> updateThemeMode(ThemeMode themeMode) async {
    final settings = getSettings();
    await saveSettings(settings.copyWith(
      themeMode: themeMode,
      lastUpdated: DateTime.now(),
    ));
  }

  Future<void> updateNotificationsEnabled(bool enabled) async {
    final settings = getSettings();
    await saveSettings(settings.copyWith(
      notificationsEnabled: enabled,
      lastUpdated: DateTime.now(),
    ));
  }

  Future<void> updateWidgetEnabled(bool enabled) async {
    final settings = getSettings();
    await saveSettings(settings.copyWith(
      widgetEnabled: enabled,
      lastUpdated: DateTime.now(),
    ));
  }

  Future<void> updateLanguage(String language) async {
    final settings = getSettings();
    await saveSettings(settings.copyWith(
      language: language,
      lastUpdated: DateTime.now(),
    ));
  }
}
