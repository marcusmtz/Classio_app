import 'package:hive/hive.dart';
import '../models/app_settings_model.dart';

class AppSettingsRepository {
  static const String _boxName = 'app_settings';
  static const String _settingsKey = 'settings';

  Box<AppSettings> get _box => Hive.box<AppSettings>(_boxName);

  AppSettings getSettings() {
    try {
      final settings =
          _box.get(_settingsKey, defaultValue: const AppSettings())!;
      print('📱 AppSettings loaded: themeMode=${settings.themeMode}');
      return settings;
    } catch (e) {
      print('⚠️ Error loading AppSettings: $e');
      return const AppSettings();
    }
  }

  Future<void> saveSettings(AppSettings settings) async {
    await _box.put(_settingsKey, settings);
    print('💾 AppSettings saved: themeMode=${settings.themeMode}');
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

  Future<void> updateShowSaturday(bool show) async {
    final settings = getSettings();
    await saveSettings(settings.copyWith(
      showSaturday: show,
      lastUpdated: DateTime.now(),
    ));
  }

  Future<void> updateShowSunday(bool show) async {
    final settings = getSettings();
    await saveSettings(settings.copyWith(
      showSunday: show,
      lastUpdated: DateTime.now(),
    ));
  }
}
