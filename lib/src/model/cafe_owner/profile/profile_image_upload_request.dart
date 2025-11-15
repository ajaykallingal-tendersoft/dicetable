import 'dart:io';
import 'package:dio/dio.dart';

class CafePhotoUploadRequest {
  // 'image' is the required field name for the single file.
  final File image;

  CafePhotoUploadRequest({
    required this.image,
  });

  // Converts the File object into Dio's FormData for the API call.
  Future<FormData> toFormData() async {
    // Create a single MultipartFile for the 'image' field.
    final multipartFile = await MultipartFile.fromFile(
      image.path,
      filename: image.path.split('/').last,
    );

    return FormData.fromMap({
      'image': multipartFile,
    });
  }
}