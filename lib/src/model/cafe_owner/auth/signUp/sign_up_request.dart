import 'dart:io';
import 'package:dio/dio.dart';
import 'dart:convert';

class SignUpRequest {
  final String? name;
  final String? venueDescription;
  final String? email;
  final String? password;
  final String? passwordConfirmation;
  final String? phone;
  final int? loginType;
  final String? country; // country ID as String
  final String? region;
  final String? address;
  final String? postcode;
  final List<String>? accommodations;
  final Map<String, Map<String, dynamic>>? workingDays;
  final File? image;
  final List<File>? multipleImages;
  final String? fcmToken;

  SignUpRequest({
    this.name,
    this.venueDescription,
    this.email,
    this.password,
    this.passwordConfirmation,
    this.phone,
    this.loginType,
    this.country,
    this.region,
    this.address,
    this.postcode,
    this.accommodations,
    this.workingDays,
    this.image,
    this.multipleImages,
    this.fcmToken,
  });

  /// ✅ Build multipart form for Dio
  FormData toFormData() {
    final formData = FormData();

    if (name != null) formData.fields.add(MapEntry('name', name!));
    if (venueDescription != null)
      formData.fields.add(MapEntry('venue_description', venueDescription!));
    if (email != null) formData.fields.add(MapEntry('email', email!));
    if (password != null) formData.fields.add(MapEntry('password', password!));
    if (passwordConfirmation != null)
      formData.fields.add(
        MapEntry('password_confirmation', passwordConfirmation!),
      );
    if (phone != null) formData.fields.add(MapEntry('phone', phone!));
    if (loginType != null)
      formData.fields.add(MapEntry('login_type', loginType.toString()));
    if (country != null)
      formData.fields.add(MapEntry('country', country!)); // ✅ match Postman key
    if (region != null) formData.fields.add(MapEntry('region', region!));
    if (address != null) formData.fields.add(MapEntry('address', address!));
    if (postcode != null) formData.fields.add(MapEntry('postcode', postcode!));
    if (fcmToken != null) formData.fields.add(MapEntry('fcm_token', fcmToken!));

    // ✅ accommodations as comma-separated (like Postman)
    if (accommodations != null && accommodations!.isNotEmpty) {
      formData.fields.add(
        MapEntry('accommodations', jsonEncode(accommodations)),
      );
    }

    // ✅ Send workingDays as JSON string, not nested fields
    if (workingDays != null && workingDays!.isNotEmpty) {
      formData.fields.add(MapEntry('working_days', jsonEncode(workingDays)));
    }

    // ✅ Main image (avatar)
    if (image != null) {
      formData.files.add(
        MapEntry(
          'avatar', // ✅ match Postman key
          MultipartFile.fromFileSync(image!.path, filename: 'main_image.jpg'),
        ),
      );
    }

    // ✅ Multiple gallery images
    if (multipleImages != null && multipleImages!.isNotEmpty) {
      for (int i = 0; i < multipleImages!.length; i++) {
        formData.files.add(
          MapEntry(
            'gallery[]', // ✅ match Postman key
            MultipartFile.fromFileSync(
              multipleImages![i].path,
              filename: 'gallery_$i.jpg',
            ),
          ),
        );
      }
    }

    return formData;
  }
}
