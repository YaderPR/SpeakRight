import 'package:speak_right/core/usecases/usecase.dart';
import 'package:speak_right/domain/repositories/stt_model_repository.dart';

class SetActiveModelUseCase implements UseCase<void, String> {
  final STTModelRepository repository;

  const SetActiveModelUseCase(this.repository);

  @override
  Future<Result<void>> call(String modelId) async {
    return repository.setActiveModel(modelId);
  }
}
