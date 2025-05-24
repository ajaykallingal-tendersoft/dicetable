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
  final String day;

  const ProfileOpeningHour({
    required this.isEnabled,
    required this.from,
    required this.to,
    required this.day,
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
      day: day,
    );
  }

  factory ProfileOpeningHour.fromJson(Map<String, dynamic> json) {
    return ProfileOpeningHour(
      isEnabled: json['is_open'] ?? false,
      from: _parseTime(json['opening']),
      to: _parseTime(json['closing']),
      day: json['day'] ?? '',
    );
  }

  static TimeOfDay _parseTime(String timeString) {
    final parts = timeString.split(':');
    return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }

  @override
  List<Object?> get props => [isEnabled, from, to, day];
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
  // final Map<String, bool> venueTypes;
  final Map<String, ProfileOpeningHour> openingHours;
  final XFile? image;
  final CafeProfile? cafeProfile;

  const ProfileState({
    this.venueName = '',
    this.venueDescription = '',
    this.email = '',
    this.password = '',
    this.confirmPassword = '',
    this.phone = '',
    this.address = '',
    this.postalCode = '',
    // this.venueTypes = const {
    //   // 'Restuarant': true,
    //   // 'Cafe': true,
    //   // 'Bakeries': true,
    //   // 'Dessert Venue': true,
    //   // 'Pub&Bars': false,
    //   // 'Clubs': false,
    //   // 'Activity Venue': false,
    //   // 'Hotel Restaurant/Cafe': false,
    // },
    this.openingHours = const {},
    this.image,
    this.cafeProfile,
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
    CafeProfile? cafeProfile,
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
      //  Cafes venueTypes: venueTypes ?? this.venueTypes,
      openingHours: openingHours ?? this.openingHours,
      image: image ?? this.image,
      cafeProfile: cafeProfile ?? this.cafeProfile,
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
    // venueTypes,
    openingHours,
    image,
    cafeProfile,
  ];
}

class ProfileImageLoadingState extends ProfileState {}

class ProfileImageLoadedState extends ProfileState {
  final XFile image;

  const ProfileImageLoadedState({required this.image});
}

class ProfileImageErrorState extends ProfileState {
  final String errorMessage;

  const ProfileImageErrorState({required this.errorMessage});
}

class ProfileLoading extends ProfileState {}

class ProfileLoaded extends ProfileState {
  final Map<String, dynamic> profileData;

  ProfileLoaded({required this.profileData});
}

class ProfileLoadError extends ProfileState {
  final String errorMessage;

  ProfileLoadError({required this.errorMessage});
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

  CafeProfile copyWith({
    int? id,
    String? name,
    String? venueDescription,
    String? email,
    String? phone,
    String? address,
    String? city,
    String? postcode,
    String? photo,
    List<VenueType>? venueTypes,
    List<OpeningHour>? openingHours,
  }) {
    return CafeProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      venue_description: venueDescription ?? this.venue_description,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      city: city ?? this.city,
      postcode: postcode ?? this.postcode,
      photo: photo ?? this.photo,
      venueTypes: venueTypes ?? this.venueTypes,
      openingHours: openingHours ?? this.openingHours,
    );
  }
}

class VenueType {
  final int id;
  final String title;
  final bool status;
  final bool selected;

  VenueType({
    required this.id,
    required this.title,
    required this.status,
    this.selected = false,
  });

  factory VenueType.fromJson(Map<String, dynamic> json) {
    return VenueType(
      id: json['id'],
      title: json['title'],
      status: json['status'] == 1,
      selected: json['selected'] ?? false,
    );
  }

  VenueType copyWith({int? id, String? title, bool? status, bool? selected}) {
    return VenueType(
      id: id ?? this.id,
      title: title ?? this.title,
      status: status ?? this.status,
      selected: selected ?? this.selected, // ✅ Important for toggle
    );
  }
}

class OpeningHour {
  final String day;
  bool isOpen;
  String opening;
  String closing;

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
