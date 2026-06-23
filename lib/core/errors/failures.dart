abstract class Failure {
  final String message;
  const Failure(this.message);
}

class DatabaseFailure extends Failure {
  const DatabaseFailure(super.message);
}

class AudioFailure extends Failure {
  const AudioFailure(super.message);
}

class SpeechToTextFailure extends Failure {
  const SpeechToTextFailure(super.message);
}
