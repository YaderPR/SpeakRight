import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:speak_right/core/di/injection_container.dart';
import 'package:speak_right/domain/usecases/evaluate_pronunciation_usecase.dart';
import 'package:speak_right/presentation/practice/state/practice_state.dart';
import 'package:speak_right/presentation/practice/viewmodels/practice_viewmodel.dart';

final practiceViewModelProvider = StateNotifierProvider<PracticeViewModel, PracticeState>((ref) {
  final evaluateUseCase = sl<EvaluatePronunciationUseCase>();
  return PracticeViewModel(evaluateUseCase);
});
