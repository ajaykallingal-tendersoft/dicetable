import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';

class PaidProfileUpdateRequest {
  final String? aboutMe;
  final String? businessDetails;
  final String? interestsHobbies;

  /// MUST contain IDs, not names
  final List<int>? myPreferences;              // FIXED TYPE
  final List<int>? venueNotifications;         // FIXED TYPE

  final List<XFile>? businessImages;
  final List<XFile>? hobbyImages;
  final XFile? image;

  PaidProfileUpdateRequest({
    this.aboutMe,
    this.businessDetails,
    this.interestsHobbies,
    this.myPreferences,
    this.venueNotifications,
    this.businessImages,
    this.hobbyImages,
    this.image,
  });

  /// Convert form data for API submission
  Future<FormData> toFormData() async {
    final Map<String, dynamic> formDataMap = {};

    // ---- TEXT FIELDS ----
    if (aboutMe != null && aboutMe!.isNotEmpty) {
      formDataMap['about_me'] = aboutMe;
    }
    if (businessDetails != null && businessDetails!.isNotEmpty) {
      formDataMap['business_details'] = businessDetails;
    }
    if (interestsHobbies != null && interestsHobbies!.isNotEmpty) {
      formDataMap['interests_hobbies'] = interestsHobbies;
    }

    // ---- PREFERENCES MUST BE JSON STRING ----
    if (myPreferences != null) {
      formDataMap['my_preferences'] = jsonEncode(myPreferences);
    }

    // ---- VENUE NOTIFICATIONS MUST BE JSON STRING ----
    if (venueNotifications != null) {
      formDataMap['favorite_venues'] = jsonEncode(venueNotifications);
    }

    // ---- PROFILE IMAGE ----
    if (image != null) {
      formDataMap['photo'] = await MultipartFile.fromFile(
        image!.path,
        filename: image!.name,
      );
    }

    // ---- BUSINESS IMAGES ----
    if (businessImages != null && businessImages!.isNotEmpty) {
      formDataMap['business_details_images[]'] = await Future.wait(
        businessImages!.map((file) async {
          return await MultipartFile.fromFile(
            file.path,
            filename: file.name,
          );
        }),
      );
    }

    // ---- HOBBY IMAGES ----
    if (hobbyImages != null && hobbyImages!.isNotEmpty) {
      formDataMap['interests_hobbies_images[]'] = await Future.wait(
        hobbyImages!.map((file) async {
          return await MultipartFile.fromFile(
            file.path,
            filename: file.name,
          );
        }),
      );
    }

    return FormData.fromMap(formDataMap);
  }

  Map<String, dynamic> toJson() {
    return {
      'about_me': aboutMe,
      'business_details': businessDetails,
      'interests_hobbies': interestsHobbies,
      'my_preferences': myPreferences,
      'favorite_venues': venueNotifications,
      'business_images_count': businessImages?.length ?? 0,
      'hobby_images_count': hobbyImages?.length ?? 0,
      'has_profile_image': image != null,
    };
  }
}
