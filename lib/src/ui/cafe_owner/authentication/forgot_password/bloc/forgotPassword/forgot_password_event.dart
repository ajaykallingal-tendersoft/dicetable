part of 'forgot_password_bloc.dart';

sealed class ForgotPasswordEvent extends Equatable {
  const ForgotPasswordEvent();
}


class GetForgotPasswordEvent extends ForgotPasswordEvent {
  final ForgotPasswordRequest forgotPasswordRequest;
  const GetForgotPasswordEvent({required this.forgotPasswordRequest});
  @override

  List<Object?> get props => [forgotPasswordRequest];

}

class ResendOtpEvent extends ForgotPasswordEvent {
  final ResendOtpRequest resendOtpRequest;
  const ResendOtpEvent({required this.resendOtpRequest});
  @override

  List<Object?> get props => [resendOtpRequest];

}