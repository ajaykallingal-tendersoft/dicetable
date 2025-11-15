// cafe_gallery_delete_response.dart

import 'dart:convert';

CafeGalleryDeleteResponse cafeGalleryDeleteResponseFromJson(String str) =>
    CafeGalleryDeleteResponse.fromJson(json.decode(str));

String cafeGalleryDeleteResponseToJson(CafeGalleryDeleteResponse data) =>
    json.encode(data.toJson());

class CafeGalleryDeleteResponse {
  final bool? status;
  final String? message;
  final Map<String, dynamic>? errors;
  final DeletedPhotoData? data;

  CafeGalleryDeleteResponse({
    this.status,
    this.message,
    this.errors,
    this.data,
  });

  factory CafeGalleryDeleteResponse.fromJson(Map<String, dynamic> json) =>
      CafeGalleryDeleteResponse(
        status: json["status"],
        message: json["message"],
        errors: json["errors"] != null
            ? Map<String, dynamic>.from(json["errors"])
            : null,
        data: json["data"] != null
            ? DeletedPhotoData.fromJson(json["data"])
            : null,
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        if (errors != null) "errors": errors,
        if (data != null) "data": data?.toJson(),
      };
}

class DeletedPhotoData {
  final String? photoId;
  final String? deletedAt;

  DeletedPhotoData({
    this.photoId,
    this.deletedAt,
  });

  factory DeletedPhotoData.fromJson(Map<String, dynamic> json) =>
      DeletedPhotoData(
        photoId: json["photo_id"],
        deletedAt: json["deleted_at"],
      );

  Map<String, dynamic> toJson() => {
        "photo_id": photoId,
        "deleted_at": deletedAt,
      };
}