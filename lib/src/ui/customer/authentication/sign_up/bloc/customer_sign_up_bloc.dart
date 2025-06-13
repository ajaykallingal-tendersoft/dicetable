import 'package:bloc/bloc.dart';
import 'package:dicetable/src/model/cafe_owner/auth/signUp/google_sign-up_request.dart';
import 'package:dicetable/src/model/cafe_owner/auth/signUp/google_sign-up_response.dart';
import 'package:dicetable/src/model/cafe_owner/auth/signUp/sign_up_request.dart';
import 'package:dicetable/src/model/cafe_owner/auth/signUp/sign_up_request_response.dart';
import 'package:dicetable/src/resources/api_providers/auth/auth_data_provider.dart';
import 'package:dicetable/src/utils/extension/state_model_extension.dart';
import 'package:equatable/equatable.dart';

part 'customer_sign_up_event.dart';
part 'customer_sign_up_state.dart';

class CustomerSignUpBloc extends Bloc<CustomerSignUpEvent, CustomerSignUpState> {
  final AuthDataProvider authDataProvider;
  SignUpFormState _formState;

  CustomerSignUpBloc({required this.authDataProvider})
      : _formState = SignUpFormState(),
        super(SignUpFormState()) {
    on<UpdateTextField>((event, emit) {
      _formState = event.update(_formState);
      emit(_formState);
    });

    on<NameChanged>((event, emit) {
      final nameError = event.name.trim().isEmpty ? 'Name field is required' : null;
      _formState = _formState.copyWith(
        name: event.name,
        nameError: nameError,
      );
      emit(_formState);
    });

    on<EmailChanged>((event, emit) {
      String? emailError;
      final emailRegex = RegExp(
          r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?)*$");
      if (event.email.trim().isEmpty) {
        emailError = 'Email is required';
      } else if (!emailRegex.hasMatch(event.email.trim())) {
        emailError = 'Enter a valid email';
      }
      _formState = _formState.copyWith(
        email: event.email,
        emailError: emailError,
      );
      emit(_formState);
    });

    on<PasswordChanged>((event, emit) {
      String? passwordError;
      if (event.password.trim().isEmpty) {
        passwordError = 'Password field is required';
      } else if (event.password.length < 6) {
        passwordError = 'Enter a Strong Password';
      }

      String? confirmPasswordError = _formState.confirmPasswordError;
      if (_formState.confirmPassword.isNotEmpty) {
        if (_formState.confirmPassword != event.password) {
          confirmPasswordError = 'Enter the correct password';
        } else {
          confirmPasswordError = null;
        }
      }

      _formState = _formState.copyWith(
        password: event.password,
        passwordError: passwordError,
        confirmPasswordError: confirmPasswordError,
      );
      emit(_formState);
    });

    on<ConfirmPasswordChanged>((event, emit) {
      final confirmPasswordError = event.confirmPassword.trim().isEmpty
          ? 'Confirm Password is required'
          : event.confirmPassword != _formState.password
          ? 'Enter the correct password'
          : null;
      _formState = _formState.copyWith(
        confirmPassword: event.confirmPassword,
        confirmPasswordError: confirmPasswordError,
      );
      emit(_formState);
    });

    on<PhoneChanged>((event, emit) {
      _formState = _formState.copyWith(
        phone: event.phone,
        phoneError: null, // Phone is optional, so no validation error
      );
      emit(_formState);
    });

    on<CountryChanged>((event, emit) {
      final countryError = event.country.trim().isEmpty ? 'Country field is required' : null;
      _formState = _formState.copyWith(
        country: event.country,
        countryError: countryError,
      );
      emit(_formState);
    });

    on<RegionChanged>((event, emit) {
      final regionError = event.region.trim().isEmpty ? 'Region field is required' : null;
      _formState = _formState.copyWith(
        region: event.region,
        regionError: regionError,
      );
      emit(_formState);
    });

    on<SubmitSignUp>((event, emit) async {
      final nameError = event.signupRequest.name!.trim().isEmpty
          ? 'Name field is required'
          : null;
      String? emailError;
      String? passwordError;
      String? confirmPasswordError;
      final countryError = event.signupRequest.country!.trim().isEmpty
          ? 'Country field is required'
          : null;
      final regionError = event.signupRequest.region!.trim().isEmpty
          ? 'Region field is required'
          : null;

      final emailRegex = RegExp(
          r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?)*$");

      if (event.signupRequest.email!.trim().isEmpty) {
        emailError = 'Email is required';
      } else if (!emailRegex.hasMatch(event.signupRequest.email!.trim())) {
        emailError = 'Enter a valid email';
      }
      if (event.signupRequest.password!.trim().isEmpty) {
        passwordError = 'Password field is required';
      } else if (event.signupRequest.password!.length < 6) {
        passwordError = 'Enter a Strong Password';
      }
      if (event.signupRequest.passwordConfirmation!.trim().isEmpty) {
        confirmPasswordError = 'Confirm Password is required';
      } else if (event.signupRequest.passwordConfirmation !=
          event.signupRequest.password) {
        confirmPasswordError = 'Enter the correct password';
      }

      if (nameError != null ||
          emailError != null ||
          passwordError != null ||
          confirmPasswordError != null ||
          countryError != null ||
          regionError != null) {
        _formState = _formState.copyWith(
          name: event.signupRequest.name,
          email: event.signupRequest.email,
          password: event.signupRequest.password,
          confirmPassword: event.signupRequest.passwordConfirmation,
          phone: event.signupRequest.phone ?? '',
          country: event.signupRequest.country,
          region: event.signupRequest.region,
          nameError: nameError,
          emailError: emailError,
          passwordError: passwordError,
          confirmPasswordError: confirmPasswordError,
          countryError: countryError,
          regionError: regionError,
        );
        emit(_formState);
        return;
      }

      emit(CustomerSignUpLoadingState());

      final result = await authDataProvider.registerUser(event.signupRequest);

      if (result!.isError) {
        final error = result.error;
        String errorMessage = "Something went wrong.";

        if (error is SignUpRequestResponse) {
          errorMessage = error.errors?.values.first.first ?? "Signup failed.";
        } else if (error is String) {
          errorMessage = error;
        }

        emit(CustomerSignUpErrorState(errorMessage: errorMessage));
        emit(_formState);
      } else if (result.isSuccess) {
        final response = result.data as SignUpRequestResponse;

        if (response.status == true) {
          emit(CustomerSignUpSuccessState(signUpRequestResponse: response));
        } else {
          final errorMessage = response.errors?.values.first.first ??
              "Signup failed";
          emit(CustomerSignUpErrorState(errorMessage: errorMessage));
          emit(_formState);
        }
      }
    });

    on<SubmitGoogleSignUp>((SubmitGoogleSignUp event,
        Emitter<CustomerSignUpState> emit) async {
      final nameError = event.signupRequest.name!.trim().isEmpty
          ? 'Name field is required'
          : null;
      String? emailError;
      String? passwordError;
      String? confirmPasswordError;
      final countryError = event.signupRequest.country!.trim().isEmpty
          ? 'Country field is required'
          : null;
      final regionError = event.signupRequest.region!.trim().isEmpty
          ? 'Region field is required'
          : null;

      final emailRegex = RegExp(
          r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?)*$");

      if (event.signupRequest.email!.trim().isEmpty) {
        emailError = 'Email is required';
      } else if (!emailRegex.hasMatch(event.signupRequest.email!.trim())) {
        emailError = 'Enter a valid email';
      }
      if (event.signupRequest.password!.trim().isEmpty) {
        passwordError = 'Password field is required';
      } else if (event.signupRequest.password!.length < 6) {
        passwordError = 'Enter a Strong Password';
      }
      if (event.signupRequest.passwordConfirmation!.trim().isEmpty) {
        confirmPasswordError = 'Confirm Password is required';
      } else if (event.signupRequest.passwordConfirmation !=
          event.signupRequest.password) {
        confirmPasswordError = 'Enter the correct password';
      }

      if (nameError != null ||
          emailError != null ||
          passwordError != null ||
          confirmPasswordError != null ||
          countryError != null ||
          regionError != null) {
        _formState = _formState.copyWith(
          name: event.signupRequest.name,
          email: event.signupRequest.email,
          password: event.signupRequest.password,
          confirmPassword: event.signupRequest.passwordConfirmation,
          phone: event.signupRequest.phone ?? '',
          country: event.signupRequest.country,
          region: event.signupRequest.region,
          nameError: nameError,
          emailError: emailError,
          passwordError: passwordError,
          confirmPasswordError: confirmPasswordError,
          countryError: countryError,
          regionError: regionError,
        );
        emit(_formState);
        return;
      }

      emit(GoogleSignUpLoadingState());

      final result = await authDataProvider.googleRegisterUser(
          event.signupRequest);

      if (result!.isError) {
        final error = result.error;
        String errorMessage = "Something went wrong.";

        if (error is GoogleSignUpRequestResponse) {
          errorMessage = error.errors?.values.first.first ?? "Signup failed.";
        } else if (error is String) {
          errorMessage = error;
        }

        emit(GoogleSignUpErrorState(errorMessage: errorMessage));
        emit(_formState);
      } else if (result.isSuccess) {
        final response = result.data as GoogleSignUpRequestResponse;

        if (response.status == true) {
          emit(GoogleSignUpSuccessState(googleSignUpRequestResponse: response));
        } else {
          final errorMessage = response.errors?.values.first.first ??
              "Signup failed";
          emit(GoogleSignUpErrorState(errorMessage: errorMessage));
          emit(_formState);
        }
      }
    });
  }
}
