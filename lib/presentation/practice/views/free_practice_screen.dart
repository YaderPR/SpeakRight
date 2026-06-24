import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:speak_right/l10n/app_localizations.dart';
import 'package:speak_right/presentation/practice/state/practice_state.dart';
import 'package:speak_right/presentation/practice/viewmodels/practice_providers.dart';

class FreePracticeScreen extends ConsumerWidget {
  const FreePracticeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final state = ref.watch(practiceViewModelProvider);
    final viewModel = ref.read(practiceViewModelProvider.notifier);
    final inputText = ref.watch(freePracticeTextProvider);

    const bgDark = Color(0xFF0F0F13);
    const surfaceDark = Color(0xFF181822);
    const borderColor = Color(0xFF282835);
    const primaryAccent = Color(0xFF6C5DD3);
    const successColor = Color(0xFF2ED47A);
    const errorColor = Color(0xFFFF5B5C);
    const textMuted = Color(0xFF8A8A9D);

    return Scaffold(
      backgroundColor: bgDark,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Row(
          children: [
            const Icon(Icons.mic_none, color: primaryAccent, size: 28),
            const SizedBox(width: 8),
            Text(
              l10n.appName,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Visual Prompt Input
              Container(
                decoration: BoxDecoration(
                  color: surfaceDark,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: borderColor),
                ),
                child: TextField(
                  maxLines: 3,
                  minLines: 1,
                  style: const TextStyle(color: Colors.white, fontSize: 18),
                  decoration: InputDecoration(
                    hintText: l10n.typePromptOptional,
                    hintStyle: const TextStyle(color: textMuted),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.all(16),
                  ),
                  onChanged: (val) {
                    ref.read(freePracticeTextProvider.notifier).state = val;
                  },
                ),
              ),
              const SizedBox(height: 12),
              Text(
                l10n.noPromptHint,
                style: const TextStyle(color: textMuted, fontSize: 14),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),

              // Feedback / Transcription Area
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: surfaceDark,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: borderColor),
                  ),
                  child: Center(
                    child: _buildFeedbackContent(state, successColor, errorColor, textMuted, primaryAccent, bgDark, l10n),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Microphone Button
              _buildControlBar(state, viewModel, inputText, bgDark, surfaceDark, borderColor, primaryAccent, errorColor, successColor, l10n),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeedbackContent(
    PracticeState state,
    Color successColor,
    Color errorColor,
    Color textMuted,
    Color primaryAccent,
    Color bgDark,
    AppLocalizations l10n,
  ) {
    if (state is PracticeInitial) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.mic_none, color: textMuted, size: 64),
          const SizedBox(height: 16),
          Text(
            l10n.startPracticeMessage,
            style: TextStyle(color: textMuted, fontSize: 16),
            textAlign: TextAlign.center,
          ),
        ],
      );
    }

    if (state is PracticeListening) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Simulated sound wave / pulse
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (int i = 0; i < 5; i++)
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: 8,
                  height: 20.0 + (i % 3) * 10,
                  decoration: BoxDecoration(
                    color: primaryAccent,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            l10n.practiceMode,
            style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            // Show real-time transcription if available, otherwise generic message
            state.partialText.isNotEmpty ? state.partialText : l10n.speakClearlyMessage,
            style: TextStyle(color: state.partialText.isNotEmpty ? Colors.white : textMuted, fontSize: 16),
            textAlign: TextAlign.center,
          ),
        ],
      );
    }

    if (state is PracticeProcessing) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(primaryAccent),
            strokeWidth: 3,
          ),
          const SizedBox(height: 24),
          Text(
            l10n.evaluatingMessage,
            style: const TextStyle(color: Colors.white, fontSize: 18),
          ),
        ],
      );
    }

    if (state is PracticeSuccess) {
      // Free Practice Success View (shows the exact transcription and IPA words)
      return SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.transcription,
              style: TextStyle(
                color: primaryAccent,
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8.0,
              runSpacing: 12.0,
              children: state.result.wordMatches.map((match) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      match.ipaPronunciation ?? '',
                      style: TextStyle(
                        color: textMuted,
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: match.isCorrect
                            ? successColor.withOpacity(0.1)
                            : errorColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        match.word,
                        style: TextStyle(
                          color: match.isCorrect ? successColor : errorColor,
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: bgDark,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Text(
                    state.result.accuracyScore >= 80 ? l10n.greatPronunciation : l10n.keepPracticing,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    l10n.scoreDetail(
                      state.result.wordMatches.where((w) => w.isCorrect).length,
                      state.result.wordMatches.length,
                    ),
                    style: TextStyle(color: textMuted, fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    if (state is PracticeError) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, color: errorColor, size: 64),
          const SizedBox(height: 16),
          Text(
            '${l10n.errorMessage}: ${state.errorMessage}',
            style: TextStyle(color: errorColor, fontSize: 16),
            textAlign: TextAlign.center,
          ),
        ],
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildControlBar(
    PracticeState state,
    dynamic viewModel,
    String inputText,
    Color bgDark,
    Color surfaceDark,
    Color borderColor,
    Color primaryAccent,
    Color errorColor,
    Color successColor,
    AppLocalizations l10n,
  ) {
    if (state is PracticeListening) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: () {
              viewModel.submitSpeech(inputText);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              decoration: BoxDecoration(
                color: errorColor,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: errorColor.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const Icon(Icons.stop, color: Colors.white),
                  const SizedBox(width: 8),
                  Text(
                    l10n.evaluate,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    } else {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: () {
              if (state is PracticeSuccess || state is PracticeError) {
                viewModel.reset();
              }
              viewModel.startPractice();
            },
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: primaryAccent,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: primaryAccent.withOpacity(0.3),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: const Icon(Icons.mic, color: Colors.white, size: 36),
            ),
          ),
        ],
      );
    }
  }
}
