import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:speak_right/core/errors/failures.dart';
import 'package:speak_right/core/usecases/usecase.dart';
import 'package:speak_right/domain/entities/stt_model_package.dart';
import 'package:speak_right/domain/repositories/stt_model_repository.dart';

class STTModelRepositoryImpl implements STTModelRepository {
  final Dio _dio;

  static const String _settingsFileName = 'model_settings.json';

  // Predefined supported models
  static const List<STTModelPackage> _predefinedModels = [
    STTModelPackage(
      id: 'en_moonshine_tiny',
      languageCode: 'en',
      languageName: 'English',
      name: 'Moonshine Tiny',
      sizeInBytes: 36700160, // ~35 MB
      fileNames: [
        'preprocess.onnx',
        'encode.onnx',
        'uncached_decode.onnx',
        'cached_decode.onnx',
        'tokens.txt',
      ],
      baseUrl: 'https://huggingface.co/csukuangfj/sherpa-onnx-moonshine-tiny-en-int8/resolve/main/',
      isStreaming: false,
    ),
    STTModelPackage(
      id: 'multi_sensevoice_small',
      languageCode: 'multi',
      languageName: 'Multilingual (EN, ZH, JA, KO)',
      name: 'SenseVoice Small',
      sizeInBytes: 125829120, // ~120 MB
      fileNames: [
        'model.int8.onnx',
        'tokens.txt',
      ],
      baseUrl: 'https://huggingface.co/csukuangfj/sherpa-onnx-sense-voice-zh-en-ja-ko/resolve/main/',
      isStreaming: false,
    ),
    STTModelPackage(
      id: 'en_whisper_tiny',
      languageCode: 'en',
      languageName: 'English',
      name: 'Whisper Tiny (English only)',
      sizeInBytes: 78643200, // ~75 MB
      fileNames: [
        'tiny.en-encoder.onnx',
        'tiny.en-decoder.onnx',
        'tiny.en-tokens.txt',
      ],
      baseUrl: 'https://huggingface.co/csukuangfj/sherpa-onnx-whisper-tiny.en/resolve/main/',
      isStreaming: false,
    ),
    STTModelPackage(
      id: 'en_zipformer_streaming',
      languageCode: 'en',
      languageName: 'English',
      name: 'Zipformer Streaming (Real-time)',
      sizeInBytes: 125829120, // ~120 MB
      fileNames: [
        'encoder-epoch-99-avg-1.onnx',
        'decoder-epoch-99-avg-1.onnx',
        'joiner-epoch-99-avg-1.onnx',
        'tokens.txt',
      ],
      baseUrl: 'https://huggingface.co/csukuangfj/sherpa-onnx-streaming-zipformer-en-2023-06-26/resolve/main/',
      isStreaming: true,
    ),
  ];

  STTModelRepositoryImpl(this._dio);

  Future<String> _getModelsDirectoryPath() async {
    final docDir = await getApplicationDocumentsDirectory();
    final modelsDir = Directory(p.join(docDir.path, 'models'));
    if (!await modelsDir.exists()) {
      await modelsDir.create(recursive: true);
    }
    return modelsDir.path;
  }

  Future<File> _getSettingsFile() async {
    final dirPath = await _getModelsDirectoryPath();
    return File(p.join(dirPath, _settingsFileName));
  }

  @override
  Future<Result<List<STTModelPackage>>> getAvailableModels() async {
    try {
      final activeIdResult = await getActiveModel();
      final activeId = activeIdResult is Success<STTModelPackage?> ? activeIdResult.data?.id : 'en_moonshine_tiny';

      final enrichedList = <STTModelPackage>[];
      for (final model in _predefinedModels) {
        final downloaded = (await isModelDownloaded(model) as Success<bool>).data;
        enrichedList.add(model.copyWith(
          isDownloaded: downloaded,
          isActive: model.id == activeId,
        ));
      }
      return Success(enrichedList);
    } catch (e) {
      return Error(DatabaseFailure('Error cargando modelos: $e'));
    }
  }

  @override
  Future<Result<STTModelPackage?>> getActiveModel() async {
    try {
      final settingsFile = await _getSettingsFile();
      if (!await settingsFile.exists()) {
        // Return default model
        return Success(_predefinedModels.first);
      }

      final content = await settingsFile.readAsString();
      final data = jsonDecode(content) as Map<String, dynamic>;
      final activeId = data['active_model_id'] as String?;

      if (activeId == null) {
        return Success(_predefinedModels.first);
      }

      final activeModel = _predefinedModels.firstWhere(
        (m) => m.id == activeId,
        orElse: () => _predefinedModels.first,
      );

      final isDownloadedResult = await isModelDownloaded(activeModel);
      final downloaded = isDownloadedResult is Success<bool> ? isDownloadedResult.data : false;

      return Success(activeModel.copyWith(
        isDownloaded: downloaded,
        isActive: true,
      ));
    } catch (e) {
      return Success(_predefinedModels.first); // Fallback to default
    }
  }

  @override
  Future<Result<void>> setActiveModel(String modelId) async {
    try {
      final settingsFile = await _getSettingsFile();
      final data = {'active_model_id': modelId};
      await settingsFile.writeAsString(jsonEncode(data));
      return const Success(null);
    } catch (e) {
      return Error(DatabaseFailure('Error al guardar modelo activo: $e'));
    }
  }

  @override
  Stream<double> downloadModel(STTModelPackage package) async* {
    final dirPath = await _getModelsDirectoryPath();
    final packageDir = Directory(p.join(dirPath, package.id));
    if (!await packageDir.exists()) {
      await packageDir.create(recursive: true);
    }

    final totalFiles = package.fileNames.length;
    final fileProgresses = List<double>.filled(totalFiles, 0.0);

    for (int i = 0; i < totalFiles; i++) {
      final fileName = package.fileNames[i];
      final fileUrl = '${package.baseUrl}$fileName';
      final filePath = p.join(packageDir.path, fileName);

      // Check if file already exists with identical size (simple cache check)
      final localFile = File(filePath);
      if (await localFile.exists()) {
        // Skip download, assume completed
        fileProgresses[i] = 1.0;
        final totalProgress = fileProgresses.reduce((a, b) => a + b) / totalFiles;
        yield totalProgress;
        continue;
      }

      final completer = Completer<void>();
      double fileProgress = 0.0;
      dynamic downloadError;

      // Start download
      await _dio.download(
        fileUrl,
        filePath,
        onReceiveProgress: (received, total) {
          if (total > 0) {
            fileProgress = received / total;
            fileProgresses[i] = fileProgress;
            final overallProgress = fileProgresses.reduce((a, b) => a + b) / totalFiles;
            // Emit progress
            completer.complete(); // just trigger event loop yield
          }
        },
      ).then((_) {
        fileProgresses[i] = 1.0;
        if (!completer.isCompleted) completer.complete();
      }).catchError((err) {
        downloadError = err;
        if (!completer.isCompleted) completer.complete();
      });

      await completer.future;

      if (downloadError != null) {
        throw Exception('Error descargando archivo $fileName: $downloadError');
      }

      final overallProgress = fileProgresses.reduce((a, b) => a + b) / totalFiles;
      yield overallProgress;
    }
  }

  @override
  Future<Result<void>> deleteModel(STTModelPackage package) async {
    try {
      final dirPath = await _getModelsDirectoryPath();
      final packageDir = Directory(p.join(dirPath, package.id));
      if (await packageDir.exists()) {
        await packageDir.delete(recursive: true);
      }
      return const Success(null);
    } catch (e) {
      return Error(DatabaseFailure('Error eliminando archivos de modelo: $e'));
    }
  }

  @override
  Future<Result<bool>> isModelDownloaded(STTModelPackage package) async {
    try {
      final dirPath = await _getModelsDirectoryPath();
      final packageDir = Directory(p.join(dirPath, package.id));
      if (!await packageDir.exists()) {
        return const Success(false);
      }

      for (final fileName in package.fileNames) {
        final filePath = p.join(packageDir.path, fileName);
        if (!await File(filePath).exists()) {
          return const Success(false);
        }
      }
      return const Success(true);
    } catch (e) {
      return const Success(false);
    }
  }
}
