import 'package:dicetable/src/model/state_model.dart';

extension StateModelExtension<T> on StateModel<T> {
  bool get isSuccess => this is SuccessState<T>;
  bool get isError => this is ErrorState<T>;

  T? get data => this is SuccessState<T> ? (this as SuccessState<T>).value : null;
  T? get error => this is ErrorState<T> ? (this as ErrorState<T>).msg : null;
}
