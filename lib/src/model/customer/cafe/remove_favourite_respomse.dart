class RemoveFavouritesResponse {
  final bool status;
  final String message;
  final Map<String, List<String>>? errors;

  RemoveFavouritesResponse({
    required this.status,
    required this.message,
    this.errors,
  });

  factory RemoveFavouritesResponse.fromJson(Map<String, dynamic> json) {
    return RemoveFavouritesResponse(
      status: json['status'] ?? false,
      message: json['message'] ?? '',
      errors: json['errors'] != null
          ? Map<String, List<String>>.from(json['errors'].map(
              (key, value) => MapEntry(key, List<String>.from(value))))
          : null,
    );
  }

  bool get hasValidationErrors => errors != null && errors!.isNotEmpty;

  String get toastMessage {
    if (status) return message;
    if (hasValidationErrors) {
      // Show first validation error message
      return errors!.values.first.first;
    }
    return message; // fallback
  }
}
