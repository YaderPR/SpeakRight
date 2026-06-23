import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:speak_right/domain/entities/transcription_result.dart';
import 'package:speak_right/presentation/practice/state/practice_state.dart';
import 'package:speak_right/presentation/practice/viewmodels/practice_providers.dart';
import 'package:speak_right/presentation/practice/viewmodels/practice_viewmodel.dart';

class PracticeScreen extends ConsumerWidget {
  const PracticeScreen({super.key});

  static const String _referenceText =
      'Integrate on-device speech-to-text engines to achieve zero-latency feedback';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(practiceViewModelProvider);
    final viewModel = ref.read(practiceViewModelProvider.notifier);

    // Premium Color System (Tailored Dark Theme)
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
        title: const Row(
          children: [
            Icon(Icons.mic_none, color: primaryAccent, size: 28),
            SizedBox(width: 8),
            Text(
              'SpeakRight',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: textMuted),
            onPressed: () {},
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Progress/Dashboard Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: surfaceDark,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: borderColor),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'PRACTICE SENTENCE',
                      style: TextStyle(
                        color: primaryAccent,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Reference text area with word highlights if success
                    if (state is PracticeSuccess)
                      Wrap(
                        spacing: 6.0,
                        runSpacing: 4.0,
                        children: state.result.wordMatches.map((match) {
                          return Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                match.ipaPronunciation ?? '',
                                style: const TextStyle(
                                  color: textMuted,
                                  fontSize: 10,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: match.isCorrect
                                      ? successColor.withOpacity(0.1)
                                      : errorColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  match.word,
                                  style: TextStyle(
                                    color: match.isCorrect
                                        ? successColor
                                        : errorColor,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                      )
                    else
                      Text(
                        _referenceText,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                          height: 1.5,
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Dynamic feedback section
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: surfaceDark.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: borderColor),
                  ),
                  child: Center(
                    child: _buildFeedbackContent(state, successColor, errorColor, textMuted, primaryAccent),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Recording / Control bar
              _buildControlBar(state, viewModel, bgDark, surfaceDark, borderColor, primaryAccent, errorColor, successColor),
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
  ) {
    if (state is PracticeInitial) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.record_voice_over, color: textMuted, size: 64),
          const SizedBox(height: 16),
          Text(
            'Press the microphone to start practicing',
            style: TextStyle(color: textMuted, fontSize: 16),
            textAlign: TextAlign.center,
          ),
        ],
      );
    } else if (state is PracticeListening) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Stack(
            alignment: Alignment.center,
            children: [
              // Wave animation mock
              _MicrophonePulseCircle(),
              Icon(Icons.mic, color: Colors.white, size: 64),
            ],
          ),
          const SizedBox(height: 24),
          const Text(
            'Listening...',
            style: TextStyle(
                color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Speak clearly into your microphone',
            style: TextStyle(color: textMuted, fontSize: 14),
          ),
        ],
      );
    } else if (state is PracticeProcessing) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(primaryAccent),
            strokeWidth: 3,
          ),
          const SizedBox(height: 24),
          const Text(
            'Evaluating pronunciation...',
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
        ],
      );
    } else if (state is PracticeSuccess) {
      final percentage = (state.result.accuracyScore * 100).toInt();
      final isGreat = percentage >= 80;

      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Elegant Score Circle
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: isGreat ? successColor : errorColor,
                width: 4,
              ),
              color: (isGreat ? successColor : errorColor).withOpacity(0.05),
            ),
            child: Center(
              child: Text(
                '$percentage%',
                style: TextStyle(
                  color: isGreat ? successColor : errorColor,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            isGreat ? 'Great Pronunciation!' : 'Keep Practicing!',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'You pronounced ${state.result.wordMatches.where((w) => w.isCorrect).length} out of ${state.result.wordMatches.length} words correctly.',
            style: TextStyle(color: textMuted, fontSize: 14),
            textAlign: TextAlign.center,
          ),
        ],
      );
    } else if (state is PracticeError) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, color: errorColor, size: 64),
          const SizedBox(height: 16),
          Text(
            'Error: ${state.errorMessage}',
            style: TextStyle(color: errorColor, fontSize: 16),
            textAlign: TextAlign.center,
          ),
        ],
      );
    }

    return const SizedBox();
  }

  Widget _buildControlBar(
    PracticeState state,
    PracticeViewModel viewModel,
    Color bgDark,
    Color surfaceDark,
    Color borderColor,
    Color primaryAccent,
    Color errorColor,
    Color successColor,
  ) {
    if (state is PracticeListening) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: () => viewModel.submitSpeech(_referenceText),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              decoration: BoxDecoration(
                color: successColor,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: successColor.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Row(
                children: [
                  Icon(Icons.check, color: Colors.white),
                  SizedBox(width: 8),
                  Text(
                    'Evaluate',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 16),
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: errorColor),
                color: errorColor.withOpacity(0.1),
              ),
              child: Icon(Icons.close, color: errorColor, size: 24),
            ),
            onPressed: viewModel.reset,
          ),
        ],
      );
    }

    return Center(
      child: GestureDetector(
        onTap: state is PracticeProcessing
            ? null
            : () {
                if (state is PracticeSuccess) {
                  viewModel.reset();
                } else {
                  viewModel.startPractice();
                }
              },
        child: Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: state is PracticeSuccess ? primaryAccent.withOpacity(0.2) : primaryAccent,
            border: Border.all(
              color: state is PracticeSuccess ? primaryAccent : Colors.transparent,
              width: 2,
            ),
            boxShadow: state is PracticeSuccess
                ? null
                : [
                    BoxShadow(
                      color: primaryAccent.withOpacity(0.4),
                      blurRadius: 15,
                      offset: const Offset(0, 6),
                    ),
                  ],
          ),
          child: Icon(
            state is PracticeSuccess ? Icons.refresh : Icons.mic,
            color: state is PracticeSuccess ? primaryAccent : Colors.white,
            size: 36,
          ),
        ),
      ),
    );
  }
}

class _MicrophonePulseCircle extends StatefulWidget {
  const _MicrophonePulseCircle();

  @override
  State<_MicrophonePulseCircle> createState() => _MicrophonePulseCircleState();
}

class _MicrophonePulseCircleState extends State<_MicrophonePulseCircle>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          width: 140 * _controller.value + 60,
          height: 140 * _controller.value + 60,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFF6C5DD3).withOpacity(1.0 - _controller.value),
          ),
        );
      },
    );
  }
}
