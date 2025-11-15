class CafeGalleryUploadResponse {
  // Success fields (200)
  final bool? success;
  final List<String>? imageUploadsId; // The list of uploaded IDs
  final String? message; // Message for 200/401

  // Error fields (422)
  final bool? status; // status: false from 422
  // errors map is used for 422 validation, where keys are "gallery.0", etc.
  final Map<String, dynamic>? errors; 

  CafeGalleryUploadResponse({
    this.success,
    this.imageUploadsId,
    this.message,
    this.status,
    this.errors,
  });

  factory CafeGalleryUploadResponse.fromJson(Map<String, dynamic> json) {
    // Helper function to safely cast List<dynamic> to List<String>
    List<String>? parseImageIds(dynamic data) {
      if (data is List) {
        return List<String>.from(data.map((e) => e.toString()));
      }
      return null;
    }

    return CafeGalleryUploadResponse(
      success: json['success'] as bool?,
      message: json['message'] as String?,
      status: json['status'] as bool?,

      // Safely parse the list of IDs from the 200 response
      imageUploadsId: parseImageIds(json['image_uploads_id']),

      // Safely parse the errors map from the 422 response
      errors: json['errors'] is Map ? Map<String, dynamic>.from(json['errors']) : null,
    );
  }
}