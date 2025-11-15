class CafePhotoUploadResponse {
  // Success fields (HTTP 200)
  final bool? success;
  final int? imageId;
  final String? path;
  
  // General Message (Used for 200/401)
  final String? message; 

  // Validation Error fields (HTTP 422)
  final bool? status; // status: false
  // errors map is used for 422 validation, where the key is 'image'.
  final Map<String, dynamic>? errors; 

  CafePhotoUploadResponse({
    this.success,
    this.imageId,
    this.path,
    this.message,
    this.status,
    this.errors,
  });

  factory CafePhotoUploadResponse.fromJson(Map<String, dynamic> json) {
    return CafePhotoUploadResponse(
      success: json['success'] as bool?,
      message: json['message'] as String?,
      status: json['status'] as bool?,
      
      // Parse image_id safely
      imageId: json['image_id'] is int 
          ? json['image_id'] 
          : (json['image_id'] is String ? int.tryParse(json['image_id']) : null),
          
      path: json['path'] as String?,

      // Safely parse the errors map
      errors: json['errors'] is Map ? Map<String, dynamic>.from(json['errors']) : null,
    );
  }
}