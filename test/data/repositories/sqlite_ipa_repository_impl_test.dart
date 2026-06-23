import 'package:flutter_test/flutter_test.dart';
import 'package:speak_right/core/errors/failures.dart';
import 'package:speak_right/core/usecases/usecase.dart';
import 'package:speak_right/data/datasources/ipa_local_data_source.dart';
import 'package:speak_right/data/repositories/sqlite_ipa_repository_impl.dart';

class StubIpaLocalDataSource implements IpaLocalDataSource {
  final Map<String, String> db = {
    'hello': 'həˈləʊ',
    'world': 'wɜːld',
    'practice': 'ˈpræktɪs',
    'on-device': 'ɒn dɪˈvaɪs',
    'don\'t': 'dəʊnt',
  };

  bool shouldThrow = false;

  @override
  Future<String?> getWordIpa(String word) async {
    if (shouldThrow) throw Exception("DB Error");
    return db[word];
  }

  @override
  Future<Map<String, String>> getWordsIpa(List<String> words) async {
    if (shouldThrow) throw Exception("DB Error");
    final result = <String, String>{};
    for (final word in words) {
      if (db.containsKey(word)) {
        result[word] = db[word]!;
      }
    }
    return result;
  }
}

void main() {
  late StubIpaLocalDataSource dataSource;
  late SqliteIPARepositoryImpl repository;

  setUp(() {
    dataSource = StubIpaLocalDataSource();
    repository = SqliteIPARepositoryImpl(dataSource);
  });

  group('SqliteIPARepositoryImpl - getWordIpa', () {
    test('should return Success with IPA phonetic translation when word exists', () async {
      final result = await repository.getWordIpa('hello');
      expect(result, isA<Success<String>>());
      expect((result as Success<String>).data, 'həˈləʊ');
    });

    test('should return Success with /*/ when word does not exist', () async {
      final result = await repository.getWordIpa('nonexistent');
      expect(result, isA<Success<String>>());
      expect((result as Success<String>).data, '/*/');
    });

    test('should strip punctuation correctly and return Success', () async {
      final result = await repository.getWordIpa('World!!!');
      expect(result, isA<Success<String>>());
      expect((result as Success<String>).data, 'wɜːld');
    });

    test('should preserve apostrophes and hyphens inside words', () async {
      final resultHyphen = await repository.getWordIpa('on-device!');
      expect(resultHyphen, isA<Success<String>>());
      expect((resultHyphen as Success<String>).data, 'ɒn dɪˈvaɪs');

      final resultContraction = await repository.getWordIpa('don\'t,');
      expect(resultContraction, isA<Success<String>>());
      expect((resultContraction as Success<String>).data, 'dəʊnt');
    });

    test('should return Error when data source throws an exception', () async {
      dataSource.shouldThrow = true;
      final result = await repository.getWordIpa('hello');
      expect(result, isA<Error<String>>());
      expect((result as Error<String>).failure, isA<DatabaseFailure>());
    });
  });

  group('SqliteIPARepositoryImpl - getSentenceIpa', () {
    test('should look up sentence in batch and return phonetic list', () async {
      final result = await repository.getSentenceIpa('Hello, world!');
      expect(result, isA<Success<List<String>>>());
      expect((result as Success<List<String>>).data, ['həˈləʊ', 'wɜːld']);
    });

    test('should return /*/ for words not in the dictionary', () async {
      final result = await repository.getSentenceIpa('Hello nonexistent world');
      expect(result, isA<Success<List<String>>>());
      expect((result as Success<List<String>>).data, ['həˈləʊ', '/*/', 'wɜːld']);
    });

    test('should return empty list for empty/whitespace input', () async {
      final resultEmpty = await repository.getSentenceIpa('');
      expect(resultEmpty, isA<Success<List<String>>>());
      expect((resultEmpty as Success<List<String>>).data, isEmpty);

      final resultWhitespace = await repository.getSentenceIpa('   ');
      expect(resultWhitespace, isA<Success<List<String>>>());
      expect((resultWhitespace as Success<List<String>>).data, isEmpty);
    });

    test('should return Error when data source throws an exception in batch query', () async {
      dataSource.shouldThrow = true;
      final result = await repository.getSentenceIpa('Hello world');
      expect(result, isA<Error<List<String>>>());
      expect((result as Error<List<String>>).failure, isA<DatabaseFailure>());
    });
  });
}
