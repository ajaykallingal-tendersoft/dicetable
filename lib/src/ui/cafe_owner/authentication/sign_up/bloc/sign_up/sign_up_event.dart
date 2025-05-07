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

class ToggleVenueType extends SignUpEvent {
  final String venueType;
  final bool isSelected;

  const ToggleVenueType({required this.venueType, required this.isSelected});
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

class SignUpRequestEvent extends SignUpEvent{
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
