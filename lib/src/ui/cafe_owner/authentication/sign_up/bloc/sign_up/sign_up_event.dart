part of 'sign_up_bloc.dart';

abstract class SignUpEvent extends Equatable {
  const SignUpEvent();

  @override
  List<Object?> get props => [];
}

class UpdateTextField extends SignUpEvent {
  final SignUpFormState Function(SignUpFormState state) update;

  const UpdateTextField(this.update);
}
class ResetFormEvent extends SignUpEvent {
  const ResetFormEvent();

  @override
  List<Object?> get props => [];
}

class ToggleVenueType extends SignUpEvent {
  final int id;
  final bool isSelected;

  const ToggleVenueType({required this.id, required this.isSelected});
}

class UpdateOpeningHour extends SignUpEvent {
  final String day;
  final OpeningHour hour;

  const UpdateOpeningHour({required this.day, required this.hour});
}

class PickImageFromGalleryEvent extends SignUpEvent {}

class ClearImageEvent extends SignUpEvent {
  @override
  List<Object?> get props => [];
}

class CaptureImageWithCameraEvent extends SignUpEvent {}

class RestoreImageEvent extends SignUpEvent {}

class SignUpRequestEvent extends SignUpEvent {
  final SignUpRequest signupRequest;
  const SignUpRequestEvent({required this.signupRequest});
  @override
  List<Object?> get props => [signupRequest];
}

class SubmitSignUp extends SignUpEvent {
  final SignUpRequest signupRequest;
  const SubmitSignUp({required this.signupRequest});
  @override
  List<Object?> get props => [signupRequest];
}

class SubmitGoogleSignUp extends SignUpEvent {
  final GoogleSignUpRequest googleSignUpRequest;
  const SubmitGoogleSignUp({required this.googleSignUpRequest});
  @override
  List<Object?> get props => [googleSignUpRequest];
}

class SubmitAppleSignUp extends SignUpEvent {
  final AppleSignUpRequest appleSignUpRequest;
  const SubmitAppleSignUp({required this.appleSignUpRequest});
  @override
  List<Object?> get props => [appleSignUpRequest];
}

class LoadVenueTypes extends SignUpEvent {}