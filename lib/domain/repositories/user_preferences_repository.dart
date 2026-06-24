import 'package:flutter/material.dart';

abstract class UserPreferencesRepository {
  // Daily Goal (minutes or words)
  int getDailyGoal();
  Future<void> saveDailyGoal(int value);

  // Reminders
  bool getRemindersEnabled();
  Future<void> saveRemindersEnabled(bool enabled);
  
  TimeOfDay? getReminderTime();
  Future<void> saveReminderTime(TimeOfDay time);

  // Audio Settings
  bool getAutoStopVAD();
  Future<void> saveAutoStopVAD(bool enabled);

  bool getNoiseSuppression();
  Future<void> saveNoiseSuppression(bool enabled);

  // Localization
  String getLanguageCode();
  Future<void> saveLanguageCode(String code);
}
