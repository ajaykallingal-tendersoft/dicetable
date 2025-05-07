part of 'profile_bloc.dart';

class ProfileState {
  final CustomerProfileModel profile;
  final bool isEditMode;

  ProfileState({required this.profile, this.isEditMode = false});

  ProfileState copyWith({
    CustomerProfileModel? profile,
    bool? isEditMode,
  }) {
    return ProfileState(
      profile: profile ?? this.profile,
      isEditMode: isEditMode ?? this.isEditMode,
    );
  }
}
