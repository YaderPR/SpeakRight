import 'package:speak_right/core/errors/failures.dart';
import 'package:speak_right/core/usecases/usecase.dart';
import 'package:speak_right/data/datasources/ipa_local_data_source.dart';
import 'package:speak_right/domain/repositories/ipa_repository.dart';

class SqliteIPARepositoryImpl implements IPARepository {
  final IpaLocalDataSource _localDataSource;

  SqliteIPARepositoryImpl(this._localDataSource);

  // Helper to strip leading and trailing punctuation (keeping hyphens and apostrophes inside)
  String _cleanWord(String word) {
    // Regex matches non-word characters at start and end of the string.
    // It keeps contractions like "don't" or compound words like "on-device".
    final cleaned = word.replaceAll(RegExp(r'^[^\w\x27\x2D]+|[^\w\x27\x2D]+$'), '');
    return cleaned.toLowerCase().trim();
  }

  @override
  Future<Result<String>> getWordIpa(String word) async {
    try {
      final cleaned = _cleanWord(word);
      if (cleaned.isEmpty) {
        return Success('/*/');
      }

      final ipa = await _localDataSource.getWordIpa(cleaned);
      return Success(ipa ?? '/*/');
    } catch (e) {
      return Error(DatabaseFailure('SQLite IPA single lookup failed: $e'));
    }
  }

  @override
  Future<Result<List<String>>> getSentenceIpa(String sentence) async {
    try {
      final trimmed = sentence.trim();
      if (trimmed.isEmpty) {
        return Success(<String>[]);
      }
      final rawWords = trimmed.split(RegExp(r'\s+'));

      // Map raw words to their cleaned search keys
      final cleanedWords = rawWords.map(_cleanWord).toList();
      
      // Perform batch lookup
      final ipaMap = await _localDataSource.getWordsIpa(cleanedWords);

      // Reconstruct list in order
      final result = <String>[];
      for (final cleaned in cleanedWords) {
        if (cleaned.isEmpty) {
          result.add('/*/');
        } else {
          result.add(ipaMap[cleaned] ?? '/*/');
        }
      }

      return Success(result);
    } catch (e) {
      return Error(DatabaseFailure('SQLite IPA batch lookup failed: $e'));
    }
  }
}
