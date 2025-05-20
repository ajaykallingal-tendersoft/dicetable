import 'package:bloc/bloc.dart';
import 'package:dicetable/src/model/state_model.dart';
import 'package:dicetable/src/model/verification/otp_verification_response.dart';
import 'package:dicetable/src/model/verification/otp_verify_request.dart';
import 'package:dicetable/src/resources/api_providers/auth/auth_data_provider.dart';
import 'package:equatable/equatable.dart';

part 'verification_event.dart';
part 'verification_state.dart';

class VerificationBloc extends Bloc<VerificationEvent, VerificationState> {
  final AuthDataProvider authDataProvider;
  VerificationBloc({required this.authDataProvider}) : super(VerificationInitial()) {
    on<VerifyOtpEvent>(_onVerifyOtp);
  }
  Future<void> _onVerifyOtp(
      VerifyOtpEvent event,
      Emitter<VerificationState> emit,
      ) async {
    emit(VerificationLoading());

    final StateModel? stateModel = await authDataProvider.verifyOTP(event.otpVerifyRequest);

    if (stateModel is SuccessState) {
      final response = stateModel.value as OtpVerificationResponse;

      emit(VerificationLoaded( otpVerificationResponse: response));

    } else if (stateModel is ErrorState) {
      emit(VerificationErrorState(errorMessage: stateModel.msg));
    }
  }
}
