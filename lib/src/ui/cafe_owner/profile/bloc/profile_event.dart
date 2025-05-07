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

  List<Object?> get props => [venueType,isSelected];
}


class UpdateOpeningHour extends ProfileEvent {
  final String day;
  final ProfileOpeningHour hour;

  const UpdateOpeningHour(this.day, this.hour);

  @override

  List<Object?> get props => [day,hour];
}
class SubmitProfile extends ProfileEvent {
  @override
  List<Object?> get props => [];
}

class PickImageFromGalleryEvent extends ProfileEvent {
  @override

  List<Object?> get props => [];
}