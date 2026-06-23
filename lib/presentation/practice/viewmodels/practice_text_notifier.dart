import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:speak_right/core/constants/practice_texts.dart';
import 'package:speak_right/domain/entities/practice_level.dart';

class PracticeTextState {
  final PracticeLevel selectedLevel;
  final int currentIndex;

  const PracticeTextState({
    required this.selectedLevel,
    required this.currentIndex,
  });

  PracticeTextState copyWith({
    PracticeLevel? selectedLevel,
    int? currentIndex,
  }) {
    return PracticeTextState(
      selectedLevel: selectedLevel ?? this.selectedLevel,
      currentIndex: currentIndex ?? this.currentIndex,
    );
  }

  String get currentText {
    final texts = practiceTexts.where((t) => t.level == selectedLevel).toList();
    if (texts.isEmpty) return "";
    return texts[currentIndex % texts.length].text;
  }
}

class PracticeTextNotifier extends StateNotifier<PracticeTextState> {
  PracticeTextNotifier()
      : super(const PracticeTextState(
            selectedLevel: PracticeLevel.basic, currentIndex: 0));

  void changeLevel(PracticeLevel level) {
    if (state.selectedLevel != level) {
      state = state.copyWith(selectedLevel: level, currentIndex: 0);
    }
  }

  void nextText() {
    final texts =
        practiceTexts.where((t) => t.level == state.selectedLevel).toList();
    if (texts.isEmpty) return;
    state =
        state.copyWith(currentIndex: (state.currentIndex + 1) % texts.length);
  }

  void previousText() {
    final texts =
        practiceTexts.where((t) => t.level == state.selectedLevel).toList();
    if (texts.isEmpty) return;
    int newIndex = state.currentIndex - 1;
    if (newIndex < 0) {
      newIndex = texts.length - 1;
    }
    state = state.copyWith(currentIndex: newIndex);
  }
}
