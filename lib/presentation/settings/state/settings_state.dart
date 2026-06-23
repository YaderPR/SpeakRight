import 'package:speak_right/domain/entities/stt_model_package.dart';

class SettingsState {
  final List<STTModelPackage> availableModels;
  final STTModelPackage? activeModel;
  final bool isLoading;
  final String? error;
  final String? downloadingModelId;
  final double downloadProgress;

  const SettingsState({
    this.availableModels = const [],
    this.activeModel,
    this.isLoading = false,
    this.error,
    this.downloadingModelId,
    this.downloadProgress = 0.0,
  });

  SettingsState copyWith({
    List<STTModelPackage>? availableModels,
    STTModelPackage? activeModel,
    bool? isLoading,
    String? error,
    String? downloadingModelId,
    double? downloadProgress,
  }) {
    return SettingsState(
      availableModels: availableModels ?? this.availableModels,
      activeModel: activeModel ?? this.activeModel,
      isLoading: isLoading ?? this.isLoading,
      error: error, // Can clear error by setting to null implicitly if not passed, but let's allow setting it
      downloadingModelId: downloadingModelId ?? this.downloadingModelId, // If we want to clear it, we'll pass null or handle it in ViewModel
      downloadProgress: downloadProgress ?? this.downloadProgress,
    );
  }

  // Clear downloading state explicitly
  SettingsState clearDownloadState() {
    return SettingsState(
      availableModels: availableModels,
      activeModel: activeModel,
      isLoading: isLoading,
      error: error,
      downloadingModelId: null,
      downloadProgress: 0.0,
    );
  }

  SettingsState clearError() {
    return SettingsState(
      availableModels: availableModels,
      activeModel: activeModel,
      isLoading: isLoading,
      error: null,
      downloadingModelId: downloadingModelId,
      downloadProgress: downloadProgress,
    );
  }
}
