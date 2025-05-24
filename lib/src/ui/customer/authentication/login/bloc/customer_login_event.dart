part of 'customer_login_bloc.dart';

sealed class CustomerLoginEvent extends Equatable {
  const CustomerLoginEvent();
}


class FormSubmitted extends CustomerLoginEvent {
  const FormSubmitted();
  @override
  List<Object?> get props => [];
}


class EmailChanged extends CustomerLoginEvent {
  final String email;
  const EmailChanged(this.email);
  @override
  List<Object?> get props => [email];
}

class PasswordChanged extends CustomerLoginEvent {
  final String password;
  const PasswordChanged(this.password);
  @override
  List<Object?> get props => [password];
}
///Google
class CustomerGoogleLoginEvent extends CustomerLoginEvent {
  final GoogleLoginRequest googleLoginRequest;
  const CustomerGoogleLoginEvent({required this.googleLoginRequest});
  @override
  List<Object?> get props => [googleLoginRequest];

}