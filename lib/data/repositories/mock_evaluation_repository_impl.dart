import 'dart:math';
import 'package:speak_right/core/usecases/usecase.dart';
import 'package:speak_right/domain/entities/transcription_result.dart';
import 'package:speak_right/domain/repositories/pronunciation_evaluation_repository.dart';

class MockEvaluationRepositoryImpl implements PronunciationEvaluationRepository {
  @override
  Future<Result<TranscriptionResult>> evaluate({
    required String referenceText,
    required String transcribedText,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500)); // Simulated processing delay

    // Simple normalization and splitting of words
    final cleanRef = referenceText.replaceAll(RegExp(r'[.,\/#!$%\^&\*;:{}=\-_`~()]'), '');
    final words = cleanRef.split(' ').where((w) => w.isNotEmpty).toList();

    final wordMatches = <WordMatch>[];
    int correctCount = 0;
    final random = Random();

    for (final word in words) {
      // Mock pronunciation evaluation: 85% chance of correct pronunciation
      final isCorrect = random.nextDouble() > 0.15;
      if (isCorrect) correctCount++;

      wordMatches.add(WordMatch(
        word: word,
        isCorrect: isCorrect,
      ));
    }

    final accuracy = words.isEmpty ? 0.0 : correctCount / words.length;

    return Success(TranscriptionResult(
      referenceText: referenceText,
      transcribedText: transcribedText,
      accuracyScore: accuracy,
      wordMatches: wordMatches,
    ));
  }
}
