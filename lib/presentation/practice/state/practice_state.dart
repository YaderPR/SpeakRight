import 'package:speak_right/domain/entities/transcription_result.dart';

abstract class PracticeState {
  const PracticeState();
}

class PracticeInitial extends PracticeState {
  const PracticeInitial();
}

class PracticeListening extends PracticeState {
  final String partialText;
  const PracticeListening(this.partialText);
}

class PracticeProcessing extends PracticeState {
  const PracticeProcessing();
}

class PracticeSuccess extends PracticeState {
  final TranscriptionResult result;
  const PracticeSuccess(this.result);
}

class PracticeError extends PracticeState {
  final String errorMessage;
  const PracticeError(this.errorMessage);
}
