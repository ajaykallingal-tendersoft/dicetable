import 'dart:convert';
import 'dart:io';
import 'package:bloc/bloc.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import 'package:soloseaters/src/model/cafe_owner/profile/delete_image_request.dart';
import 'package:soloseaters/src/model/cafe_owner/profile/profile_image_upload_request.dart';
import 'package:soloseaters/src/model/cafe_owner/profile/profile_multiple_image_upload_request.dart';
import 'package:soloseaters/src/model/cafe_owner/profile/profile_view_response.dart';
import 'package:soloseaters/src/model/cafe_owner/profile/profile_edit_view_response.dart';
import 'package:soloseaters/src/model/cafe_owner/profile/profile_update_request.dart';
import 'package:soloseaters/src/model/cafe_owner/profile/profile_update_response.dart';
import 'package:soloseaters/src/model/country_response.dart';
import 'package:soloseaters/src/model/delete_profile_response.dart';
import 'package:soloseaters/src/model/state_model.dart';
import 'package:soloseaters/src/resources/api_providers/venue_owner/profile_data_provider.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:soloseaters/src/utils/extension/state_model_extension.dart';

part 'profile_event.dart';
part 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final ProfileDataProvider profileDataProvider;
  final ImagePicker _picker = ImagePicker();
  String base64Encoded = '';

  ProfileBloc({required this.profileDataProvider})
    : super(const ProfileState()) {
    /*on<UpdateTextField>((event, emit) {
      emit(event.update(state));
    });*/

    on<UpdateTextField>((event, emit) {
      final updated = event.update(state);
      // Preserve ProfileEditViewLoaded state type if it exists
      if (state is ProfileEditViewLoaded) {
        final loadedState = state as ProfileEditViewLoaded;
        emit(
          ProfileEditViewLoaded(
            profileEditViewResponse: loadedState.profileEditViewResponse,
            venueName: updated.venueName,
            venueDescription: updated.venueDescription,
            email: updated.email,
            phone: updated.phone,
            country: updated.country,
            address: updated.address,
            postalCode: updated.postalCode,
            venueTypes: loadedState.venueTypes,
            selectedVenueTypeIds: loadedState.selectedVenueTypeIds,
            openingHours: loadedState.openingHours,
            image: loadedState.image,
            blob: loadedState.blob,
            originalName: loadedState.originalName,
            gallery: loadedState.gallery,
            galleryIds: loadedState.galleryIds,
            countryName: loadedState.countryName,
          ),
        );
      } else {
        emit(
          state.copyWith(
            venueName: updated.venueName,
            venueDescription: updated.venueDescription,
            email: updated.email,
            phone: updated.phone,
            address: updated.address,
            country: updated.country,
            postalCode: updated.postalCode,
          ),
        );
      }
    });

    on<ToggleVenueType>((event, emit) {
      final currentIds = List<int>.from(state.selectedVenueTypeIds);

      if (event.isSelected) {
        if (!currentIds.contains(event.venueTypeId)) {
          currentIds.add(event.venueTypeId);
        }
      } else {
        currentIds.remove(event.venueTypeId);
      }

      // Preserve ProfileEditViewLoaded state type if it exists
      if (state is ProfileEditViewLoaded) {
        final loadedState = state as ProfileEditViewLoaded;
        emit(
          ProfileEditViewLoaded(
            profileEditViewResponse: loadedState.profileEditViewResponse,
            venueName: loadedState.venueName,
            venueDescription: loadedState.venueDescription,
            email: loadedState.email,
            phone: loadedState.phone,
            country: loadedState.country,
            address: loadedState.address,
            postalCode: loadedState.postalCode,
            venueTypes: loadedState.venueTypes,
            selectedVenueTypeIds: currentIds,
            openingHours: loadedState.openingHours,
            image: loadedState.image,
            blob: loadedState.blob,
            originalName: loadedState.originalName,
            gallery: loadedState.gallery,
            galleryIds: loadedState.galleryIds,
          ),
        );
      } else {
        emit(state.copyWith(selectedVenueTypeIds: currentIds));
      }
    });

    on<UpdateOpeningHour>((event, emit) {
      final updatedHours = Map<String, ProfileOpeningHour>.from(
        state.openingHours,
      )..[event.day] = event.hour;

      // Preserve ProfileEditViewLoaded state type if it exists
      if (state is ProfileEditViewLoaded) {
        final loadedState = state as ProfileEditViewLoaded;
        emit(
          ProfileEditViewLoaded(
            profileEditViewResponse: loadedState.profileEditViewResponse,
            venueName: loadedState.venueName,
            venueDescription: loadedState.venueDescription,
            email: loadedState.email,
            phone: loadedState.phone,
            country: loadedState.country,
            address: loadedState.address,
            postalCode: loadedState.postalCode,
            venueTypes: loadedState.venueTypes,
            selectedVenueTypeIds: loadedState.selectedVenueTypeIds,
            openingHours: updatedHours,
            image: loadedState.image,
            blob: loadedState.blob,
            originalName: loadedState.originalName,
            gallery: loadedState.gallery,
            galleryIds: loadedState.galleryIds,
          ),
        );
      } else {
        emit(state.copyWith(openingHours: updatedHours));
      }
    });

    /*on<ToggleVenueType>((event, emit) {
      final currentIds = List<int>.from(state.selectedVenueTypeIds);
      if (event.isSelected) {
        if (!currentIds.contains(event.venueTypeId)) {
          currentIds.add(event.venueTypeId);
        }
      } else {
        currentIds.remove(event.venueTypeId);
      }
      emit(state.copyWith(selectedVenueTypeIds: currentIds));
    });*/

    /*on<UpdateOpeningHour>((event, emit) {
      final updatedHours = Map<String, ProfileOpeningHour>.from(
        state.openingHours,
      )..[event.day] = event.hour;
      emit(state.copyWith(openingHours: updatedHours));
    });*/

    // Profile Image Picker
    on<PickProfileImageFromGalleryEvent>((event, emit) async {
      await _pickSingleImage(emit, ImageSource.gallery);
    });

    on<PickProfileImageFromCameraEvent>((event, emit) async {
      await _pickSingleImage(emit, ImageSource.camera);
    });

    on<PickGalleryImagesFromGalleryEvent>((event, emit) async {
      await _pickMultipleImages(emit, ImageSource.gallery);
    });

    on<PickGalleryImagesFromCameraEvent>((event, emit) async {
      await _pickMultipleImages(emit, ImageSource.camera);
    });

    //  on<DeleteGalleryPhotoEvent>((event, emit) async {
    //   if (event.isNewPhoto) {
    //     // Delete from local files
    //     final updatedFiles = List<File>.from(state.galleryPhotoFiles);
    //     updatedFiles.removeAt(event.index);
    //     emit(state.copyWith(galleryPhotoFiles: updatedFiles));
    //   } else {
    //     // Delete from server
    //     emit(GalleryPhotoDeleteLoading.fromState(state));
    //     final photoId = state.galleryIds?[event.index];
    //     if (photoId == null) {
    //       emit(
    //         GalleryPhotoDeleteError.fromState(
    //           state,
    //           errorMessage: "Invalid photo ID",
    //         ),
    //       );
    //       return;
    //     }

    //     final stateModel = await profileDataProvider.deleteGalleryPhoto(photoId);
    //     if (stateModel is SuccessState) {
    //       final updatedUrls = List<String>.from(state.gallery ?? []);
    //       final updatedIds = List<String>.from(state.galleryIds ?? []);
    //       updatedUrls.removeAt(event.index);
    //       updatedIds.removeAt(event.index);

    //       emit(
    //         GalleryPhotoDeleteSuccess.fromState(
    //           state,
    //           gallery: updatedUrls,
    //           galleryIds: updatedIds,
    //         ),
    //       );
    //     } else if (stateModel is ErrorState) {
    //       emit(
    //         GalleryPhotoDeleteError.fromState(
    //           state,
    //           errorMessage: stateModel.msg,
    //         ),
    //       );
    //     }
    //   }
    // });

    /*on<GetProfileViewEvent>((event, emit) async {
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
            country: response.data?.country ?? '',
            postalCode: response.data?.postcode ?? '',
            venueType: response.data?.venueType ?? '',
            openingHours:
                response.data?.openingHours?.asMap().map(
                  (_, hour) => MapEntry(
                    hour.day ?? '',
                    ProfileOpeningHour(
                      isEnabled: hour.isOpen ?? false,
                      from: parseTimeOfDay(hour.opening ?? '10:00'),
                      to: parseTimeOfDay(hour.closing ?? '12:00'),
                    ),
                  ),
                ) ??
                state.openingHours,
            gallery: response.data?.gallery ?? [],
            galleryIds: response.data?.galleryIds ?? [],
          ),
        );
      } else if (stateModel is ErrorState) {
        emit(ProfileViewError(errorMessage: stateModel.msg));
      }
    });*/

    on<GetProfileViewEvent>((event, emit) async {
      emit(const ProfileViewLoading());
      final StateModel? stateModel =
          await profileDataProvider.getCafeProfileById();
      if (stateModel is SuccessState) {
        final response = stateModel.value as ProfileViewResponse;

        // ✅ ADD DAY MAPPING HERE (same as in GetProfileEditViewEvent)
        final dayMap = {
          'monday': 'mon',
          'tuesday': 'tue',
          'wednesday': 'wed',
          'thursday': 'thu',
          'friday': 'fri',
          'saturday': 'sat',
          'sunday': 'sun',
        };

        final Map<String, ProfileOpeningHour> processedOpeningHours = {};

        final openingHoursObject = response.data?.openingHours;

        if (openingHoursObject != null) {
          // Helper to process and map a single Day object
          void processDay(String key, Day? day) {
            if (day != null) {
              processedOpeningHours[key] = ProfileOpeningHour(
                isEnabled: day.isOpen ?? false,
                from: parseTimeOfDay(day.open ?? '10:00 AM'),
                to: parseTimeOfDay(day.close ?? '12:00 PM'),
                id: day.id,
              );
            }
          }

          processDay('mon', openingHoursObject.mon);
          processDay('tue', openingHoursObject.tue);
          processDay('wed', openingHoursObject.wed);
          processDay('thu', openingHoursObject.thu);
          processDay('fri', openingHoursObject.fri);
          processDay('sat', openingHoursObject.sat);
          processDay('sun', openingHoursObject.sun);
        }

        emit(
          ProfileViewLoaded(
            profileViewResponse: response,
            venueName: response.data?.name ?? '',
            venueDescription: response.data?.venueDescription ?? '',
            email: response.data?.email ?? '',
            phone: response.data?.phone ?? '',
            address: response.data?.address ?? '',
            country: response.data?.country ?? '',
            postalCode: response.data?.postcode ?? '',
            venueType: response.data?.venueTypes ?? '',
            openingHours: processedOpeningHours, // ✅ Use processed hours
            gallery: response.data?.gallery ?? [],
            galleryIds: response.data?.galleryIds ?? [],
            countryName: response.data?.countryName ?? "",
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

      // Inside on<GetProfileEditViewEvent>((event, emit) async { ... }

final Map<String, ProfileOpeningHour> processedOpeningHours = {};
final openingHoursObject = data.data?.openingHours;

// Define default hour values (as you already had)
const defaultFrom = TimeOfDay(hour: 10, minute: 0);
const defaultTo = TimeOfDay(hour: 22, minute: 0);

// Helper function to process and map a single Day object from the API response
void processDay(String key, OpeningHourDay? day) {
  // Use the API data if available, otherwise use defaults
  processedOpeningHours[key] = ProfileOpeningHour(
    isEnabled: day?.isOpen ?? false,
    // Use parseTimeOfDay if the time string is available, otherwise use default TimeOfDay
    from: parseTimeOfDay(day?.open ?? '10:00 AM'),
    to: parseTimeOfDay(day?.close ?? '10:00 PM'),
    id: day?.id,
  );
}

// 1. Initialize all 7 days in the map with default closed/default hours
for (String key in ['mon', 'tue', 'wed', 'thu', 'fri', 'sat', 'sun']) {
  processedOpeningHours[key] = ProfileOpeningHour(
    isEnabled: false,
    from: defaultFrom,
    to: defaultTo,
    id: null,
  );
}

// 2. If the OpeningHours object exists, override the defaults with actual data
if (openingHoursObject != null) {
  processDay('mon', openingHoursObject.mon);
  processDay('tue', openingHoursObject.tue);
  processDay('wed', openingHoursObject.wed);
  processDay('thu', openingHoursObject.thu);
  processDay('fri', openingHoursObject.fri);
  processDay('sat', openingHoursObject.sat);
  processDay('sun', openingHoursObject.sun);
}

// ... rest of the emit(ProfileEditViewLoaded( ... )) call remains the same
    
        emit(
          ProfileEditViewLoaded(
            profileEditViewResponse: data,
            venueName: data.data?.name ?? '',
            venueDescription: data.data?.venueDescription ?? '',
            email: data.data?.email ?? '',
            phone: data.data?.phone ?? '',
            country: data.data?.country ?? '',
            address: data.data?.address ?? '',
            postalCode: data.data?.postcode ?? '',
            venueTypes: data.data?.venueType ?? [],
            selectedVenueTypeIds: selectedVenueTypeIds,
            openingHours: processedOpeningHours,
            image: null,
            blob: null,
            originalName: null,
            gallery: data.data?.gallery ?? [],
            galleryIds: data.data?.galleryIds ?? [],
            countryId: data.data?.country ?? "",
            countryName: data.data?.countryName ?? "",
          ),
        );
      } else if (stateModel is ErrorState) {
        emit(ProfileEditViewError(errorMessage: stateModel.msg));
      }
    });

    // on<GetProfileEditViewEvent>((event, emit) async {
    //   emit(const ProfileEditViewLoading());
    //   final StateModel? stateModel =
    //       await profileDataProvider.getCafeEditProfileById();
    //   if (stateModel is SuccessState) {
    //     final data = stateModel.value as ProfileEditViewResponse;

    //     final selectedVenueTypeIds =
    //         data.data?.venueType
    //             ?.where((type) => type.status == true)
    //             .map((type) => type.id!)
    //             .toList() ??
    //         [];

    //     final Map<String, ProfileOpeningHour> processedOpeningHours = {};

    //     // Initialize all days with default values first
    //     for (String day in ['mon', 'tue', 'wed', 'thu', 'fri', 'sat', 'sun']) {
    //       processedOpeningHours[day] = ProfileOpeningHour(
    //         isEnabled: false,
    //         from: TimeOfDay(hour: 10, minute: 0),
    //         to: TimeOfDay(hour: 22, minute: 0),
    //         id: null,
    //       );
    //     }

    //     if (data.data?.openingHours != null) {
    //       for (var hour in data.data!.openingHours!) {
    //         if (hour.day != null) {
    //           // Convert the day name from API to lowercase before using as a key
    //           final String lowerCaseDay = hour.day!.toLowerCase();
    //           processedOpeningHours[lowerCaseDay] = ProfileOpeningHour(
    //             id: hour.id,
    //             isEnabled: hour.isOpen ?? false,
    //             from: parseTimeOfDay(hour.opening ?? '10:00:00'),
    //             to: parseTimeOfDay(hour.closing ?? '22:00:00'),
    //           );
    //         }
    //       }
    //     }

    //     // debugPrint(
    //     //   'Processed Opening Hours in Bloc (Corrected): $processedOpeningHours',
    //     // ); // Updated debug print

    //     emit(
    //       ProfileEditViewLoaded(
    //         profileEditViewResponse: data,
    //         venueName: data.data?.name ?? '',
    //         venueDescription: data.data?.venueDescription ?? '',
    //         email: data.data?.email ?? '',
    //         phone: data.data?.phone ?? '',
    //         country: data.data?.country ?? '',
    //         address: data.data?.address ?? '',
    //         postalCode: data.data?.postcode ?? '',
    //         venueTypes: data.data?.venueType ?? [],
    //         selectedVenueTypeIds: selectedVenueTypeIds,
    //         openingHours: processedOpeningHours,
    //         image: null,
    //         blob: null,
    //         originalName: null,
    //         gallery: data.data?.gallery ?? [],
    //         galleryIds: data.data?.galleryIds ?? [],
    //       ),
    //     );
    //   } else if (stateModel is ErrorState) {
    //     emit(ProfileEditViewError(errorMessage: stateModel.msg));
    //   }
    // });

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
        add(GetProfileViewEvent());
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

    on<DeleteGalleryPhotoEvent>((event, emit) async {
      print("DeleteGalleryPhotoEvent triggered for photoId: ${event.photoId}");

      emit(GalleryPhotoDeleteLoading.fromState(state));

      final stateModel = await profileDataProvider.deleteGalleryPhoto(
        event.deleteGalleryImageRequest,
      );

      if (stateModel is SuccessState) {
        print("Gallery photo deleted successfully");

        final updatedUrls = List<String>.from(state.gallery ?? []);
        final updatedIds = List<String>.from(state.galleryIds ?? []);

        // Remove the photo at the specified index
        if (event.index < updatedUrls.length &&
            event.index < updatedIds.length) {
          updatedUrls.removeAt(event.index);
          updatedIds.removeAt(event.index);

          emit(
            GalleryPhotoDeleteSuccess.fromState(
              state,
              gallery: updatedUrls,
              galleryIds: updatedIds,
            ),
          );
        } else {
          emit(
            GalleryPhotoDeleteError.fromState(
              state,
              errorMessage: "Invalid photo index",
            ),
          );
        }
      } else if (stateModel is ErrorState) {
        print("Gallery photo deletion failed: ${stateModel.msg}");

        emit(
          GalleryPhotoDeleteError.fromState(
            state,
            errorMessage: stateModel.msg,
          ),
        );
      }
    });

    on<LoadCountriesEvent>((event, emit) async {
      try {
        emit(state.copyWith(isLoadingCountries: true, countryError: null));

        final StateModel? response = await profileDataProvider.getCountryList();

        if (response is SuccessState<CountryResponse>) {
          final countryResponse = response.value as CountryResponse;
          final List<Country> countryList = countryResponse.data ?? [];

          String updatedCountryName = state.country ?? '';
          String updatedCountryId = state.countryId ?? '';

          if (state is ProfileEditViewLoaded) {
            final loadedState = state as ProfileEditViewLoaded;
            emit(
              ProfileEditViewLoaded(
                profileEditViewResponse: loadedState.profileEditViewResponse,
                venueName: loadedState.venueName,
                venueDescription: loadedState.venueDescription,
                email: loadedState.email,
                phone: loadedState.phone,
                country: loadedState.country, // ✅ FIX: show name in dropdown
                address: loadedState.address,
                postalCode: loadedState.postalCode,
                venueTypes: loadedState.venueTypes,
                selectedVenueTypeIds: loadedState.selectedVenueTypeIds,
                openingHours: loadedState.openingHours,
                image: loadedState.image,
                blob: loadedState.blob,
                originalName: loadedState.originalName,
                gallery: loadedState.gallery,
                galleryIds: loadedState.galleryIds,
                countries: countryList,
                isLoadingCountries: false,
                countryError: null,
                countryId: updatedCountryId,
                countryName: updatedCountryName,
              ),
            );
          } else {
            emit(
              state.copyWith(
                countries: countryList,
                isLoadingCountries: false,
                countryError: null,
                countryId: updatedCountryId,
                countryName: updatedCountryName,
                // country: updatedCountryName,
              ),
            );
          }
        } else if (response is ErrorState) {
          emit(
            state.copyWith(
              isLoadingCountries: false,
              countryError: response.msg,
            ),
          );
        } else {
          emit(
            state.copyWith(
              isLoadingCountries: false,
              countryError: "Unexpected response type",
            ),
          );
        }
      } catch (e) {
        emit(
          state.copyWith(isLoadingCountries: false, countryError: e.toString()),
        );
      }
    });

    //  on<LoadCountriesEvent>((event, emit) async {
    //   try {
    //     emit(state.copyWith(isLoadingCountries: true, countryError: null));

    //     final StateModel? response = await profileDataProvider.getCountryList();

    //     if (response is SuccessState<CountryResponse>) {
    //            final countryResponse = response.value as CountryResponse;
    //       final List<Country> countryList = countryResponse!.data ?? [];

    //       // Preserve ProfileEditViewLoaded state type if it exists
    //       if (state is ProfileEditViewLoaded) {
    //         final loadedState = state as ProfileEditViewLoaded;
    //         emit(
    //           ProfileEditViewLoaded(
    //             profileEditViewResponse: loadedState.profileEditViewResponse,
    //             venueName: loadedState.venueName,
    //             venueDescription: loadedState.venueDescription,
    //             email: loadedState.email,
    //             phone: loadedState.phone,
    //             country: loadedState.country,
    //             address: loadedState.address,
    //             postalCode: loadedState.postalCode,
    //             venueTypes: loadedState.venueTypes,
    //             selectedVenueTypeIds: loadedState.selectedVenueTypeIds,
    //             openingHours: loadedState.openingHours,
    //             image: loadedState.image,
    //             blob: loadedState.blob,
    //             originalName: loadedState.originalName,
    //             gallery: loadedState.gallery,
    //             galleryIds: loadedState.galleryIds,
    //             countries: countryList,
    //             isLoadingCountries: false,
    //             countryError: null,
    //             countryId: loadedState.countryId,
    //             countryName: loadedState.countryName,
    //           ),
    //         );
    //       } else {
    //         emit(
    //           state.copyWith(
    //             countries: countryList,
    //             isLoadingCountries: false,
    //             countryError: null,
    //           ),
    //         );
    //       }
    //     } else if (response is ErrorState) {
    //       if (state is ProfileEditViewLoaded) {
    //         final loadedState = state as ProfileEditViewLoaded;
    //         emit(
    //           ProfileEditViewLoaded(
    //             profileEditViewResponse: loadedState.profileEditViewResponse,
    //             venueName: loadedState.venueName,
    //             venueDescription: loadedState.venueDescription,
    //             email: loadedState.email,
    //             phone: loadedState.phone,
    //             country: loadedState.country,
    //             address: loadedState.address,
    //             postalCode: loadedState.postalCode,
    //             venueTypes: loadedState.venueTypes,
    //             selectedVenueTypeIds: loadedState.selectedVenueTypeIds,
    //             openingHours: loadedState.openingHours,
    //             image: loadedState.image,
    //             blob: loadedState.blob,
    //             originalName: loadedState.originalName,
    //             gallery: loadedState.gallery,
    //             galleryIds: loadedState.galleryIds,
    //             countries: loadedState.countries,
    //             isLoadingCountries: false,
    //             countryError: response.msg,
    //             countryId: loadedState.countryId,
    //             countryName: loadedState.countryName,
    //           ),
    //         );
    //       } else {
    //         emit(
    //           state.copyWith(
    //             isLoadingCountries: false,
    //             countryError: response.msg,
    //           ),
    //         );
    //       }
    //     } else {
    //       if (state is ProfileEditViewLoaded) {
    //         final loadedState = state as ProfileEditViewLoaded;
    //         emit(
    //           ProfileEditViewLoaded(
    //             profileEditViewResponse: loadedState.profileEditViewResponse,
    //             venueName: loadedState.venueName,
    //             venueDescription: loadedState.venueDescription,
    //             email: loadedState.email,
    //             phone: loadedState.phone,
    //             country: loadedState.country,
    //             address: loadedState.address,
    //             postalCode: loadedState.postalCode,
    //             venueTypes: loadedState.venueTypes,
    //             selectedVenueTypeIds: loadedState.selectedVenueTypeIds,
    //             openingHours: loadedState.openingHours,
    //             image: loadedState.image,
    //             blob: loadedState.blob,
    //             originalName: loadedState.originalName,
    //             gallery: loadedState.gallery,
    //             galleryIds: loadedState.galleryIds,
    //             countries: loadedState.countries,
    //             isLoadingCountries: false,
    //             countryError: "Unexpected response type",
    //             countryId: loadedState.countryId,
    //             countryName: loadedState.countryName,
    //           ),
    //         );
    //       } else {
    //         emit(
    //           state.copyWith(
    //             isLoadingCountries: false,
    //             countryError: "Unexpected response type",
    //           ),
    //         );
    //       }
    //     }
    //   } catch (e) {
    //     if (state is ProfileEditViewLoaded) {
    //       final loadedState = state as ProfileEditViewLoaded;
    //       emit(
    //         ProfileEditViewLoaded(
    //           profileEditViewResponse: loadedState.profileEditViewResponse,
    //           venueName: loadedState.venueName,
    //           venueDescription: loadedState.venueDescription,
    //           email: loadedState.email,
    //           phone: loadedState.phone,
    //           country: loadedState.country,
    //           address: loadedState.address,
    //           postalCode: loadedState.postalCode,
    //           venueTypes: loadedState.venueTypes,
    //           selectedVenueTypeIds: loadedState.selectedVenueTypeIds,
    //           openingHours: loadedState.openingHours,
    //           image: loadedState.image,
    //           blob: loadedState.blob,
    //           originalName: loadedState.originalName,
    //           gallery: loadedState.gallery,
    //           galleryIds: loadedState.galleryIds,
    //           countries: loadedState.countries,
    //           isLoadingCountries: false,
    //           countryError: e.toString(),
    //           countryId: loadedState.countryId,
    //           countryName: loadedState.countryName,
    //         ),
    //       );
    //     } else {
    //       emit(
    //         state.copyWith(
    //           isLoadingCountries: false,
    //           countryError: e.toString(),
    //         ),
    //       );
    //     }
    //   }
    // });

    on<SelectCountryEvent>((event, emit) {
      // Preserve ProfileEditViewLoaded state type if it exists
      if (state is ProfileEditViewLoaded) {
        final loadedState = state as ProfileEditViewLoaded;
        emit(
          ProfileEditViewLoaded(
            profileEditViewResponse: loadedState.profileEditViewResponse,
            venueName: loadedState.venueName,
            venueDescription: loadedState.venueDescription,
            email: loadedState.email,
            phone: loadedState.phone,
            country: loadedState.country, // Update country text field
            address: loadedState.address,
            postalCode: loadedState.postalCode,
            venueTypes: loadedState.venueTypes,
            selectedVenueTypeIds: loadedState.selectedVenueTypeIds,
            openingHours: loadedState.openingHours,
            image: loadedState.image,
            blob: loadedState.blob,
            originalName: loadedState.originalName,
            gallery: loadedState.gallery,
            galleryIds: loadedState.galleryIds,
            countries: loadedState.countries,
            isLoadingCountries: loadedState.isLoadingCountries,
            countryError: loadedState.countryError,
            countryId: event.countryId,
            countryName: event.countryName,
          ),
        );
      } else {
        emit(
          state.copyWith(
            // country: state,
            countryId: event.countryId,
            countryName: event.countryName,
          ),
        );
      }
    });

    on<SaveProfileChangesEvent>((event, emit) async {
      final currentState = state;

      // Check if we're in edit mode or have edit data loaded
      if (currentState is! ProfileEditViewLoaded &&
          !currentState.isEditMode &&
          (currentState.profileEditViewResponse == null)) {
        add(GetProfileEditViewEvent());
        return;
      }

      // Prevent double-clicks during loading
      if (currentState is ProfileUpdateLoading ||
          currentState is ProfileImageUploadLoading ||
          currentState is GalleryPhotoUploadLoading) {
        return;
      }

      final baseState =
          currentState is ProfileEditViewLoaded ? currentState : currentState;

      final needsProfileUpdate = event.isTextDataChanged;
      final hasProfileImageChanged = baseState.profileImageFile != null;
      final hasNewGalleryImages = baseState.galleryPhotoFiles.isNotEmpty;

      // Check if ANY changes exist
      if (!needsProfileUpdate &&
          !hasProfileImageChanged &&
          !hasNewGalleryImages) {
        emit(
          ProfileNoChangeDetected(
            message: 'No changes to update',
            venueName: baseState.venueName,
            venueDescription: baseState.venueDescription,
            email: baseState.email,
            phone: baseState.phone,
            address: baseState.address,
            country: baseState.countryName,
            postalCode: baseState.postalCode,
            gallery: baseState.gallery,
            galleryPhotoFiles: baseState.galleryPhotoFiles,
            galleryIds: baseState.galleryIds,
            venueTypes: baseState.venueTypes,
            selectedVenueTypeIds: baseState.selectedVenueTypeIds,
            openingHours: baseState.openingHours,
          ),
        );
        return;
      }

      // Track if any upload failed (for final message)
      bool hasUploadError = false;
      String uploadErrorMessage = "";

      // ========== STEP 1: Update profile data (CRITICAL - must succeed) ==========
      if (needsProfileUpdate) {
        emit(const ProfileUpdateLoading());

        final StateModel stateModel = await profileDataProvider
            .profileUpdateById(event.updateRequest);

        if (stateModel is SuccessState) {
          final response = stateModel.value as ProfileUpdateResponse;

          if (response.status == true) {
            debugPrint('✅ Profile data updated successfully');
          } else {
            emit(
              ProfileUpdateError.fromState(
                baseState,
                errorMessage:
                    response.message ?? 'Failed to update profile data.',
              ),
            );
            await Future.delayed(const Duration(milliseconds: 300));
            add(GetProfileEditViewEvent());
            return; // STOP - critical error
          }
        } else if (stateModel is ErrorState) {
          emit(
            ProfileUpdateError.fromState(
              baseState,
              errorMessage: stateModel.msg,
            ),
          );
          await Future.delayed(const Duration(milliseconds: 300));
          add(GetProfileEditViewEvent());
          return; // STOP - critical error
        }
      }

      // ========== STEP 2: Upload profile image (NON-CRITICAL) ==========
      if (hasProfileImageChanged) {
        final imageState = baseState;
        debugPrint('🖼️ Starting profile image upload...');
        emit(ProfileImageUploadLoading.fromState(imageState));

        final imageRequest = CafePhotoUploadRequest(
          image: imageState.profileImageFile!,
        );

        final imageResult = await profileDataProvider.uploadCafePhoto(
          imageRequest,
        );

        if (imageResult is SuccessState) {
          debugPrint('✅ Profile image upload successful!');
          final uploadedUrl = imageResult.value.path;
          final cacheBustedUrl =
              '$uploadedUrl?cb=${DateTime.now().millisecondsSinceEpoch}';

          final latestState = state;

          if (latestState is ProfileEditViewLoaded) {
            emit(
              ProfileEditViewLoaded(
                // profileEditViewResponse: latestState.profileEditViewResponse,
                profileEditViewResponse: latestState.profileEditViewResponse
                    .copyWith(
                      data: latestState.profileEditViewResponse?.data?.copyWith(
                        photo:
                            cacheBustedUrl, // <-- Manually set cache-busted url
                      ),
                    ),
                venueName: latestState.venueName,
                venueDescription: latestState.venueDescription,
                email: latestState.email,
                phone: latestState.phone,
                country: latestState.countryName,
                address: latestState.address,
                postalCode: latestState.postalCode,
                venueTypes: latestState.venueTypes,
                selectedVenueTypeIds: latestState.selectedVenueTypeIds,
                openingHours: latestState.openingHours,
                image: latestState.image,
                blob: latestState.blob,
                originalName: latestState.originalName,
                gallery: latestState.gallery,
                galleryIds: latestState.galleryIds,
              ).copyWith(
                profileImageFile: null,
                profileImagePath: null,
                imageWasJustUploaded: true,
              ),
            );
          } else {
            emit(
              ProfileImageUploadSuccess.fromState(
                latestState.copyWith(
                  profileImageFile: null,
                  imageWasJustUploaded: true,
                ),
                message: "Profile image updated successfully.",
              ),
            );
          }
        } else if (imageResult is ErrorState) {
          debugPrint('❌ Profile image upload failed: ${imageResult.msg}');
          hasUploadError = true;
          uploadErrorMessage = "Profile image failed to upload.";
          // Don't emit error state - just track for final message
        }
      }

      // ========== STEP 3: Upload gallery images (NON-CRITICAL) ==========
      if (hasNewGalleryImages) {
        final galleryState = baseState;
        debugPrint('🖼️ Starting gallery images upload...');
        debugPrint(
          '📊 Number of files: ${galleryState.galleryPhotoFiles.length}',
        );
        emit(GalleryPhotoUploadLoading.fromState(galleryState));

        final galleryRequest = CafeGalleryUploadRequest(
          gallery: galleryState.galleryPhotoFiles,
        );

        final galleryResult = await profileDataProvider.uploadCafeGalleryImages(
          galleryRequest,
        );

        if (galleryResult is SuccessState) {
          debugPrint('✅ Gallery images upload successful!');
          final latestState = state;

          if (latestState is ProfileEditViewLoaded) {
            emit(
              ProfileEditViewLoaded(
                profileEditViewResponse: latestState.profileEditViewResponse,
                venueName: latestState.venueName,
                venueDescription: latestState.venueDescription,
                email: latestState.email,
                phone: latestState.phone,
                country: latestState.countryName,
                address: latestState.address,
                postalCode: latestState.postalCode,
                venueTypes: latestState.venueTypes,
                selectedVenueTypeIds: latestState.selectedVenueTypeIds,
                openingHours: latestState.openingHours,
                image: latestState.image,
                blob: latestState.blob,
                originalName: latestState.originalName,
                gallery: latestState.gallery,
                galleryIds: latestState.galleryIds,
              ).copyWith(galleryPhotoFiles: []),
            );
          } else {
            emit(
              GalleryPhotoUploadSuccess.fromState(
                latestState.copyWith(galleryPhotoFiles: []),
                message: "Gallery photos uploaded successfully.",
              ),
            );
          }
        } else if (galleryResult is ErrorState) {
          debugPrint('❌ Gallery images upload failed: ${galleryResult.msg}');
          hasUploadError = true;
          if (uploadErrorMessage.isEmpty) {
            uploadErrorMessage = "Gallery photos failed to upload.";
          } else {
            uploadErrorMessage += " Gallery upload also failed.";
          }
          // Don't emit error state - just track for final message
        }
      }

      // ========== STEP 4: Final summary and refresh ==========
      final latestStateForSuccess = state;
      final String finalMessage =
          hasUploadError
              ? "Profile data saved. $uploadErrorMessage"
              : "Profile updated successfully!";

      // Emit success with appropriate message
      emit(
        ProfileSaveSuccess.fromState(
          latestStateForSuccess,
          message: finalMessage,
        ),
      );

      // Show loading before refresh
      await Future.delayed(const Duration(milliseconds: 500));
      emit(const ProfileEditViewLoading());

      // Refresh to show latest data from server
      add(GetProfileEditViewEvent());
    });

    on<DeleteLocalGalleryPhotoEvent>((event, emit) {
      // 1. Create a mutable copy of the local files list
      final updatedFiles = List<File>.from(state.galleryPhotoFiles);

      // 2. Safely remove the file at the specified local index
      if (event.index >= 0 && event.index < updatedFiles.length) {
        updatedFiles.removeAt(event.index);

        // 3. Emit the new state with the updated local files list,
        // preserving the current state type (ProfileEditViewLoaded or base state).
        if (state is ProfileEditViewLoaded) {
          final loadedState = state as ProfileEditViewLoaded;
          emit(
            ProfileEditViewLoaded(
              profileEditViewResponse: loadedState.profileEditViewResponse,
              venueName: loadedState.venueName,
              venueDescription: loadedState.venueDescription,
              email: loadedState.email,
              phone: loadedState.phone,
              country: loadedState.country,
              address: loadedState.address,
              postalCode: loadedState.postalCode,
              venueTypes: loadedState.venueTypes,
              selectedVenueTypeIds: loadedState.selectedVenueTypeIds,
              openingHours: loadedState.openingHours,
              image: loadedState.image,
              blob: loadedState.blob,
              originalName: loadedState.originalName,
              gallery: loadedState.gallery,
              galleryIds: loadedState.galleryIds,
            ).copyWith(galleryPhotoFiles: updatedFiles),
          );
        } else {
          // For any other state, use copyWith on the base state
          emit(state.copyWith(galleryPhotoFiles: updatedFiles));
        }
      }
    });
  }
  Future<bool> _isAndroid13OrHigher() async {
    if (!Platform.isAndroid) return false;
    final deviceInfoPlugin = DeviceInfoPlugin();
    final androidInfo = await deviceInfoPlugin.androidInfo;
    return androidInfo.version.sdkInt >= 33;
  }

  TimeOfDay parseTimeOfDay(String time) {
    // Example input: "10:00 AM"
    final regex = RegExp(r'(.*):(\d{2})\s*(AM|PM)', caseSensitive: false);
    final match = regex.firstMatch(time.trim());
    if (match != null) {
      int hour = int.parse(match.group(1)!);
      int minute = int.parse(match.group(2)!);
      String period = match.group(3)!.toUpperCase();
      if (period == "PM" && hour != 12) hour += 12;
      if (period == "AM" && hour == 12) hour = 0;
      return TimeOfDay(hour: hour, minute: minute);
    } else {
      // Fallback for "HH:mm" format if "AM"/"PM" are missing
      final parts = time.split(':');
      int hour = int.parse(parts[0]);
      int minute = int.parse(parts[1]);
      return TimeOfDay(hour: hour, minute: minute);
    }
  }

  Future<void> _pickSingleImage(
    Emitter<ProfileState> emit,
    ImageSource source,
  ) async {
    emit(ProfileImageLoadingState.fromState(state));
    try {
      if (Platform.isAndroid) {
        Permission permission;
        if (await _isAndroid13OrHigher()) {
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
                      ? "Photo permission permanently denied. Enable from settings."
                      : "Photo permission is required to select images.",
            ),
          );
          return;
        }
      }

      final pickedFile = await _picker.pickImage(
        source: source,
        imageQuality: 80,
      );

      if (pickedFile == null) {
        emit(
          ProfileImageErrorState.fromState(
            state,
            errorMessage: "No image selected.",
          ),
        );
        return;
      }

      final file = File(pickedFile.path);
      final ext = pickedFile.name.toLowerCase();
      final fileSize = file.lengthSync();

      if (!(ext.endsWith('.png') ||
          ext.endsWith('.jpg') ||
          ext.endsWith('.jpeg'))) {
        emit(
          ProfileImageErrorState.fromState(
            state,
            errorMessage: "Only JPEG or PNG allowed.",
          ),
        );
        return;
      }

      if (fileSize > 5 * 1024 * 1024) {
        emit(
          ProfileImageErrorState.fromState(
            state,
            errorMessage: "Image must be under 5MB.",
          ),
        );
        return;
      }

      // Compress the image using bytes
      final compressedBytes = await FlutterImageCompress.compressWithList(
        await pickedFile.readAsBytes(),
        minHeight: 1920,
        minWidth: 1080,
        quality: 85,
      );

      if (compressedBytes.isEmpty) {
        emit(
          ProfileImageErrorState.fromState(
            state,
            errorMessage: "Failed to compress image.",
          ),
        );
        return;
      }

      // Save compressed file to temp directory
      final tempDir = await getTemporaryDirectory();
      final compressedFile = File(
        '${tempDir.path}/profile_${DateTime.now().millisecondsSinceEpoch}.jpg',
      );
      await compressedFile.writeAsBytes(compressedBytes);

      // Preserve ProfileEditViewLoaded state type if it exists
      if (state is ProfileEditViewLoaded) {
        final loadedState = state as ProfileEditViewLoaded;
        final newState = ProfileEditViewLoaded(
          profileEditViewResponse: loadedState.profileEditViewResponse,
          venueName: loadedState.venueName,
          venueDescription: loadedState.venueDescription,
          email: loadedState.email,
          phone: loadedState.phone,
          country: loadedState.country,
          address: loadedState.address,
          postalCode: loadedState.postalCode,
          venueTypes: loadedState.venueTypes,
          selectedVenueTypeIds: loadedState.selectedVenueTypeIds,
          openingHours: loadedState.openingHours,
          image: loadedState.image,
          blob: loadedState.blob,
          originalName: loadedState.originalName,
          gallery: loadedState.gallery,
          galleryIds: loadedState.galleryIds,
        );
        emit(
          newState.copyWith(
            profileImageFile: compressedFile,
            profileImagePath: compressedFile.path,
          ),
        );
      } else {
        emit(
          ProfileImageLoadedState.fromState(
            state,
            profileImageFile: compressedFile,
            profileImagePath: compressedFile.path,
          ),
        );
      }
    } catch (e) {
      emit(
        ProfileImageErrorState.fromState(
          state,
          errorMessage: "Failed to pick image: $e",
        ),
      );
    }
  }



  //////////
  ///
  Future<void> _pickMultipleImages(
    Emitter<ProfileState> emit,
    ImageSource source,
  ) async {
    emit(GalleryPhotoLoadingState.fromState(state));
    try {
      if (Platform.isAndroid) {
        Permission permission;
        if (await _isAndroid13OrHigher()) {
          permission = Permission.photos;
        } else {
          permission = Permission.storage;
        }

        final permissionStatus = await permission.request();
        if (!permissionStatus.isGranted) {
          emit(
            GalleryPhotoPermissionDeniedState.fromState(
              state,
              isPermanentlyDenied: permissionStatus.isPermanentlyDenied,
              errorMessage: "Photo permission denied.",
            ),
          );
          return;
        }
      }

      // 🟢 Calculate how many images are already present (server + local)
      final currentServerCount = state.gallery?.length ?? 0;
      final currentLocalCount = state.galleryPhotoFiles.length;
      final totalCurrentCount = currentServerCount + currentLocalCount;
      final remainingSlots = 4 - totalCurrentCount;

      debugPrint('📊 Gallery status:');
      debugPrint('  Server images: $currentServerCount');
      debugPrint('  Local images: $currentLocalCount');
      debugPrint('  Total: $totalCurrentCount');
      debugPrint('  Remaining slots: $remainingSlots');

      if (remainingSlots <= 0) {
        emit(
          GalleryPhotoErrorState.fromState(
            state,
            errorMessage:
                "Maximum 4 images allowed. Delete existing images to add more.",
          ),
        );
        return;
      }

      List<XFile> pickedFiles = [];

      if (source == ImageSource.gallery) {
        pickedFiles = await _picker.pickMultiImage(imageQuality: 80);
      } else if (source == ImageSource.camera) {
        final single = await _picker.pickImage(
          source: ImageSource.camera,
          imageQuality: 80,
        );
        if (single != null) pickedFiles.add(single);
      }

      if (pickedFiles.isEmpty) {
        emit(
          GalleryPhotoErrorState.fromState(
            state,
            errorMessage: "No images selected.",
          ),
        );
        return;
      }

      // 🟢 Limit picked files to remaining slots
      if (pickedFiles.length > remainingSlots) {
        debugPrint(
          '⚠️ Selected ${pickedFiles.length} images, but only $remainingSlots slots available',
        );
        pickedFiles = pickedFiles.sublist(0, remainingSlots);
      }

      final compressedFiles = <File>[];

      for (final x in pickedFiles) {
        final ext = x.name.toLowerCase();
        if (!(ext.endsWith('.png') ||
            ext.endsWith('.jpg') ||
            ext.endsWith('.jpeg'))) {
          debugPrint('⚠️ Skipping invalid file type: ${x.name}');
          continue;
        }

        final originalFile = File(x.path);
        final fileSize = originalFile.lengthSync();
        if (fileSize > 5 * 1024 * 1024) {
          debugPrint('⚠️ Skipping file larger than 5MB: ${x.name}');
          continue;
        }

        // Compress image
        final compressedBytes = await FlutterImageCompress.compressWithList(
          await x.readAsBytes(),
          minHeight: 1920,
          minWidth: 1080,
          quality: 85,
        );

        if (compressedBytes.isEmpty) {
          debugPrint('⚠️ Compression failed for: ${x.name}');
          continue;
        }

        // Save compressed file
        final tempDir = await getTemporaryDirectory();
        final compressedFile = File(
          '${tempDir.path}/gallery_${DateTime.now().millisecondsSinceEpoch}.jpg',
        );
        await compressedFile.writeAsBytes(compressedBytes);

        compressedFiles.add(compressedFile);
      }

      if (compressedFiles.isEmpty) {
        emit(
          GalleryPhotoErrorState.fromState(
            state,
            errorMessage: "No valid images found after compression.",
          ),
        );
        return;
      }

      // 🟢 Combine with existing local images, ensuring total <= remainingSlots
      final updatedList = List<File>.from(state.galleryPhotoFiles)
        ..addAll(compressedFiles);

      // Double-check total count (should not exceed 4 when combined with server images)
      final finalTotalCount = currentServerCount + updatedList.length;
      if (finalTotalCount > 4) {
        debugPrint('⚠️ Final count exceeds 4, trimming...');
        final maxAllowed = 4 - currentServerCount;
        if (maxAllowed > 0) {
          updatedList.removeRange(maxAllowed, updatedList.length);
        } else {
          updatedList.clear();
        }
      }

      debugPrint('✅ Final gallery files count: ${updatedList.length}');

      // Preserve ProfileEditViewLoaded state type
      if (state is ProfileEditViewLoaded) {
        final loadedState = state as ProfileEditViewLoaded;
        final newState = ProfileEditViewLoaded(
          profileEditViewResponse: loadedState.profileEditViewResponse,
          venueName: loadedState.venueName,
          venueDescription: loadedState.venueDescription,
          email: loadedState.email,
          phone: loadedState.phone,
          country: loadedState.country,
          address: loadedState.address,
          postalCode: loadedState.postalCode,
          venueTypes: loadedState.venueTypes,
          selectedVenueTypeIds: loadedState.selectedVenueTypeIds,
          openingHours: loadedState.openingHours,
          image: loadedState.image,
          blob: loadedState.blob,
          originalName: loadedState.originalName,
          gallery: loadedState.gallery,
          galleryIds: loadedState.galleryIds,
        );
        emit(newState.copyWith(galleryPhotoFiles: updatedList));
      } else {
        emit(
          GalleryPhotoLoadedState.fromState(
            state,
            galleryPhotoFiles: updatedList,
          ),
        );
      }
    } catch (e) {
      debugPrint('❌ Error picking gallery images: $e');
      emit(
        GalleryPhotoErrorState.fromState(
          state,
          errorMessage: "Failed to pick images: $e",
        ),
      );
    }
  }
}

Future<File> _compressImageInIsolate(String filePath) async {
  final bytes = await File(filePath).readAsBytes();
  final compressedBytes = await FlutterImageCompress.compressWithList(
    bytes,
    minHeight: 1920,
    minWidth: 1080,
    quality: 85,
  );

  final tempDir = await getTemporaryDirectory();
  final compressedFile = File(
    '${tempDir.path}/gallery_${DateTime.now().millisecondsSinceEpoch}.jpg',
  );
  await compressedFile.writeAsBytes(compressedBytes);
  return compressedFile;
}
