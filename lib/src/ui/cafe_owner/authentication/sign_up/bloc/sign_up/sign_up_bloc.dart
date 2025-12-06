import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:bloc/bloc.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import 'package:soloseaters/src/model/cafe_owner/auth/login/google_login_request_response.dart';
import 'package:soloseaters/src/model/cafe_owner/auth/signUp/apple_sign-up_request.dart';
import 'package:soloseaters/src/model/cafe_owner/auth/signUp/apple_sign-up_response.dart';
import 'package:soloseaters/src/model/cafe_owner/auth/signUp/google_sign-up_request.dart';
import 'package:soloseaters/src/model/cafe_owner/auth/signUp/google_sign-up_response.dart';
import 'package:soloseaters/src/model/cafe_owner/auth/signUp/sign_up_request.dart';
import 'package:soloseaters/src/model/cafe_owner/auth/signUp/sign_up_request_response.dart';
import 'package:soloseaters/src/model/country_response.dart';
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
  List<XFile> _multipleImages = [];
  List<String> base64ImageList = [];
  List<XFile> _multipleImageFiles = [];

  SignUpBloc({
    required this.authDataProvider,
    this.isGoogleSignUp = false,
    this.isAppleSignUp = false,
  }) : _formState = SignUpFormState(
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
      _formState = _initialFormState;
      _image = null;
      base64String = '';
      base64Encoded = '';

      // 🔧 Fix: clear all multi-image lists
      _multipleImages.clear();
      base64ImageList.clear();
      _multipleImageFiles.clear();

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

    on<SelectCountryEvent>((event, emit) {
      _formState = _formState.copyWith(
        country: event.countryId,
        countryName: event.countryName,
      );
      emit(_formState);
    });

    on<PickImageFromGalleryEvent>((event, emit) async {
      emit(SignUpImageLoadingState());
      try {
        //  Handle Android permission
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

        //  Pick image from gallery
        final pickedImage = await _picker.pickImage(
          source: ImageSource.gallery,
          imageQuality: 80,
        );

        if (pickedImage == null) {
          emit(_formState);
          return;
        }

        //  Validate file type
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

        // Compress
        Uint8List? compressedBytes = await _compressImage(pickedImage);
        if (compressedBytes == null || compressedBytes.isEmpty) {
          emit(SignUpImageErrorState(errorMessage: "Failed to process image."));
          emit(_formState);
          return;
        }

        // Save compressed bytes as a temp File
        final tempDir = await getTemporaryDirectory();
        final compressedFile = File(
          '${tempDir.path}/compressed_${DateTime.now().millisecondsSinceEpoch}.jpg',
        );
        await compressedFile.writeAsBytes(compressedBytes);

        _formState = _formState.copyWith(image: XFile(compressedFile.path));
        emit(_formState);
      } catch (e) {
        emit(SignUpImageErrorState(errorMessage: "Failed to pick image: $e"));
        emit(_formState);
      }
    });

    ///New Functionality for picking image from gallery
    /* on<PickImageFromGalleryEvent>((event, emit) async {
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
    });*/

    // on<PickMultipleImagesFromGalleryEvent>((event, emit) async {
    //   emit(SignUpImageLoadingState());
    //   try {
    //     // Check permission
    //     if (Platform.isAndroid) {
    //       Permission permission;
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
    //         return;
    //       }
    //     }

    //     final currentCount = _multipleImages.length;
    //     final remainingSlots = 4 - currentCount;

    //     if (remainingSlots <= 0) {
    //       emit(
    //         SignUpImageErrorState(
    //           errorMessage: "You can upload a maximum of 4 images total.",
    //         ),
    //       );
    //       emit(
    //         _formState,
    //       ); // <--- Add this to reset from the loading state and display current images
    //       return;
    //     }

    //     // FIX: Pick images, enforcing the maximum limit right here
    //     final pickedImages = await _picker.pickMultiImage(
    //       imageQuality: 80,
    //       limit: remainingSlots, // <-- Add the limit parameter!
    //     );

    //     if (pickedImages.isEmpty) {
    //       emit(_formState);
    //       return;
    //     }

    //     // Process only the allowed number of images
    //     List<XFile> processedImages = [];

    //     for (final pickedImage in pickedImages.take(remainingSlots)) {
    //       // Validate file type
    //       final ext = pickedImage.name.toLowerCase();
    //       if (!(ext.endsWith('.png') ||
    //           ext.endsWith('.jpeg') ||
    //           ext.endsWith('.jpg'))) {
    //         emit(
    //           SignUpImageErrorState(
    //             errorMessage: "Only JPEG or PNG images are allowed.",
    //           ),
    //         );
    //         return;
    //       }

    //       // Compress image
    //       final compressedBytes = await FlutterImageCompress.compressWithList(
    //         await pickedImage.readAsBytes(),
    //         minHeight: 1920,
    //         minWidth: 1080,
    //         quality: 85,
    //       );

    //       if (compressedBytes.isEmpty) {
    //         continue; // Skip this image if compression fails
    //       }

    //       // Save compressed file
    //       final tempDir = await getTemporaryDirectory();
    //       final file = File(
    //         '${tempDir.path}/multi_${DateTime.now().millisecondsSinceEpoch}_${processedImages.length}.jpg',
    //       );
    //       await file.writeAsBytes(compressedBytes);

    //       // Add as XFile
    //       processedImages.add(XFile(file.path));
    //     }

    //     // Update state with new images
    //     _multipleImages = [..._multipleImages, ...processedImages];
    //     _formState = _formState.copyWith(multipleImages: _multipleImages);
    //     emit(_formState);
    //   } catch (e) {
    //     emit(SignUpImageErrorState(errorMessage: "Failed to pick images: $e"));
    //   }
    // });

    on<PickMultipleImagesFromGalleryEvent>((event, emit) async {
      emit(SignUpImageLoadingState());
      try {
        // Check permission
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
            emit(_formState); // Return to current state
            return;
          }
        }

        final currentCount = _multipleImages.length;
        final remainingSlots = 4 - currentCount;

        if (remainingSlots <= 0) {
          emit(
            SignUpImageErrorState(
              errorMessage: "You can upload a maximum of 4 images total.",
            ),
          );
          emit(_formState); // Return to current state
          return;
        }

        // FIX: pickMultiImage's limit parameter must be >= 2
        // If only 1 slot remains, use pickImage instead
        List<XFile> pickedImages;

        if (remainingSlots == 1) {
          // Use single image picker when only 1 slot remains
          final singleImage = await _picker.pickImage(
            source: ImageSource.gallery,
            imageQuality: 80,
          );

          if (singleImage == null) {
            emit(_formState);
            return;
          }

          pickedImages = [singleImage];
        } else {
          // Use multiple image picker when 2 or more slots remain
          pickedImages = await _picker.pickMultiImage(
            imageQuality: 80,
            limit: remainingSlots,
          );

          if (pickedImages.isEmpty) {
            emit(_formState);
            return;
          }
        }

        // Process the picked images
        List<XFile> processedImages = [];

        for (final pickedImage in pickedImages.take(remainingSlots)) {
          // Validate file type
          final ext = pickedImage.name.toLowerCase();
          if (!(ext.endsWith('.png') ||
              ext.endsWith('.jpeg') ||
              ext.endsWith('.jpg'))) {
            emit(
              SignUpImageErrorState(
                errorMessage: "Only JPEG or PNG images are allowed.",
              ),
            );
            emit(_formState); // Return to current state
            return;
          }

          // Compress image
          final compressedBytes = await FlutterImageCompress.compressWithList(
            await pickedImage.readAsBytes(),
            minHeight: 1920,
            minWidth: 1080,
            quality: 85,
          );

          if (compressedBytes.isEmpty) {
            continue; // Skip this image if compression fails
          }

          // Save compressed file
          final tempDir = await getTemporaryDirectory();
          final file = File(
            '${tempDir.path}/multi_${DateTime.now().millisecondsSinceEpoch}_${processedImages.length}.jpg',
          );
          await file.writeAsBytes(compressedBytes);

          // Add as XFile
          processedImages.add(XFile(file.path));
        }

        // Update state with new images
        _multipleImages = [..._multipleImages, ...processedImages];
        _formState = _formState.copyWith(multipleImages: _multipleImages);
        emit(_formState);
      } catch (e) {
        debugPrint('Error picking images: $e');
        emit(SignUpImageErrorState(errorMessage: "Failed to pick images: $e"));
        emit(_formState); // Return to current state after error
      }
    });

    on<ClearAllImagesEvent>((event, emit) async {
      emit(SignUpImageLoadingState());
      _multipleImages.clear();
      base64ImageList.clear();
      _formState = _formState.copyWith(
        multipleImages: [],
        multipleBase64Images: [],
      );
      emit(_formState);
    });

    on<ClearSingleProfileImageEvent>((event, emit) async {
      emit(SignUpImageLoadingState());
      try {
        _image = null;
        base64String = '';
        base64Encoded = '';
        _formState = _formState.copyWith(clearImage: true, base64Image: '');
        ObjectFactory().prefs.clearImageData();
        emit(_formState);
      } catch (e) {
        debugPrint('Error clearing profile image: $e');
        emit(SignUpImageErrorState(errorMessage: "Failed to clear image: $e"));
        emit(_formState);
      }
    });

    // on<RemoveSingleImageEvent>((event, emit) async {
    //   emit(SignUpImageLoadingState());
    //   if (event.index < _multipleImages.length) {
    //     _multipleImages.removeAt(event.index);
    //     _formState = _formState.copyWith(multipleImages: _multipleImages);
    //   }
    //   emit(_formState);
    // });

    on<RemoveMultipleImageEvent>((event, emit) async {
      emit(SignUpImageLoadingState());

      try {
        // Validate index
        if (event.index < 0 || event.index >= _multipleImages.length) {
          debugPrint(
            'Invalid remove index: ${event.index} for length: ${_multipleImages.length}',
          );
          emit(_formState);
          return;
        }

        // Create a new list without the removed image
        final updatedImages = List<XFile>.from(_multipleImages);
        updatedImages.removeAt(event.index);

        // Update the instance variable and state
        _multipleImages = updatedImages;
        _formState = _formState.copyWith(multipleImages: _multipleImages);

        emit(_formState);
      } catch (e) {
        debugPrint('Error removing image: $e');
        emit(SignUpImageErrorState(errorMessage: "Failed to remove image: $e"));
      }
    });

    on<TakeMultiplePicturesEvent>((event, emit) async {
      emit(SignUpImageLoadingState());
      try {
        // Check camera permission
        if (Platform.isAndroid) {
          final permissionStatus = await Permission.camera.request();
          if (!permissionStatus.isGranted) {
            emit(
              SignUpImageErrorState(errorMessage: "Camera permission denied."),
            );
            return;
          }
        }

        // Check if limit is reached
        if (_multipleImages.length >= 4) {
          emit(
            SignUpImageErrorState(
              errorMessage: "You can upload a maximum of 4 images.",
            ),
          );
          return;
        }

        // Capture image
        final XFile? capturedImage = await _picker.pickImage(
          source: ImageSource.camera,
          imageQuality: 80,
        );

        if (capturedImage == null) {
          emit(_formState);
          return;
        }

        // Validate extension
        final ext = capturedImage.name.toLowerCase();
        if (!(ext.endsWith('.png') ||
            ext.endsWith('.jpeg') ||
            ext.endsWith('.jpg'))) {
          emit(
            SignUpImageErrorState(
              errorMessage: "Only JPEG or PNG images are allowed.",
            ),
          );
          return;
        }

        // Compress
        final compressedBytes = await FlutterImageCompress.compressWithList(
          await capturedImage.readAsBytes(),
          minHeight: 1920,
          minWidth: 1080,
          quality: 85,
        );

        if (compressedBytes.isEmpty) {
          emit(
            SignUpImageErrorState(errorMessage: "Failed to compress image."),
          );
          return;
        }

        // Save compressed file
        final tempDir = await getTemporaryDirectory();
        final file = File(
          '${tempDir.path}/camera_multi_${DateTime.now().millisecondsSinceEpoch}.jpg',
        );
        await file.writeAsBytes(compressedBytes);

        // Add to list
        _multipleImages = [..._multipleImages, XFile(file.path)];
        _formState = _formState.copyWith(multipleImages: _multipleImages);

        emit(_formState);
      } catch (e) {
        emit(
          SignUpImageErrorState(errorMessage: "Failed to capture image: $e"),
        );
      }
    });

    // on<TakeMultiplePicturesEvent>((event, emit) async {
    //   emit(SignUpImageLoadingState());
    //   try {
    //     //  Camera permission
    //     if (Platform.isAndroid) {
    //       final permissionStatus = await Permission.camera.request();
    //       if (!permissionStatus.isGranted) {
    //         emit(
    //           SignUpImageErrorState(errorMessage: "Camera permission denied."),
    //         );
    //         emit(_formState);
    //         return;
    //       }
    //     }

    //     //  Capture image from camera
    //     final XFile? capturedImage = await _picker.pickImage(
    //       source: ImageSource.camera,
    //       imageQuality: 80,
    //     );

    //     if (capturedImage == null) {
    //       emit(_formState); // user cancelled
    //       return;
    //     }

    //     //  Validate extension
    //     final ext = capturedImage.name.toLowerCase();
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

    //     //  Compress the image
    //     final compressedBytes = await FlutterImageCompress.compressWithList(
    //       await capturedImage.readAsBytes(),
    //       minHeight: 1920,
    //       minWidth: 1080,
    //       quality: 85,
    //     );

    //     if (compressedBytes.isEmpty) {
    //       emit(
    //         SignUpImageErrorState(errorMessage: "Failed to compress image."),
    //       );
    //       emit(_formState);
    //       return;
    //     }

    //     // Save compressed file to temp directory
    //     final tempDir = await getTemporaryDirectory();
    //     final file = File(
    //       '${tempDir.path}/camera_multi_${DateTime.now().millisecondsSinceEpoch}.jpg',
    //     );
    //     await file.writeAsBytes(compressedBytes);

    //     // ✅ Convert File → XFile
    //     final newXFile = XFile(file.path);

    //     // ✅ Add to existing image list safely
    //     final updatedList = [...?_formState.multipleImages, newXFile];

    //     // ✅ Update form state
    //     _formState = _formState.copyWith(multipleImages: updatedList);
    //     emit(_formState);
    //   } catch (e) {
    //     emit(
    //       SignUpImageErrorState(errorMessage: "Failed to capture image: $e"),
    //     );
    //     emit(_formState);
    //   }
    // });

    // on<TakeMultiplePicturesEvent>((event, emit) async {
    //   emit(SignUpImageLoadingState());
    //   try {
    //     if (Platform.isAndroid) {
    //       Permission permission = await isAndroid13OrHigher()
    //           ? Permission.camera
    //           : Permission.storage;
    //       final permissionStatus = await permission.request();
    //       if (!permissionStatus.isGranted) {
    //         emit(SignUpImageErrorState(errorMessage: "Camera permission denied."));
    //         emit(_formState);
    //         return;
    //       }
    //     }

    //     // Capture an image from camera
    //     final XFile? capturedImage = await _picker.pickImage(
    //       source: ImageSource.camera,
    //       imageQuality: 80,
    //     );

    //     if (capturedImage == null) {
    //       emit(_formState); // user cancelled
    //       return;
    //     }

    //     // Validate extension
    //     final ext = capturedImage.name.toLowerCase();
    //     if (!(ext.endsWith('.png') || ext.endsWith('.jpeg') || ext.endsWith('.jpg'))) {
    //       emit(SignUpImageErrorState(errorMessage: "Only JPEG or PNG images are allowed."));
    //       emit(_formState);
    //       return;
    //     }

    //     // Compress image
    //     final compressedBytes = await FlutterImageCompress.compressWithList(
    //       await capturedImage.readAsBytes(),
    //       minHeight: 1920,
    //       minWidth: 1080,
    //       quality: 85,
    //     );

    //     if (compressedBytes.isEmpty) {
    //       emit(SignUpImageErrorState(errorMessage: "Failed to compress image."));
    //       emit(_formState);
    //       return;
    //     }

    //     // Convert to base64
    //     final base64String = base64.encode(compressedBytes);
    //     base64ImageList.add("data:image/jpeg;base64,$base64String");
    //     _multipleImages.add(capturedImage);

    //     // ✅ Update form state with appended images
    //     _formState = _formState.copyWith(
    //       multipleImages: _multipleImages,
    //       multipleBase64Images: base64ImageList,
    //     );
    //     emit(_formState);
    //   } catch (e) {
    //     emit(SignUpImageErrorState(errorMessage: "Failed to capture image: $e"));
    //     emit(_formState);
    //   }
    // });

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
        final Object? error = result.error;

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
        return;
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
        final Object? error = result.error;

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
        return;
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
        final Object? error = result.error;

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
        return;
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
    on<LoadCountries>(_onFetchCountries);
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

  Future<void> _onFetchCountries(
    LoadCountries event,
    Emitter<SignUpState> emit,
  ) async {
    try {
      emit(_formState.copyWith(isLoadingCountries: true, countryError: null));

      final StateModel? response = await authDataProvider.getCountryList();

      if (response is SuccessState<CountryResponse>) {
        final countryResponse = response.data;
        final List<Country> countryList = countryResponse!.data ?? [];

        _formState = _formState.copyWith(
          countries: countryList,
          isLoadingCountries: false,
          countryError: null,
        );
        emit(_formState);
      } else if (response is ErrorState) {
        _formState = _formState.copyWith(
          isLoadingCountries: false,
          countryError: response.msg,
        );
        emit(_formState);
      } else {
        _formState = _formState.copyWith(
          isLoadingCountries: false,
          countryError: "Unexpected response type",
        );
        emit(_formState);
      }
    } catch (e) {
      _formState = _formState.copyWith(
        isLoadingCountries: false,
        countryError: e.toString(),
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
