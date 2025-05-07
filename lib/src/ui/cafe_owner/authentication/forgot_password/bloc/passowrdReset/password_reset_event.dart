part of 'password_reset_bloc.dart';

sealed class PasswordResetEvent extends Equatable {
  const PasswordResetEvent();
}

class GetPasswordResetEvent extends PasswordResetEvent {
  final PasswordResetRequest passwordResetRequest;
  const GetPasswordResetEvent({required this.passwordResetRequest});
  @override

  List<Object?> get props => [passwordResetRequest];
}