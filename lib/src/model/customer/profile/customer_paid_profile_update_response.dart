class PaidProfileUpdateResponse {
  final bool status;
  final String? message;
  final Map<String, List<String>>? errors;

  PaidProfileUpdateResponse({
    required this.status,
    this.message,
    this.errors,
  });

  factory PaidProfileUpdateResponse.fromJson(Map<String, dynamic> json) {
    // The errors field might be null
    Map<String, List<String>>? parsedErrors;
    if (json['errors'] != null) {
      parsedErrors = (json['errors'] as Map<String, dynamic>).map(
        (key, value) => MapEntry(
          key,
          (value as List<dynamic>).map((e) => e.toString()).toList(),
        ),
      );
    }

    return PaidProfileUpdateResponse(
      status: json['status'] ?? false,
      message: json['message'],
      errors: parsedErrors,
    );
  }
}
