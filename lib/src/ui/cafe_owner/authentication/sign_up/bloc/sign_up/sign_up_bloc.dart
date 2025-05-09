import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:bloc/bloc.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:dicetable/src/model/cafe_owner/auth/signUp/sign_up_request.dart';
import 'package:dicetable/src/model/cafe_owner/auth/signUp/sign_up_request_response.dart';
import 'package:dicetable/src/resources/api_providers/auth/auth_data_provider.dart';
import 'package:dicetable/src/ui/cafe_owner/authentication/sign_up/model/venue_type_model.dart';
import 'package:dicetable/src/utils/extension/state_model_extension.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

part 'sign_up_event.dart';

part 'sign_up_state.dart';

class SignUpBloc extends Bloc<SignUpEvent, SignUpState> {
  final AuthDataProvider authDataProvider;
  final ImagePicker _picker = ImagePicker();
  XFile? _image;
  String base64String = '';
  String base64Encoded = '';
  SignUpFormState _formState;

  SignUpBloc({required this.authDataProvider})
    : _formState = SignUpFormState(
        openingHours: {
          for (final day in [
            'Monday',
            'Tuesday',
            'Wednesday',
            'Thursday',
            'Friday',
            'Saturday',
            'Sunday',
          ])
            day: OpeningHour(
              isEnabled: false,
              from: const TimeOfDay(hour: 9, minute: 0),
              to: const TimeOfDay(hour: 17, minute: 0),
            ),
        },
      ),
      super(SignUpInitial()) {
    emit(_formState);

    on<UpdateTextField>((event, emit) {
      _formState = event.update(_formState);
      emit(_formState);
    });

    on<ToggleVenueType>((event, emit) {
      final updatedVenueTypes = Map<String, VenueTypeModel>.from(_formState.venueTypes);

      final current = updatedVenueTypes[event.venueType];
      if (current != null) {
        updatedVenueTypes[event.venueType] = current.copyWith(isSelected: event.isSelected);
        _formState = _formState.copyWith(venueTypes: updatedVenueTypes);
        emit(_formState);
      }
    });

    on<UpdateOpeningHour>((event, emit) {
      final updatedHours = Map<String, OpeningHour>.from(
        _formState.openingHours,
      )..[event.day] = event.hour;
      _formState = _formState.copyWith(openingHours: updatedHours);
      emit(_formState);
    });

    on<PickImageFromGalleryEvent>((event, emit) async {
      emit(SignUpImageLoadingState());
      try {
        Permission permission;
        if (Platform.isAndroid) {
          // For Android 13 (API level 33) and higher, use READ_MEDIA_IMAGES
          if (await isAndroid13OrHigher()) {
            permission =
                Permission
                    .photos; // This maps to READ_MEDIA_IMAGES on Android 13+
          } else {
            // For Android 12 and below
            permission = Permission.storage;
          }
        } else {
          // For iOS
          permission = Permission.photos;
        }

        // Request permission
        final permissionStatus = await permission.request();

        if (!permissionStatus.isGranted) {
          emit(
            SignUpImageErrorState(
              errorMessage: "Photo access permission denied.",
            ),
          );
          emit(_formState); // Restore form state
          return;
        }

        final pickedImage = await _picker.pickImage(
          source: ImageSource.gallery,
          imageQuality: 80, // Optimize image quality/size
        );

        if (pickedImage == null) {
          emit(SignUpImageErrorState(errorMessage: "No image selected."));
          emit(_formState);
          return;
        }

        final file = File(pickedImage.path);
        final fileSize = file.lengthSync();
        final ext = pickedImage.name.toLowerCase();

        if (!(ext.endsWith('.png') ||
            ext.endsWith('.jpeg') ||
            ext.endsWith('.jpg'))) {
          emit(
            SignUpImageErrorState(
              errorMessage: "Only JPEG or PNG images are allowed.",
            ),
          );
          emit(_formState);
          return;
        }

        if (fileSize > 5 * 1024 * 1024) {
          emit(
            SignUpImageErrorState(
              errorMessage: "Image size must be under 5MB.",
            ),
          );
          emit(_formState);
          return;
        }

        Uint8List bytes = await pickedImage.readAsBytes();
        base64String = base64.encode(bytes);
        _image = pickedImage;
        String base64Encoded = "data:image/png;base64,$base64String";

        _formState = _formState.copyWith(
          image: _image,
          base64Image: base64Encoded,
        );
        emit(_formState);
      } catch (e) {
        emit(SignUpImageErrorState(errorMessage: "Failed to pick image: $e"));
        emit(_formState);
      }
    });
    on<CaptureImageWithCameraEvent>((event, emit) async {
      emit(SignUpImageLoadingState());

      try {
        Permission permission;

        if (Platform.isAndroid) {
          permission = Permission.camera;
        } else {
          permission = Permission.camera;
        }

        final permissionStatus = await permission.request();

        if (!permissionStatus.isGranted) {
          emit(
            SignUpImageErrorState(
              errorMessage: "Camera access permission denied.",
            ),
          );
          emit(_formState); // Restore form state
          return;
        }

        final pickedImage = await _picker.pickImage(
          source: ImageSource.camera,
          imageQuality: 80, // Optimize image quality/size
        );

        if (pickedImage == null) {
          emit(SignUpImageErrorState(errorMessage: "No image captured."));
          emit(_formState);
          return;
        }

        final file = File(pickedImage.path);
        final fileSize = file.lengthSync();
        final ext = pickedImage.name.toLowerCase();

        if (!(ext.endsWith('.png') ||
            ext.endsWith('.jpeg') ||
            ext.endsWith('.jpg'))) {
          emit(
            SignUpImageErrorState(
              errorMessage: "Only JPEG or PNG images are allowed.",
            ),
          );
          emit(_formState);
          return;
        }

        if (fileSize > 5 * 1024 * 1024) {
          emit(
            SignUpImageErrorState(
              errorMessage: "Image size must be under 5MB.",
            ),
          );
          emit(_formState);
          return;
        }

        Uint8List bytes = await pickedImage.readAsBytes();
        base64String = base64.encode(bytes);
        _image = pickedImage;
        String base64Encoded = "data:image/png;base64,$base64String";
        _formState = _formState.copyWith(
          image: _image,
          base64Image: base64Encoded,
        );
        emit(_formState);
      } catch (e) {
        emit(
          SignUpImageErrorState(errorMessage: "Failed to capture image: $e"),
        );
        emit(_formState);
      }
    });
    on<ClearImageEvent>((event, emit) async {
      emit(SignUpImageLoadingState());
      try {
        _image = null;
        base64String = '';
        _formState = _formState.copyWith(
          clearImage: true,
          base64Image: '',
        );
        emit(_formState);
        print("Image cleared successfully. New state: ${_formState.image}, ${_formState.base64Image}");
      } catch (e) {
        print("Error clearing image: $e");
        emit(SignUpImageErrorState(errorMessage: "Failed to clear image: $e"));
        emit(_formState);
      }
    });

    on<SubmitSignUp>((event, emit) async {
      emit(SignUpLoadingState());

      if (_image == null) {
        emit(
          SignUpErrorState(
            errorMessage: "Please upload an image to complete sign-up.",
          ),
        );
        return;
      }

      final result = await authDataProvider.registerUser(event.signupRequest);

      if (result!.isError) {
        final error = result.error;

        if (error is SignUpRequestResponse) {
          final firstError =
              error.errors?.values.first.first ?? "Signup failed.";
          emit(SignUpErrorState(errorMessage: firstError));
        } else if (error is String) {
          emit(SignUpErrorState(errorMessage: error));
        } else {
          emit(SignUpErrorState(errorMessage: "Something went wrong."));
        }
      } else if (result.isSuccess) {
        final response = result.data as SignUpRequestResponse;

        if (response.status == true) {
          emit(SignUpSuccessState(signUpRequestResponse: response));
        } else {
          emit(
            SignUpErrorState(
              errorMessage:
                  response.errors?.values.first.first ?? "Signup failed",
            ),
          );
        }
      }
    });
  }

  Future<bool> isAndroid13OrHigher() async {
    if (!Platform.isAndroid) return false;

    final deviceInfoPlugin = DeviceInfoPlugin();
    final androidInfo = await deviceInfoPlugin.androidInfo;

    // Android 13 is API level 33
    return androidInfo.version.sdkInt >= 33;
  }
}
