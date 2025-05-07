part of 'profile_bloc.dart';

/*sealed class ProfileState extends Equatable {
  const ProfileState();
}*/

final class ProfileInitial extends ProfileState {
  @override
  List<Object> get props => [];
}

class ProfileOpeningHour extends Equatable {
  final bool isEnabled;
  final TimeOfDay from;
  final TimeOfDay to;

  const ProfileOpeningHour({
    required this.isEnabled,
    required this.from,
    required this.to,
  });

  ProfileOpeningHour copyWith({
    bool? isEnabled,
    TimeOfDay? from,
    TimeOfDay? to,
  }) {
    return ProfileOpeningHour(
      isEnabled: isEnabled ?? this.isEnabled,
      from: from ?? this.from,
      to: to ?? this.to,
    );
  }

  @override
  List<Object?> get props => [isEnabled, from, to];
}
class ProfileState extends Equatable {
  final String venueName;
  final String venueDescription;
  final String email;
  final String password;
  final String confirmPassword;
  final String phone;
  final String address;
  final String postalCode;
  final Map<String, bool> venueTypes;
  final Map<String, ProfileOpeningHour> openingHours;
  final XFile? image;


  const ProfileState({
    this.venueName = '',
    this.venueDescription = '',
    this.email = '',
    this.password = '',
    this.confirmPassword = '',
    this.phone = '',
    this.address = '',
    this.postalCode = '',
    this.venueTypes = const {  'Restuarant': true,
      'Cafe': true,
      'Bakeries': true,
      'Dessert Venue': false,
      'Pub&Bars': false,
      'Clubs': false,
      'Activity Venue': false,
      'Hotel Restaurant/Cafe': false,},
    this.openingHours = const {},
    this.image,

  });

  ProfileState copyWith({
    String? venueName,
    String? venueDescription,
    String? email,
    String? password,
    String? confirmPassword,
    String? phone,
    String? address,
    String? postalCode,
    Map<String, bool>? venueTypes,
    Map<String, ProfileOpeningHour>? openingHours,
    XFile? image,

  }) {
    return ProfileState(
      venueName: venueName ?? this.venueName,
      venueDescription: venueDescription ?? this.venueDescription,
      email: email ?? this.email,
      password: password ?? this.password,
      confirmPassword: confirmPassword ?? this.confirmPassword,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      postalCode: postalCode ?? this.postalCode,
      venueTypes: venueTypes ?? this.venueTypes,
      openingHours: openingHours ?? this.openingHours,
      image: image ?? this.image,
    );
  }



  @override
  List<Object?> get props => [
    venueName,
    venueDescription,
    email,
    password,
    confirmPassword,
    phone,
    address,
    postalCode,
    venueTypes,
    openingHours,
    image,
  ];
}

class ProfileImageLoadingState extends ProfileState {

}

class ProfileImageLoadedState extends ProfileState {
  final XFile image;

  const ProfileImageLoadedState({required this.image});
}

class ProfileImageErrorState extends ProfileState {
  final String errorMessage;

  const ProfileImageErrorState({required this.errorMessage});
}