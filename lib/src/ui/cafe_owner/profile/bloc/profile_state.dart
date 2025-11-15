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
  // final List<String> cafePhotos; // URLs or base64 images to display
  final bool isUploadingPhotos;
  final List<String> gallery;
  final List<String> galleryIds;
  final File? profileImageFile;
  final String? profileImagePath;
  final List<File> galleryPhotoFiles;
  final String? successMessage;
  final bool? imageWasJustUploaded;
   final List<Country> countries;
  final bool isLoadingCountries;
  final String? countryError;
  final String countryId; // Store the selected country ID
  final String countryName;


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
    // this.cafePhotos = const [],
    this.isUploadingPhotos = false,
    this.gallery = const [],
    this.galleryIds = const [],
    this.profileImageFile,
    this.profileImagePath,
    this.galleryPhotoFiles = const [],
    this.successMessage,
    this.imageWasJustUploaded = false,
     this.countries = const [],
    this.isLoadingCountries = false,
    this.countryError,
    this.countryId = '',
    this.countryName = '',
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
    File? profileImageFile,
    String? profileImagePath,
    List<File>? galleryPhotoFiles,
    String? successMessage,
    bool? imageWasJustUploaded,
     List<Country>? countries,
    bool? isLoadingCountries,
    String? countryError,
    String? countryId,
    String? countryName,
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
        venueTypes ?? List<VenueType>.from(this.venueTypes),
    selectedVenueTypeIds:
        selectedVenueTypeIds ?? List<int>.from(this.selectedVenueTypeIds),
        openingHours:
        openingHours ?? Map<String, ProfileOpeningHour>.from(this.openingHours),
      // venueTypes:
      //     venueTypes != null
      //         ? List<VenueType>.from(venueTypes)
      //         : List<VenueType>.from(this.venueTypes),
      // selectedVenueTypeIds:
      //     selectedVenueTypeIds != null
      //         ? List<int>.from(selectedVenueTypeIds)
      //         : List<int>.from(this.selectedVenueTypeIds),
      // openingHours:
      //     openingHours != null
      //         ? Map<String, ProfileOpeningHour>.from(openingHours)
      //         : Map<String, ProfileOpeningHour>.from(this.openingHours),
      image: image ?? this.image,
      blob: blob ?? this.blob,
      originalName: originalName ?? this.originalName,
      isEditMode: isEditMode ?? this.isEditMode,
      profileViewResponse: profileViewResponse ?? this.profileViewResponse,
      profileEditViewResponse:
          profileEditViewResponse ?? this.profileEditViewResponse,
      errorMessage: errorMessage ?? this.errorMessage,
      isLoading: isLoading ?? this.isLoading,
      // cafePhotos: cafePhotos ?? this.cafePhotos,
      isUploadingPhotos: isUploadingPhotos ?? this.isUploadingPhotos,
      gallery: gallery ?? this.gallery,
      galleryIds: galleryIds ?? this.galleryIds,
      profileImageFile: profileImageFile ?? this.profileImageFile,
      profileImagePath: profileImagePath ?? this.profileImagePath,
      galleryPhotoFiles:
          galleryPhotoFiles != null
              ? List<File>.from(galleryPhotoFiles)
              : List<File>.from(this.galleryPhotoFiles),
      successMessage: successMessage,
       imageWasJustUploaded: imageWasJustUploaded ?? this.imageWasJustUploaded,
         countries: countries ?? this.countries,
      isLoadingCountries: isLoadingCountries ?? this.isLoadingCountries,
      countryError: countryError ?? this.countryError,
      countryId: countryId ?? this.countryId,
      countryName: countryName ?? this.countryName,
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
    profileImageFile,
    profileImagePath,
    galleryPhotoFiles,
    successMessage,
    imageWasJustUploaded,
       countries,
    isLoadingCountries,
    countryError,
    countryId,
    countryName,
  ];
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
       String countryId = '',
    String countryName = '',
  }) : super(
         profileViewResponse: profileViewResponse,
         gallery: gallery ?? const [], // ✅ added
         galleryIds: galleryIds ?? const [],
           countryId: countryId,
    countryName: countryName, // ✅ added
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
    String? blob,
    String? originalName,
    List<String>? gallery,
    List<String>? galleryIds,
    bool? imageWasJustUploaded,
      List<Country> countries = const [],
    bool isLoadingCountries = false,
    String? countryError,
    String countryId = '',
    String countryName = '',

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
         gallery: gallery ?? const [], // ✅ added
         galleryIds: galleryIds ?? const [], // ✅ added
         isEditMode: true,
         imageWasJustUploaded: imageWasJustUploaded ?? false,
           countries: countries,
    isLoadingCountries: isLoadingCountries,
    countryError: countryError,
    countryId: countryId,
    countryName: countryName,
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
  const ProfileUpdateError({
    required this.errorMessage,
    // keep existing fields here
    super.venueName,
    super.venueDescription,
    super.email,
    super.phone,
    super.countryName,
    super.address,
    super.postalCode,
    super.venueTypes,
    super.selectedVenueTypeIds,
    super.openingHours,
    super.gallery,
    super.galleryIds,
  });

  factory ProfileUpdateError.fromState(ProfileState state, {
    required String errorMessage,
  }) {
    return ProfileUpdateError(
      errorMessage: errorMessage,
      venueName: state.venueName,
      venueDescription: state.venueDescription,
      email: state.email,
      phone: state.phone,
      countryName: state.countryName,
      address: state.address,
      postalCode: state.postalCode,
      venueTypes: state.venueTypes,
      selectedVenueTypeIds: state.selectedVenueTypeIds,
      openingHours: state.openingHours,
      gallery: state.gallery,
      galleryIds: state.galleryIds,
    );
  }
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

//New Chnages

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
    super.profileImageFile,
    super.profileImagePath,
    required super.galleryPhotoFiles,
    super.gallery,
    super.galleryIds,
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
      profileImageFile: state.profileImageFile,
      profileImagePath: state.profileImagePath,
      galleryPhotoFiles: state.galleryPhotoFiles,
      gallery: state.gallery,
      galleryIds: state.galleryIds,
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
    required super.profileImageFile,
    required super.profileImagePath,
    required super.galleryPhotoFiles,
    super.gallery,
    super.galleryIds,
    required super.isEditMode,
    super.profileViewResponse,
    super.profileEditViewResponse,
  }) : super(isLoading: false);

  factory ProfileImageLoadedState.fromState(
    ProfileState state, {
    required File profileImageFile,
    required String profileImagePath,
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
      profileImageFile: profileImageFile,
      profileImagePath: profileImagePath,
      galleryPhotoFiles: state.galleryPhotoFiles,
      gallery: state.gallery,
      galleryIds: state.galleryIds,
      isEditMode: state.isEditMode,
      profileViewResponse: state.profileViewResponse,
      profileEditViewResponse: state.profileEditViewResponse,
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
    super.profileImageFile,
    super.profileImagePath,
    required super.galleryPhotoFiles,
    super.gallery,
    super.galleryIds,
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
      profileImageFile: state.profileImageFile,
      profileImagePath: state.profileImagePath,
      galleryPhotoFiles: state.galleryPhotoFiles,
      gallery: state.gallery,
      galleryIds: state.galleryIds,
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
    super.profileImageFile,
    super.profileImagePath,
    required super.galleryPhotoFiles,
    super.gallery,
    super.galleryIds,
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
      profileImageFile: state.profileImageFile,
      profileImagePath: state.profileImagePath,
      galleryPhotoFiles: state.galleryPhotoFiles,
      gallery: state.gallery,
      galleryIds: state.galleryIds,
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

// Profile Image Upload States
class ProfileImageUploadLoading extends ProfileState {
  factory ProfileImageUploadLoading.fromState(ProfileState state) {
    return ProfileImageUploadLoading(
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
      profileImageFile: state.profileImageFile,
      profileImagePath: state.profileImagePath,
      galleryPhotoFiles: state.galleryPhotoFiles,
      gallery: state.gallery,
      galleryIds: state.galleryIds,
      isEditMode: state.isEditMode,
      profileViewResponse: state.profileViewResponse,
      profileEditViewResponse: state.profileEditViewResponse,
    );
  }

  const ProfileImageUploadLoading({
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
    super.profileImageFile,
    super.profileImagePath,
    required super.galleryPhotoFiles,
    super.gallery,
    super.galleryIds,
    required super.isEditMode,
    super.profileViewResponse,
    super.profileEditViewResponse,
  }) : super(isLoading: true);
}

class ProfileImageUploadSuccess extends ProfileState {
  factory ProfileImageUploadSuccess.fromState(
    ProfileState state, {
    required String message,
  }) {
    return ProfileImageUploadSuccess(
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
      galleryPhotoFiles: state.galleryPhotoFiles,
      gallery: state.gallery,
      galleryIds: state.galleryIds,
      isEditMode: state.isEditMode,
      profileViewResponse: state.profileViewResponse,
      profileEditViewResponse: state.profileEditViewResponse,
      successMessage: message,
    );
  }

  const ProfileImageUploadSuccess({
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
    required super.galleryPhotoFiles,
    super.gallery,
    super.galleryIds,
    required super.isEditMode,
    super.profileViewResponse,
    super.profileEditViewResponse,
    super.successMessage,
  }) : super(isLoading: false);
}

class ProfileImageUploadError extends ProfileState {
  factory ProfileImageUploadError.fromState(
    ProfileState state, {
    required String errorMessage,
  }) {
    return ProfileImageUploadError(
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
      profileImageFile: state.profileImageFile,
      profileImagePath: state.profileImagePath,
      galleryPhotoFiles: state.galleryPhotoFiles,
      gallery: state.gallery,
      galleryIds: state.galleryIds,
      isEditMode: state.isEditMode,
      profileViewResponse: state.profileViewResponse,
      profileEditViewResponse: state.profileEditViewResponse,
      errorMessage: errorMessage,
    );
  }

  const ProfileImageUploadError({
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
    super.profileImageFile,
    super.profileImagePath,
    required super.galleryPhotoFiles,
    super.gallery,
    super.galleryIds,
    required super.isEditMode,
    super.profileViewResponse,
    super.profileEditViewResponse,
    super.errorMessage,
  }) : super(isLoading: false);
}

// ============ Gallery Photo States ============
class GalleryPhotoLoadingState extends ProfileState {
  factory GalleryPhotoLoadingState.fromState(ProfileState state) {
    return GalleryPhotoLoadingState(
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
      profileImageFile: state.profileImageFile,
      profileImagePath: state.profileImagePath,
      galleryPhotoFiles: state.galleryPhotoFiles,
      gallery: state.gallery,
      galleryIds: state.galleryIds,
      isEditMode: state.isEditMode,
      profileViewResponse: state.profileViewResponse,
      profileEditViewResponse: state.profileEditViewResponse,
    );
  }

  const GalleryPhotoLoadingState({
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
    super.profileImageFile,
    super.profileImagePath,
    required super.galleryPhotoFiles,
    super.gallery,
    super.galleryIds,
    required super.isEditMode,
    super.profileViewResponse,
    super.profileEditViewResponse,
  }) : super(isLoading: true);
}

class GalleryPhotoLoadedState extends ProfileState {
  factory GalleryPhotoLoadedState.fromState(
    ProfileState state, {
    required List<File> galleryPhotoFiles,
  }) {
    return GalleryPhotoLoadedState(
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
      profileImageFile: state.profileImageFile,
      profileImagePath: state.profileImagePath,
      galleryPhotoFiles: galleryPhotoFiles,
      gallery: state.gallery,
      galleryIds: state.galleryIds,
      isEditMode: state.isEditMode,
      profileViewResponse: state.profileViewResponse,
      profileEditViewResponse: state.profileEditViewResponse,
    );
  }

  const GalleryPhotoLoadedState({
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
    super.profileImageFile,
    super.profileImagePath,
    required super.galleryPhotoFiles,
    super.gallery,
    super.galleryIds,
    required super.isEditMode,
    super.profileViewResponse,
    super.profileEditViewResponse,
  }) : super(isLoading: false);
}

class GalleryPhotoErrorState extends ProfileState {
  factory GalleryPhotoErrorState.fromState(
    ProfileState state, {
    String? errorMessage,
  }) {
    return GalleryPhotoErrorState(
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
      profileImageFile: state.profileImageFile,
      profileImagePath: state.profileImagePath,
      galleryPhotoFiles: state.galleryPhotoFiles,
      gallery: state.gallery,
      galleryIds: state.galleryIds,
      isEditMode: state.isEditMode,
      profileViewResponse: state.profileViewResponse,
      profileEditViewResponse: state.profileEditViewResponse,
      errorMessage: errorMessage,
    );
  }

  const GalleryPhotoErrorState({
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
    super.profileImageFile,
    super.profileImagePath,
    required super.galleryPhotoFiles,
    super.gallery,
    super.galleryIds,
    required super.isEditMode,
    super.profileViewResponse,
    super.profileEditViewResponse,
    super.errorMessage,
  }) : super(isLoading: false);
}

class GalleryPhotoPermissionDeniedState extends ProfileState {
  final bool isPermanentlyDenied;

  factory GalleryPhotoPermissionDeniedState.fromState(
    ProfileState state, {
    required bool isPermanentlyDenied,
    required String errorMessage,
  }) {
    return GalleryPhotoPermissionDeniedState(
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
      profileImageFile: state.profileImageFile,
      profileImagePath: state.profileImagePath,
      galleryPhotoFiles: state.galleryPhotoFiles,
      gallery: state.gallery,
      galleryIds: state.galleryIds,
      isEditMode: state.isEditMode,
      profileViewResponse: state.profileViewResponse,
      profileEditViewResponse: state.profileEditViewResponse,
      errorMessage: errorMessage,
      isPermanentlyDenied: isPermanentlyDenied,
    );
  }

  const GalleryPhotoPermissionDeniedState({
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
    super.profileImageFile,
    super.profileImagePath,
    required super.galleryPhotoFiles,
    super.gallery,
    super.galleryIds,
    required super.isEditMode,
    super.profileViewResponse,
    super.profileEditViewResponse,
    super.errorMessage,
    required this.isPermanentlyDenied,
  }) : super(isLoading: false);

  @override
  List<Object?> get props => [...super.props, isPermanentlyDenied];
}

// Gallery Photo Upload States
class GalleryPhotoUploadLoading extends ProfileState {
  factory GalleryPhotoUploadLoading.fromState(ProfileState state) {
    return GalleryPhotoUploadLoading(
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
      profileImageFile: state.profileImageFile,
      profileImagePath: state.profileImagePath,
      galleryPhotoFiles: state.galleryPhotoFiles,
      gallery: state.gallery,
      galleryIds: state.galleryIds,
      isEditMode: state.isEditMode,
      profileViewResponse: state.profileViewResponse,
      profileEditViewResponse: state.profileEditViewResponse,
    );
  }

  const GalleryPhotoUploadLoading({
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
    super.profileImageFile,
    super.profileImagePath,
    required super.galleryPhotoFiles,
    super.gallery,
    super.galleryIds,
    required super.isEditMode,
    super.profileViewResponse,
    super.profileEditViewResponse,
  }) : super(isLoading: true);
}

class GalleryPhotoUploadSuccess extends ProfileState {
  factory GalleryPhotoUploadSuccess.fromState(
    ProfileState state, {
    required String message,
  }) {
    return GalleryPhotoUploadSuccess(
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
      profileImageFile: state.profileImageFile,
      profileImagePath: state.profileImagePath,
      galleryPhotoFiles: state.galleryPhotoFiles,
      gallery: state.gallery,
      galleryIds: state.galleryIds,
      isEditMode: state.isEditMode,
      profileViewResponse: state.profileViewResponse,
      profileEditViewResponse: state.profileEditViewResponse,
      successMessage: message,
    );
  }

  const GalleryPhotoUploadSuccess({
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
    super.profileImageFile,
    super.profileImagePath,
    required super.galleryPhotoFiles,
    super.gallery,
    super.galleryIds,
    required super.isEditMode,
    super.profileViewResponse,
    super.profileEditViewResponse,
    super.successMessage,
  }) : super(isLoading: false);
}

class GalleryPhotoUploadError extends ProfileState {
  factory GalleryPhotoUploadError.fromState(
    ProfileState state, {
    required String errorMessage,
  }) {
    return GalleryPhotoUploadError(
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
      profileImageFile: state.profileImageFile,
      profileImagePath: state.profileImagePath,
      galleryPhotoFiles: state.galleryPhotoFiles,
      gallery: state.gallery,
      galleryIds: state.galleryIds,
      isEditMode: state.isEditMode,
      profileViewResponse: state.profileViewResponse,
      profileEditViewResponse: state.profileEditViewResponse,
      errorMessage: errorMessage,
    );
  }

  const GalleryPhotoUploadError({
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
    super.profileImageFile,
    super.profileImagePath,
    required super.galleryPhotoFiles,
    super.gallery,
    super.galleryIds,
    required super.isEditMode,
    super.profileViewResponse,
    super.profileEditViewResponse,
    super.errorMessage,
  }) : super(isLoading: false);
}

// Gallery Photo Delete States
class GalleryPhotoDeleteLoading extends ProfileState {
  factory GalleryPhotoDeleteLoading.fromState(ProfileState state) {
    return GalleryPhotoDeleteLoading(
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
      profileImageFile: state.profileImageFile,
      profileImagePath: state.profileImagePath,
      galleryPhotoFiles: state.galleryPhotoFiles,
      gallery: state.gallery,
      galleryIds: state.galleryIds,
      isEditMode: state.isEditMode,
      profileViewResponse: state.profileViewResponse,
      profileEditViewResponse: state.profileEditViewResponse,
    );
  }

  const GalleryPhotoDeleteLoading({
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
    super.profileImageFile,
    super.profileImagePath,
    required super.galleryPhotoFiles,
    super.gallery,
    super.galleryIds,
    required super.isEditMode,
    super.profileViewResponse,
    super.profileEditViewResponse,
  }) : super(isLoading: true);
}

class GalleryPhotoDeleteSuccess extends ProfileState {
  factory GalleryPhotoDeleteSuccess.fromState(
    ProfileState state, {
    required List<String> gallery,
    required List<String> galleryIds,
  }) {
    return GalleryPhotoDeleteSuccess(
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
      profileImageFile: state.profileImageFile,
      profileImagePath: state.profileImagePath,
      galleryPhotoFiles: state.galleryPhotoFiles,
      gallery: gallery,
      galleryIds: galleryIds,
      isEditMode: state.isEditMode,
      profileViewResponse: state.profileViewResponse,
      profileEditViewResponse: state.profileEditViewResponse,
    );
  }

  const GalleryPhotoDeleteSuccess({
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
    super.profileImageFile,
    super.profileImagePath,
    required super.galleryPhotoFiles,
    super.gallery,
    super.galleryIds,
    required super.isEditMode,
    super.profileViewResponse,
    super.profileEditViewResponse,
  }) : super(isLoading: false);
}

class GalleryPhotoDeleteError extends ProfileState {
  factory GalleryPhotoDeleteError.fromState(
    ProfileState state, {
    required String errorMessage,
  }) {
    return GalleryPhotoDeleteError(
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
      profileImageFile: state.profileImageFile,
      profileImagePath: state.profileImagePath,
      galleryPhotoFiles: state.galleryPhotoFiles,
      gallery: state.gallery,
      galleryIds: state.galleryIds,
      isEditMode: state.isEditMode,
      profileViewResponse: state.profileViewResponse,
      profileEditViewResponse: state.profileEditViewResponse,
      errorMessage: errorMessage,
    );
  }

  const GalleryPhotoDeleteError({
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
    super.profileImageFile,
    super.profileImagePath,
    required super.galleryPhotoFiles,
    super.gallery,
    super.galleryIds,
    required super.isEditMode,
    super.profileViewResponse,
    super.profileEditViewResponse,
    super.errorMessage,
  }) : super(isLoading: false);
}

// file: bloc/profile/profile_state.dart

// ... (Rest of your State definitions)

class ProfileSaveSuccess extends ProfileState {
  final String message;

  // Constructor to create the success state from an existing state instance
  ProfileSaveSuccess.fromState(ProfileState state, {required this.message})
    : super(
        // --- Pass all properties from the existing state to the super constructor ---
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
        profileImageFile: state.profileImageFile,
        profileImagePath: state.profileImagePath,
        galleryPhotoFiles: state.galleryPhotoFiles,
        gallery: state.gallery,
        galleryIds: state.galleryIds,
        isEditMode: state.isEditMode,
        profileViewResponse: state.profileViewResponse,
        profileEditViewResponse: state.profileEditViewResponse,
        // Clear any existing error message since this is a success state
        errorMessage: null,
      );

  @override
  List<Object?> get props => [
    // Include properties from base state plus the new message
    ...super.props,
    message,
  ];
}

class ProfileNoChangeDetected extends ProfileState {
  final String message;

  const ProfileNoChangeDetected({
    required this.message,
    required super.venueName,
    required super.venueDescription,
    required super.email,
    required super.phone,
    required super.address,
    required super.country,
    required super.postalCode,
    required super.gallery,
    required super.galleryPhotoFiles,
    required super.galleryIds,
    required super.venueTypes,
    required super.selectedVenueTypeIds,
    required super.openingHours,
  });
}
