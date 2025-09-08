import 'package:dose_reminder/src/services/settings_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// This provider will be responsible for managing the theme state.
final themeNotifierProvider = StateNotifierProvider<ThemeNotifier, ThemeMode>((ref) {
  final settingsService = ref.watch(settingsServiceProvider);
  return ThemeNotifier(settingsService);
});

class ThemeNotifier extends StateNotifier<ThemeMode> {
  final SettingsService _settingsService;

  // Initialize with system theme as default, then load the saved theme.
  ThemeNotifier(this._settingsService) : super(ThemeMode.system) {
    _loadTheme();
  }

  // Load the saved theme from shared_preferences.
  Future<void> _loadTheme() async {
    state = await _settingsService.getThemeMode();
  }

  // Change the theme and save the new preference.
  Future<void> setTheme(ThemeMode themeMode) async {
    if (state == themeMode) return;
    state = themeMode;
    await _settingsService.setThemeMode(themeMode);
  }
}

final localeNotifierProvider = StateNotifierProvider<LocaleNotifier, Locale?>((ref) {
  final settingsService = ref.watch(settingsServiceProvider);
  return LocaleNotifier(settingsService);
});

class LocaleNotifier extends StateNotifier<Locale?> {
  final SettingsService _settingsService;

  LocaleNotifier(this._settingsService) : super(null) {
    _loadLocale();
  }

  Future<void> _loadLocale() async {
    state = await _settingsService.getLocale();
  }

  Future<void> setLocale(Locale? locale) async {
    if (state == locale) return;
    state = locale;
    // Save null if locale is null, otherwise save languageCode
    await _settingsService.setLocale(locale);
  }
}