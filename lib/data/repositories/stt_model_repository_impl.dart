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

import 'package:flutter/services.dart' show rootBundle;

class STTModelRepositoryImpl implements STTModelRepository {
  final Dio _dio;

  static const String _settingsFileName = 'model_settings.json';

  // Cache for loaded models
  List<STTModelPackage> _cachedModels = [];

  Future<List<STTModelPackage>> _loadModels() async {
    if (_cachedModels.isNotEmpty) return _cachedModels;
    
    try {
      // Future enhancement: Try fetching from a remote JSON URL first using _dio.get()
      
      // Fallback to bundled assets
      final jsonString = await rootBundle.loadString('assets/models.json');
      final jsonData = jsonDecode(jsonString) as Map<String, dynamic>;
      final modelsList = jsonData['models'] as List<dynamic>;
      
      _cachedModels = modelsList.map((m) {
        return STTModelPackage(
          id: m['id'],
          languageCode: m['languageCode'],
          languageName: m['languageName'],
          name: m['name'],
          sizeInBytes: m['sizeInBytes'],
          fileNames: List<String>.from(m['fileNames']),
          baseUrl: m['baseUrl'],
          isStreaming: m['isStreaming'],
        );
      }).toList();
      
      return _cachedModels;
    } catch (e) {
      // Ultimate fallback if something fails
      return [];
    }
  }

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
      
      final models = await _loadModels();

      final enrichedList = <STTModelPackage>[];
      for (final model in models) {
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
      final models = await _loadModels();
      final defaultModel = models.isNotEmpty ? models.first : null;
      
      final settingsFile = await _getSettingsFile();
      if (!await settingsFile.exists()) {
        return Success(defaultModel);
      }

      final content = await settingsFile.readAsString();
      final data = jsonDecode(content) as Map<String, dynamic>;
      final activeId = data['active_model_id'] as String?;

      if (activeId == null) {
        return Success(defaultModel);
      }

      final activeModel = models.firstWhere(
        (m) => m.id == activeId,
        orElse: () => defaultModel!,
      );

      final isDownloadedResult = await isModelDownloaded(activeModel);
      final downloaded = isDownloadedResult is Success<bool> ? isDownloadedResult.data : false;

      return Success(activeModel.copyWith(
        isDownloaded: downloaded,
        isActive: true,
      ));
    } catch (e) {
      final models = await _loadModels();
      return Success(models.isNotEmpty ? models.first : null); // Fallback to default
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
  Stream<double> downloadModel(STTModelPackage package) {
    final controller = StreamController<double>();
    
    Future<void> performDownload() async {
      try {
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

          final localFile = File(filePath);
          if (await localFile.exists()) {
            fileProgresses[i] = 1.0;
            final totalProgress = fileProgresses.reduce((a, b) => a + b) / totalFiles;
            controller.add(totalProgress);
            continue;
          }

          await _dio.download(
            fileUrl,
            filePath,
            onReceiveProgress: (received, total) {
              if (total > 0) {
                fileProgresses[i] = received / total;
                final overallProgress = fileProgresses.reduce((a, b) => a + b) / totalFiles;
                controller.add(overallProgress);
              }
            },
          );
          
          fileProgresses[i] = 1.0;
          controller.add(fileProgresses.reduce((a, b) => a + b) / totalFiles);
        }
        controller.close();
      } catch (e) {
        controller.addError(Exception('Error descargando archivo: $e'));
        controller.close();
      }
    }

    performDownload();
    return controller.stream;
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
