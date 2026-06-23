import 'package:speak_right/core/usecases/usecase.dart';

abstract class IPARepository {
  /// Converts a single English word into its International Phonetic Alphabet (IPA) representation.
  Future<Result<String>> getWordIpa(String word);

  /// Converts a full sentence into its IPA phonetic representation word by word.
  Future<Result<List<String>>> getSentenceIpa(String sentence);
}
