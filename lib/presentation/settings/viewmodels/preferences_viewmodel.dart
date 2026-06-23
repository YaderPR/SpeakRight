import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:speak_right/core/di/injection_container.dart';
import 'package:speak_right/core/services/notification_service.dart';
import 'package:speak_right/domain/repositories/user_preferences_repository.dart';
import 'package:speak_right/presentation/settings/state/preferences_state.dart';

final preferencesViewModelProvider = StateNotifierProvider<PreferencesViewModel, PreferencesState>((ref) {
  return PreferencesViewModel(
    repository: sl<UserPreferencesRepository>(),
    notificationService: sl<NotificationService>(),
  );
});

class PreferencesViewModel extends StateNotifier<PreferencesState> {
  final UserPreferencesRepository _repository;
  final NotificationService _notificationService;

  PreferencesViewModel({
    required UserPreferencesRepository repository,
    required NotificationService notificationService,
  })  : _repository = repository,
        _notificationService = notificationService,
        super(PreferencesState(
          dailyGoal: repository.getDailyGoal(),
          remindersEnabled: repository.getRemindersEnabled(),
          reminderTime: repository.getReminderTime(),
          autoStopVAD: repository.getAutoStopVAD(),
          noiseSuppression: repository.getNoiseSuppression(),
          languageCode: repository.getLanguageCode(),
        ));

  Future<void> setDailyGoal(int minutes) async {
    await _repository.saveDailyGoal(minutes);
    state = state.copyWith(dailyGoal: minutes);
  }

  Future<void> toggleReminders(bool enabled) async {
    await _repository.saveRemindersEnabled(enabled);
    
    if (enabled && state.reminderTime != null) {
      await _notificationService.scheduleDailyReminder(state.reminderTime!);
    } else {
      await _notificationService.cancelAllNotifications();
    }
    
    state = state.copyWith(remindersEnabled: enabled);
  }

  Future<void> setReminderTime(TimeOfDay time) async {
    await _repository.saveReminderTime(time);
    
    if (state.remindersEnabled) {
      await _notificationService.scheduleDailyReminder(time);
    }
    
    state = state.copyWith(reminderTime: time);
  }

  Future<void> toggleAutoStopVAD(bool enabled) async {
    await _repository.saveAutoStopVAD(enabled);
    state = state.copyWith(autoStopVAD: enabled);
  }

  Future<void> toggleNoiseSuppression(bool enabled) async {
    await _repository.saveNoiseSuppression(enabled);
    state = state.copyWith(noiseSuppression: enabled);
  }

  Future<void> setLanguage(String code) async {
    await _repository.saveLanguageCode(code);
    state = state.copyWith(languageCode: code);
  }
}
