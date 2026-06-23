import 'package:speak_right/core/errors/failures.dart';

abstract class UseCase<Type, Params> {
  Future<Result<Type>> call(Params params);
}

class NoParams {}

abstract class Result<T> {
  const Result();
}

class Success<T> extends Result<T> {
  final T data;
  const Success(this.data);
}

class Error<T> extends Result<T> {
  final Failure failure;
  const Error(this.failure);
}
