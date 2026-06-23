abstract class IpaLocalDataSource {
  /// Looks up the IPA representation of a single word.
  /// Returns null if the word is not in the dictionary.
  Future<String?> getWordIpa(String word);

  /// Batch looks up the IPA representations for multiple words.
  /// Returns a map where keys are input words and values are their IPA transcriptions.
  Future<Map<String, String>> getWordsIpa(List<String> words);
}
