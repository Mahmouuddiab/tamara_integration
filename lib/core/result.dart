sealed class Result<F, S> {
  const Result();

  T when<T>({
    required T Function(F failure) failure,
    required T Function(S success) success,
  }) {
    final self = this;
    if (self is Failure<F, S>) return failure(self.value);
    if (self is Success<F, S>) return success(self.value);
    throw StateError('Unreachable');
  }

  bool get isSuccess => this is Success<F, S>;
}

class Success<F, S> extends Result<F, S> {
  final S value;
  const Success(this.value);
}

class Failure<F, S> extends Result<F, S> {
  final F value;
  const Failure(this.value);
}
