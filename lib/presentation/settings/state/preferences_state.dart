import 'package:flutter/material.dart';

class PreferencesState {
  final int dailyGoal;
  final bool remindersEnabled;
  final TimeOfDay? reminderTime;
  final bool autoStopVAD;
  final bool noiseSuppression;

  const PreferencesState({
    required this.dailyGoal,
    required this.remindersEnabled,
    required this.reminderTime,
    required this.autoStopVAD,
    required this.noiseSuppression,
  });

  PreferencesState copyWith({
    int? dailyGoal,
    bool? remindersEnabled,
    TimeOfDay? reminderTime,
    bool? autoStopVAD,
    bool? noiseSuppression,
  }) {
    return PreferencesState(
      dailyGoal: dailyGoal ?? this.dailyGoal,
      remindersEnabled: remindersEnabled ?? this.remindersEnabled,
      reminderTime: reminderTime ?? this.reminderTime,
      autoStopVAD: autoStopVAD ?? this.autoStopVAD,
      noiseSuppression: noiseSuppression ?? this.noiseSuppression,
    );
  }
}
