import 'package:speak_right/core/usecases/usecase.dart';
import 'package:speak_right/domain/entities/stt_model_package.dart';
import 'package:speak_right/domain/repositories/stt_model_repository.dart';

class GetActiveModelUseCase implements UseCase<STTModelPackage?, NoParams> {
  final STTModelRepository repository;

  const GetActiveModelUseCase(this.repository);

  @override
  Future<Result<STTModelPackage?>> call(NoParams params) async {
    return repository.getActiveModel();
  }
}
