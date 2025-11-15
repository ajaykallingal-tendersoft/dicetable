// class AppleSignUpRequest {
//   final String? name;
//   final String? venueDescription;
//   final String? email;
//   final String? phone;
//   final int? loginType;
//   final String? country;
//   final String? region;
//   final String? address;
//   final String? postcode;
//   final List<String>? accommodations;
//   final Map<String, Map<String, dynamic>>? workingDays;
//   final String? blob;
//   final String? fcmToken;
//   final String? apple_id;

//   AppleSignUpRequest({
//     this.name,
//     this.venueDescription,
//     this.email,
//     this.phone,
//     this.loginType,
//     this.country,
//     this.region,
//     this.address,
//     this.postcode,
//     this.accommodations,
//     this.workingDays,
//     this.blob,
//     this.fcmToken,
//     this.apple_id,
//   });

//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> json = {};
//     if (name != null) {
//       json['name'] = name;
//     }
//     if (venueDescription != null) {
//       json['venue_description'] = venueDescription;
//     }
//     if (email != null) {
//       json['email'] = email;
//     }
//     if (phone != null) {
//       json['phone'] = phone;
//     }
//     if (loginType != null) {
//       json['login_type'] = loginType;
//     }
//     if (country != null) {
//       json['country'] = country;
//     }
//     if (region != null) {
//       json['region'] = region;
//     }
//     if (address != null) {
//       json['address'] = address;
//     }
//     if (postcode != null) {
//       json['postcode'] = postcode;
//     }
//     if (accommodations != null) {
//       json['accommodations'] = accommodations;
//     }
//     if (workingDays != null) {
//       json['working_days'] = workingDays;
//     }
//     if (blob != null) {
//       json['blob'] = blob;
//     }
//     if (fcmToken != null) {
//       json['fcm_token'] = fcmToken;
//     }
//      if (apple_id != null) {
//       json['apple_id'] = apple_id;
//     }

//     return json;
//   }
// }

// class WorkingDay {
//   final bool? isOpen;
//   final String? open;
//   final String? close;

//   WorkingDay({this.isOpen, this.open, this.close});

//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> map = {};
//     if (isOpen != null) {
//       map['is_open'] = isOpen;
//       if (isOpen == true) {
//         // only add open/close if isOpen is true
//         map['open'] = open;
//         map['close'] = close;
//       }
//     }

//     return map;
//   }
// }


import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
class AppleSignUpRequest {
  final String? name;
  final String? venueDescription;
  final String? email;
  final String? phone;
  final int? loginType;
  final String? country;
  final String? region;
  final String? address;
  final String? postcode;
  final List<String>? accommodations;
  final Map<String, Map<String, dynamic>>? workingDays;
  final String? blob;
  final String? fcmToken;
  final String? apple_id;
  final File? image;
  final List<File>? multipleImages;

  AppleSignUpRequest({
    this.name,
    this.venueDescription,
    this.email,
    this.phone,
    this.loginType,
    this.country,
    this.region,
    this.address,
    this.postcode,
    this.accommodations,
    this.workingDays,
    this.blob,
    this.fcmToken,
    this.apple_id,
    this.image,
    this.multipleImages,
  });

  /// ✅ Build multipart form for Dio
  FormData toFormData() {
    final formData = FormData();

    if (name != null) formData.fields.add(MapEntry('name', name!));
    if (venueDescription != null) formData.fields.add(MapEntry('venue_description', venueDescription!));
    if (email != null) formData.fields.add(MapEntry('email', email!));
    if (phone != null) formData.fields.add(MapEntry('phone', phone!));
    if (loginType != null) formData.fields.add(MapEntry('login_type', loginType.toString()));
    if (country != null) formData.fields.add(MapEntry('country', country!));
    if (region != null) formData.fields.add(MapEntry('region', region!));
    if (address != null) formData.fields.add(MapEntry('address', address!));
    if (postcode != null) formData.fields.add(MapEntry('postcode', postcode!));
    if (fcmToken != null) formData.fields.add(MapEntry('fcm_token', fcmToken!));
    if (blob != null) formData.fields.add(MapEntry('blob', blob!));
    if (apple_id != null) formData.fields.add(MapEntry('apple_id', apple_id!));

    // ✅ accommodations
    if (accommodations != null && accommodations!.isNotEmpty) {
      formData.fields.add(
        MapEntry('accommodations', jsonEncode(accommodations)),
      );
    }


    // ✅ working days JSON
    if (workingDays != null && workingDays!.isNotEmpty) {
      formData.fields.add(MapEntry('working_days', jsonEncode(workingDays)));
    }

    // ✅ Single image (avatar)
    if (image != null) {
      formData.files.add(MapEntry(
        'avatar',
        MultipartFile.fromFileSync(image!.path, filename: 'avatar.jpg'),
      ));
    }

    // ✅ Multiple gallery images
    if (multipleImages != null && multipleImages!.isNotEmpty) {
      for (int i = 0; i < multipleImages!.length; i++) {
        formData.files.add(MapEntry(
          'gallery[]',
          MultipartFile.fromFileSync(multipleImages![i].path, filename: 'gallery_$i.jpg'),
        ));
      }
    }

    return formData;
  }
}
