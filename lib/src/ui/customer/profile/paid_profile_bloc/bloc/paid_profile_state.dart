import 'package:equatable/equatable.dart';
import 'package:image_picker/image_picker.dart';
import 'package:soloseaters/src/model/customer/profile/customer_paid_profile_response.dart';
import 'package:soloseaters/src/ui/customer/profile/paid_profile_bloc/bloc/paid_profile_bloc.dart';

class PaidProfileState extends Equatable {
  final CustomerPaidProfileResponse profile;
  final bool isLoading;
  final bool isUpdating;
  final bool updateSuccess;
  final String? errorMessage;
  final String? successMessage;

  /// Map of preference_id -> isSelected
  final Map<int, bool> localPreferences;

  /// Map of venue_id -> isNotificationEnabled
  final Map<int, bool> localVenueNotifications;

  final List<XFile> selectedBusinessImages;
  final List<XFile> selectedHobbyImages;
  final bool hasUnsavedChanges;
  final XFile? selectedProfileImage;
  final bool? imageWasJustUploaded;
  // Add this helper method
  static Map<int, bool> _initializeDefaultPreferences() {
    final Map<int, bool> defaults = {};
    for (var pref in PreferenceConstants.getStaticPreferences()) {
      if (pref.id != null) {
        defaults[pref.id!] = false;
      }
    }
    return defaults;
  }

  PaidProfileState({
    CustomerPaidProfileResponse? profile,
    this.isLoading = false,
    this.isUpdating = false,
    this.updateSuccess = false,
    this.errorMessage,
    this.successMessage,
    Map<int, bool>? localPreferences,
    this.localVenueNotifications = const {},
    this.selectedBusinessImages = const [],
    this.selectedHobbyImages = const [],
    this.hasUnsavedChanges = false,
    this.selectedProfileImage,
    this.imageWasJustUploaded = false,
  }) : profile =
           profile ??
           CustomerPaidProfileResponse(
             status: false,
             data: Data(
               myPreferences: PreferenceConstants.getStaticPreferences(),
             ),
             message: '',
           ),
       localPreferences = localPreferences ?? _initializeDefaultPreferences();

  PaidProfileState copyWith({
    CustomerPaidProfileResponse? profile,
    bool? isLoading,
    bool? isUpdating,
    bool? updateSuccess,
    String? errorMessage,
    String? successMessage,
    Map<int, bool>? localPreferences,
    Map<int, bool>? localVenueNotifications,
    List<XFile>? selectedBusinessImages,
    List<XFile>? selectedHobbyImages,
    bool? hasUnsavedChanges,
    XFile? selectedProfileImage,
    bool clearErrorMessage = false,
    bool clearSuccessMessage = false,
    bool? imageWasJustUploaded,
  }) {
    return PaidProfileState(
      profile: profile ?? this.profile,
      isLoading: isLoading ?? this.isLoading,
      isUpdating: isUpdating ?? this.isUpdating,
      updateSuccess: updateSuccess ?? this.updateSuccess,
      errorMessage:
          clearErrorMessage ? null : (errorMessage ?? this.errorMessage),
      successMessage:
          clearSuccessMessage ? null : (successMessage ?? this.successMessage),
      localPreferences: localPreferences ?? this.localPreferences,
      localVenueNotifications:
          localVenueNotifications ?? this.localVenueNotifications,
      selectedBusinessImages:
          selectedBusinessImages ?? this.selectedBusinessImages,
      selectedHobbyImages: selectedHobbyImages ?? this.selectedHobbyImages,
      hasUnsavedChanges: hasUnsavedChanges ?? this.hasUnsavedChanges,
      selectedProfileImage: selectedProfileImage ?? this.selectedProfileImage,
      imageWasJustUploaded: imageWasJustUploaded ?? this.imageWasJustUploaded,
    );
  }

  @override
  List<Object?> get props => [
    profile,
    isLoading,
    isUpdating,
    updateSuccess,
    errorMessage,
    successMessage,
    localPreferences,
    localVenueNotifications,
    selectedBusinessImages,
    selectedHobbyImages,
    hasUnsavedChanges,
    selectedProfileImage,
    imageWasJustUploaded,
  ];
}
