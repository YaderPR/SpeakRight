import 'package:speak_right/core/usecases/usecase.dart';
import 'package:speak_right/domain/entities/stt_model_package.dart';
import 'package:speak_right/domain/repositories/stt_model_repository.dart';

class DeleteModelUseCase implements UseCase<void, STTModelPackage> {
  final STTModelRepository repository;

  const DeleteModelUseCase(this.repository);

  @override
  Future<Result<void>> call(STTModelPackage package) async {
    return repository.deleteModel(package);
  }
}
