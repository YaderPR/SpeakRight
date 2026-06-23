import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:speak_right/core/di/injection_container.dart';
import 'package:speak_right/domain/usecases/evaluate_pronunciation_usecase.dart';
import 'package:speak_right/domain/repositories/stt_repository.dart';
import 'package:speak_right/presentation/practice/state/practice_state.dart';
import 'package:speak_right/presentation/practice/viewmodels/practice_viewmodel.dart';
import 'package:speak_right/presentation/practice/viewmodels/practice_text_notifier.dart';

final practiceTextNotifierProvider =
    StateNotifierProvider<PracticeTextNotifier, PracticeTextState>((ref) {
  return PracticeTextNotifier();
});

final currentPracticeTextProvider = Provider<String>((ref) {
  final textState = ref.watch(practiceTextNotifierProvider);
  return textState.currentText;
});

final freePracticeTextProvider = StateProvider<String>((ref) => '');

final practiceViewModelProvider =
    StateNotifierProvider<PracticeViewModel, PracticeState>((ref) {
  final evaluateUseCase = sl<EvaluatePronunciationUseCase>();
  final sttRepository = sl<STTRepository>();
  return PracticeViewModel(evaluateUseCase, sttRepository);
});
