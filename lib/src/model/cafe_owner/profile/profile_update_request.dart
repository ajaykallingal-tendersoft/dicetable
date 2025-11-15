import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:path/path.dart';

class ProfileUpdateRequest {
  final String name;
  final String venueDescription;
  final String email;
  final String? password;
  final String phone;
  final String? country;
  final String address;
  final String postcode;
  final List<String> accommodations;
  final Map<String, dynamic> workingDays;
  final MultipartFile? image; // optional

  ProfileUpdateRequest({
    required this.name,
    required this.venueDescription,
    required this.email,
    this.password,
    required this.phone,
    this.country,
    required this.address,
    required this.postcode,
    required this.accommodations,
    required this.workingDays,
    this.image,
  });

  /// ✅ Converts to proper Multipart FormData for Dio
  FormData toFormData() {
    final formData = FormData();

    // 🔹 Basic text fields
    formData.fields.addAll([
      MapEntry('name', name),
      MapEntry('venue_description', venueDescription),
      MapEntry('email', email),
      MapEntry('phone', phone),
      MapEntry('country', country ?? ''),
      MapEntry('address', address),
      MapEntry('postcode', postcode),
    ]);

    // 🔹 accommodations[] format expected by backend
    for (var acc in accommodations) {
      formData.fields.add(MapEntry('accommodations[]', acc));
    }

    formData.fields.add(MapEntry('working_days', jsonEncode(workingDays)));

    // 🔹 Optional password
    if (password != null && password!.isNotEmpty) {
      formData.fields.add(MapEntry('password', password!));
    }

    // 🔹 Optional image file
    if (image != null) {
      formData.files.add(MapEntry('image', image!));
    }

    return formData;
  }

  /// For debugging/logging
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'venue_description': venueDescription,
      'email': email,
      'phone': phone,
      'country': country,
      'address': address,
      'postcode': postcode,
      'accommodations': accommodations,
      'working_days': workingDays
    };
  }
}

class WorkingDay {
  final int? id;
  final String day;
  final bool isOpen;
  final String open;
  final String close;

  WorkingDay({
    this.id,
    required this.day,
    required this.isOpen,
    required this.open,
    required this.close,
  });

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{
      'day': day,
      'is_open': isOpen,
      'open': open,
      'close': close,
    };
    if (id != null) data['id'] = id;
    return data;
  }
}
