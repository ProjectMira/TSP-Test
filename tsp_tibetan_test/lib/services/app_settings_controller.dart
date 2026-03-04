import 'package:flutter/material.dart';
import 'dart:developer' as developer;

import 'notification_service.dart';
import 'preferences_service.dart';

class AppSettingsController extends ChangeNotifier {
  final PreferencesService _preferencesService;
  final NotificationService _notificationService;

  ThemeMode _themeMode = ThemeMode.system;
  InterfaceLanguage _interfaceLanguage = InterfaceLanguage.english;
  bool _reminderEnabled = false;
  TimeOfDay _reminderTime = const TimeOfDay(hour: 20, minute: 0);

  AppSettingsController({
    required PreferencesService preferencesService,
    required NotificationService notificationService,
  })  : _preferencesService = preferencesService,
        _notificationService = notificationService;

  ThemeMode get themeMode => _themeMode;
  InterfaceLanguage get interfaceLanguage => _interfaceLanguage;
  bool get reminderEnabled => _reminderEnabled;
  TimeOfDay get reminderTime => _reminderTime;

  String tr(String english, String tibetan) {
    return _interfaceLanguage == InterfaceLanguage.tibetan ? tibetan : english;
  }

  Future<void> initialize() async {
    _themeMode = await _preferencesService.loadThemeMode();
    _interfaceLanguage = await _preferencesService.loadInterfaceLanguage();
    _reminderEnabled = await _preferencesService.loadReminderEnabled();
    _reminderTime = await _preferencesService.loadReminderTime();
    if (_reminderEnabled) {
      try {
        await _notificationService.initialize();
        await _scheduleReminder();
      } catch (error, stackTrace) {
        developer.log(
          'Notification initialization failed',
          name: 'AppSettingsController',
          error: error,
          stackTrace: stackTrace,
        );
      }
    }
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode value) async {
    if (_themeMode == value) {
      return;
    }
    _themeMode = value;
    notifyListeners();
    await _preferencesService.saveThemeMode(value);
  }

  Future<void> setInterfaceLanguage(InterfaceLanguage value) async {
    if (_interfaceLanguage == value) {
      return;
    }
    _interfaceLanguage = value;
    notifyListeners();
    await _preferencesService.saveInterfaceLanguage(value);
    if (_reminderEnabled) {
      await _scheduleReminder();
    }
  }

  Future<void> setReminderEnabled(bool value) async {
    if (_reminderEnabled == value) {
      return;
    }
    _reminderEnabled = value;
    notifyListeners();
    await _preferencesService.saveReminderEnabled(value);
    if (value) {
      await _scheduleReminder();
    } else {
      await _notificationService.cancelDailyReminder();
    }
  }

  Future<void> setReminderTime(TimeOfDay value) async {
    _reminderTime = value;
    notifyListeners();
    await _preferencesService.saveReminderTime(value);
    if (_reminderEnabled) {
      await _scheduleReminder();
    }
  }

  Future<void> _scheduleReminder() async {
    await _notificationService.scheduleDailyReminder(
      hour: _reminderTime.hour,
      minute: _reminderTime.minute,
      title: tr('Time to practice TSP MCQs', 'TSP MCQ སྦྱོང་བརྡ་འཕྲིན།'),
      body: tr('Open the app and complete a quick practice set.',
          'ཉིན་རེའི་སྦྱོང་བ་ཞིག་བསྒྲུབས་པར་མཉེན་ཆས་ཁ་ཕྱེ།'),
    );
  }
}
