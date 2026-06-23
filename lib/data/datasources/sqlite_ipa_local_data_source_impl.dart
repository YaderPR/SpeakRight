import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:speak_right/data/datasources/ipa_local_data_source.dart';

class SqliteIpaLocalDataSourceImpl implements IpaLocalDataSource {
  Database? _database;
  final String _dbName = 'ipa_dictionary.db';

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _dbName);

    // Check if the database already exists on the device
    final exists = await databaseExists(path);

    if (!exists) {
      // Ensure the directory exists
      try {
        await Directory(dirname(path)).create(recursive: true);
      } catch (e) {
        // Safe to ignore or log if directory already exists
      }

      // Copy from asset
      try {
        final ByteData data = await rootBundle.load(join('assets', 'database', _dbName));
        final List<int> bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
        await File(path).writeAsBytes(bytes, flush: true);
      } catch (e) {
        throw Exception("Failed to copy SQLite database from assets: $e");
      }
    }

    // Open the database in read-only mode for performance
    return await openDatabase(path, readOnly: true);
  }

  @override
  Future<String?> getWordIpa(String word) async {
    final db = await database;
    final cleanWord = word.toLowerCase().trim();
    if (cleanWord.isEmpty) return null;

    final List<Map<String, dynamic>> maps = await db.query(
      'ipa_words',
      columns: ['ipa'],
      where: 'word = ?',
      whereArgs: [cleanWord],
      limit: 1,
    );

    if (maps.isNotEmpty) {
      return maps.first['ipa'] as String?;
    }
    return null;
  }

  @override
  Future<Map<String, String>> getWordsIpa(List<String> words) async {
    final db = await database;
    final cleanWords = words
        .map((w) => w.toLowerCase().trim())
        .where((w) => w.isNotEmpty)
        .toSet()
        .toList();

    if (cleanWords.isEmpty) return {};

    // Group lookups into IN statement to avoid N queries
    final placeholders = List.filled(cleanWords.length, '?').join(', ');
    final List<Map<String, dynamic>> results = await db.rawQuery(
      'SELECT word, ipa FROM ipa_words WHERE word IN ($placeholders)',
      cleanWords,
    );

    final map = <String, String>{};
    for (final row in results) {
      final word = row['word'] as String;
      final ipa = row['ipa'] as String;
      map[word] = ipa;
    }

    return map;
  }
}
