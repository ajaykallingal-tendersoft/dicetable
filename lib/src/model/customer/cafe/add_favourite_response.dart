class AddToFavouritesResponse {
  final bool status;
  final String message;
  final Map<String, List<String>>? errors;

  AddToFavouritesResponse({
    required this.status,
    required this.message,
    this.errors,
  });

  factory AddToFavouritesResponse.fromJson(Map<String, dynamic> json) {
    return AddToFavouritesResponse(
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
