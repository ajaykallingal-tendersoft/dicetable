import 'package:bloc/bloc.dart';
import 'package:dicetable/src/model/cafe_owner/auth/login/apple_login_request.dart';
import 'package:dicetable/src/model/cafe_owner/auth/login/apple_login_request_response.dart';
import 'package:dicetable/src/model/cafe_owner/auth/login/google_login_request.dart';
import 'package:dicetable/src/model/cafe_owner/auth/login/google_login_request_response.dart';
import 'package:dicetable/src/model/cafe_owner/auth/login/login_request.dart';
import 'package:dicetable/src/model/cafe_owner/auth/login/login_request_response.dart';
import 'package:dicetable/src/model/state_model.dart';
import 'package:dicetable/src/resources/api_providers/auth/auth_data_provider.dart';
import 'package:dicetable/src/utils/data/object_factory.dart';
import 'package:dicetable/src/utils/extension/state_model_extension.dart';
import 'package:equatable/equatable.dart';

part 'login_event.dart';
part 'login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final AuthDataProvider authDataProvider;
  LoginBloc({required this.authDataProvider}) : super(const LoginFormState()) {
    on<EmailChanged>((event, emit) {
      if (state is LoginFormState) {
        final formState = state as LoginFormState;
        emit(formState.copyWith(email: event.email, emailError: null));
      }
    });

    on<PasswordChanged>((event, emit) {
      if (state is LoginFormState) {
        final formState = state as LoginFormState;
        emit(formState.copyWith(password: event.password, passwordError: null));
      }
    });

    on<FormSubmitted>(_onFormSubmitted);
    on<GetGoogleLoginEvent>(_handleGoogleLogin);
    on<GetAppleLoginEvent>(_handleAppleLogin);
  }

  Future<void> _onFormSubmitted(
    FormSubmitted event,
    Emitter<LoginState> emit,
  ) async {
    if (state is LoginFormState) {
      final formState = state as LoginFormState;

      String email = formState.email.trim();
      String password = formState.password;
      print("Email: $email");
      print("Password: $password");

      String? emailError;
      String? passwordError;

      final emailRegex = RegExp(
        r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?)*$",
      );

      if (email.isEmpty) {
        emailError = 'Email is required';
      } else if (!emailRegex.hasMatch(email)) {
        emailError = 'Enter a valid email address';
      }

      if (password.isEmpty) {
        passwordError = 'Password is required';
      } else if (password.length < 6) {
        passwordError = 'Invalid password';
      }

      if (emailError != null || passwordError != null) {
        emit(
          formState.copyWith(
            emailError: emailError,
            passwordError: passwordError,
          ),
        );
        return;
      }

      emit(LoginLoadingState());

      try {
        final loginRequest = LoginRequest(
          login: email,
          password: password,
          fcmToken: ObjectFactory().prefs.getFcmToken().toString(), loginType: 3,
        );
        final stateModel = await authDataProvider.loginUser(loginRequest);
        print("EmailAfter: $email");
        print("PasswordAfter: $password");

        if (stateModel.isSuccess) {
          emit(
            LoginSuccessState(
              loginRequestResponse: stateModel.data as LoginRequestResponse,
            ),
          );
          emit(formState.copyWith());
        } else if (stateModel.isError) {
          emit(LoginFailureState(stateModel.error as String));
          emit(formState.copyWith());
        } else {
          emit(const LoginFailureState("Unknown error occurred"));
          emit(formState.copyWith());
        }
      } catch (e) {
        emit(LoginFailureState("Exception: ${e.toString()}"));
        emit(formState.copyWith());
      }
    }
  }

  Future<void> _handleGoogleLogin(
    GetGoogleLoginEvent event,
    Emitter<LoginState> emit,
  ) async {
    try {
      emit(GoogleLoginLoading());
      await Future.delayed(Duration(seconds: 1));

      final response = await authDataProvider.googleLogin(
        event.googleLoginRequest,
      );
      if (response!.data.status == true) {
        emit(GoogleLoginLoaded(googleLoginResponse: response.data));
      } else {
        emit(GoogleLoginErrorState(msg: response.data.message));
      }
    } catch (e) {
      emit(GoogleLoginErrorState(msg: e.toString()));
    }
  }

  Future<void> _handleAppleLogin(
    GetAppleLoginEvent event,
    Emitter<LoginState> emit,
  ) async {
    try {
      emit(LoginWithAppleLoading());
      await Future.delayed(Duration(seconds: 1));

      final response = await authDataProvider.appleLogin(
        event.appleLoginRequest,
      );

      if (response!.data.status == true) {
        emit(LoginWithAppleLoaded(appleLoginRequestResponse: response.data));
      } else {
        // Pass appleId from response
        emit(
          LoginWithAppleError(
            response.data.message,
            response.data,
            response.data.appleId,
          ),
        );
      }
    } catch (e) {
      // Optional: Pass appleId from event if available
      emit(LoginWithAppleError(e.toString(), null, null));
    }
  }
}
