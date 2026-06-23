import 'package:speak_right/domain/entities/stt_model_package.dart';
import 'package:speak_right/domain/repositories/stt_model_repository.dart';

class DownloadModelUseCase {
  final STTModelRepository repository;

  const DownloadModelUseCase(this.repository);

  Stream<double> call(STTModelPackage package) {
    return repository.downloadModel(package);
  }
}
