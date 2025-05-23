part of 'login_bloc.dart';

sealed class LoginState extends Equatable {
  const LoginState();
}

class LoginInitial extends LoginState {
  const LoginInitial();

  @override

  List<Object?> get props => [];
}

class LoginLoadingState extends LoginState {
  @override

  List<Object?> get props => [];
}

class LoginSuccessState extends LoginState {
  final LoginRequestResponse loginRequestResponse;

  const LoginSuccessState({required this.loginRequestResponse});

  @override
  List<Object?> get props => [loginRequestResponse];
}

class LoginFailureState extends LoginState {
  final String message;
  const LoginFailureState(this.message);

  @override

  List<Object?> get props => [message];
}

class LoginFormState  extends LoginState{
  final String email;
  final String? emailError;
  final String password;
  final String? passwordError;

  const LoginFormState({
    this.email = '',
    this.emailError,
    this.password = '',
    this.passwordError,
  });

  LoginFormState copyWith({
    String? email,
    String? emailError,
    String? password,
    String? passwordError,
  }) {
    return LoginFormState(
      email: email ?? this.email,
      emailError: emailError,
      password: password ?? this.password,
      passwordError: passwordError,
    );
  }

  @override
  List<Object?> get props => [email, emailError, password, passwordError];
}

///Google Login
class GoogleLoginInitial extends LoginState {
  @override
  List<Object> get props => [];

  @override
  String toString() => 'GoogleLoginInitial';
}

class GoogleLoginLoading extends LoginState {
  @override
  List<Object> get props => [];

  @override
  String toString() => 'GoogleLoginLoading';
}

class GoogleLoginLoaded extends LoginState {
  final GoogleLoginRequestResponse googleLoginResponse;

  const GoogleLoginLoaded({required this.googleLoginResponse});

  @override
  List<Object> get props => [googleLoginResponse];

  @override
  String toString() => 'GoogleLoginLoaded: $googleLoginResponse';
}

class GoogleLoginErrorState extends LoginState {
  final String msg;
  const GoogleLoginErrorState({required this.msg});

  @override
  List<Object> get props => [msg];

  @override
  String toString() => 'GoogleLoginErrorState: $msg';
}
