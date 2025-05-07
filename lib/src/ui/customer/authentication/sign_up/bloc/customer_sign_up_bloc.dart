import 'package:bloc/bloc.dart';
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
  CustomerSignUpBloc({required this.authDataProvider}) :
      _formState = SignUpFormState(),
        super(CustomerSignUpInitial()) {
    on<UpdateTextField>((event, emit) {
      _formState = event.update(_formState);
      emit(_formState);
    });
    on<SubmitSignUp>((event, emit) async {
      emit(CustomerSignUpLoadingState());

      final result = await authDataProvider.registerUser(event.signupRequest);

      if (result!.isError) {
        final error = result.error;

        if (error is SignUpRequestResponse) {
          final firstError = error.errors?.values.first.first ?? "Signup failed.";
          emit(CustomerSignUpErrorState(errorMessage: firstError));
        } else if (error is String) {
          emit(CustomerSignUpErrorState(errorMessage: error));
        } else {
          emit(CustomerSignUpErrorState(errorMessage: "Something went wrong."));
        }

        // ❗️ Restore form state after showing the error
        emit(_formState);
      } else if (result.isSuccess) {
        final response = result.data as SignUpRequestResponse;

        if (response.status == true) {
          emit(CustomerSignUpSuccessState(signUpRequestResponse: response));
        } else {
          emit(CustomerSignUpErrorState(
            errorMessage: response.errors?.values.first.first ?? "Signup failed",
          ));

          // ❗️ Restore form state after showing the error
          emit(_formState);
        }
      }
    });

  }
}
