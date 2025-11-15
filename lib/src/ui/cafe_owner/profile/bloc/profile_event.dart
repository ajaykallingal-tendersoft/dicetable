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

class SaveProfileChangesEvent extends ProfileEvent {
  final ProfileUpdateRequest updateRequest;
  final bool isTextDataChanged;
  final bool isProfileImageChanged;
  final bool isGalleryChanged;

  const SaveProfileChangesEvent({
    required this.updateRequest,
    this.isTextDataChanged = false,
    this.isProfileImageChanged = false,
    this.isGalleryChanged = false,
  });

  @override
  List<Object?> get props => [
    updateRequest,
    isTextDataChanged,
    isProfileImageChanged,
    isGalleryChanged,
  ];
}

// --- Profile Image Picker Events ---
class PickProfileImageFromGalleryEvent extends ProfileEvent {
  @override
  List<Object?> get props => [];
}

class PickProfileImageFromCameraEvent extends ProfileEvent {
  @override
  List<Object?> get props => [];
}

// --- Gallery Image Picker Events ---
class PickGalleryImagesFromGalleryEvent extends ProfileEvent {
  @override
  List<Object?> get props => [];
}

class PickGalleryImagesFromCameraEvent extends ProfileEvent {
  @override
  List<Object?> get props => [];
}

// In profile_event.dart - ADD THIS EVENT
class DeleteGalleryPhotoEvent extends ProfileEvent {
  final DeleteGalleryImageRequest deleteGalleryImageRequest;
  final String photoId;
  final int index;

  const DeleteGalleryPhotoEvent({
    required this.photoId,
    required this.index,
    required this.deleteGalleryImageRequest,
  });

  @override
  List<Object?> get props => [photoId, index];
}

class DeleteLocalGalleryPhotoEvent extends ProfileEvent {
  final int index; // The index within the local list (galleryPhotoFiles)

  const DeleteLocalGalleryPhotoEvent({required this.index});

  @override
  List<Object?> get props => [index];
}
// Add these events to your profile_event.dart file

// Event to load countries from API
class LoadCountriesEvent extends ProfileEvent {
  const LoadCountriesEvent();

  @override
  List<Object?> get props => [];
}

// Event to select a country
class SelectCountryEvent extends ProfileEvent {
  final String countryId;
  final String countryName;

  const SelectCountryEvent({
    required this.countryId,
    required this.countryName,
  });

  @override
  List<Object?> get props => [countryId, countryName];
}