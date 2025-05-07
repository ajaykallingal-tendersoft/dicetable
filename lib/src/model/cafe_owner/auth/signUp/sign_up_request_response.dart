class SignUpRequestResponse {
  final bool status;
  final String? message;
  final Map<String, List<String>>? errors;

  SignUpRequestResponse({
    required this.status,
    this.message,
    this.errors,
  });

  factory SignUpRequestResponse.fromJson(Map<String, dynamic> json) {
    return SignUpRequestResponse(
      status: json['status'] ?? false,
      message: json['message'], // message can be null
      errors: json['errors'] != null
          ? (json['errors'] as Map<String, dynamic>?)?.map(
            (key, value) => MapEntry(key, List<String>.from(value)),
      )
          : null,
    );
  }
}
