class GoogleSignUpRequestResponse {
  final bool status;
  final String? token;
  final User? user;
  final String? message;
  final String? cafeId;
  final String? expiresAt;
  final int? otpLength;
  final int? resendAvailableInSeconds;
  final Map<String, List<String>>? errors;
  final Map<String, dynamic> extra;

  GoogleSignUpRequestResponse({
    required this.status,
    this.token,
    this.user,
    this.message,
    this.cafeId,
    this.expiresAt,
    this.otpLength,
    this.resendAvailableInSeconds,
    this.errors,
    this.extra = const {},
  });

  factory GoogleSignUpRequestResponse.fromJson(Map<String, dynamic> json) {
    final knownKeys = {
      'status',
      'token',
      'user',
      'message',
      'errors',
      'expires_at',
      'otp_length',
      'resend_available_in_seconds',
    };

    return GoogleSignUpRequestResponse(
      status: json['status'] ?? false,
      token: json['token'],
      user:
          json['user'] != null &&
                  json['user'] is Map &&
                  (json['user'] as Map).isNotEmpty
              ? User.fromJson(Map<String, dynamic>.from(json['user']))
              : null,
      message: json['message'],
      cafeId: json['cafe_id']?.toString(),

      expiresAt: json['expires_at'],
      otpLength:
          json['otp_length'] is int
              ? json['otp_length']
              : int.tryParse(json['otp_length']?.toString() ?? ''),
      resendAvailableInSeconds:
          json['resend_available_in_seconds'] is int
              ? json['resend_available_in_seconds']
              : int.tryParse(
                json['resend_available_in_seconds']?.toString() ?? '',
              ),
      errors:
          json['errors'] != null
              ? Map<String, List<String>>.from(
                json['errors'].map(
                  (key, value) => MapEntry(key, List<String>.from(value)),
                ),
              )
              : null,
      extra: Map<String, dynamic>.from(json)
        ..removeWhere((key, _) => knownKeys.contains(key)),
    );
  }

  bool get hasValidationErrors => errors != null && errors!.isNotEmpty;
}

class User {
  final String userLogin;
  final String name;
  final String email;
  final String phone;
  final int loginType;
  final String? country;
  final String? state;
  final String updatedAt;
  final String createdAt;
  final int id;

  User({
    required this.userLogin,
    required this.name,
    required this.email,
    required this.phone,
    required this.loginType,
    this.country,
    this.state,
    required this.updatedAt,
    required this.createdAt,
    required this.id,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      userLogin: json['user_login'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone']?.toString() ?? '',
      loginType:
          json['login_type'] is int
              ? json['login_type']
              : int.tryParse(json['login_type']?.toString() ?? '') ?? 0,
      country: json['country'],
      state: json['state'],
      updatedAt: json['updated_at'] ?? '',
      createdAt: json['created_at'] ?? '',
      id:
          json['id'] is int
              ? json['id']
              : int.tryParse(json['id']?.toString() ?? '') ?? 0,
    );
  }
}
