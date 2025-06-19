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
      final nameError = _validateName(event.name);
      _formState = _formState.copyWith(
        name: event.name,
        nameError: nameError,
        isFormValid: _isFormValid(_formState.copyWith(
          name: event.name,
          nameError: nameError,
        )),
      );
      emit(_formState);
    });

    on<EmailChanged>((event, emit) {
      final emailError = _validateEmail(event.email);
      _formState = _formState.copyWith(
        email: event.email,
        emailError: emailError,
        isFormValid: _isFormValid(_formState.copyWith(
          email: event.email,
          emailError: emailError,
        )),
      );
      emit(_formState);
    });

    on<PasswordChanged>((event, emit) {
      final passwordError = _validatePassword(event.password);

      // Revalidate confirm password if it exists
      String? confirmPasswordError = _formState.confirmPasswordError;
      if (_formState.confirmPassword.isNotEmpty) {
        confirmPasswordError = _validateConfirmPassword(
            _formState.confirmPassword,
            event.password
        );
      }

      _formState = _formState.copyWith(
        password: event.password,
        passwordError: passwordError,
        confirmPasswordError: confirmPasswordError,
        passwordStrength: _calculatePasswordStrength(event.password),
        isFormValid: _isFormValid(_formState.copyWith(
          password: event.password,
          passwordError: passwordError,
          confirmPasswordError: confirmPasswordError,
        )),
      );
      emit(_formState);
    });

    on<ConfirmPasswordChanged>((event, emit) {
      final confirmPasswordError = _validateConfirmPassword(
          event.confirmPassword,
          _formState.password
      );
      _formState = _formState.copyWith(
        confirmPassword: event.confirmPassword,
        confirmPasswordError: confirmPasswordError,
        isFormValid: _isFormValid(_formState.copyWith(
          confirmPassword: event.confirmPassword,
          confirmPasswordError: confirmPasswordError,
        )),
      );
      emit(_formState);
    });

    on<PhoneChanged>((event, emit) {
      final phoneError = _validatePhone(event.phone);
      _formState = _formState.copyWith(
        phone: event.phone,
        phoneError: phoneError,
        isFormValid: _isFormValid(_formState.copyWith(
          phone: event.phone,
          phoneError: phoneError,
        )),
      );
      emit(_formState);
    });

    on<CountryChanged>((event, emit) {
      final countryError = _validateCountry(event.country);
      _formState = _formState.copyWith(
        country: event.country,
        countryError: countryError,
        isFormValid: _isFormValid(_formState.copyWith(
          country: event.country,
          countryError: countryError,
        )),
      );
      emit(_formState);
    });

    on<RegionChanged>((event, emit) {
      final regionError = _validateRegion(event.region);
      _formState = _formState.copyWith(
        region: event.region,
        regionError: regionError,
        isFormValid: _isFormValid(_formState.copyWith(
          region: event.region,
          regionError: regionError,
        )),
      );
      emit(_formState);
    });

    on<ValidateForm>((event, emit) {
      _formState = _validateAllFields(_formState);
      emit(_formState);
    });

    on<SubmitSignUp>((event, emit) async {
      // Final validation before submission
      final validatedState = _validateAllFields(_formState.copyWith(
        name: event.signupRequest.name ?? '',
        email: event.signupRequest.email ?? '',
        password: event.signupRequest.password ?? '',
        confirmPassword: event.signupRequest.passwordConfirmation ?? '',
        phone: event.signupRequest.phone ?? '',
        country: event.signupRequest.country ?? '',
        region: event.signupRequest.region ?? '',
      ));

      if (!validatedState.isFormValid) {
        _formState = validatedState;
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
      // Final validation before submission
      final validatedState = _validateAllFields(_formState.copyWith(
        name: event.signupRequest.name ?? '',
        email: event.signupRequest.email ?? '',
        password: event.signupRequest.password ?? '',
        confirmPassword: event.signupRequest.passwordConfirmation ?? '',
        phone: event.signupRequest.phone ?? '',
        country: event.signupRequest.country ?? '',
        region: event.signupRequest.region ?? '',
      ));

      if (!validatedState.isFormValid) {
        _formState = validatedState;
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

  // Validation Methods
  String? _validateName(String name) {
    final trimmedName = name.trim();
    if (trimmedName.isEmpty) {
      return 'Name is required';
    }
    if (trimmedName.length < 2) {
      return 'Name must be at least 2 characters';
    }
    if (trimmedName.length > 50) {
      return 'Name must be less than 50 characters';
    }
    // Check for invalid characters
    // if (!RegExp(r'^[a-zA-Z\s\.\']+$').hasMatch(trimmedName)) {
    // return 'Name contains invalid characters';
    // }
  return null;
}


String? _validateEmail(String email) {
  final trimmedEmail = email.trim();
  if (trimmedEmail.isEmpty) {
    return 'Email is required';
  }

  // Enhanced email regex
  final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
  // RegExp(
  //     r'^[a-zA-Z0-9.!#$%&\'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$'
  // );

  if (!emailRegex.hasMatch(trimmedEmail)) {
  return 'Please enter a valid email address';
  }

  if (trimmedEmail.length > 254) {
  return 'Email address is too long';
  }

  return null;
}

String? _validatePassword(String password) {
  if (password.isEmpty) {
    return 'Password is required';
  }
  if (password.length < 6) {
    return 'Password must be at least 6 characters';
  }
  if (password.length > 128) {
    return 'Password must be less than 128 characters';
  }

  return null;
}

String? _validateConfirmPassword(String confirmPassword, String password) {
  if (confirmPassword.isEmpty) {
    return 'Please confirm your password';
  }
  if (confirmPassword != password) {
    return 'Passwords do not match';
  }
  return null;
}

String? _validatePhone(String phone) {
  // Phone is optional in your implementation
  if (phone.trim().isEmpty) {
    return null; // Optional field
  }

  final digitsOnly = phone.replaceAll(RegExp(r'\D'), '');

  if (digitsOnly.length < 10) {
    return 'Phone number must be at least 10 digits';
  }
  if (digitsOnly.length > 15) {
    return 'Phone number must be less than 15 digits';
  }

  return null;
}

String? _validateCountry(String country) {
  final trimmedCountry = country.trim();
  if (trimmedCountry.isEmpty) {
    return 'Country is required';
  }
  if (trimmedCountry.length < 2) {
    return 'Please enter a valid country';
  }
  if (trimmedCountry.length > 50) {
    return 'Country name is too long';
  }
  return null;
}

String? _validateRegion(String region) {
  final trimmedRegion = region.trim();
  if (trimmedRegion.isEmpty) {
    return 'Region is required';
  }
  if (trimmedRegion.length < 2) {
    return 'Please enter a valid region';
  }
  if (trimmedRegion.length > 50) {
    return 'Region name is too long';
  }
  return null;
}

PasswordStrength _calculatePasswordStrength(String password) {
  if (password.isEmpty) return PasswordStrength.none;

  int score = 0;

  // Length
  if (password.length >= 8) score++;
  if (password.length >= 12) score++;

  // Character variety
  if (RegExp(r'[a-z]').hasMatch(password)) score++;
  if (RegExp(r'[A-Z]').hasMatch(password)) score++;
  if (RegExp(r'\d').hasMatch(password)) score++;
  if (RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password)) score++;

  // Bonus for length
  if (password.length >= 16) score++;

  if (score <= 2) return PasswordStrength.weak;
  if (score <= 4) return PasswordStrength.medium;
  if (score <= 6) return PasswordStrength.strong;
  return PasswordStrength.veryStrong;
}

SignUpFormState _validateAllFields(SignUpFormState state) {
  return state.copyWith(
    nameError: _validateName(state.name),
    emailError: _validateEmail(state.email),
    passwordError: _validatePassword(state.password),
    confirmPasswordError: _validateConfirmPassword(state.confirmPassword, state.password),
    phoneError: _validatePhone(state.phone),
    countryError: _validateCountry(state.country),
    regionError: _validateRegion(state.region),
    passwordStrength: _calculatePasswordStrength(state.password),
    isFormValid: _isFormValid(state),
  );
}

bool _isFormValid(SignUpFormState state) {
  return _validateName(state.name) == null &&
      _validateEmail(state.email) == null &&
      _validatePassword(state.password) == null &&
      _validateConfirmPassword(state.confirmPassword, state.password) == null &&
      _validatePhone(state.phone) == null &&
      _validateCountry(state.country) == null &&
      _validateRegion(state.region) == null;
}
}