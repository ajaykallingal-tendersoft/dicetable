class GuestSignInResponse {
  final bool status;
  final int? guestUserId;
  final String? deviceToken;
  final String? message;
  final Map<String, List<String>>? errors;

  GuestSignInResponse({
    required this.status,
    this.guestUserId,
    this.deviceToken,
    this.message,
    this.errors,
  });

  factory GuestSignInResponse.fromJson(Map<String, dynamic> json) {
    return GuestSignInResponse(
      status: json['status'],
      guestUserId: json['guest_user_id'],
      deviceToken: json['device_token'],
      message: json['message'],
      errors: json['errors'] != null
          ? Map<String, List<String>>.from(json['errors'].map(
              (key, value) => MapEntry(key, List<String>.from(value))))
          : null,
    );
  }
}
