part of 'verification_bloc.dart';

sealed class VerificationState extends Equatable {
  const VerificationState();
}

final class VerificationInitial extends VerificationState {
  @override
  List<Object> get props => [];
}

final class VerificationLoading extends VerificationState {
  @override
  List<Object> get props => [];
}

final class VerificationLoaded extends VerificationState {
  final OtpVerificationResponse otpVerificationResponse;
  const VerificationLoaded({required this.otpVerificationResponse});
  @override
  List<Object> get props => [otpVerificationResponse];
}

final class VerificationErrorState extends VerificationState {
  final String errorMessage;
  const VerificationErrorState({required this.errorMessage});
  @override
  List<Object> get props => [errorMessage];
}
