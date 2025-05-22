import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:dicetable/src/utils/client/api_client.dart';
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
      final updated = Map<String, bool>.from(state.venueTypes)
        ..[event.venueType] = event.isSelected;

      emit(state.copyWith(venueTypes: updated));
    });

    on<UpdateOpeningHour>((event, emit) {
      final updatedHours = Map<String, ProfileOpeningHour>.from(
        state.openingHours,
      )..[event.day] = event.hour;
      emit(state.copyWith(openingHours: updatedHours));
    });

    on<SubmitProfile>((event, emit) {
      // You could add validation or API interaction here
      emit(state);
    });

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
}

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
      emit(EditProfileLoaded(profileData: profile));
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
