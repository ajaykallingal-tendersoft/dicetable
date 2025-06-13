part of 'profile_bloc.dart';

sealed class ProfileEvent extends Equatable {
  const ProfileEvent();
}

class UpdateTextField extends ProfileEvent {
  final Function(ProfileState) update;
  const UpdateTextField(this.update);
  @override
  List<Object?> get props => [update];
}

// class UpdateCity extends ProfileEvent { // Added
//   final String city;
//   const UpdateCity(this.city);
//   @override
//   List<Object?> get props => [city];
// }

class ToggleVenueType extends ProfileEvent {
  final int venueTypeId;
  final bool isSelected;

  const ToggleVenueType({required this.venueTypeId, required this.isSelected});

  @override
  List<Object?> get props => [venueTypeId, isSelected];
}

class UpdateOpeningHour extends ProfileEvent {
  final String day;
  final ProfileOpeningHour hour;
  const UpdateOpeningHour(this.day, this.hour);
  @override
  List<Object?> get props => [day, hour];
}

class SubmitProfile extends ProfileEvent {
  final ProfileUpdateRequest profileUpdateRequest;
  const SubmitProfile({required this.profileUpdateRequest});
  @override
  List<Object?> get props => [profileUpdateRequest];
}

class PickImageFromGalleryEvent extends ProfileEvent {
  @override
  List<Object?> get props => [];
}

class GetProfileViewEvent extends ProfileEvent {
  @override
  List<Object?> get props => [];
}

class GetProfileEditViewEvent extends ProfileEvent {
  @override
  List<Object?> get props => [];
}

class ToggleEditModeEvent extends ProfileEvent {
  @override
  List<Object?> get props => [];
}