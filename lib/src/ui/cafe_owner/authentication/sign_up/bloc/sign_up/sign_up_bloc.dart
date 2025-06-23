import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:bloc/bloc.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:dicetable/src/model/cafe_owner/auth/login/google_login_request_response.dart';
import 'package:dicetable/src/model/cafe_owner/auth/signUp/apple_sign-up_request.dart';
import 'package:dicetable/src/model/cafe_owner/auth/signUp/apple_sign-up_response.dart';
import 'package:dicetable/src/model/cafe_owner/auth/signUp/google_sign-up_request.dart';
import 'package:dicetable/src/model/cafe_owner/auth/signUp/google_sign-up_response.dart';
import 'package:dicetable/src/model/cafe_owner/auth/signUp/sign_up_request.dart';
import 'package:dicetable/src/model/cafe_owner/auth/signUp/sign_up_request_response.dart';
import 'package:dicetable/src/model/state_model.dart';
import 'package:dicetable/src/model/venue_type_response.dart';
import 'package:dicetable/src/resources/api_providers/auth/auth_data_provider.dart';
import 'package:dicetable/src/ui/cafe_owner/authentication/sign_up/model/venue_type_model.dart';
import 'package:dicetable/src/utils/data/object_factory.dart';
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
  final SignUpFormState _initialFormState;

  SignUpBloc({required this.authDataProvider})
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
          imageQuality: 80,
        );

        if (pickedImage == null) {
          emit(_formState); // User cancelled or permission denied
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
        base64Encoded = "data:image/png;base64,$base64String";

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
          imageQuality: 80,
        );

        if (pickedImage == null) {
          // emit(SignUpImageErrorState(errorMessage: "No image captured."));
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
        base64Encoded = "data:image/png;base64,$base64String";

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

    // on<PickImageFromGalleryEvent>((event, emit) async {
    //   emit(SignUpImageLoadingState());
    //   try {
    //     Permission permission;
    //     if (Platform.isAndroid) {
    //       if (await isAndroid13OrHigher()) {
    //         permission = Permission.photos;
    //       } else {
    //         permission = Permission.storage;
    //       }

    //       final permissionStatus = await permission.request();
    //       if (!permissionStatus.isGranted) {
    //         emit(
    //           SignUpImageErrorState(
    //             errorMessage: "Photo access permission denied.",
    //           ),
    //         );
    //         emit(_formState);
    //         return;
    //       }
    //     }

    //     final pickedImage = await _picker.pickImage(
    //       source: ImageSource.gallery,
    //       imageQuality: 80,
    //     );

    //     if (pickedImage == null) {
    //       // emit(SignUpImageErrorState(errorMessage: "No image selected."));
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
    //     emit(SignUpImageErrorState(errorMessage: "Failed to pick image: $e"));
    //     emit(_formState);
    //   }
    // });

    // on<CaptureImageWithCameraEvent>((event, emit) async {
    //   emit(SignUpImageLoadingState());
    //   try {
    //     Permission permission = Permission.camera;
    //     final permissionStatus = await permission.request();

    //     if (!permissionStatus.isGranted) {
    //       emit(
    //         SignUpImageErrorState(
    //           errorMessage: "Camera access permission denied.",
    //         ),
    //       );
    //       emit(_formState);
    //       return;
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
        event.signupRequest,
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
        event.signupRequest,
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
      emit(_formState.copyWith(isLoadingVenueTypes: true));
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
