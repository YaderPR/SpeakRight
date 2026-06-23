import 'package:speak_right/core/usecases/usecase.dart';
import 'package:speak_right/domain/entities/stt_model_package.dart';
import 'package:speak_right/domain/repositories/stt_model_repository.dart';

class GetAvailableModelsUseCase implements UseCase<List<STTModelPackage>, NoParams> {
  final STTModelRepository repository;

  const GetAvailableModelsUseCase(this.repository);

  @override
  Future<Result<List<STTModelPackage>>> call(NoParams params) async {
    return repository.getAvailableModels();
  }
}
