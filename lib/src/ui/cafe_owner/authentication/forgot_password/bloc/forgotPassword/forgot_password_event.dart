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