import 'package:speak_right/core/usecases/usecase.dart';
import 'package:speak_right/domain/entities/transcription_result.dart';

abstract class STTRepository {
  Future<Result<void>> startListening();
  Future<Result<void>> stopListening();
  Stream<String> get transcriptionStream;
  Future<Result<TranscriptionResult>> evaluatePronunciation(String referenceText);
}
