import 'dart:async';
import 'package:speak_right/core/usecases/usecase.dart';
import 'package:speak_right/domain/repositories/stt_repository.dart';

class MockSTTRepositoryImpl implements STTRepository {
  final _transcriptionController = StreamController<String>.broadcast();
  Timer? _mockTimer;

  @override
  Stream<String> get transcriptionStream => _transcriptionController.stream;

  @override
  Future<Result<void>> initialize() async {
    return const Success(null);
  }

  @override
  Future<Result<void>> startListening() async {
    _mockTimer?.cancel();
    return const Success(null);
  }

  @override
  Future<Result<void>> stopListening() async {
    _mockTimer?.cancel();
    return const Success(null);
  }

  @override
  Future<Result<void>> dispose() async {
    _mockTimer?.cancel();
    await _transcriptionController.close();
    return const Success(null);
  }
}
