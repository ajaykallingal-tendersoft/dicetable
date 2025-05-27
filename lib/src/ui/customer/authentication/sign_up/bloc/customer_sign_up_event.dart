part of 'customer_sign_up_bloc.dart';

sealed class CustomerSignUpEvent extends Equatable {
  const CustomerSignUpEvent();
}

class UpdateTextField extends CustomerSignUpEvent {
  final SignUpFormState Function(SignUpFormState state) update;

  const UpdateTextField(this.update);

  @override
  // TODO: implement props
  List<Object?> get props => throw UnimplementedError();
}

class SignUpRequestEvent extends CustomerSignUpEvent{
  final SignUpRequest signupRequest;
  const SignUpRequestEvent({required this.signupRequest});
  @override

  List<Object?> get props => [signupRequest];

}

class SubmitSignUp extends CustomerSignUpEvent {
  final SignUpRequest signupRequest;
  const SubmitSignUp({required this.signupRequest});
  @override

  List<Object?> get props => [signupRequest];

}

class SubmitGoogleSignUp extends CustomerSignUpEvent {
  final GoogleSignUpRequest signupRequest;
  const SubmitGoogleSignUp({required this.signupRequest});
  @override

  List<Object?> get props => [signupRequest];

}