import 'dart:io';

import 'package:bloc/bloc.dart';
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
    ;

    on<ToggleVenueType>((event, emit) {
      final updated = Map<String, bool>.from(state.venueTypes)
        ..[event.venueType] = event.isSelected;

      emit(state.copyWith(venueTypes: updated));
    });

    on<UpdateOpeningHour>((event, emit) {
      final updatedHours = Map<String, ProfileOpeningHour>.from(state.openingHours)
        ..[event.day] = event.hour;
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
        if (!(ext.endsWith('.png') ||
            ext.endsWith('.jpeg')
        )) {
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
