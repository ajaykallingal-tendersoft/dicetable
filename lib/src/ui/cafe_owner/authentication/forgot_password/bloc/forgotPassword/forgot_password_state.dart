part of 'forgot_password_bloc.dart';

sealed class ForgotPasswordState extends Equatable {
  const ForgotPasswordState();
}

final class ForgotPasswordInitial extends ForgotPasswordState {
  @override
  List<Object> get props => [];
}

final class ForgotPasswordLoading extends ForgotPasswordState {
  @override
  List<Object> get props => [];
}

final class ForgotPasswordLoaded extends ForgotPasswordState {
  final ForgotPasswordRequestResponse forgotPasswordRequestResponse;
  const ForgotPasswordLoaded({required this.forgotPasswordRequestResponse});
  @override
  List<Object> get props => [forgotPasswordRequestResponse];
}
final class ForgotPasswordError extends ForgotPasswordState {
  final String errorMessage;
  const ForgotPasswordError({required this.errorMessage});
  @override
  List<Object> get props => [errorMessage];
}
