class TranscriptionResult {
  final String referenceText;
  final String transcribedText;
  final double accuracyScore;
  final List<WordMatch> wordMatches;

  const TranscriptionResult({
    required this.referenceText,
    required this.transcribedText,
    required this.accuracyScore,
    required this.wordMatches,
  });
}

class WordMatch {
  final String word;
  final bool isCorrect;
  final String? ipaPronunciation;

  const WordMatch({
    required this.word,
    required this.isCorrect,
    this.ipaPronunciation,
  });
}
