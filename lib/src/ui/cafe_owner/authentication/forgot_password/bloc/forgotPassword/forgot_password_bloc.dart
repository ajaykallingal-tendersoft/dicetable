import 'package:bloc/bloc.dart';
import 'package:soloseaters/src/model/cafe_owner/auth/forgot_password/forgot_password_request.dart';
import 'package:soloseaters/src/model/cafe_owner/auth/forgot_password/forgot_password_request_response.dart';
import 'package:soloseaters/src/model/cafe_owner/auth/forgot_password/resend_otp_request.dart';
import 'package:soloseaters/src/model/state_model.dart';
import 'package:soloseaters/src/resources/api_providers/auth/auth_data_provider.dart';
import 'package:soloseaters/src/ui/verification/bloc/verification_bloc.dart';
import 'package:equatable/equatable.dart';

part 'forgot_password_event.dart';
part 'forgot_password_state.dart';

class ForgotPasswordBloc extends Bloc<ForgotPasswordEvent, ForgotPasswordState> {
  final AuthDataProvider authDataProvider;
  ForgotPasswordBloc({required this.authDataProvider}) : super(ForgotPasswordInitial()) {
    on<GetForgotPasswordEvent>((event, emit) async {
      emit(ForgotPasswordLoading());
      final StateModel? stateModel = await authDataProvider.forgotPassword(event.forgotPasswordRequest);
      if (stateModel is SuccessState) {
        emit(ForgotPasswordLoaded(forgotPasswordRequestResponse: stateModel.value));
      } else if (stateModel is ErrorState) {
        emit(ForgotPasswordError(errorMessage: stateModel.msg));
      }
    });

    on<ResendOtpEvent>((event, emit) async {
      emit(ResendOtpLoading());
      final StateModel? stateModel = await authDataProvider.resendOtp(event.resendOtpRequest);
      if (stateModel is SuccessState) {
        emit(ResendOtpSuccess(forgotPasswordRequestResponse: stateModel.value));
      } else if (stateModel is ErrorState) {
        emit(ResendOtpError(errorMessage: stateModel.msg));
      }
    });

    // on<VerifyOtpEvent>((event, emit) async {
    //   emit(VerificationLoading());
    //   final StateModel? stateModel = await authDataProvider.verifyOtp(event.otpVerifyRequest);
    //   if (stateModel is SuccessState) {
    //     emit(VerificationLoaded(forgotPasswordRequestResponse: stateModel.value));
    //   } else if (stateModel is ErrorState) {
    //     emit(VerificationError(errorMessage: stateModel.msg));
    //   }
    // });
  }
}
