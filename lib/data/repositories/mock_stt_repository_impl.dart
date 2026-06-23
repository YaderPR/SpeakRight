import 'dart:async';
import 'dart:math';
import 'package:speak_right/core/usecases/usecase.dart';
import 'package:speak_right/domain/entities/transcription_result.dart';
import 'package:speak_right/domain/repositories/stt_repository.dart';

class MockSTTRepositoryImpl implements STTRepository {
  final _transcriptionController = StreamController<String>.broadcast();
  Timer? _mockTypingTimer;

  @override
  Stream<String> get transcriptionStream => _transcriptionController.stream;

  @override
  Future<Result<void>> startListening() async {
    _mockTypingTimer?.cancel();
    return Success(null);
  }

  @override
  Future<Result<void>> stopListening() async {
    _mockTypingTimer?.cancel();
    return Success(null);
  }

  @override
  Future<Result<TranscriptionResult>> evaluatePronunciation(String referenceText) async {
    await Future.delayed(const Duration(milliseconds: 800)); // Simulating processing delay
    
    // Normalizing text for comparison
    final words = referenceText
        .replaceAll(RegExp(r'[.,\/#!$%\^&\*;:{}=\-_`~()]'), '')
        .split(' ')
        .where((element) => element.isNotEmpty)
        .toList();
        
    final wordMatches = <WordMatch>[];
    int correctCount = 0;
    
    final random = Random();
    for (final word in words) {
      // 85% chance of pronouncing it right for the mock
      final isCorrect = random.nextDouble() > 0.15;
      if (isCorrect) correctCount++;
      
      // Simple mock phonetics dictionary for standard vocabulary
      final ipa = _getMockIpa(word);
      
      wordMatches.add(WordMatch(
        word: word,
        isCorrect: isCorrect,
        ipaPronunciation: ipa,
      ));
    }

    final accuracy = words.isEmpty ? 0.0 : correctCount / words.length;
    final simulatedTranscription = wordMatches.map((e) => e.isCorrect ? e.word : '...').join(' ');

    return Success(TranscriptionResult(
      referenceText: referenceText,
      transcribedText: simulatedTranscription,
      accuracyScore: accuracy,
      wordMatches: wordMatches,
    ));
  }

  String _getMockIpa(String word) {
    final cleanWord = word.toLowerCase().trim();
    final mockIpaDb = {
      'integrate': 'ˈɪntɪɡreɪt',
      'on-device': 'ɒn dɪˈvaɪs',
      'speech': 'spiːtʃ',
      'speech-to-text': 'spiːtʃ tuː tɛkst',
      'speechto-text': 'spiːtʃ tuː tɛkst',
      'engine': 'ˈɛndʒɪn',
      'engines': 'ˈɛndʒɪnz',
      'to': 'tuː',
      'achieve': 'əˈtʃiːv',
      'zero-latency': 'ˈzɪərəʊ ˈleɪtənsi',
      'zerolatency': 'ˈzɪərəʊ ˈleɪtənsi',
      'feedback': 'ˈfiːdbæk',
      'hello': 'həˈləʊ',
      'world': 'wɜːld',
      'flutter': 'ˈflʌtə',
      'practice': 'ˈpræktɪs',
      'english': 'ˈɪŋɡlɪʃ',
      'pronunciation': 'prəˌnʌnsiˈeɪʃn',
    };
    return mockIpaDb[cleanWord] ?? '/*/';
  }
}
