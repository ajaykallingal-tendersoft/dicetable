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

class ProfileDeleteEvent extends ProfileEvent {
  @override
  List<Object?> get props => [];
}

/// Pick cafe/eatery photo from gallery
class PickCafePhotoFromGalleryEvent extends ProfileEvent {
  @override
  List<Object?> get props => [];
}

/// Pick cafe/eatery photo from camera
class PickCafePhotoFromCameraEvent extends ProfileEvent {
  @override
  List<Object?> get props => [];
}

/// Delete a cafe/eatery photo at a specific index
class DeleteCafePhotoEvent extends ProfileEvent {
  final int index;
  const DeleteCafePhotoEvent(this.index);

  @override
  List<Object?> get props => [index];
}

/// Upload new photos to backend (optional trigger)
class UploadCafePhotosEvent extends ProfileEvent {
  final List<String> base64Photos;
  const UploadCafePhotosEvent(this.base64Photos);

  @override
  List<Object?> get props => [base64Photos];
}