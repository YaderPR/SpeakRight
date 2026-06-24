import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:speak_right/domain/repositories/user_preferences_repository.dart';

class SharedPrefsUserPreferencesRepositoryImpl implements UserPreferencesRepository {
  final SharedPreferences _prefs;

  // Keys
  static const _kDailyGoal = 'daily_goal';
  static const _kRemindersEnabled = 'reminders_enabled';
  static const _kReminderHour = 'reminder_hour';
  static const _kReminderMinute = 'reminder_minute';
  static const _kAutoStopVAD = 'auto_stop_vad';
  static const _kNoiseSuppression = 'noise_suppression';
  static const _kLanguageCode = 'language_code';

  SharedPrefsUserPreferencesRepositoryImpl(this._prefs);

  @override
  int getDailyGoal() {
    return _prefs.getInt(_kDailyGoal) ?? 15; // default 15 minutes
  }

  @override
  Future<void> saveDailyGoal(int value) async {
    await _prefs.setInt(_kDailyGoal, value);
  }

  @override
  bool getRemindersEnabled() {
    return _prefs.getBool(_kRemindersEnabled) ?? false;
  }

  @override
  Future<void> saveRemindersEnabled(bool enabled) async {
    await _prefs.setBool(_kRemindersEnabled, enabled);
  }

  @override
  TimeOfDay? getReminderTime() {
    final hour = _prefs.getInt(_kReminderHour);
    final minute = _prefs.getInt(_kReminderMinute);
    if (hour != null && minute != null) {
      return TimeOfDay(hour: hour, minute: minute);
    }
    return null;
  }

  @override
  Future<void> saveReminderTime(TimeOfDay time) async {
    await _prefs.setInt(_kReminderHour, time.hour);
    await _prefs.setInt(_kReminderMinute, time.minute);
  }

  @override
  bool getAutoStopVAD() {
    return _prefs.getBool(_kAutoStopVAD) ?? true; // default true
  }

  @override
  Future<void> saveAutoStopVAD(bool enabled) async {
    await _prefs.setBool(_kAutoStopVAD, enabled);
  }

  @override
  bool getNoiseSuppression() {
    return _prefs.getBool(_kNoiseSuppression) ?? false; // default false
  }

  @override
  Future<void> saveNoiseSuppression(bool enabled) async {
    await _prefs.setBool(_kNoiseSuppression, enabled);
  }

  @override
  String getLanguageCode() {
    return _prefs.getString(_kLanguageCode) ?? 'en';
  }

  @override
  Future<void> saveLanguageCode(String code) async {
    await _prefs.setString(_kLanguageCode, code);
  }
}
