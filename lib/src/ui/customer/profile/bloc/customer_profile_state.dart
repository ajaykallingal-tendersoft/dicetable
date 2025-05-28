part of 'customer_profile_bloc.dart';


class CustomerProfileState extends Equatable {
  final CustomerGetProfileResponse profile;
  final bool isEditMode;
  final bool isLoading;
  final String? errorMessage;
  final double? latitude;
  final double? longitude;

   CustomerProfileState({
    CustomerGetProfileResponse? profile,
    this.isEditMode = false,
    this.isLoading = false,
    this.errorMessage,
    this.latitude,
    this.longitude,
  }) : profile = profile ??  CustomerGetProfileResponse(
    status: false,
    data: CustomerProfileData(),
    message: '',
  );

  CustomerProfileState copyWith({
    CustomerGetProfileResponse? profile,
    bool? isEditMode,
    bool? isLoading,
    String? errorMessage,
    double? latitude,
    double? longitude,
  }) {
    return CustomerProfileState(
      profile: profile ?? this.profile,
      isEditMode: isEditMode ?? this.isEditMode,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
    );
  }

  @override
  List<Object?> get props => [profile, isEditMode, isLoading, errorMessage, latitude, longitude];
}

extension CustomerProfileDataExtension on CustomerProfileData {
  CustomerProfileData copyWithField(String field, String value) {
    switch (field) {
      case 'name':
        return copyWith(name: value);
      case 'email':
        return copyWith(email: value);
      case 'phone':
        return copyWith(phone: value);
      case 'country':
        return copyWith(country: value);
      case 'state':
        return copyWith(state: value);
      default:
        return this;
    }
  }
}