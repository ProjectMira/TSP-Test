import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum InterfaceLanguage { english, tibetan }

class PreferencesService {
  static const _themeModeKey = 'pref_theme_mode';
  static const _interfaceLanguageKey = 'pref_interface_language';
  static const _reminderEnabledKey = 'pref_reminder_enabled';
  static const _reminderHourKey = 'pref_reminder_hour';
  static const _reminderMinuteKey = 'pref_reminder_minute';

  Future<ThemeMode> loadThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getString(_themeModeKey) ?? ThemeMode.system.name;
    return ThemeMode.values.firstWhere(
      (mode) => mode.name == value,
      orElse: () => ThemeMode.system,
    );
  }

  Future<void> saveThemeMode(ThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeModeKey, mode.name);
  }

  Future<InterfaceLanguage> loadInterfaceLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getString(_interfaceLanguageKey) ?? InterfaceLanguage.english.name;
    return InterfaceLanguage.values.firstWhere(
      (lang) => lang.name == value,
      orElse: () => InterfaceLanguage.english,
    );
  }

  Future<void> saveInterfaceLanguage(InterfaceLanguage language) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_interfaceLanguageKey, language.name);
  }

  Future<bool> loadReminderEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_reminderEnabledKey) ?? false;
  }

  Future<void> saveReminderEnabled(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_reminderEnabledKey, value);
  }

  Future<TimeOfDay> loadReminderTime() async {
    final prefs = await SharedPreferences.getInstance();
    final hour = prefs.getInt(_reminderHourKey) ?? 20;
    final minute = prefs.getInt(_reminderMinuteKey) ?? 0;
    return TimeOfDay(hour: hour, minute: minute);
  }

  Future<void> saveReminderTime(TimeOfDay value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_reminderHourKey, value.hour);
    await prefs.setInt(_reminderMinuteKey, value.minute);
  }
}
