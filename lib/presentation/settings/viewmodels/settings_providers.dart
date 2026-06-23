import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:speak_right/core/di/injection_container.dart';
import 'package:speak_right/domain/usecases/delete_model_usecase.dart';
import 'package:speak_right/domain/usecases/download_model_usecase.dart';
import 'package:speak_right/domain/usecases/get_active_model_usecase.dart';
import 'package:speak_right/domain/usecases/get_available_models_usecase.dart';
import 'package:speak_right/domain/usecases/set_active_model_usecase.dart';
import 'package:speak_right/presentation/settings/state/settings_state.dart';
import 'package:speak_right/presentation/settings/viewmodels/settings_viewmodel.dart';

final settingsViewModelProvider = StateNotifierProvider<SettingsViewModel, SettingsState>((ref) {
  return SettingsViewModel(
    getAvailableModelsUseCase: sl<GetAvailableModelsUseCase>(),
    getActiveModelUseCase: sl<GetActiveModelUseCase>(),
    setActiveModelUseCase: sl<SetActiveModelUseCase>(),
    downloadModelUseCase: sl<DownloadModelUseCase>(),
    deleteModelUseCase: sl<DeleteModelUseCase>(),
  );
});
