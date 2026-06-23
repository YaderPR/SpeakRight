import 'package:speak_right/core/usecases/usecase.dart';
import 'package:speak_right/domain/entities/stt_model_package.dart';

abstract class STTModelRepository {
  /// Fetches all available models (both local and cloud-based).
  Future<Result<List<STTModelPackage>>> getAvailableModels();

  /// Gets the currently active model package.
  Future<Result<STTModelPackage?>> getActiveModel();

  /// Sets a model as the active one.
  Future<Result<void>> setActiveModel(String modelId);

  /// Downloads the specified model package from the cloud.
  /// Yields a stream of double values representing the progress (0.0 to 1.0).
  Stream<double> downloadModel(STTModelPackage package);

  /// Deletes the downloaded model files from local storage.
  Future<Result<void>> deleteModel(STTModelPackage package);

  /// Verifies if the local files for the package exist and are valid.
  Future<Result<bool>> isModelDownloaded(STTModelPackage package);
}
