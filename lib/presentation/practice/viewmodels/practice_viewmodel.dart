import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:speak_right/core/usecases/usecase.dart';
import 'package:speak_right/domain/usecases/evaluate_pronunciation_usecase.dart';
import 'package:speak_right/domain/entities/transcription_result.dart';
import 'package:speak_right/presentation/practice/state/practice_state.dart';

class PracticeViewModel extends StateNotifier<PracticeState> {
  final EvaluatePronunciationUseCase _evaluateUseCase;

  PracticeViewModel(this._evaluateUseCase) : super(const PracticeInitial());

  Future<void> startPractice() async {
    state = const PracticeListening('');
  }

  Future<void> submitSpeech(String referenceText) async {
    state = const PracticeProcessing();

    // Since STT is currently mocked, we simulate the user's transcription input.
    // In the real implementation, this will be passed from the captured STT stream.
    final simulatedTranscribedText = referenceText;

    final result = await _evaluateUseCase(EvaluatePronunciationParams(
      referenceText: referenceText,
      transcribedText: simulatedTranscribedText,
    ));

    if (result is Success<TranscriptionResult>) {
      state = PracticeSuccess(result.data);
    } else if (result is Error<TranscriptionResult>) {
      state = PracticeError(result.failure.message);
    }
  }

  void reset() {
    state = const PracticeInitial();
  }
}
