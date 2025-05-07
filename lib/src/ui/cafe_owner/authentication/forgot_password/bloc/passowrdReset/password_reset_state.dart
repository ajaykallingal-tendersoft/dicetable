part of 'password_reset_bloc.dart';

sealed class PasswordResetState extends Equatable {
  const PasswordResetState();
}

final class PasswordResetInitial extends PasswordResetState {
  @override
  List<Object> get props => [];
}

final class PasswordResetLoading extends PasswordResetState {
  @override
  List<Object> get props => [];
}
final class PasswordResetLoaded extends PasswordResetState {
  final PasswordResetRequestResponse passwordResetRequestResponse;
  const PasswordResetLoaded({required this.passwordResetRequestResponse});
  @override
  List<Object> get props => [passwordResetRequestResponse];
}
final class PasswordResetError extends PasswordResetState {
  final String errorMessage;
  const PasswordResetError({required this.errorMessage});
  @override
  List<Object> get props => [errorMessage];
}