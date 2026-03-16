import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/app_settings_model.dart';
import '../../data/repositories/app_settings_repository.dart';

final appSettingsRepositoryProvider =
    Provider((ref) => AppSettingsRepository());

final appSettingsProvider =
    StateNotifierProvider<AppSettingsNotifier, AppSettings>((ref) {
  final notifier = AppSettingsNotifier(ref.read(appSettingsRepositoryProvider));
  notifier.loadSettings();
  return notifier;
});

class AppSettingsNotifier extends StateNotifier<AppSettings> {
  final AppSettingsRepository _repository;

  AppSettingsNotifier(this._repository) : super(const AppSettings());

  void loadSettings() {
    state = _repository.getSettings();
  }

  Future<void> updateThemeMode(ThemeMode themeMode) async {
    await _repository.updateThemeMode(themeMode);
    state = state.copyWith(themeMode: themeMode);
  }

  Future<void> updateNotificationsEnabled(bool enabled) async {
    await _repository.updateNotificationsEnabled(enabled);
    state = state.copyWith(notificationsEnabled: enabled);
  }

  Future<void> updateWidgetEnabled(bool enabled) async {
    await _repository.updateWidgetEnabled(enabled);
    state = state.copyWith(widgetEnabled: enabled);
  }

  Future<void> updateLanguage(String language) async {
    await _repository.updateLanguage(language);
    state = state.copyWith(language: language);
  }

  Future<void> updateShowSaturday(bool show) async {
    await _repository.updateShowSaturday(show);
    state = state.copyWith(showSaturday: show);
  }

  Future<void> updateShowSunday(bool show) async {
    await _repository.updateShowSunday(show);
    state = state.copyWith(showSunday: show);
  }
}
