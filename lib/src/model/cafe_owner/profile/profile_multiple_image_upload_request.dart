import 'dart:io';
import 'package:dio/dio.dart';

class CafeGalleryUploadRequest {
  // 'gallery' is the required field name for the array of files.
  final List<File> gallery;

  CafeGalleryUploadRequest({
    required this.gallery,
  });

  // Method to convert the request model into Dio's FormData object
  Future<FormData> toFormData() async {
    List<MultipartFile> files = [];

    for (var file in gallery) {
      // Create a MultipartFile for each file in the list.
      // The field name must be the same as the parameter name: 'gallery'
      files.add(
        await MultipartFile.fromFile(
          file.path,
          filename: file.path.split('/').last,
          // You might need to specify the correct media type (e.g., contentType: MediaType('image', 'jpeg'))
        ),
      );
    }

    return FormData.fromMap({
      // Dio handles sending the list of MultipartFiles under the 'gallery' key correctly
      'gallery[]': files,
    });
  }
}