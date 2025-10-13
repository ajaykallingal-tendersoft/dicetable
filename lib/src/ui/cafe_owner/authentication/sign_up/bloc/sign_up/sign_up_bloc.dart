import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:bloc/bloc.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:soloseaters/src/model/cafe_owner/auth/login/google_login_request_response.dart';
import 'package:soloseaters/src/model/cafe_owner/auth/signUp/apple_sign-up_request.dart';
import 'package:soloseaters/src/model/cafe_owner/auth/signUp/apple_sign-up_response.dart';
import 'package:soloseaters/src/model/cafe_owner/auth/signUp/google_sign-up_request.dart';
import 'package:soloseaters/src/model/cafe_owner/auth/signUp/google_sign-up_response.dart';
import 'package:soloseaters/src/model/cafe_owner/auth/signUp/sign_up_request.dart';
import 'package:soloseaters/src/model/cafe_owner/auth/signUp/sign_up_request_response.dart';
import 'package:soloseaters/src/model/state_model.dart';
import 'package:soloseaters/src/model/venue_type_response.dart';
import 'package:soloseaters/src/resources/api_providers/auth/auth_data_provider.dart';
import 'package:soloseaters/src/ui/cafe_owner/authentication/sign_up/model/venue_type_model.dart';
import 'package:soloseaters/src/utils/data/object_factory.dart';
import 'package:soloseaters/src/utils/extension/state_model_extension.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

part 'sign_up_event.dart';
part 'sign_up_state.dart';

class SignUpBloc extends Bloc<SignUpEvent, SignUpState> {
  final AuthDataProvider authDataProvider;
   bool isGoogleSignUp;
   bool isAppleSignUp;
  final ImagePicker _picker = ImagePicker();
  XFile? _image;
  String base64String = '';
  String base64Encoded = '';
  SignUpFormState _formState;
  final SignUpFormState _initialFormState;

  SignUpBloc({required this.authDataProvider, this.isGoogleSignUp = false, this.isAppleSignUp = false})
    : _formState = SignUpFormState(
        openingHours: {
          for (final day in ['mon', 'tue', 'wed', 'thu', 'fri', 'sat', 'sun'])
            day: OpeningHour(
              isEnabled: false,
              from: const TimeOfDay(hour: 9, minute: 0),
              to: const TimeOfDay(hour: 17, minute: 0),
            ),
        },
      ),
      _initialFormState = SignUpFormState(
        openingHours: {
          for (final day in ['mon', 'tue', 'wed', 'thu', 'fri', 'sat', 'sun'])
            day: OpeningHour(
              isEnabled: false,
              from: const TimeOfDay(hour: 9, minute: 0),
              to: const TimeOfDay(hour: 17, minute: 0),
            ),
        },
      ),
      super(SignUpInitial()) {
    emit(_formState);


  on<SetSignUpType>((event, emit) {
      isGoogleSignUp = event.isGoogleSignUp;
      isAppleSignUp = event.isAppleSignUp;
    });
  
    on<UpdateTextField>((event, emit) {
      _formState = event.update(_formState);
      emit(_formState);
    });
    on<ResetFormEvent>((event, emit) {
      _formState = _initialFormState; // Reset to initial state
      _image = null;
      base64String = '';
      base64Encoded = '';
      ObjectFactory().prefs.clearImageData();
      emit(_formState);
    });

    on<ToggleVenueType>((event, emit) {
      final updatedVenueTypes =
          _formState.venueTypes.map((model) {
            if (model.id == event.id) {
              return model.copyWith(isSelected: event.isSelected);
            }
            return model;
          }).toList();

      _formState = _formState.copyWith(venueTypes: updatedVenueTypes);
      emit(_formState);
    });

    on<UpdateOpeningHour>((event, emit) {
      final updatedHours = Map<String, OpeningHour>.from(
        _formState.openingHours,
      )..[event.day] = event.hour;
      _formState = _formState.copyWith(openingHours: updatedHours);
      emit(_formState);
    });

    Future<Uint8List?> _compressImage(XFile imageFile) async {
      try {
        Uint8List originalBytes = await imageFile.readAsBytes();
        final compressedBytes = await FlutterImageCompress.compressWithList(
          originalBytes,
          minHeight: 1920,
          minWidth: 1080,
          quality: 85,
          rotate: 0,
        );
        return compressedBytes;
      } catch (e) {
        print('Error compressing image: $e');
        return null;
      }
    }

    ///New Functionality for picking image from gallery
    on<PickImageFromGalleryEvent>((event, emit) async {
      emit(SignUpImageLoadingState());
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
              SignUpImageErrorState(
                errorMessage: "Photo access permission denied.",
              ),
            );
            emit(_formState);
            return;
          }
        }

        // This will trigger iOS permission dialog if needed
        final pickedImage = await _picker.pickImage(
          source: ImageSource.gallery,
          imageQuality: 80, // Initial compression by image_picker
        );

        if (pickedImage == null) {
          emit(_formState); // User cancelled or permission denied
          return;
        }

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

        // Debug print: Original image size
        final originalBytes = await pickedImage.readAsBytes();
        debugPrint('📸 Original image size: ${originalBytes.length} bytes');

        // Compress the image
        Uint8List? compressedBytes = await _compressImage(pickedImage);

        if (compressedBytes == null) {
          emit(SignUpImageErrorState(errorMessage: "Failed to process image."));
          emit(_formState);
          return;
        }

        // Debug print: Compressed image size
        debugPrint('📏 Compressed image size: ${compressedBytes.length} bytes');

        // Check compressed size (optional - you can remove this check if you want)
        if (compressedBytes.length > 5 * 1024 * 1024) {
          emit(
            SignUpImageErrorState(
              errorMessage: "Image is too large even after compression.",
            ),
          );
          emit(_formState);
          return;
        }

        base64String = base64.encode(compressedBytes);
        _image = pickedImage;
        base64Encoded =
            "data:image/jpeg;base64,$base64String"; // Use jpeg for compressed images

        _formState = _formState.copyWith(
          image: _image,
          base64Image: base64Encoded,
        );
        ObjectFactory().prefs.setImageData(cafeUserImage: base64Encoded);
        emit(_formState);
      } catch (e) {
        emit(SignUpImageErrorState(errorMessage: "Failed to pick image: $e"));
        emit(_formState);
      }
    });

    List<XFile> _multipleImages = [];
    List<String> base64ImageList = [];

    on<PickMultipleImagesFromGalleryEvent>((event, emit) async {
      emit(SignUpImageLoadingState());
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
            emit(SignUpImageErrorState(errorMessage: "Photo access permission denied."));
            emit(_formState);
            return;
          }
        }

        // Pick new images
        final pickedImages = await _picker.pickMultiImage(imageQuality: 80);

        // If user cancels or picks none, just keep existing state
        if (pickedImages.isEmpty) {
          emit(_formState);
          return;
        }

        // ✅ Keep existing images if already present
        List<XFile> existingImages = List<XFile>.from(_multipleImages);
        List<String> existingBase64 = List<String>.from(base64ImageList);

        for (final pickedImage in pickedImages) {
          final ext = pickedImage.name.toLowerCase();
          if (!(ext.endsWith('.png') || ext.endsWith('.jpeg') || ext.endsWith('.jpg'))) {
            emit(SignUpImageErrorState(errorMessage: "Only JPEG or PNG images are allowed."));
            emit(_formState);
            return;
          }

          final compressedBytes = await FlutterImageCompress.compressWithList(
            await pickedImage.readAsBytes(),
            minHeight: 1920,
            minWidth: 1080,
            quality: 85,
            rotate: 0,
          );

          if (compressedBytes == null) continue;
          if (compressedBytes.length > 5 * 1024 * 1024) {
            emit(SignUpImageErrorState(errorMessage: "Image too large after compression."));
            emit(_formState);
            return;
          }

          final base64String = base64.encode(compressedBytes);
          existingBase64.add("data:image/jpeg;base64,$base64String");
          existingImages.add(pickedImage);
        }

        // ✅ Update the stored image lists (append instead of replacing)
        _multipleImages = existingImages;
        base64ImageList = existingBase64;

        _formState = _formState.copyWith(
          multipleImages: _multipleImages,
          multipleBase64Images: base64ImageList,
        );
        emit(_formState);
      } catch (e) {
        emit(SignUpImageErrorState(errorMessage: "Failed to pick images: $e"));
        emit(_formState);
      }
    });

    on<ClearAllImagesEvent>((event, emit) async {
      emit(SignUpImageLoadingState());
      _multipleImages.clear();
      base64ImageList.clear();
      _formState = _formState.copyWith(multipleImages: [], multipleBase64Images: []);
      emit(_formState);
    });

    on<RemoveSingleImageEvent>((event, emit) async {
      emit(SignUpImageLoadingState());
      if (event.index < _multipleImages.length) {
        _multipleImages.removeAt(event.index);
        base64ImageList.removeAt(event.index);
        _formState = _formState.copyWith(multipleImages: _multipleImages, multipleBase64Images: base64ImageList);
      }
      emit(_formState);
    });

    on<TakeMultiplePicturesEvent>((event, emit) async {
      emit(SignUpImageLoadingState());
      try {
        if (Platform.isAndroid) {
          Permission permission = await isAndroid13OrHigher()
              ? Permission.camera
              : Permission.storage;
          final permissionStatus = await permission.request();
          if (!permissionStatus.isGranted) {
            emit(SignUpImageErrorState(errorMessage: "Camera permission denied."));
            emit(_formState);
            return;
          }
        }

        // Capture an image from camera
        final XFile? capturedImage = await _picker.pickImage(
          source: ImageSource.camera,
          imageQuality: 80,
        );

        if (capturedImage == null) {
          emit(_formState); // user cancelled
          return;
        }

        // Validate extension
        final ext = capturedImage.name.toLowerCase();
        if (!(ext.endsWith('.png') || ext.endsWith('.jpeg') || ext.endsWith('.jpg'))) {
          emit(SignUpImageErrorState(errorMessage: "Only JPEG or PNG images are allowed."));
          emit(_formState);
          return;
        }

        // Compress image
        final compressedBytes = await FlutterImageCompress.compressWithList(
          await capturedImage.readAsBytes(),
          minHeight: 1920,
          minWidth: 1080,
          quality: 85,
        );

        if (compressedBytes.isEmpty) {
          emit(SignUpImageErrorState(errorMessage: "Failed to compress image."));
          emit(_formState);
          return;
        }

        // Convert to base64
        final base64String = base64.encode(compressedBytes);
        base64ImageList.add("data:image/jpeg;base64,$base64String");
        _multipleImages.add(capturedImage);

        // ✅ Update form state with appended images
        _formState = _formState.copyWith(
          multipleImages: _multipleImages,
          multipleBase64Images: base64ImageList,
        );
        emit(_formState);
      } catch (e) {
        emit(SignUpImageErrorState(errorMessage: "Failed to capture image: $e"));
        emit(_formState);
      }
    });

    ///New Functionality for capturing image with camera
    ///
    Future<Uint8List?> _compressCameraImage(XFile imageFile) async {
      try {
        Uint8List originalBytes = await imageFile.readAsBytes();

        // Camera images are often larger,
        final compressedBytes = await FlutterImageCompress.compressWithList(
          originalBytes,
          minHeight: 1920,
          minWidth: 1080,
          quality: 80,
          rotate: 0,
          format: CompressFormat.jpeg,
          keepExif: false,
        );
        return compressedBytes;
      } catch (e) {
        print('Error compressing camera image: $e');
        return null;
      }
    }

    on<CaptureImageWithCameraEvent>((event, emit) async {
      emit(SignUpImageLoadingState());
      try {
        if (Platform.isAndroid) {
          Permission permission = Permission.camera;
          final permissionStatus = await permission.request();

          if (!permissionStatus.isGranted) {
            emit(
              SignUpImageErrorState(
                errorMessage: "Camera access permission denied.",
              ),
            );
            emit(_formState);
            return;
          }
        }

        final pickedImage = await _picker.pickImage(
          source: ImageSource.camera,
          imageQuality: 80, // Initial compression by image_picker
        );

        if (pickedImage == null) {
          emit(_formState);
          return;
        }

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

        // Debug print: Original image size from camera
        final originalCameraBytes = await pickedImage.readAsBytes();
        debugPrint(
          '📸 Camera - Original image size: ${originalCameraBytes.length} bytes',
        );

        // Compress the captured image
        Uint8List? compressedBytes = await _compressCameraImage(pickedImage);

        if (compressedBytes == null) {
          emit(
            SignUpImageErrorState(
              errorMessage: "Failed to process captured image.",
            ),
          );
          emit(_formState);
          return;
        }

        // Debug print: Compressed image size from camera
        debugPrint(
          '📏 Camera - Compressed image size: ${compressedBytes.length} bytes',
        );

        // Optional: Check compressed size (you can remove this if you want to allow any size after compression)
        if (compressedBytes.length > 5 * 1024 * 1024) {
          emit(
            SignUpImageErrorState(
              errorMessage:
                  "Captured image is too large even after compression.",
            ),
          );
          emit(_formState);
          return;
        }

        base64String = base64.encode(compressedBytes);
        _image = pickedImage;
        base64Encoded =
            "data:image/jpeg;base64,$base64String"; // Use jpeg for compressed images

        _formState = _formState.copyWith(
          image: _image,
          base64Image: base64Encoded,
        );
        ObjectFactory().prefs.setImageData(cafeUserImage: base64Encoded);
        emit(_formState);
      } catch (e) {
        emit(
          SignUpImageErrorState(errorMessage: "Failed to capture image: $e"),
        );
        emit(_formState);
      }
    });

    // on<CaptureImageWithCameraEvent>((event, emit) async {
    //   emit(SignUpImageLoadingState());
    //   try {
    //     if (Platform.isAndroid) {
    //       Permission permission = Permission.camera;
    //       final permissionStatus = await permission.request();

    //       if (!permissionStatus.isGranted) {
    //         emit(
    //           SignUpImageErrorState(
    //             errorMessage: "Camera access permission denied.",
    //           ),
    //         );
    //         emit(_formState);
    //         return;
    //       }
    //     }

    //     final pickedImage = await _picker.pickImage(
    //       source: ImageSource.camera,
    //       imageQuality: 80,
    //     );

    //     if (pickedImage == null) {
    //       // emit(SignUpImageErrorState(errorMessage: "No image captured."));
    //       emit(_formState);
    //       return;
    //     }

    //     final file = File(pickedImage.path);
    //     final fileSize = file.lengthSync();
    //     final ext = pickedImage.name.toLowerCase();

    //     if (!(ext.endsWith('.png') ||
    //         ext.endsWith('.jpeg') ||
    //         ext.endsWith('.jpg'))) {
    //       emit(
    //         SignUpImageErrorState(
    //           errorMessage: "Only JPEG or PNG images are allowed.",
    //         ),
    //       );
    //       emit(_formState);
    //       return;
    //     }

    //     if (fileSize > 5 * 1024 * 1024) {
    //       emit(
    //         SignUpImageErrorState(
    //           errorMessage: "Image size must be under 5MB.",
    //         ),
    //       );
    //       emit(_formState);
    //       return;
    //     }

    //     Uint8List bytes = await pickedImage.readAsBytes();
    //     base64String = base64.encode(bytes);
    //     _image = pickedImage;
    //     base64Encoded = "data:image/png;base64,$base64String";

    //     _formState = _formState.copyWith(
    //       image: _image,
    //       base64Image: base64Encoded,
    //     );
    //     ObjectFactory().prefs.setImageData(cafeUserImage: base64Encoded);
    //     emit(_formState);
    //   } catch (e) {
    //     emit(
    //       SignUpImageErrorState(errorMessage: "Failed to capture image: $e"),
    //     );
    //     emit(_formState);
    //   }
    // });

    on<ClearImageEvent>((event, emit) async {
      emit(SignUpImageLoadingState());
      try {
        _image = null;
        base64String = '';
        base64Encoded = '';
        _formState = _formState.copyWith(clearImage: true, base64Image: '');
        ObjectFactory().prefs.clearImageData();
        emit(_formState);
      } catch (e) {
        emit(SignUpImageErrorState(errorMessage: "Failed to clear image: $e"));
        emit(_formState);
      }
    });

    on<RestoreImageEvent>((event, emit) async {
      if (ObjectFactory().prefs.isLoggedIn() == true ||
          ObjectFactory().prefs.getAuthToken() != null) {
        return; // Do not restore image if user is logged in or has a signup token
      }
      final savedImage = ObjectFactory().prefs.getImageData();
      if (savedImage != null && savedImage.isNotEmpty) {
        _formState = _formState.copyWith(
          base64Image: savedImage,
          image: _image,
        );
        emit(_formState);
      }
    });

    on<SubmitSignUp>((event, emit) async {
      emit(SignUpLoadingState());
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
        emit(_formState);
      } else if (result.isSuccess) {
        final response = result.data as SignUpRequestResponse;
        if (response.status == true) {
          // Clear image on successful signup
          _image = null;
          base64String = '';
          base64Encoded = '';
          _formState = _formState.copyWith(
            image: null,
            base64Image: '',
            clearImage: true,
          );
          ObjectFactory().prefs.clearImageData();
          emit(SignUpSuccessState(signUpRequestResponse: response));
        } else {
          emit(
            SignUpErrorState(
              errorMessage:
                  response.errors?.values.first.first ?? "Signup failed",
            ),
          );
          emit(_formState);
        }
      }
    });

    on<SubmitGoogleSignUp>((event, emit) async {
      emit(GoogleSignUpLoadingState());
      final result = await authDataProvider.googleRegisterUser(
        event.googleSignUpRequest,
      );

      if (result!.isError) {
        final error = result.error;
        if (error is GoogleSignUpRequestResponse) {
          final firstError =
              error.errors?.values.first.first ?? "Signup failed.";
          emit(GoogleSignUpErrorState(errorMessage: firstError));
        } else if (error is String) {
          emit(GoogleSignUpErrorState(errorMessage: error));
        } else {
          emit(GoogleSignUpErrorState(errorMessage: "Something went wrong."));
        }
        emit(_formState);
      } else if (result.isSuccess) {
        final response = result.data as GoogleSignUpRequestResponse;
        if (response.status == true) {
          // Clear image on successful signup
          _image = null;
          base64String = '';
          base64Encoded = '';
          _formState = _formState.copyWith(
            image: null,
            base64Image: '',
            clearImage: true,
          );
          ObjectFactory().prefs.clearImageData();
          emit(GoogleSignUpSuccessState(googleSignUpRequestResponse: response));
        } else {
          emit(
            GoogleSignUpErrorState(
              errorMessage:
                  response.errors?.values.first.first ?? "Signup failed",
            ),
          );
          emit(_formState);
        }
      }
    });
    on<SubmitAppleSignUp>((event, emit) async {
      emit(AppleSignUpLoadingState());
      final result = await authDataProvider.appleRegisterUser(
        event.appleSignUpRequest,
      );

      if (result!.isError) {
        final error = result.error;
        if (error is AppleSignUpRequestResponse) {
          final firstError =
              error.errors?.values.first.first ?? "Signup failed.";
          emit(AppleSignUpErrorState(errorMessage: firstError));
        } else if (error is String) {
          emit(AppleSignUpErrorState(errorMessage: error));
        } else {
          emit(AppleSignUpErrorState(errorMessage: "Something went wrong."));
        }
        emit(_formState);
      } else if (result.isSuccess) {
        final response = result.data as AppleSignUpRequestResponse;
        if (response.status == true) {
          // Clear image on successful signup
          _image = null;
          base64String = '';
          base64Encoded = '';
          _formState = _formState.copyWith(
            image: null,
            base64Image: '',
            clearImage: true,
          );
          ObjectFactory().prefs.clearImageData();
          emit(AppleSignUpSuccessState(appleSignUpRequestResponse: response));
        } else {
          emit(
            AppleSignUpErrorState(
              errorMessage:
                  response.errors?.values.first.first ?? "Signup failed",
            ),
          );
          emit(_formState);
        }
      }
    });

    on<LoadVenueTypes>(_onFetchVenueType);
  }

  Future<void> _onFetchVenueType(
    LoadVenueTypes event,
    Emitter<SignUpState> emit,
  ) async {
    try {
      emit(_formState.copyWith(isLoadingVenueTypes: true, error: null));
      final response = await authDataProvider.getVenueTypes();

      if (response is SuccessState) {
        final data = response.value as VenueTypeResponse;
        final types =
            data.venueTypes
                ?.map((venueType) => VenueTypeModel.fromVenueType(venueType))
                .toList() ??
            [];

        _formState = _formState.copyWith(
          venueTypes: types,
          isLoadingVenueTypes: false,
          error: null,
        );
        emit(_formState);
      } else {
        _formState = _formState.copyWith(
          isLoadingVenueTypes: false,
          error: (response as ErrorState).msg,
        );
        emit(_formState);
      }
    } catch (e) {
      _formState = _formState.copyWith(
        isLoadingVenueTypes: false,
        error: e.toString(),
      );
      emit(_formState);
    }
  }

  Future<bool> isAndroid13OrHigher() async {
    if (!Platform.isAndroid) return false;

    final deviceInfoPlugin = DeviceInfoPlugin();
    final androidInfo = await deviceInfoPlugin.androidInfo;

    return androidInfo.version.sdkInt >= 33;
  }
}
