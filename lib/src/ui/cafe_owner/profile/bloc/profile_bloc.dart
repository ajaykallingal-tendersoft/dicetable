import 'dart:async';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:dicetable/src/utils/client/api_client.dart';
import 'package:dicetable/src/utils/data/object_factory.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

part 'profile_event.dart';
part 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final ImagePicker _picker = ImagePicker();
  XFile? _image;

  ProfileBloc() : super(ProfileState()) {
    on<UpdateTextField>((event, emit) {
      emit(event.update(state));
    });

    on<FetchCafeProfile>(_onFetchCafeProfile);

    on<FetchEditCafeProfile>(_onFetchCafeEditProfile);

    on<ToggleVenueType>((event, emit) {
      if (state.cafeProfile == null) return;

      // Update venueTypes list with toggled selected value
      final updatedVenueTypes =
          state.cafeProfile!.venueTypes.map((venue) {
            if (venue.title == event.venueType) {
              return venue.copyWith(selected: event.isSelected);
            }
            return venue;
          }).toList();

      // Create a new CafeProfile with updated venueTypes list
      final updatedCafeProfile = state.cafeProfile!.copyWith(
        venueTypes: updatedVenueTypes,
      );

      // Emit a new ProfileState with updated cafeProfile
      emit(state.copyWith(cafeProfile: updatedCafeProfile));
    });

    on<UpdateOpeningHour>((event, emit) {
      final updatedMap = Map<String, ProfileOpeningHour>.from(
        state.openingHours,
      );

      updatedMap[event.day] = event.hour;
      print("Updated Map: ${event.day}");
      for (var hour in state.cafeProfile!.openingHours) {
        if (hour.day == event.day) {
          hour.isOpen = event.hour.isEnabled;
          print("Updated Map: ${hour}");
        }
      }
      emit(state.copyWith(openingHours: updatedMap));
    });

    on<SubmitProfile>(_onSubmitEditProfile);

    on<PickImageFromGalleryEvent>((event, emit) async {
      emit(ProfileImageLoadingState());

      final permissionStatus = await Permission.photos.request();
      if (permissionStatus.isDenied) {
        emit(ProfileImageErrorState(errorMessage: "Photo permission denied."));
        return;
      }

      try {
        final pickedImage = await _picker.pickImage(
          source: ImageSource.gallery,
        );

        if (pickedImage == null) {
          emit(ProfileImageErrorState(errorMessage: "No image selected."));
          return;
        }

        final file = File(pickedImage.path);
        final fileSize = file.lengthSync();
        final ext = pickedImage.name.toLowerCase();

        // Check format and size
        if (!(ext.endsWith('.png') || ext.endsWith('.jpeg'))) {
          emit(
            ProfileImageErrorState(
              errorMessage: "Only JPEG or PNG images are allowed.",
            ),
          );
          return;
        }

        if (fileSize > 5 * 1024 * 1024) {
          emit(
            ProfileImageErrorState(
              errorMessage: "Image size must be under 5MB.",
            ),
          );
          return;
        }

        _image = pickedImage;

        print(_image!.name);
        emit(ProfileImageLoadedState(image: _image!));
      } catch (e) {
        emit(ProfileImageErrorState(errorMessage: "Failed to pick image: $e"));
      }
    });
  }

  FutureOr<void> _onFetchCafeProfile(
    FetchCafeProfile event,
    Emitter<ProfileState> emit,
  ) async {
    emit(ProfileLoading());
    final apiClient = ApiClient();
    try {
      final response = await apiClient.getCafeProfileById(event.id);
      if (response.statusCode == 200) {
        emit(ProfileLoaded(profileData: response.data['data']));
      } else {
        emit(
          ProfileLoadError(
            errorMessage: "Failed with status: ${response.statusCode}",
          ),
        );
      }
    } catch (e) {
      emit(ProfileLoadError(errorMessage: "Error: $e"));
    }
  }

  FutureOr<void> _onFetchCafeEditProfile(
    FetchEditCafeProfile event,
    Emitter<ProfileState> emit,
  ) async {
    emit(ProfileLoading());
    final apiClient = ApiClient();
    try {
      final response = await apiClient.getCafeEditProfilebyId(event.id);
      if (response.statusCode == 200) {
        final profile = CafeProfile.fromJson(response.data['data']);
        emit(state.copyWith(cafeProfile: profile));
      } else {
        emit(
          EditProfileLoadError(
            errorMessage: "Failed with status: ${response.statusCode}",
          ),
        );
      }
    } catch (e) {
      emit(EditProfileLoadError(errorMessage: "Error: $e"));
    }
  }

  FutureOr<void> _onSubmitEditProfile(
    SubmitProfile event,
    Emitter<ProfileState> emit,
  ) async {
    List<OpeningHour>? selectedOpeningHours =
        state.cafeProfile?.openingHours.where((hour) => hour.isOpen).toList();
    for (var hour in selectedOpeningHours!) {
      print("Selected Opening Hours: ${hour}");
    }
    final apiClient = ApiClient();
    final data = {
      "name": state.cafeProfile?.name,
      "email": state.cafeProfile?.email,
      "phone": state.cafeProfile?.phone,
      "address": state.cafeProfile?.address,
      "postcode": state.cafeProfile?.postcode,
      "venue_description": state.cafeProfile?.venue_description,
      "accommodations": [1],
      "working_days":
          selectedOpeningHours
              .map(
                (hour) => {
                  "day": hour.day,
                  "from": hour.opening,
                  "to": hour.closing,
                  "isEnabled": hour.isOpen,
                },
              )
              .toList(),
      "blob": "data:image/png;base64,iVBORw0KG...",
      "original_name": "profile.png",
      "password": "password",
    };
    try {
      final response = await apiClient.postCafeEditSubmitProfileById(
        ObjectFactory().prefs.getCafeId().toString(),
        data,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Assuming the API returns the updated profile data
        // emit(ProfileLoaded(profileData: response.data['data']));
        emit(state);
      } else {
        emit(
          ProfileLoadError(
            errorMessage:
                "Failed to update profile. Status: ${response.statusCode}",
          ),
        );
      }
    } catch (e) {
      emit(ProfileLoadError(errorMessage: "Error: $e"));
    }
  }
}
/*
Future<void> _onFetchCafeProfile(
  FetchCafeProfile event,
  Emitter<ProfileState> emit,
) async {
  emit(ProfileLoading());
  final apiClient = ApiClient();
  try {
    final response = await apiClient.getCafeProfileById(event.id);
    if (response.statusCode == 200) {
      emit(ProfileLoaded(profileData: response.data['data']));
    } else {
      emit(
        ProfileLoadError(
          errorMessage: "Failed with status: ${response.statusCode}",
        ),
      );
    }
  } catch (e) {
    emit(ProfileLoadError(errorMessage: "Error: $e"));
  }
}

Future<void> _onFetchCafeEditProfile(
  FetchEditCafeProfile event,
  Emitter<ProfileState> emit,
) async {
  emit(ProfileLoading());
  final apiClient = ApiClient();
  try {
    final response = await apiClient.getCafeEditProfilebyId(event.id);
    if (response.statusCode == 200) {
      final profile = CafeProfile.fromJson(response.data['data']);
      emit(ProfileState(cafeProfile: profile));
    } else {
      emit(
        EditProfileLoadError(
          errorMessage: "Failed with status: ${response.statusCode}",
        ),
      );
    }
  } catch (e) {
    emit(EditProfileLoadError(errorMessage: "Error: $e"));
  }
}
*/
// Future<void> _onFetchCafeEditProfile(
//   FetchEditCafeProfile event,
//   Emitter<ProfileState> emit,
// ) async {
//   emit(ProfileLoading());
//   final apiClient = ApiClient();
//   try {
//     final response = await apiClient.getCafeEditProfilebyId(event.id);
//     if (response.statusCode == 200) {
//       final cafeProfile = CafeProfile.fromJson(response.data['data']);

//       // Convert the opening hours and venue types to correct formats
//       final openingHours = <String, ProfileOpeningHour>{};
//       for (var entry in cafeProfile.openingHours.entries) {
//         openingHours[entry.key] = ProfileOpeningHour(
//           isEnabled: entry.value['isEnabled'],
//           from: _parseTime(entry.value['from']),
//           to: _parseTime(entry.value['to']),
//         );
//       }

//       final venueTypes = Map<String, bool>.from(cafeProfile.venueTypes as Map);

//       emit(
//         ProfileState(
//           venueName: cafeProfile.venueName ?? '',
//           venueDescription: cafeProfile.venueDescription ?? '',
//           email: cafeProfile.email ?? '',
//           phone: cafeProfile.phone ?? '',
//           address: cafeProfile.address ?? '',
//           postalCode: cafeProfile.postalCode ?? '',
//           venueTypes: venueTypes,
//           openingHours: openingHours,
//           image: null, // or use XFile.fromData if available
//         ),
//       );
//     } else {
//       emit(
//         ProfileLoadError(
//           errorMessage: "Failed with status: ${response.statusCode}",
//         ),
//       );
//     }
//   } catch (e) {
//     emit(ProfileLoadError(errorMessage: "Error: $e"));
//   }
// }

// extension on CafeProfile {
//   get venueName => null;

//   get venueDescription => null;

//   get postalCode => null;
// }

// extension on List<OpeningHour> {
//   get entries => null;
// }

// TimeOfDay _parseTime(String time) {
//   final parts = time.split(":");
//   return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
// }
