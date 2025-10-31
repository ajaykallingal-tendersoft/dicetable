part of 'profile_bloc.dart';

class ProfileOpeningHour extends Equatable {
  final bool isEnabled;
  final TimeOfDay from;
  final TimeOfDay to;
  final int? id;

  const ProfileOpeningHour({
    required this.isEnabled,
    required this.from,
    required this.to,
    this.id,
  });

  ProfileOpeningHour copyWith({
    bool? isEnabled,
    TimeOfDay? from,
    TimeOfDay? to,
    int? id,
  }) {
    return ProfileOpeningHour(
      isEnabled: isEnabled ?? this.isEnabled,
      from: from ?? this.from,
      to: to ?? this.to,
      id: id ?? this.id,
    );
  }

  @override
  List<Object?> get props => [isEnabled, from, to, id];
}

class ProfileState extends Equatable {
  final String venueName;
  final String venueDescription;
  final String email;
  final String password;
  final String phone;
  final String country; // Added
  final String address;
  final String city;
  final String postalCode;
  final String venueType;
  final List<VenueType> venueTypes;
  final List<int> selectedVenueTypeIds;
  final Map<String, ProfileOpeningHour> openingHours;
  final XFile? image;
  final String? blob;
  final String? originalName;
  final bool isEditMode;
  final ProfileViewResponse? profileViewResponse;
  final ProfileEditViewResponse? profileEditViewResponse;
  final String? errorMessage;
  final bool isLoading;
  final List<String> cafePhotos; // URLs or base64 images to display
  final bool isUploadingPhotos;
  final List<String>? gallery;
  final List<String>? galleryIds;

  const ProfileState({
    this.venueName = '',
    this.venueDescription = '',
    this.email = '',
    this.password = '',
    this.phone = '',
    this.country = '',
    this.address = '',
    this.city = '',
    this.postalCode = '',
    this.venueType = "",
    this.venueTypes = const [],
    this.selectedVenueTypeIds = const [],
    this.openingHours = const {},
    this.image,
    this.blob,
    this.originalName,
    this.isEditMode = false,
    this.profileViewResponse,
    this.profileEditViewResponse,
    this.errorMessage,
    this.isLoading = false,
    this.cafePhotos = const [],
    this.isUploadingPhotos = false,
    this.gallery,
    this.galleryIds,
  });

  ProfileState copyWith({
    String? venueName,
    String? venueDescription,
    String? email,
    String? password,
    String? phone,
    String? country,
    String? address,
    String? city,
    String? postalCode,
    String? venueType,
    List<VenueType>? venueTypes,
    List<int>? selectedVenueTypeIds,
    Map<String, ProfileOpeningHour>? openingHours,
    XFile? image,
    String? blob,
    String? originalName,
    bool? isEditMode,
    ProfileViewResponse? profileViewResponse,
    ProfileEditViewResponse? profileEditViewResponse,
    String? errorMessage,
    bool? isLoading,
    List<String>? cafePhotos,
    bool? isUploadingPhotos,
    List<String>? gallery,
    List<String>? galleryIds,
  }) {
    return ProfileState(
      venueName: venueName ?? this.venueName,
      venueDescription: venueDescription ?? this.venueDescription,
      email: email ?? this.email,
      password: password ?? this.password,
      phone: phone ?? this.phone,
      country: country ?? this.country,
      address: address ?? this.address,
      city: city ?? this.city,
      postalCode: postalCode ?? this.postalCode,
      venueType: venueType ?? this.venueType,
      venueTypes:
          venueTypes != null
              ? List<VenueType>.from(venueTypes)
              : List<VenueType>.from(this.venueTypes),
      selectedVenueTypeIds:
          selectedVenueTypeIds != null
              ? List<int>.from(selectedVenueTypeIds)
              : List<int>.from(this.selectedVenueTypeIds),
      openingHours:
          openingHours != null
              ? Map<String, ProfileOpeningHour>.from(openingHours)
              : Map<String, ProfileOpeningHour>.from(this.openingHours),
      image: image ?? this.image,
      blob: blob ?? this.blob,
      originalName: originalName ?? this.originalName,
      isEditMode: isEditMode ?? this.isEditMode,
      profileViewResponse: profileViewResponse ?? this.profileViewResponse,
      profileEditViewResponse:
          profileEditViewResponse ?? this.profileEditViewResponse,
      errorMessage: errorMessage ?? this.errorMessage,
      isLoading: isLoading ?? this.isLoading,
      cafePhotos: cafePhotos ?? this.cafePhotos,
      isUploadingPhotos: isUploadingPhotos ?? this.isUploadingPhotos,
      gallery: gallery ?? this.gallery,
      galleryIds: galleryIds ?? this.galleryIds,
    );
  }

  @override
  List<Object?> get props => [
    venueName,
    venueDescription,
    email,
    password,
    phone,
    country,
    address,
    city,
    postalCode,
    venueType,
    venueTypes,
    selectedVenueTypeIds,
    openingHours,
    image,
    blob,
    originalName,
    isEditMode,
    profileViewResponse,
    profileEditViewResponse,
    errorMessage,
    isLoading,
    gallery,
    galleryIds,
  ];
}

class ProfileImageLoadingState extends ProfileState {
  const ProfileImageLoadingState({
    required super.venueName,
    required super.venueDescription,
    required super.email,
    required super.password,
    required super.phone,
    required super.country,
    required super.address,
    required super.city,
    required super.postalCode,
    required super.venueType,
    required super.venueTypes,
    required super.selectedVenueTypeIds,
    required super.openingHours,
    super.image,
    super.blob,
    super.originalName,
    required super.isEditMode,
    super.profileViewResponse,
    super.profileEditViewResponse,
    super.errorMessage,
  }) : super(isLoading: true);

  factory ProfileImageLoadingState.fromState(ProfileState state) {
    return ProfileImageLoadingState(
      venueName: state.venueName,
      venueDescription: state.venueDescription,
      email: state.email,
      password: state.password,
      phone: state.phone,
      country: state.country,
      address: state.address,
      city: state.city,
      postalCode: state.postalCode,
      venueType: state.venueType,
      venueTypes: state.venueTypes,
      selectedVenueTypeIds: state.selectedVenueTypeIds,
      openingHours: state.openingHours,
      image: state.image,
      blob: state.blob,
      originalName: state.originalName,
      isEditMode: state.isEditMode,
      profileViewResponse: state.profileViewResponse,
      profileEditViewResponse: state.profileEditViewResponse,
      errorMessage: state.errorMessage,
    );
  }
}

class ProfileImageLoadedState extends ProfileState {
  const ProfileImageLoadedState({
    required super.venueName,
    required super.venueDescription,
    required super.email,
    required super.password,
    required super.phone,
    required super.country,
    required super.address,
    required super.city,
    required super.postalCode,
    required super.venueType,
    required super.venueTypes,
    required super.selectedVenueTypeIds,
    required super.openingHours,
    required super.image,
    required super.blob,
    required super.originalName,
    required super.isEditMode,
    super.profileViewResponse,
    super.profileEditViewResponse,
    super.errorMessage,
  }) : super(isLoading: false);

  factory ProfileImageLoadedState.fromState(
    ProfileState state, {
    required XFile image,
    required String blob,
    required String originalName,
  }) {
    return ProfileImageLoadedState(
      venueName: state.venueName,
      venueDescription: state.venueDescription,
      email: state.email,
      password: state.password,
      phone: state.phone,
      country: state.country,
      address: state.address,
      city: state.city,
      postalCode: state.postalCode,
      venueType: state.venueType,
      venueTypes: state.venueTypes,
      selectedVenueTypeIds: state.selectedVenueTypeIds,
      openingHours: state.openingHours,
      image: image,
      blob: blob,
      originalName: originalName,
      isEditMode: state.isEditMode,
      profileViewResponse: state.profileViewResponse,
      profileEditViewResponse: state.profileEditViewResponse,
      errorMessage: state.errorMessage,
    );
  }
}

class ProfileImageErrorState extends ProfileState {
  const ProfileImageErrorState({
    required super.venueName,
    required super.venueDescription,
    required super.email,
    required super.password,
    required super.phone,
    required super.country,
    required super.address,
    required super.city,
    required super.postalCode,
    required super.venueType,
    required super.venueTypes,
    required super.selectedVenueTypeIds,
    required super.openingHours,
    super.image,
    super.blob,
    super.originalName,
    required super.isEditMode,
    super.profileViewResponse,
    super.profileEditViewResponse,
    super.errorMessage,
  }) : super(isLoading: false);

  factory ProfileImageErrorState.fromState(
    ProfileState state, {
    String? errorMessage,
  }) {
    return ProfileImageErrorState(
      venueName: state.venueName,
      venueDescription: state.venueDescription,
      email: state.email,
      password: state.password,
      phone: state.phone,
      country: state.country,
      address: state.address,
      city: state.city,
      postalCode: state.postalCode,
      venueType: state.venueType,
      venueTypes: state.venueTypes,
      selectedVenueTypeIds: state.selectedVenueTypeIds,
      openingHours: state.openingHours,
      image: state.image,
      blob: state.blob,
      originalName: state.originalName,
      isEditMode: state.isEditMode,
      profileViewResponse: state.profileViewResponse,
      profileEditViewResponse: state.profileEditViewResponse,
      errorMessage: errorMessage,
    );
  }
}

class ProfileImagePermissionDeniedState extends ProfileState {
  final bool isPermanentlyDenied;

  const ProfileImagePermissionDeniedState({
    required super.venueName,
    required super.venueDescription,
    required super.email,
    required super.password,
    required super.phone,
    required super.country,
    required super.address,
    required super.city,
    required super.postalCode,
    required super.venueType,
    required super.venueTypes,
    required super.selectedVenueTypeIds,
    required super.openingHours,
    super.image,
    super.blob,
    super.originalName,
    required super.isEditMode,
    super.profileViewResponse,
    super.profileEditViewResponse,
    super.errorMessage,
    required this.isPermanentlyDenied,
  }) : super(isLoading: false);

  factory ProfileImagePermissionDeniedState.fromState(
    ProfileState state, {
    required bool isPermanentlyDenied,
    required String errorMessage,
  }) {
    return ProfileImagePermissionDeniedState(
      venueName: state.venueName,
      venueDescription: state.venueDescription,
      email: state.email,
      password: state.password,
      phone: state.phone,
      country: state.country,
      address: state.address,
      city: state.city,
      postalCode: state.postalCode,
      venueType: state.venueType,
      venueTypes: state.venueTypes,
      selectedVenueTypeIds: state.selectedVenueTypeIds,
      openingHours: state.openingHours,
      image: state.image,
      blob: state.blob,
      originalName: state.originalName,
      isEditMode: state.isEditMode,
      profileViewResponse: state.profileViewResponse,
      profileEditViewResponse: state.profileEditViewResponse,
      errorMessage: errorMessage,
      isPermanentlyDenied: isPermanentlyDenied,
    );
  }

  @override
  List<Object?> get props => [...super.props, isPermanentlyDenied];
}

class ProfileViewLoading extends ProfileState {
  const ProfileViewLoading() : super(isLoading: true);
}

class ProfileViewLoaded extends ProfileState {
  @override
  final ProfileViewResponse profileViewResponse;
  const ProfileViewLoaded({
    required this.profileViewResponse,
    required super.venueName,
    required super.venueDescription,
    required super.email,
    required super.phone,
    required super.country,
    required super.address,
    required super.postalCode,
    required super.venueType,
    required super.openingHours,
    List<String>? gallery,
    List<String>? galleryIds,
  }) : super(
         profileViewResponse: profileViewResponse,
         gallery: gallery,
         galleryIds: galleryIds,
       );
}

class ProfileViewError extends ProfileState {
  final String errorMessage;
  const ProfileViewError({required this.errorMessage})
    : super(errorMessage: errorMessage);
}

class ProfileEditViewLoading extends ProfileState {
  const ProfileEditViewLoading() : super(isLoading: true);
}

class ProfileEditViewLoaded extends ProfileState {
  final ProfileEditViewResponse profileEditViewResponse;
  const ProfileEditViewLoaded({
    required this.profileEditViewResponse,
    required String venueName,
    required String venueDescription,
    required String email,
    required String phone,
    required String country,
    required String address,
    required String postalCode,
    required List<VenueType> venueTypes,
    required List<int> selectedVenueTypeIds,
    required Map<String, ProfileOpeningHour> openingHours,
    XFile? image,
    String? blob, // Added
    String? originalName,
    List<String>? gallery,
    List<String>? galleryIds,
  }) : super(
         profileEditViewResponse: profileEditViewResponse,
         venueName: venueName,
         venueDescription: venueDescription,
         email: email,
         phone: phone,
         address: address,
         country: country,
         postalCode: postalCode,
         venueTypes: venueTypes,
         selectedVenueTypeIds: selectedVenueTypeIds,
         openingHours: openingHours,
         image: image,
         blob: blob,
         originalName: originalName,
         isEditMode: true,
       );
}

class ProfileEditViewError extends ProfileState {
  final String errorMessage;
  const ProfileEditViewError({required this.errorMessage})
    : super(errorMessage: errorMessage);
}

class ProfileUpdateLoading extends ProfileState {
  const ProfileUpdateLoading() : super(isLoading: true);
}

class ProfileUpdateSuccess extends ProfileState {
  final ProfileUpdateResponse profileUpdateResponse;
  const ProfileUpdateSuccess({required this.profileUpdateResponse});
}

class ProfileUpdateError extends ProfileState {
  final String errorMessage;
  const ProfileUpdateError({required this.errorMessage})
    : super(errorMessage: errorMessage);
}

class ProfileDeleteLoading extends ProfileState {}

class ProfileDeleteSuccess extends ProfileState {
  final DeleteProfileResponse cafeDeleteProfileResponse;
  const ProfileDeleteSuccess({required this.cafeDeleteProfileResponse});
}

class ProfileDeleteError extends ProfileState {
  final String errorMessage;
  const ProfileDeleteError({required this.errorMessage})
    : super(errorMessage: errorMessage);
}

// Add this to your profile_state.dart file

class ProfileImageLimitedAccessState extends ProfileState {
  final String message;

  const ProfileImageLimitedAccessState({
    required this.message,
    required super.venueName,
    required super.venueDescription,
    required super.email,
    required super.phone,
    required super.country,
    required super.address,
    required super.postalCode,
    required super.selectedVenueTypeIds,
    required super.openingHours,
    super.image,
    super.blob,
    super.originalName,
    super.isEditMode = false,
  });

  factory ProfileImageLimitedAccessState.fromState(
    ProfileState state, {
    required String message,
  }) {
    return ProfileImageLimitedAccessState(
      message: message,
      venueName: state.venueName,
      venueDescription: state.venueDescription,
      email: state.email,
      phone: state.phone,
      country: state.country,
      address: state.address,
      postalCode: state.postalCode,
      selectedVenueTypeIds: state.selectedVenueTypeIds,
      openingHours: state.openingHours,
      image: state.image,
      blob: state.blob,
      originalName: state.originalName,
      isEditMode: state.isEditMode,
    );
  }

  @override
  List<Object?> get props => [...super.props, message];
}
