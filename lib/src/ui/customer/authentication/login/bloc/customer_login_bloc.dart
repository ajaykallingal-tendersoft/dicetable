import 'package:bloc/bloc.dart';
import 'package:dicetable/src/model/cafe_owner/auth/login/login_request.dart';
import 'package:dicetable/src/model/cafe_owner/auth/login/login_request_response.dart';
import 'package:dicetable/src/resources/api_providers/auth/auth_data_provider.dart';
import 'package:dicetable/src/utils/extension/state_model_extension.dart';
import 'package:equatable/equatable.dart';

part 'customer_login_event.dart';
part 'customer_login_state.dart';

class CustomerLoginBloc extends Bloc<CustomerLoginEvent, CustomerLoginState> {
  final AuthDataProvider authDataProvider;

  CustomerLoginBloc({required this.authDataProvider}) : super(LoginFormState()) {
    // Register event handlers in one place - ONE handler per event type
    on<EmailChanged>(_onEmailChanged);
    on<PasswordChanged>(_onPasswordChanged);
    on<FormSubmitted>(_onFormSubmitted);

  }

  void _onEmailChanged(EmailChanged event, Emitter<CustomerLoginState> emit) {
    if (state is LoginFormState) {
      final formState = state as LoginFormState;
      emit(formState.copyWith(email: event.email, emailError: null));
    }
  }

  void _onPasswordChanged(PasswordChanged event, Emitter<CustomerLoginState> emit) {
    if (state is LoginFormState) {
      final formState = state as LoginFormState;
      emit(formState.copyWith(password: event.password, passwordError: null));
    }
  }

  Future<void> _onFormSubmitted(FormSubmitted event, Emitter<CustomerLoginState> emit) async {
    if (state is LoginFormState) {
      final formState = state as LoginFormState;

      String email = formState.email.trim();
      String password = formState.password;
      print("Email: $email");
      print("Password: $password");

      String? emailError;
      String? passwordError;

      final emailRegex = RegExp(
          r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?)*$");

      if (email.isEmpty) {
        emailError = 'Email is required';
      } else if (!emailRegex.hasMatch(email)) {
        emailError = 'Enter a valid email address';
      }

      if (password.isEmpty) {
        passwordError = 'Password is required';
      } else if (password.length < 6) {
        passwordError = 'Password must be at least 6 characters';
      }

      if (emailError != null || passwordError != null) {
        emit(formState.copyWith(
          emailError: emailError,
          passwordError: passwordError,
        ));
        return;
      }

      emit(CustomerLoginLoadingState());

      try {
        final loginRequest = LoginRequest(login: email, password: password);
        final stateModel = await authDataProvider.loginUser(loginRequest);
        print("EmailAfter: $email");
        print("PasswordAfter: $password");

        if (stateModel.isSuccess) {
          emit(CustomerLoginSuccessState(loginRequestResponse: stateModel.data as LoginRequestResponse));
        } else if (stateModel.isError) {

          emit(CustomerLoginFailureState(stateModel.error as String));
          emit(LoginFormState(
            email: email,
            password: password,
          ));
        } else {
          emit(const CustomerLoginFailureState("Unknown error occurred"));
          emit(LoginFormState(
            email: email,
            password: password,
          ));
        }
      } catch (e) {
        emit(CustomerLoginFailureState("Exception: ${e.toString()}"));
        emit(LoginFormState(
          email: email,
          password: password,
        ));
      }
    }
  }
}

