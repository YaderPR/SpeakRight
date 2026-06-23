import 'package:speak_right/core/usecases/usecase.dart';
import 'package:speak_right/domain/repositories/ipa_repository.dart';

class MockIPARepositoryImpl implements IPARepository {
  @override
  Future<Result<String>> getWordIpa(String word) async {
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

    final result = mockIpaDb[cleanWord] ?? '/*/';
    return Success(result);
  }

  @override
  Future<Result<List<String>>> getSentenceIpa(String sentence) async {
    final words = sentence.split(' ');
    final ipas = <String>[];
    for (final word in words) {
      final res = await getWordIpa(word);
      if (res is Success<String>) {
        ipas.add(res.data);
      } else {
        ipas.add('/*/');
      }
    }
    return Success(ipas);
  }
}
