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

class CafeProfile {
  final int id;
  final String name;
  final String venue_description;
  final String email;
  final String phone;
  final String address;
  final String city;
  final String postcode;
  final String photo;
  final List<VenueType> venueTypes;
  final List<OpeningHour> openingHours;

  CafeProfile({
    required this.id,
    required this.name,
    required this.venue_description,
    required this.email,
    required this.phone,
    required this.address,
    required this.city,
    required this.postcode,
    required this.photo,
    required this.venueTypes,
    required this.openingHours,
  });

  factory CafeProfile.fromJson(Map<String, dynamic> json) {
    return CafeProfile(
      id: json['id'],
      name: json['name'],
      venue_description: json['venue_description'],
      email: json['email'],
      phone: json['phone'],
      address: json['address'],
      city: json['city'],
      postcode: json['postcode'],
      photo: json['photo'],
      venueTypes:
          (json['venue_type'] as List)
              .map((e) => VenueType.fromJson(e))
              .toList(),
      openingHours:
          (json['opening_hours'] as List)
              .map((e) => OpeningHour.fromJson(e))
              .toList(),
    );
  }
}

class VenueType {
  final int id;
  final String title;
  final bool status;

  VenueType({required this.id, required this.title, required this.status});

  factory VenueType.fromJson(Map<String, dynamic> json) {
    return VenueType(
      id: json['id'],
      title: json['title'],
      status: json['status'] == 1,
    );
  }
}

class OpeningHour {
  final String day;
  final bool isOpen;
  final String opening;
  final String closing;

  OpeningHour({
    required this.day,
    required this.isOpen,
    required this.opening,
    required this.closing,
  });

  factory OpeningHour.fromJson(Map<String, dynamic> json) {
    return OpeningHour(
      day: json['day'],
      isOpen: json['is_open'] == 1,
      opening: json['opening'],
      closing: json['closing'],
    );
  }
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
