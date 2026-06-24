import 'package:speak_right/core/usecases/usecase.dart';

abstract class STTRepository {
  /// Initializes the on-device STT engine (e.g. loading ONNX models in memory).
  Future<Result<void>> initialize();

  /// Starts listening to audio input from the device microphone.
  Future<Result<void>> startListening();

  /// Stops listening and releases the microphone. Returns the final transcribed text.
  Future<Result<String>> stopListening();

  /// A stream of the live transcribed text from the microphone input.
  Stream<String> get transcriptionStream;

  /// Disposes the STT engine resources.
  Future<Result<void>> dispose();
}
