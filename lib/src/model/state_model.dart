class StateModel<T> {
  StateModel._();

  factory StateModel.success(T value) = SuccessState<T>;

  // Always expect String for errors
  factory StateModel.error(String msg) = ErrorState<T>;
}

class ErrorState<T> extends StateModel<T> {
  ErrorState(this.msg) : super._();

  final String msg;   // ← FIX: always String
}

class SuccessState<T> extends StateModel<T> {
  SuccessState(this.value) : super._();

  final T value;
}
