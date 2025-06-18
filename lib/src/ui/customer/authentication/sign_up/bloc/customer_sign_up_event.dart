// customer_sign_up_event.dart
part of 'customer_sign_up_bloc.dart';

abstract class CustomerSignUpEvent extends Equatable {
  const CustomerSignUpEvent();

  @override
  List<Object?> get props => [];
}

class UpdateTextField extends CustomerSignUpEvent {
  final SignUpFormState Function(SignUpFormState) update;
  const UpdateTextField(this.update);

  @override
  List<Object?> get props => [update];
}

class NameChanged extends CustomerSignUpEvent {
  final String name;
  const NameChanged({required this.name});

  @override
  List<Object?> get props => [name];
}

class EmailChanged extends CustomerSignUpEvent {
  final String email;
  const EmailChanged({required this.email});

  @override
  List<Object?> get props => [email];
}

class PasswordChanged extends CustomerSignUpEvent {
  final String password;
  const PasswordChanged({required this.password});

  @override
  List<Object?> get props => [password];
}

class ConfirmPasswordChanged extends CustomerSignUpEvent {
  final String confirmPassword;
  const ConfirmPasswordChanged({required this.confirmPassword});

  @override
  List<Object?> get props => [confirmPassword];
}

class PhoneChanged extends CustomerSignUpEvent {
  final String phone;
  const PhoneChanged({required this.phone});

  @override
  List<Object?> get props => [phone];
}

class CountryChanged extends CustomerSignUpEvent {
  final String country;
  const CountryChanged({required this.country});

  @override
  List<Object?> get props => [country];
}

class RegionChanged extends CustomerSignUpEvent {
  final String region;
  const RegionChanged({required this.region});

  @override
  List<Object?> get props => [region];
}

class ValidateForm extends CustomerSignUpEvent {
  const ValidateForm();
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