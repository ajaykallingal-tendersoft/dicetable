part of 'customer_login_bloc.dart';

sealed class CustomerLoginState extends Equatable {
  const CustomerLoginState();
}

final class CustomerLoginInitial extends CustomerLoginState {
  @override
  List<Object> get props => [];
}

class CustomerLoginLoadingState extends CustomerLoginState {
  @override

  List<Object?> get props => [];
}

class CustomerLoginSuccessState extends CustomerLoginState {
  final LoginRequestResponse loginRequestResponse;

  const CustomerLoginSuccessState({required this.loginRequestResponse});

  @override
  List<Object?> get props => [loginRequestResponse];
}

class CustomerLoginFailureState extends CustomerLoginState {
  final String message;
  const CustomerLoginFailureState(this.message);

  @override

  List<Object?> get props => [message];
}

class LoginFormState extends CustomerLoginState {
  final String email;
  final String password;
  final String? emailError;
  final String? passwordError;

  const LoginFormState({
    this.email = '',
    this.password = '',
    this.emailError,
    this.passwordError,
  });

  LoginFormState copyWith({
    String? email,
    String? password,
    String? emailError,
    String? passwordError,
  }) {
    return LoginFormState(
      email: email ?? this.email,
      password: password ?? this.password,
      emailError: emailError,
      passwordError: passwordError,
    );
  }

  @override
  List<Object?> get props => [email,password,emailError,passwordError];
}