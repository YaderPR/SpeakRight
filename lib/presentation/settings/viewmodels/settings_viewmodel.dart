import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:speak_right/core/usecases/usecase.dart';
import 'package:speak_right/domain/entities/stt_model_package.dart';
import 'package:speak_right/domain/usecases/delete_model_usecase.dart';
import 'package:speak_right/domain/usecases/download_model_usecase.dart';
import 'package:speak_right/domain/usecases/get_active_model_usecase.dart';
import 'package:speak_right/domain/usecases/get_available_models_usecase.dart';
import 'package:speak_right/domain/usecases/set_active_model_usecase.dart';
import 'package:speak_right/presentation/settings/state/settings_state.dart';

class SettingsViewModel extends StateNotifier<SettingsState> {
  final GetAvailableModelsUseCase _getAvailableModelsUseCase;
  final GetActiveModelUseCase _getActiveModelUseCase;
  final SetActiveModelUseCase _setActiveModelUseCase;
  final DownloadModelUseCase _downloadModelUseCase;
  final DeleteModelUseCase _deleteModelUseCase;

  StreamSubscription<double>? _downloadSubscription;

  SettingsViewModel({
    required GetAvailableModelsUseCase getAvailableModelsUseCase,
    required GetActiveModelUseCase getActiveModelUseCase,
    required SetActiveModelUseCase setActiveModelUseCase,
    required DownloadModelUseCase downloadModelUseCase,
    required DeleteModelUseCase deleteModelUseCase,
  })  : _getAvailableModelsUseCase = getAvailableModelsUseCase,
        _getActiveModelUseCase = getActiveModelUseCase,
        _setActiveModelUseCase = setActiveModelUseCase,
        _downloadModelUseCase = downloadModelUseCase,
        _deleteModelUseCase = deleteModelUseCase,
        super(const SettingsState()) {
    loadSettings();
  }

  Future<void> loadSettings() async {
    state = state.copyWith(isLoading: true);

    final modelsResult = await _getAvailableModelsUseCase(NoParams());
    final activeResult = await _getActiveModelUseCase(NoParams());

    if (modelsResult is Success<List<STTModelPackage>> &&
        activeResult is Success<STTModelPackage?>) {
      state = state.copyWith(
        availableModels: modelsResult.data,
        activeModel: activeResult.data,
        isLoading: false,
      );
    } else {
      state = state.copyWith(
        isLoading: false,
        error: 'Error al cargar las configuraciones de voz.',
      );
    }
  }

  Future<void> selectActiveModel(String modelId) async {
    state = state.copyWith(isLoading: true);

    // Verify if chosen model is downloaded
    final model = state.availableModels.firstWhere((m) => m.id == modelId);
    if (!model.isDownloaded) {
      state = state.copyWith(
        isLoading: false,
        error: 'Debes descargar el modelo primero para activarlo.',
      );
      return;
    }

    final result = await _setActiveModelUseCase(modelId);
    if (result is Success<void>) {
      // Reload settings to update UI checkmarks
      await loadSettings();
    } else {
      state = state.copyWith(
        isLoading: false,
        error: 'No se pudo guardar la selección del modelo.',
      );
    }
  }

  void startDownload(STTModelPackage package) {
    if (state.downloadingModelId != null) {
      state = state.copyWith(error: 'Ya hay una descarga en progreso.');
      return;
    }

    state = state.copyWith(
      downloadingModelId: package.id,
      downloadProgress: 0.0,
    );

    _downloadSubscription?.cancel();
    _downloadSubscription = _downloadModelUseCase(package).listen(
      (progress) {
        state = state.copyWith(downloadProgress: progress);
      },
      onError: (err) {
        state = state.copyWith(
          error: 'Fallo al descargar el modelo: $err',
          downloadingModelId: null,
          downloadProgress: 0.0,
        );
      },
      onDone: () async {
        // Complete download
        state = state.clearDownloadState();
        await loadSettings(); // Reload to refresh downloaded flag
      },
    );
  }

  Future<void> removeModel(STTModelPackage package) async {
    if (package.isActive) {
      state = state.copyWith(error: 'No puedes borrar el modelo que está actualmente activo.');
      return;
    }

    state = state.copyWith(isLoading: true);
    final result = await _deleteModelUseCase(package);

    if (result is Success<void>) {
      await loadSettings();
    } else {
      state = state.copyWith(
        isLoading: false,
        error: 'No se pudieron borrar los archivos del modelo.',
      );
    }
  }

  void dismissError() {
    state = state.clearError();
  }

  @override
  void dispose() {
    _downloadSubscription?.cancel();
    super.dispose();
  }
}
