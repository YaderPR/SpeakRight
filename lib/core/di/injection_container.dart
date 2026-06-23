import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:speak_right/data/datasources/ipa_local_data_source.dart';
import 'package:speak_right/data/datasources/sqlite_ipa_local_data_source_impl.dart';
import 'package:speak_right/data/repositories/mock_evaluation_repository_impl.dart';
import 'package:speak_right/data/repositories/sherpa_onnx_stt_repository_impl.dart';
import 'package:speak_right/data/repositories/sqlite_ipa_repository_impl.dart';
import 'package:speak_right/data/repositories/stt_model_repository_impl.dart';
import 'package:speak_right/domain/repositories/ipa_repository.dart';
import 'package:speak_right/domain/repositories/pronunciation_evaluation_repository.dart';
import 'package:speak_right/domain/repositories/stt_model_repository.dart';
import 'package:speak_right/domain/repositories/stt_repository.dart';
import 'package:speak_right/domain/usecases/delete_model_usecase.dart';
import 'package:speak_right/domain/usecases/download_model_usecase.dart';
import 'package:speak_right/domain/usecases/evaluate_pronunciation_usecase.dart';
import 'package:speak_right/domain/usecases/get_active_model_usecase.dart';
import 'package:speak_right/domain/usecases/get_available_models_usecase.dart';
import 'package:speak_right/domain/usecases/set_active_model_usecase.dart';

final sl = GetIt.instance;

Future<void> initDependencies() async {
  // External client (Dio HTTP Client)
  sl.registerLazySingleton<Dio>(() => Dio(BaseOptions(
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 30),
      )));

  // Data Sources
  sl.registerLazySingleton<IpaLocalDataSource>(() => SqliteIpaLocalDataSourceImpl());

  // Repositories
  sl.registerLazySingleton<STTRepository>(() => SherpaOnnxSttRepositoryImpl(sl<STTModelRepository>()));
  sl.registerLazySingleton<IPARepository>(() => SqliteIPARepositoryImpl(sl<IpaLocalDataSource>()));
  sl.registerLazySingleton<PronunciationEvaluationRepository>(
    () => MockEvaluationRepositoryImpl(),
  );
  sl.registerLazySingleton<STTModelRepository>(
    () => STTModelRepositoryImpl(sl<Dio>()),
  );

  // UseCases - Evaluation
  sl.registerLazySingleton(() => EvaluatePronunciationUseCase(
        evaluationRepository: sl(),
        ipaRepository: sl(),
      ));

  // UseCases - STT Model Management
  sl.registerLazySingleton(() => GetAvailableModelsUseCase(sl()));
  sl.registerLazySingleton(() => GetActiveModelUseCase(sl()));
  sl.registerLazySingleton(() => SetActiveModelUseCase(sl()));
  sl.registerLazySingleton(() => DownloadModelUseCase(sl()));
  sl.registerLazySingleton(() => DeleteModelUseCase(sl()));
}
