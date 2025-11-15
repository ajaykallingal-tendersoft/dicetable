// No external imports needed for this parameter-only request model

class DeleteGalleryImageRequest {
  // The unique identifier of the gallery image to be deleted.
  final int galleryId;

  DeleteGalleryImageRequest({
    required this.galleryId,
  });

  // A helper method to get the query parameters map for Dio.
  // This map will be passed to Dio's options or request method.
  Map<String, dynamic> toQueryParams() {
    return {
      'gallery_id': galleryId,
    };
  }
}