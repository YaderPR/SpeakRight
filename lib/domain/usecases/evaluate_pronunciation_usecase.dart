import 'package:speak_right/core/errors/failures.dart';
import 'package:speak_right/core/usecases/usecase.dart';
import 'package:speak_right/domain/entities/transcription_result.dart';
import 'package:speak_right/domain/repositories/stt_repository.dart';

class EvaluatePronunciationUseCase implements UseCase<TranscriptionResult, EvaluatePronunciationParams> {
  final STTRepository repository;

  const EvaluatePronunciationUseCase(this.repository);

  @override
  Future<Result<TranscriptionResult>> call(EvaluatePronunciationParams params) async {
    if (params.referenceText.trim().isEmpty) {
      return Error(const SpeechToTextFailure('El texto de referencia no puede estar vacío.'));
    }
    return repository.evaluatePronunciation(params.referenceText);
  }
}

class EvaluatePronunciationParams {
  final String referenceText;
  const EvaluatePronunciationParams({required this.referenceText});
}
