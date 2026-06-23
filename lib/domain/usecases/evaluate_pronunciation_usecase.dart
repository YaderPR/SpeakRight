import 'package:speak_right/core/errors/failures.dart';
import 'package:speak_right/core/usecases/usecase.dart';
import 'package:speak_right/domain/entities/transcription_result.dart';
import 'package:speak_right/domain/repositories/ipa_repository.dart';
import 'package:speak_right/domain/repositories/pronunciation_evaluation_repository.dart';

class EvaluatePronunciationUseCase implements UseCase<TranscriptionResult, EvaluatePronunciationParams> {
  final PronunciationEvaluationRepository evaluationRepository;
  final IPARepository ipaRepository;

  const EvaluatePronunciationUseCase({
    required this.evaluationRepository,
    required this.ipaRepository,
  });

  @override
  Future<Result<TranscriptionResult>> call(EvaluatePronunciationParams params) async {
    if (params.referenceText.trim().isEmpty) {
      return Error(const SpeechToTextFailure('El texto de referencia no puede estar vacío.'));
    }

    // 1. Evaluate text matching
    final evalResult = await evaluationRepository.evaluate(
      referenceText: params.referenceText,
      transcribedText: params.transcribedText,
    );

    if (evalResult is Error<TranscriptionResult>) {
      return evalResult;
    }

    final originalResult = (evalResult as Success<TranscriptionResult>).data;

    // 2. Fetch IPA phonetics for each word to enrich the final result
    final enrichedWordMatches = <WordMatch>[];
    for (final match in originalResult.wordMatches) {
      final ipaResult = await ipaRepository.getWordIpa(match.word);
      String? ipaText;
      
      if (ipaResult is Success<String>) {
        ipaText = ipaResult.data;
      }

      enrichedWordMatches.add(WordMatch(
        word: match.word,
        isCorrect: match.isCorrect,
        ipaPronunciation: ipaText,
      ));
    }

    return Success(TranscriptionResult(
      referenceText: originalResult.referenceText,
      transcribedText: originalResult.transcribedText,
      accuracyScore: originalResult.accuracyScore,
      wordMatches: enrichedWordMatches,
    ));
  }
}

class EvaluatePronunciationParams {
  final String referenceText;
  final String transcribedText;

  const EvaluatePronunciationParams({
    required this.referenceText,
    required this.transcribedText,
  });
}
