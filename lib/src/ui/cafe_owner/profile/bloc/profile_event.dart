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

class ToggleVenueType extends ProfileEvent {
  final String venueType;
  final bool isSelected;

  const ToggleVenueType({required this.venueType, required this.isSelected});

  @override
  List<Object?> get props => [venueType, isSelected];
}

class UpdateOpeningHour extends ProfileEvent {
  final String day;
  final ProfileOpeningHour hour;
  const UpdateOpeningHour(this.day, this.hour);

  @override
  List<Object?> get props => [day, hour];
}

class SubmitProfile extends ProfileEvent {
  @override
  List<Object?> get props => [];
}

class PickImageFromGalleryEvent extends ProfileEvent {
  @override
  List<Object?> get props => [];
}

class FetchCafeProfile extends ProfileEvent {
  final String id;

  const FetchCafeProfile(this.id);

  @override
  List<Object?> get props => [id];
}

class EditProfileLoaded extends ProfileState {
  final CafeProfile profileData; // ✅ new version

  const EditProfileLoaded({required this.profileData});

  @override
  List<Object> get props => [profileData];
}

class EditProfileLoadError extends ProfileState {
  final String errorMessage;

  EditProfileLoadError({required this.errorMessage});
}

class FetchEditCafeProfile extends ProfileEvent {
  final String id;

  const FetchEditCafeProfile(this.id);

  @override
  List<Object?> get props => [id];
}
