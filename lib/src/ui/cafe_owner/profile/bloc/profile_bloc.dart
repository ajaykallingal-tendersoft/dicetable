import 'dart:convert';
import 'dart:io';
import 'package:bloc/bloc.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:dicetable/src/model/cafe_owner/profile/profile_view_response.dart';
import 'package:dicetable/src/model/cafe_owner/profile/profile_edit_view_response.dart';
import 'package:dicetable/src/model/cafe_owner/profile/profile_update_request.dart';
import 'package:dicetable/src/model/cafe_owner/profile/profile_update_response.dart';
import 'package:dicetable/src/model/delete_profile_response.dart';
import 'package:dicetable/src/model/state_model.dart';
import 'package:dicetable/src/resources/api_providers/venue_owner/profile_data_provider.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

part 'profile_event.dart';
part 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final ProfileDataProvider profileDataProvider;
  final ImagePicker _picker = ImagePicker();
  String base64Encoded = '';

  ProfileBloc({required this.profileDataProvider})
    : super(const ProfileState()) {
    on<UpdateTextField>((event, emit) {
      emit(event.update(state));
    });

    // on<UpdateCity>((event, emit) { // Added
    //   emit(state.copyWith(city: event.city));
    // });

    on<ToggleVenueType>((event, emit) {
      final currentIds = List<int>.from(state.selectedVenueTypeIds);
      if (event.isSelected) {
        if (!currentIds.contains(event.venueTypeId)) {
          currentIds.add(event.venueTypeId);
        }
      } else {
        currentIds.remove(event.venueTypeId);
      }
      emit(state.copyWith(selectedVenueTypeIds: currentIds));
    });

    on<UpdateOpeningHour>((event, emit) {
      final updatedHours = Map<String, ProfileOpeningHour>.from(
        state.openingHours,
      )..[event.day] = event.hour;
      emit(state.copyWith(openingHours: updatedHours));
    });

    on<PickImageFromGalleryEvent>((event, emit) async {
      Future<bool> isAndroid13OrHigher() async {
        if (!Platform.isAndroid) return false;

        final deviceInfoPlugin = DeviceInfoPlugin();
        final androidInfo = await deviceInfoPlugin.androidInfo;

        return androidInfo.version.sdkInt >= 33;
      }

      emit(ProfileImageLoadingState.fromState(state));
      try {
        if (Platform.isAndroid) {
          Permission permission;
          if (await isAndroid13OrHigher()) {
            permission = Permission.photos;
          } else {
            permission = Permission.storage;
          }

          final permissionStatus = await permission.request();
          if (!permissionStatus.isGranted) {
            emit(
              ProfileImagePermissionDeniedState.fromState(
                state,
                isPermanentlyDenied: permissionStatus.isPermanentlyDenied,
                errorMessage:
                    permissionStatus.isPermanentlyDenied
                        ? "Photo permission is permanently denied. Please enable it from settings to upload images."
                        : "Photo permission is required to upload images.",
              ),
            );

            return;
          }
        }

        // This will trigger iOS permission dialog if needed
        final pickedImage = await _picker.pickImage(
          source: ImageSource.gallery,
          imageQuality: 80,
        );

        if (pickedImage == null) {
          emit(
            ProfileImageErrorState.fromState(state),
          ); // User cancelled or permission denied
          return;
        }

        final file = File(pickedImage.path);
        final fileSize = file.lengthSync();
        final ext = pickedImage.name.toLowerCase();

        if (!(ext.endsWith('.png') ||
            ext.endsWith('.jpeg') ||
            ext.endsWith('.jpg'))) {
          emit(
            ProfileImageErrorState.fromState(
              state,
              errorMessage: "Only JPEG or PNG images are allowed.",
            ),
          );
          emit(ProfileImageErrorState.fromState(state));
          return;
        }

        if (fileSize > 5 * 1024 * 1024) {
          emit(
            ProfileImageErrorState.fromState(
              state,
              errorMessage: "Image size must be under 5MB.",
            ),
          );
          emit(ProfileImageErrorState.fromState(state));
          return;
        }

        final bytes = await file.readAsBytes();
        final base64Image = base64Encode(bytes);
        base64Encoded = "data:image/png;base64,$base64Image";
        emit(
          ProfileImageLoadedState.fromState(
            state,
            image: pickedImage,
            blob: base64Encoded,
            originalName: pickedImage.name,
          ),
        );
      } catch (e) {
        emit(
          ProfileImageErrorState.fromState(
            state,
            errorMessage: "Failed to pick image: $e",
          ),
        );
      }
    });
    //     on<PickImageFromGalleryEvent>((event, emit) async {
    //       emit(ProfileImageLoadingState.fromState(state));

    //       // Android 13+ (SDK 33) requires Permission.photos, below requires Permission.storage

    //       PermissionStatus permissionStatus;

    //       if (Platform.isAndroid) {
    //         final is13OrHigher = await isAndroid13OrHigher();
    //         if (is13OrHigher) {
    //           permissionStatus = await Permission.photos.request();
    //         } else {
    //           permissionStatus = await Permission.storage.request();
    //         }
    //       } else {
    //         // iOS and others
    //         permissionStatus = await Permission.photos.request();
    //       }

    //       if (permissionStatus.isDenied ||
    //           permissionStatus.isPermanentlyDenied ||
    //           (Platform.isIOS && permissionStatus.isLimited)) {
    //         emit(
    //           ProfileImagePermissionDeniedState.fromState(
    //             state,
    //             isPermanentlyDenied: permissionStatus.isPermanentlyDenied,
    //             errorMessage:
    //                 permissionStatus.isPermanentlyDenied
    //                     ? "Photo permission is permanently denied. Please enable it from settings to upload images."
    //                     : "Photo permission is required to upload images.",
    //           ),
    //         );
    //         return;
    //       }
    // final isGranted =
    //           permissionStatus.isGranted ||
    //           (Platform.isIOS && permissionStatus.isLimited);

    //       if (!isGranted) {
    //         emit(
    //           ProfileImagePermissionDeniedState.fromState(
    //             state,
    //             isPermanentlyDenied: permissionStatus.isPermanentlyDenied,
    //             errorMessage:
    //                 permissionStatus.isPermanentlyDenied
    //                     ? "Photo permission is permanently denied. Please enable it from settings to upload images."
    //                     : "Photo permission is required to upload images.",
    //           ),
    //         );
    //         return;
    //       }

    //       try {
    //         final pickedImage = await _picker.pickImage(source: ImageSource.gallery);
    //         if (pickedImage == null) {
    //           emit(ProfileImageErrorState.fromState(state));
    //           return;
    //         }

    //         final file = File(pickedImage.path);
    //         final fileSize = file.lengthSync();
    //         final fileName = pickedImage.name.toLowerCase();

    //         final isValidFormat = fileName.endsWith('.png') ||
    //             fileName.endsWith('.jpg') ||
    //             fileName.endsWith('.jpeg');

    //         if (!isValidFormat) {
    //           emit(ProfileImageErrorState.fromState(state, errorMessage: "Only JPEG or PNG images are allowed."));
    //           return;
    //         }

    //         if (fileSize > 5 * 1024 * 1024) {
    //           emit(ProfileImageErrorState.fromState(state, errorMessage: "Image size must be under 5MB."));
    //           return;
    //         }

    //         final bytes = await file.readAsBytes();
    //         final base64Image = base64Encode(bytes);
    //         base64Encoded = "data:image/png;base64,$base64Image";
    //         emit(ProfileImageLoadedState.fromState(
    //           state,
    //           image: pickedImage,
    //           blob: base64Encoded,
    //           originalName: pickedImage.name,
    //         ));
    //       } catch (e) {
    //         emit(ProfileImageErrorState.fromState(state, errorMessage: "Failed to pick image: $e"));
    //       }
    //     });

    on<GetProfileViewEvent>((event, emit) async {
      emit(const ProfileViewLoading());
      final StateModel? stateModel =
          await profileDataProvider.getCafeProfileById();
      if (stateModel is SuccessState) {
        final response = stateModel.value as ProfileViewResponse;
        emit(
          ProfileViewLoaded(
            profileViewResponse: response,
            venueName: response.data?.name ?? '',
            venueDescription: response.data?.venueDescription ?? '',
            email: response.data?.email ?? '',
            phone: response.data?.phone ?? '',
            address: response.data?.address ?? '',
            // city: response.data?.city ?? '',
            postalCode: response.data?.postcode ?? '',
            venueType: response.data?.venueType ?? '',
            openingHours:
                response.data?.openingHours?.asMap().map(
                  (_, hour) => MapEntry(
                    hour.day ?? '',
                    ProfileOpeningHour(
                      isEnabled: hour.isOpen ?? false,
                      from: _parseTimeOfDay(hour.opening ?? '10:00'),
                      to: _parseTimeOfDay(hour.closing ?? '12:00'),
                    ),
                  ),
                ) ??
                state.openingHours,
          ),
        );
      } else if (stateModel is ErrorState) {
        emit(ProfileViewError(errorMessage: stateModel.msg));
      }
    });

    on<GetProfileEditViewEvent>((event, emit) async {
      emit(const ProfileEditViewLoading());
      final StateModel? stateModel =
          await profileDataProvider.getCafeEditProfileById();
      if (stateModel is SuccessState) {
        final data = stateModel.value as ProfileEditViewResponse;

        final selectedVenueTypeIds =
            data.data?.venueType
                ?.where((type) => type.status == true)
                .map((type) => type.id!)
                .toList() ??
            [];

        final Map<String, ProfileOpeningHour> processedOpeningHours = {};

        // Initialize all days with default values first
        for (String day in ['mon', 'tue', 'wed', 'thu', 'fri', 'sat', 'sun']) {
          processedOpeningHours[day] = ProfileOpeningHour(
            isEnabled: false,
            from: TimeOfDay(hour: 10, minute: 0),
            to: TimeOfDay(hour: 22, minute: 0),
            id: null,
          );
        }

        if (data.data?.openingHours != null) {
          for (var hour in data.data!.openingHours!) {
            if (hour.day != null) {
              // Convert the day name from API to lowercase before using as a key
              final String lowerCaseDay = hour.day!.toLowerCase();
              processedOpeningHours[lowerCaseDay] = ProfileOpeningHour(
                id: hour.id,
                isEnabled: hour.isOpen ?? false,
                from: _parseTimeOfDay(hour.opening ?? '10:00:00'),
                to: _parseTimeOfDay(hour.closing ?? '22:00:00'),
              );
            }
          }
        }

        debugPrint(
          'Processed Opening Hours in Bloc (Corrected): $processedOpeningHours',
        ); // Updated debug print

        emit(
          ProfileEditViewLoaded(
            profileEditViewResponse: data,
            venueName: data.data?.name ?? '',
            venueDescription: data.data?.venueDescription ?? '',
            email: data.data?.email ?? '',
            phone: data.data?.phone ?? '',
            address: data.data?.address ?? '',
            // city: data.data?.city ?? '',
            postalCode: data.data?.postcode ?? '',
            venueTypes: data.data?.venueType ?? [],
            selectedVenueTypeIds: selectedVenueTypeIds,
            openingHours: processedOpeningHours,
            image: null,
            blob: null,
            originalName: null,
          ),
        );
      } else if (stateModel is ErrorState) {
        emit(ProfileEditViewError(errorMessage: stateModel.msg));
      }
    });

    on<ToggleEditModeEvent>((event, emit) {
      if (!state.isEditMode) {
        add(GetProfileEditViewEvent());
      } else {
        emit(state.copyWith(isEditMode: false));
      }
    });

    on<SubmitProfile>((event, emit) async {
      emit(const ProfileUpdateLoading());
      final StateModel? stateModel = await profileDataProvider
          .profileUpdateById(event.profileUpdateRequest);
      if (stateModel is SuccessState) {
        final response = stateModel.value as ProfileUpdateResponse;
        if (response.status == true) {
          emit(ProfileUpdateSuccess(profileUpdateResponse: response));
          add(GetProfileViewEvent());
        } else {
          emit(
            ProfileUpdateError(
              errorMessage: response.message ?? 'Failed to update profile',
            ),
          );
          add(GetProfileViewEvent());
        }
      } else if (stateModel is ErrorState) {
        emit(ProfileUpdateError(errorMessage: stateModel.msg));
      }
    });

    on<ProfileDeleteEvent>((event, emit) async {
      emit(ProfileDeleteLoading());
      final StateModel? stateModel =
          await profileDataProvider.cafeProfileDelete();
      if (stateModel is SuccessState) {
        final response = stateModel.value as DeleteProfileResponse;
        if (response.status == true) {
          emit(ProfileDeleteSuccess(cafeDeleteProfileResponse: response));
        } else {
          emit(
            ProfileDeleteError(
              errorMessage: response.message ?? 'Failed to delete profile',
            ),
          );
        }
      } else if (stateModel is ErrorState) {
        emit(ProfileDeleteError(errorMessage: stateModel.msg));
      }
    });
  }

  TimeOfDay _parseTimeOfDay(String time) {
    final parts = time.split(':');
    return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }
}
