import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:soloseaters/src/model/customer/profile/customer_paid_profile_request.dart';
import 'package:soloseaters/src/model/customer/profile/customer_paid_profile_response.dart';
import 'package:soloseaters/src/model/customer/profile/customer_paid_profile_update_response.dart';
import 'package:soloseaters/src/model/state_model.dart';
import 'package:soloseaters/src/resources/api_providers/customer/profile_data_provider.dart';
import 'package:soloseaters/src/ui/customer/profile/paid_profile_bloc/bloc/paid_profile_event.dart';
import 'package:soloseaters/src/ui/customer/profile/paid_profile_bloc/bloc/paid_profile_state.dart';
import 'package:soloseaters/src/utils/extension/state_model_extension.dart';


class PaidProfileBloc extends Bloc<PaidProfileEvent, PaidProfileState> {
  final CustomerProfileDataProvider customerProfileDataProvider;

  PaidProfileBloc({required this.customerProfileDataProvider})
      : super(PaidProfileState()) {
    on<GetPaidProfileEvent>(_onGetPaidProfile);
    on<UpdatePaidProfileEvent>(_onUpdatePaidProfile);
    on<AddBusinessImagesEvent>(_onAddBusinessImages);
    on<AddHobbyImagesEvent>(_onAddHobbyImages);
    on<RemoveBusinessImageEvent>(_onRemoveBusinessImage);
    on<RemoveHobbyImageEvent>(_onRemoveHobbyImage);
    on<ToggleVenueNotification>(_onToggleVenueNotification);
    on<TogglePreferenceEvent>(_onTogglePreference);
    on<UpdateTextFieldEvent>(_onUpdateTextField);
    on<ResetUpdateStatusEvent>(_onResetUpdateStatus);
    on<UpdateProfileImageEvent>(_onUpdateProfileImage);
  }

  /// Compress image to reduce file size
  Future<XFile?> _compressImage(XFile file) async {
    try {
      final dir = await getTemporaryDirectory();
      final ext = path.extension(file.path);
      final targetPath = path.join(
        dir.path,
        '${DateTime.now().millisecondsSinceEpoch}_c$ext',
      );

      final compressedFile = await FlutterImageCompress.compressAndGetFile(
        file.path,
        targetPath,
        quality: 85,
        minWidth: 1024,
        minHeight: 1024,
      );

      if (compressedFile != null) {
        return XFile(compressedFile.path);
      } else {
        return file;
      }
    } catch (e) {
      print('Image compression error: $e');
      return file;
    }
  }

  Future<void> _onUpdateProfileImage(
    UpdateProfileImageEvent event,
    Emitter<PaidProfileState> emit,
  ) async {
    try {
      final compressed = await _compressImage(event.image);
      if (compressed != null) {
        emit(
          state.copyWith(
            selectedProfileImage: compressed,
            hasUnsavedChanges: true,
            errorMessage: null,
          ),
        );
      }
    } catch (e) {
      emit(state.copyWith(errorMessage: 'Failed to process profile image: $e'));
    }
  }

  Future<void> _onGetPaidProfile(
    GetPaidProfileEvent event,
    Emitter<PaidProfileState> emit,
  ) async {
    emit(state.copyWith(
      isLoading: true, 
      clearErrorMessage: true,
    ));

    try {
      final StateModel? stateModel =
          await customerProfileDataProvider.getPaidCustomerProfileById();

      if (stateModel is SuccessState<CustomerPaidProfileResponse>) {
        final profile = stateModel.value;

        // Build preference map: preference_id -> isSelected
        Map<int, bool> initialPreferences = {};
        final apiPreferences = profile.data?.myPreferences ?? [];
        
        for (var pref in apiPreferences) {
          if (pref.id != null) {
            initialPreferences[pref.id!] = pref.isPreferences ?? false;
          }
        }

        // Build venue notification map: venue_id -> isEnabled
        Map<int, bool> initialVenueNotifications = {};
        final favoriteVenues = profile.data?.favoriteVenues ?? [];
        
        for (var venue in favoriteVenues) {
          if (venue.id != null) {
            initialVenueNotifications[venue.id!] = venue.notification ?? false;
          }
        }

        emit(
          state.copyWith(
            isLoading: false,
            profile: profile,
            clearErrorMessage: true,
            localPreferences: initialPreferences,
            localVenueNotifications: initialVenueNotifications,
            // Reset changes on fresh GET
            selectedBusinessImages: [],
            selectedHobbyImages: [],
            selectedProfileImage: null,
            hasUnsavedChanges: false,
            imageWasJustUploaded: false,
          ),
        );
      } else if (stateModel is ErrorState) {
        emit(
          state.copyWith(
            isLoading: false,
            errorMessage: stateModel.error.msg ?? 'Something went wrong.',
          ),
        );
      } else {
        emit(
          state.copyWith(
            isLoading: false,
            errorMessage: 'Failed to load profile data.',
          ),
        );
      }
    } catch (e, st) {
      print('🔥 Paid Profile Fetch Error: $e');
      print(st);
      emit(
        state.copyWith(
          isLoading: false,
          errorMessage: 'Error loading profile: $e',
        ),
      );
    }
  }

  Future<void> _onUpdatePaidProfile(
    UpdatePaidProfileEvent event,
    Emitter<PaidProfileState> emit,
  ) async {
    emit(
      state.copyWith(
        isUpdating: true,
        errorMessage: null,
        updateSuccess: false,
      ),
    );

    try {
      // Build the request with IDs
      final selectedPreferenceIds = state.localPreferences.entries
          .where((entry) => entry.value == true)
          .map((entry) => entry.key)
          .toList();

      final selectedVenueIds = state.localVenueNotifications.entries
          .where((entry) => entry.value == true)
          .map((entry) => entry.key)
          .toList();

      final mergedRequest = PaidProfileUpdateRequest(
        aboutMe: event.request.aboutMe,
        businessDetails: event.request.businessDetails,
        interestsHobbies: event.request.interestsHobbies,
        myPreferences: selectedPreferenceIds,
        venueNotifications: selectedVenueIds,
        businessImages:
            state.selectedBusinessImages.isNotEmpty
                ? state.selectedBusinessImages
                : null,
        hobbyImages:
            state.selectedHobbyImages.isNotEmpty
                ? state.selectedHobbyImages
                : null,
        image: state.selectedProfileImage,
      );
      final bool imageUploaded = state.selectedProfileImage != null;

      final stateModel = await customerProfileDataProvider
          .updatePaidCustomerProfile(mergedRequest);

      // SUCCESS
      if (stateModel!.isSuccess) {
        // Clear local selections immediately on success
        emit(
          state.copyWith(
            selectedBusinessImages: [],
            selectedHobbyImages: [],
            selectedProfileImage: null,
            hasUnsavedChanges: false,
            imageWasJustUploaded: imageUploaded,
          ),
        );

        // Small delay to allow backend to process images
        await Future.delayed(const Duration(seconds: 1));
String? baseImageUrl;
        // Try to refresh profile data
        try {
          final refreshed =
              await customerProfileDataProvider.getPaidCustomerProfileById();

          if (refreshed != null && refreshed.isSuccess) {
            final profile = refreshed.data!;
            baseImageUrl = profile.data?.photo;

            // Rebuild preferences from refreshed data
            Map<int, bool> updatedPreferences = {};
            final apiPreferences = profile.data?.myPreferences ?? [];
            
            for (var pref in apiPreferences) {
              if (pref.id != null) {
                updatedPreferences[pref.id!] = pref.isPreferences ?? false;
              }
            }

            // Rebuild venue notifications
            Map<int, bool> updatedVenueNotifications = {};
            final favoriteVenues = profile.data?.favoriteVenues ?? [];
            
            for (var venue in favoriteVenues) {
              if (venue.id != null) {
                updatedVenueNotifications[venue.id!] = venue.notification ?? false;
              }
            }

            emit(
              state.copyWith(
                isUpdating: false,
                updateSuccess: true,
                successMessage:
                    stateModel.data?.message ?? 'Profile updated successfully!',
                profile: profile,
                errorMessage: null,
                localPreferences: updatedPreferences,
                localVenueNotifications: updatedVenueNotifications,
              ),
            );
          } else {
            // Refresh failed but update succeeded
            print('⚠️ Profile refresh failed after update, keeping current state');
            baseImageUrl = state.profile.data?.photo;
            emit(
              state.copyWith(
                isUpdating: false,
                updateSuccess: true,
                successMessage:
                    stateModel.data?.message ?? 'Profile updated successfully!',
                errorMessage: null,
              ),
            );
          }
        } catch (refreshError) {
          // Refresh threw an error but update succeeded
          print('⚠️ Profile refresh error: $refreshError');
          baseImageUrl = state.profile.data?.photo;
          emit(
            state.copyWith(
              isUpdating: false,
              updateSuccess: true,
              successMessage:
                  stateModel.data?.message ?? 'Profile updated successfully!',
              errorMessage: null,
            ),
          );
        }
        if (imageUploaded && baseImageUrl != null && baseImageUrl.isNotEmpty) {
    try {
      await DefaultCacheManager().removeFile(baseImageUrl);
      print('✅ Evicted cache for profile image: $baseImageUrl');
    } catch (evictError) {
      print('⚠️ Cache eviction failed: $evictError');
      // Non-fatal; cache bust fallback still works
    }
  }

        return;
      }

      // ERROR RESPONSE
      if (stateModel.isError) {
        final dynamic err = stateModel.error;

        String message = "Failed to update profile.";

        if (err is PaidProfileUpdateResponse) {
          if (err.message != null && err.message!.trim().isNotEmpty) {
            message = err.message!;
          } else if (err.errors != null && err.errors!.isNotEmpty) {
            message = err.errors!.entries
                .map((e) => "${e.key}: ${e.value.join(', ')}")
                .join("\n");
          }
        } else if (err is String) {
          message = err;
        }

        emit(
          state.copyWith(
            isUpdating: false,
            updateSuccess: false,
            errorMessage: message,
          ),
        );

        return;
      }

      // FALLBACK ERROR
      emit(
        state.copyWith(
          isUpdating: false,
          updateSuccess: false,
          errorMessage: 'Unexpected error during profile update.',
        ),
      );
    } catch (e, st) {
      print('🔥 Profile Update Error: $e');
      print(st);
      emit(
        state.copyWith(
          isUpdating: false,
          updateSuccess: false,
          errorMessage: 'Error updating profile: $e',
        ),
      );
    }
  }

  Future<void> _onAddBusinessImages(
    AddBusinessImagesEvent event,
    Emitter<PaidProfileState> emit,
  ) async {
    final localCount = state.selectedBusinessImages.length;

    // ALWAYS allow up to 2 local images
    if (localCount >= 2) {
      emit(state.copyWith(
        errorMessage: 'You can only select up to 2 new business images at a time'
      ));
      return;
    }

    final allowed = 2 - localCount;
    final toProcess = event.images.take(allowed).toList();

    final List<XFile> compressedImages = [];
    for (var img in toProcess) {
      final compressed = await _compressImage(img);
      if (compressed != null) compressedImages.add(compressed);
    }

    emit(
      state.copyWith(
        selectedBusinessImages: [
          ...state.selectedBusinessImages,
          ...compressedImages,
        ],
        hasUnsavedChanges: true,
        errorMessage: null,
      ),
    );
  }

  Future<void> _onAddHobbyImages(
    AddHobbyImagesEvent event,
    Emitter<PaidProfileState> emit,
  ) async {
    final localCount = state.selectedHobbyImages.length;

    // ALWAYS allow up to 2 local images
    if (localCount >= 2) {
      emit(state.copyWith(
        errorMessage: 'You can only select up to 2 new hobby images at a time'
      ));
      return;
    }

    final allowed = 2 - localCount;
    final toProcess = event.images.take(allowed).toList();

    final List<XFile> compressedImages = [];
    for (var img in toProcess) {
      final compressed = await _compressImage(img);
      if (compressed != null) compressedImages.add(compressed);
    }

    emit(
      state.copyWith(
        selectedHobbyImages: [
          ...state.selectedHobbyImages,
          ...compressedImages,
        ],
        hasUnsavedChanges: true,
        errorMessage: null,
      ),
    );
  }

  void _onRemoveBusinessImage(
    RemoveBusinessImageEvent event,
    Emitter<PaidProfileState> emit,
  ) {
    final updated = List<XFile>.from(state.selectedBusinessImages)
      ..removeAt(event.index);
    emit(
      state.copyWith(selectedBusinessImages: updated, hasUnsavedChanges: true),
    );
  }

  void _onRemoveHobbyImage(
    RemoveHobbyImageEvent event,
    Emitter<PaidProfileState> emit,
  ) {
    final updated = List<XFile>.from(state.selectedHobbyImages)
      ..removeAt(event.index);
    emit(state.copyWith(selectedHobbyImages: updated, hasUnsavedChanges: true));
  }

  void _onToggleVenueNotification(
    ToggleVenueNotification event,
    Emitter<PaidProfileState> emit,
  ) {
    final updatedNotifications = Map<int, bool>.from(state.localVenueNotifications);
    updatedNotifications[event.venueId] = event.isEnabled;
    
    emit(
      state.copyWith(
        localVenueNotifications: updatedNotifications,
        hasUnsavedChanges: true,
      ),
    );
  }

  void _onTogglePreference(
    TogglePreferenceEvent event,
    Emitter<PaidProfileState> emit,
  ) {
    final updatedPreferences = Map<int, bool>.from(state.localPreferences);
    updatedPreferences[event.preferenceId] = event.isEnabled;
    
    emit(
      state.copyWith(
        localPreferences: updatedPreferences,
        hasUnsavedChanges: true,
      ),
    );
  }

  void _onUpdateTextField(
    UpdateTextFieldEvent event,
    Emitter<PaidProfileState> emit,
  ) {
    emit(state.copyWith(hasUnsavedChanges: true));
  }

  void _onResetUpdateStatus(
    ResetUpdateStatusEvent event,
    Emitter<PaidProfileState> emit,
  ) {
    emit(
      state.copyWith(
        updateSuccess: false,
        successMessage: null,
        errorMessage: null,
        imageWasJustUploaded: false,
      ),
    );
  }
}


