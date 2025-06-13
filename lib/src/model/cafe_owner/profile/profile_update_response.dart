class ProfileUpdateResponse {
  final bool status;
  final String? message;
  final Map<String, List<String>>? errors;
  final Map<String, dynamic>? data;

  ProfileUpdateResponse({
    required this.status,
    this.message,
    this.errors,
    this.data,
  });

  factory ProfileUpdateResponse.fromJson(Map<String, dynamic> json) {
    return ProfileUpdateResponse(
      status: json['status'] ?? false,
      message: json['message'],
      errors: json['errors'] != null
          ? Map<String, List<String>>.from(json['errors'].map(
              (key, value) => MapEntry(key, List<String>.from(value))))
          : null,
      data: json['data'] != null ? Map<String, dynamic>.from(json['data']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      if (message != null) 'message': message,
      if (errors != null) 'errors': errors,
      if (data != null) 'data': data,
    };
  }
}
