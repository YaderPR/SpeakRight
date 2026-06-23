import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:speak_right/core/usecases/usecase.dart';
import 'package:speak_right/domain/repositories/stt_repository.dart';
import 'package:speak_right/domain/usecases/evaluate_pronunciation_usecase.dart';
import 'package:speak_right/domain/entities/transcription_result.dart';
import 'package:speak_right/presentation/practice/state/practice_state.dart';

class PracticeViewModel extends StateNotifier<PracticeState> {
  final EvaluatePronunciationUseCase _evaluateUseCase;
  final STTRepository _sttRepository;
  StreamSubscription<String>? _sttSubscription;

  PracticeViewModel(this._evaluateUseCase, this._sttRepository) : super(const PracticeInitial());

  Future<void> startPractice() async {
    state = const PracticeListening('');

    final initResult = await _sttRepository.initialize();
    if (initResult is Error) {
      state = PracticeError(initResult.failure.message);
      return;
    }

    final startResult = await _sttRepository.startListening();
    if (startResult is Error) {
      state = PracticeError(startResult.failure.message);
      return;
    }

    _sttSubscription?.cancel();
    _sttSubscription = _sttRepository.transcriptionStream.listen((partialText) {
      if (state is PracticeListening) {
        state = PracticeListening(partialText);
      }
    }, onError: (err) {
      state = PracticeError(err.toString());
    });
  }

  Future<void> submitSpeech(String referenceText) async {
    String finalTranscribedText = '';
    if (state is PracticeListening) {
      finalTranscribedText = (state as PracticeListening).partialText;
    }

    state = const PracticeProcessing();

    await _sttRepository.stopListening();
    _sttSubscription?.cancel();

    // If there's no reference text, evaluate the transcribed text against itself
    final textToEvaluate = referenceText.trim().isEmpty ? finalTranscribedText : referenceText;

    if (textToEvaluate.trim().isEmpty) {
        state = const PracticeError("No speech detected.");
        return;
    }

    final result = await _evaluateUseCase(EvaluatePronunciationParams(
      referenceText: textToEvaluate,
      transcribedText: finalTranscribedText,
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

  @override
  void dispose() {
    _sttSubscription?.cancel();
    _sttRepository.stopListening();
    super.dispose();
  }
}
