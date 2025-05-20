part of 'verification_bloc.dart';

sealed class VerificationEvent extends Equatable {
  const VerificationEvent();
}

class VerifyOtpEvent extends VerificationEvent {
  final OtpVerifyRequest otpVerifyRequest;
  const VerifyOtpEvent({required this.otpVerifyRequest});
  @override
  List<Object?> get props => [otpVerifyRequest];

}