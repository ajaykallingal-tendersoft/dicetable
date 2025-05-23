part of 'sign_up_bloc.dart';




class OpeningHour extends Equatable {
  final bool isEnabled;
  final TimeOfDay from;
  final TimeOfDay to;

  const OpeningHour({
    required this.isEnabled,
    required this.from,
    required this.to,
  });

  OpeningHour copyWith({
    bool? isEnabled,
    TimeOfDay? from,
    TimeOfDay? to,
  }) {
    return OpeningHour(
      isEnabled: isEnabled ?? this.isEnabled,
      from: from ?? this.from,
      to: to ?? this.to,
    );
  }

  @override
  List<Object?> get props => [isEnabled, from, to];
}

abstract class SignUpState extends Equatable {
  const SignUpState();

  @override
  List<Object?> get props => [];
}

class SignUpInitial extends SignUpState {}

class SignUpLoadingState extends SignUpState {}

class SignUpSuccessState extends SignUpState {
  final SignUpRequestResponse signUpRequestResponse;
  const SignUpSuccessState({required this.signUpRequestResponse});
}

class SignUpErrorState extends SignUpState {
  final String errorMessage;

  const SignUpErrorState({required this.errorMessage});

  @override
  List<Object?> get props => [errorMessage];
}

///Google signup
class GoogleSignUpInitial extends SignUpState {}

class GoogleSignUpLoadingState extends SignUpState {}

class GoogleSignUpSuccessState extends SignUpState {
  final GoogleSignUpRequestResponse googleSignUpRequestResponse;
  const GoogleSignUpSuccessState({required this.googleSignUpRequestResponse});
}

class GoogleSignUpErrorState extends SignUpState {
  final String errorMessage;

  const GoogleSignUpErrorState({required this.errorMessage});

  @override
  List<Object?> get props => [errorMessage];
}

class SignUpImageLoadedState extends SignUpState {
  final XFile image;

  const SignUpImageLoadedState({required this.image});

  @override
  List<Object?> get props => [image];
}
class SignUpImageLoadingState extends SignUpState {}

class SignUpImageErrorState extends SignUpState {
  final String errorMessage;

  const SignUpImageErrorState({required this.errorMessage});

  @override
  List<Object?> get props => [errorMessage];
}

///Venue
class VenueLoadingState extends SignUpState {}

class VenueLoadedState extends SignUpState {
  final VenueTypeResponse venueTypeResponse;
  const VenueLoadedState({required this.venueTypeResponse});
}

class VenueErrorState extends SignUpState {
  final String errorMessage;

  const VenueErrorState({required this.errorMessage});

  @override
  List<Object?> get props => [errorMessage];
}

class SignUpFormState extends SignUpState {
  final String venueName;
  final String venueDescription;
  final String email;
  final String password;
  final String confirmPassword;
  final String phone;
  final String country;
  final String region;
  final String address;
  final String postalCode;
  final List<VenueTypeModel> venueTypes;
  final Map<String, OpeningHour> openingHours;
  final XFile? image;
  final String? base64Image;
  final bool isLoadingVenueTypes;
  final String? error;

  const SignUpFormState({
    this.venueName = '',
    this.venueDescription = '',
    this.email = '',
    this.password = '',
    this.confirmPassword = '',
    this.phone = '',
    this.country = '',
    this.region = '',
    this.address = '',
    this.postalCode = '',
    this.venueTypes = const [],
    this.openingHours = const {},
    this.image,
    this.base64Image,
    this.isLoadingVenueTypes = false,
    this.error,
  });

  SignUpFormState copyWith({
    String? venueName,
    String? venueDescription,
    String? email,
    String? password,
    String? confirmPassword,
    String? phone,
    String? country,
    String? region,
    String? address,
    String? postalCode,
    List<VenueTypeModel>? venueTypes,
    Map<String, OpeningHour>? openingHours,
    XFile? image,
    bool clearImage = false,
    String? base64Image,
    bool? isLoadingVenueTypes,
    final String? error,

  }) {
    return SignUpFormState(
      venueName: venueName ?? this.venueName,
      venueDescription: venueDescription ?? this.venueDescription,
      email: email ?? this.email,
      password: password ?? this.password,
      confirmPassword: confirmPassword ?? this.confirmPassword,
      phone: phone ?? this.phone,
      country: country ?? this.country,
      region: region ?? this.region,
      address: address ?? this.address,
      postalCode: postalCode ?? this.postalCode,
      venueTypes: venueTypes ?? this.venueTypes,
      openingHours: openingHours ?? this.openingHours,
      image: clearImage ? null : (image ?? this.image),
      base64Image: base64Image ?? this.base64Image,
      isLoadingVenueTypes: isLoadingVenueTypes ?? this.isLoadingVenueTypes,
      error: error ?? this.error,
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
    country,
    region,
    address,
    postalCode,
    venueTypes,
    openingHours,
    image,
    base64Image,
    isLoadingVenueTypes,
    error,
  ];
}