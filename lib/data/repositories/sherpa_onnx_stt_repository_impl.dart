import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:sherpa_onnx/sherpa_onnx.dart' as sherpa;
import 'package:speak_right/core/errors/failures.dart';
import 'package:speak_right/core/usecases/usecase.dart';
import 'package:speak_right/domain/entities/stt_model_package.dart';
import 'package:speak_right/domain/repositories/stt_model_repository.dart';
import 'package:speak_right/domain/repositories/stt_repository.dart';

class SherpaOnnxSttRepositoryImpl implements STTRepository {
  final STTModelRepository _modelRepository;
  final AudioRecorder _audioRecorder;

  static bool _isBindingsInitialized = false;

  final _transcriptionController = StreamController<String>.broadcast();
  StreamSubscription<Uint8List>? _recordingSubscription;

  sherpa.OfflineRecognizer? _offlineRecognizer;
  sherpa.OnlineRecognizer? _onlineRecognizer;
  sherpa.OnlineStream? _onlineStream;
  String? _initializedModelId;

  // Buffer to accumulate normalized Float32 samples for offline mode
  final List<double> _offlineAudioBuffer = [];

  SherpaOnnxSttRepositoryImpl(this._modelRepository)
      : _audioRecorder = AudioRecorder();

  @override
  Stream<String> get transcriptionStream => _transcriptionController.stream;

  @override
  Future<Result<void>> initialize() async {
    try {
      if (!_isBindingsInitialized) {
        sherpa.initBindings();
        _isBindingsInitialized = true;
      }

      final activeModelResult = await _modelRepository.getActiveModel();
      if (activeModelResult is! Success<STTModelPackage?> || activeModelResult.data == null) {
        return const Error(SpeechToTextFailure('No active model selected.'));
      }
      final activeModel = activeModelResult.data!;
      final isDownloadedResult = await _modelRepository.isModelDownloaded(activeModel);
      final isDownloaded = isDownloadedResult is Success<bool> ? isDownloadedResult.data : false;
      if (!isDownloaded) {
        return Error(SpeechToTextFailure('Active model "${activeModel.name}" is not downloaded.'));
      }

      return await _setupRecognizer(activeModel);
    } catch (e) {
      return Error(SpeechToTextFailure('Failed to initialize Sherpa-ONNX: $e'));
    }
  }

  Future<Result<void>> _setupRecognizer(STTModelPackage model) async {
    try {
      if (_initializedModelId == model.id) {
        return const Success(null);
      }

      _disposeRecognizers();

      final docDir = await getApplicationDocumentsDirectory();
      final modelDir = p.join(docDir.path, 'models', model.id);

      if (model.isStreaming) {
        // Zipformer streaming transducer config
        final encoderPath = p.join(modelDir, model.fileNames.firstWhere((f) => f.contains('encoder')));
        final decoderPath = p.join(modelDir, model.fileNames.firstWhere((f) => f.contains('decoder')));
        final joinerPath = p.join(modelDir, model.fileNames.firstWhere((f) => f.contains('joiner')));
        final tokensPath = p.join(modelDir, model.fileNames.firstWhere((f) => f.contains('tokens')));

        if (!await File(encoderPath).exists() ||
            !await File(decoderPath).exists() ||
            !await File(joinerPath).exists() ||
            !await File(tokensPath).exists()) {
          return Error(SpeechToTextFailure('Model files are missing for ${model.name}.'));
        }

        final transducerConfig = sherpa.OnlineTransducerModelConfig(
          encoder: encoderPath,
          decoder: decoderPath,
          joiner: joinerPath,
        );

        final modelConfig = sherpa.OnlineModelConfig(
          transducer: transducerConfig,
          tokens: tokensPath,
          numThreads: 1,
          debug: false,
        );

        final config = sherpa.OnlineRecognizerConfig(
          model: modelConfig,
          decodingMethod: 'greedy_search',
        );

        _onlineRecognizer = sherpa.OnlineRecognizer(config);
      } else {
        // Offline recognizer setup
        final tokensPath = p.join(modelDir, model.fileNames.firstWhere((f) => f.contains('tokens'), orElse: () => 'tokens.txt'));
        sherpa.OfflineModelConfig modelConfig;

        if (model.id.contains('moonshine')) {
          final preprocess = p.join(modelDir, model.fileNames.firstWhere((f) => f.contains('preprocess')));
          final encoder = p.join(modelDir, model.fileNames.firstWhere((f) => f.contains('encode')));
          final uncachedDecoder = p.join(modelDir, model.fileNames.firstWhere((f) => f.contains('uncached')));
          final cachedDecoder = p.join(modelDir, model.fileNames.firstWhere((f) => f.contains('cached')));

          if (!await File(preprocess).exists() ||
              !await File(encoder).exists() ||
              !await File(uncachedDecoder).exists() ||
              !await File(cachedDecoder).exists() ||
              !await File(tokensPath).exists()) {
            return Error(SpeechToTextFailure('Model files are missing for ${model.name}.'));
          }

          modelConfig = sherpa.OfflineModelConfig(
            moonshine: sherpa.OfflineMoonshineModelConfig(
              preprocessor: preprocess,
              encoder: encoder,
              uncachedDecoder: uncachedDecoder,
              cachedDecoder: cachedDecoder,
            ),
            tokens: tokensPath,
            numThreads: 1,
            debug: false,
          );
        } else if (model.id.contains('sensevoice')) {
          final modelPath = p.join(modelDir, model.fileNames.firstWhere((f) => f.contains('model')));

          if (!await File(modelPath).exists() || !await File(tokensPath).exists()) {
            return Error(SpeechToTextFailure('Model files are missing for ${model.name}.'));
          }

          modelConfig = sherpa.OfflineModelConfig(
            senseVoice: sherpa.OfflineSenseVoiceModelConfig(
              model: modelPath,
              language: 'en',
              useInverseTextNormalization: true,
            ),
            tokens: tokensPath,
            numThreads: 1,
            debug: false,
          );
        } else if (model.id.contains('whisper')) {
          final encoder = p.join(modelDir, model.fileNames.firstWhere((f) => f.contains('encoder')));
          final decoder = p.join(modelDir, model.fileNames.firstWhere((f) => f.contains('decoder')));

          if (!await File(encoder).exists() ||
              !await File(decoder).exists() ||
              !await File(tokensPath).exists()) {
            return Error(SpeechToTextFailure('Model files are missing for ${model.name}.'));
          }

          modelConfig = sherpa.OfflineModelConfig(
            whisper: sherpa.OfflineWhisperModelConfig(
              encoder: encoder,
              decoder: decoder,
            ),
            tokens: tokensPath,
            numThreads: 1,
            debug: false,
          );
        } else {
          return Error(SpeechToTextFailure('Unsupported model type for ID: ${model.id}'));
        }

        final config = sherpa.OfflineRecognizerConfig(
          model: modelConfig,
          decodingMethod: 'greedy_search',
        );

        _offlineRecognizer = sherpa.OfflineRecognizer(config);
      }

      _initializedModelId = model.id;
      return const Success(null);
    } catch (e) {
      return Error(SpeechToTextFailure('Failed to configure recognizer: $e'));
    }
  }

  void _disposeRecognizers() {
    _onlineStream?.free();
    _onlineStream = null;
    _onlineRecognizer?.free();
    _onlineRecognizer = null;
    _offlineRecognizer?.free();
    _offlineRecognizer = null;
    _initializedModelId = null;
  }

  Float32List _convertToFloat32(Uint8List bytes) {
    final byteData = ByteData.sublistView(bytes);
    final float32List = Float32List(bytes.length ~/ 2);
    for (int i = 0; i < float32List.length; i++) {
      float32List[i] = byteData.getInt16(i * 2, Endian.little) / 32768.0;
    }
    return float32List;
  }

  @override
  Future<Result<void>> startListening() async {
    try {
      // Safely check and initialize before recording
      final initResult = await initialize();
      if (initResult is Error<void>) {
        return initResult;
      }

      if (!await _audioRecorder.hasPermission()) {
        return const Error(AudioFailure('Microphone permission denied.'));
      }

      // Stop any active subscriptions/recordings
      await _recordingSubscription?.cancel();
      _recordingSubscription = null;
      if (await _audioRecorder.isRecording()) {
        await _audioRecorder.stop();
      }

      final activeModelResult = await _modelRepository.getActiveModel();
      final isStreaming = activeModelResult is Success<STTModelPackage?> &&
          activeModelResult.data != null &&
          activeModelResult.data!.isStreaming;

      const recordConfig = RecordConfig(
        encoder: AudioEncoder.pcm16bits,
        sampleRate: 16000,
        numChannels: 1,
      );

      final audioStream = await _audioRecorder.startStream(recordConfig);

      if (isStreaming) {
        _transcriptionController.add(""); // Clear previous text
        
        if (_onlineRecognizer == null) {
          return const Error(SpeechToTextFailure('OnlineRecognizer is not initialized.'));
        }

        _onlineStream?.free();
        _onlineStream = _onlineRecognizer!.createStream();

        _recordingSubscription = audioStream.listen((chunk) {
          final floatSamples = _convertToFloat32(chunk);
          _onlineStream!.acceptWaveform(samples: floatSamples, sampleRate: 16000);

          while (_onlineRecognizer!.isReady(_onlineStream!)) {
            _onlineRecognizer!.decode(_onlineStream!);
          }

          final result = _onlineRecognizer!.getResult(_onlineStream!);
          if (result.text.trim().isNotEmpty) {
            _transcriptionController.add(result.text);
          }
        });
      } else {
        _offlineAudioBuffer.clear();
        _recordingSubscription = audioStream.listen((chunk) {
          final floatSamples = _convertToFloat32(chunk);
          _offlineAudioBuffer.addAll(floatSamples);
        });
      }

      return const Success(null);
    } catch (e) {
      return Error(SpeechToTextFailure('Failed to start listening: $e'));
    }
  }

  @override
  Future<Result<void>> stopListening() async {
    try {
      await _recordingSubscription?.cancel();
      _recordingSubscription = null;

      if (await _audioRecorder.isRecording()) {
        await _audioRecorder.stop();
      }

      final activeModelResult = await _modelRepository.getActiveModel();
      final isStreaming = activeModelResult is Success<STTModelPackage?> &&
          activeModelResult.data != null &&
          activeModelResult.data!.isStreaming;

      if (!isStreaming) {
        if (_offlineRecognizer == null) {
          return const Error(SpeechToTextFailure('OfflineRecognizer is not initialized.'));
        }

        if (_offlineAudioBuffer.isNotEmpty) {
          final samples = Float32List.fromList(_offlineAudioBuffer);
          final stream = _offlineRecognizer!.createStream();
          stream.acceptWaveform(samples: samples, sampleRate: 16000);
          _offlineRecognizer!.decode(stream);
          final result = _offlineRecognizer!.getResult(stream);
          _transcriptionController.add(result.text);
          stream.free();
        }
        _offlineAudioBuffer.clear();
      } else {
        // Online stream finalization
        _onlineStream?.free();
        _onlineStream = null;
      }

      return const Success(null);
    } catch (e) {
      return Error(SpeechToTextFailure('Failed to stop listening: $e'));
    }
  }

  @override
  Future<Result<void>> dispose() async {
    try {
      await _recordingSubscription?.cancel();
      _recordingSubscription = null;
      await _audioRecorder.dispose();
      _disposeRecognizers();
      await _transcriptionController.close();
      return const Success(null);
    } catch (e) {
      return Error(SpeechToTextFailure('Failed to dispose STT repository: $e'));
    }
  }
}
