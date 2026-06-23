import 'package:get_it/get_it.dart';
import 'package:speak_right/data/repositories/mock_stt_repository_impl.dart';
import 'package:speak_right/domain/repositories/stt_repository.dart';
import 'package:speak_right/domain/usecases/evaluate_pronunciation_usecase.dart';

final sl = GetIt.instance;

Future<void> initDependencies() async {
  // Repositories
  sl.registerLazySingleton<STTRepository>(() => MockSTTRepositoryImpl());

  // UseCases
  sl.registerLazySingleton(() => EvaluatePronunciationUseCase(sl()));
}
