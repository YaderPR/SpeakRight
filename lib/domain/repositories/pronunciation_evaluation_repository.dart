import 'package:speak_right/core/usecases/usecase.dart';
import 'package:speak_right/domain/entities/transcription_result.dart';

abstract class PronunciationEvaluationRepository {
  /// Aligns and compares the transcribed text against the reference text.
  /// Returns a detailed [TranscriptionResult] mapping correctness and scores.
  Future<Result<TranscriptionResult>> evaluate({
    required String referenceText,
    required String transcribedText,
  });
}
