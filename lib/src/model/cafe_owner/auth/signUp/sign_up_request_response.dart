class SignUpRequestResponse {
  final bool status;
  final String? token;
  final User? user;
  final String? message;
  final String? cafeId;
  final String? expiresAt;
  final int? otpLength;
  final int? resendAvailableInSeconds;
  final Map<String, dynamic>? errors;
  final Map<String, dynamic> extra;

  SignUpRequestResponse({
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

  factory SignUpRequestResponse.fromJson(Map<String, dynamic> json) {
    final knownKeys = {
      'status',
      'token',
      'user',
      'message',
      'errors',
      'expiresAt',
      'otpLength',
      'resendAvailableInSeconds',
      'cafe_id'
    };

    return SignUpRequestResponse(
      status: json['status'] ?? false,
      token: json['token'],
      user: json['user'] != null ? User.fromJson(json['user']) : null,
      message: json['message'],
      cafeId: json['cafe_id']?.toString(),
      expiresAt: json['expiresAt'],
      otpLength: json['otpLength'],
      resendAvailableInSeconds: json['resendAvailableInSeconds'],
      errors: json['errors'] != null ? Map<String, dynamic>.from(json['errors']) : null,
      extra: Map<String, dynamic>.from(json)
        ..removeWhere((key, _) => knownKeys.contains(key)),
    );
  }
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
  final int? emailOtp;
  final DateTime? otpExpiresAt;
  final String? avatar;
  final String? countryName;

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
    this.emailOtp,
    this.otpExpiresAt,
    this.avatar,
    this.countryName,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      userLogin: json['user_login'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone']?.toString() ?? '',
      loginType: int.tryParse(json['login_type'].toString()) ?? 0,
      country: json['country'],
      state: json['state'],
      updatedAt: json['updated_at'] ?? '',
      createdAt: json['created_at'] ?? '',
      id: json['id'] ?? 0,
      emailOtp: json['email_otp'],
      otpExpiresAt: json['otp_expires_at'] != null
          ? DateTime.tryParse(json['otp_expires_at'])
          : null,
      avatar: json['avatar'],
      countryName: json['country_name'],
    );
  }
}
