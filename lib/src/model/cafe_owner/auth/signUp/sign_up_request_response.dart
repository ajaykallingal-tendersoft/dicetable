class SignUpRequestResponse {
  final bool status;
  final String? token;
  final User? user;
  final String? message;
  final Map<String, dynamic>? errors;
  final Map<String, dynamic> extra; // To hold any additional dynamic fields

  SignUpRequestResponse({
    required this.status,
    this.token,
    this.user,
    this.message,
    this.errors,
    this.extra = const {},
  });

  factory SignUpRequestResponse.fromJson(Map<String, dynamic> json) {
    // Extract known fields
    final status = json['status'] as bool;
    final token = json['token'] as String?;
    final user = json['user'] != null ? User.fromJson(json['user']) : null;
    final message = json['message'] as String?;
    final errors = json['errors'] != null ? Map<String, dynamic>.from(json['errors']) : null;

    // Remove known keys to get extra/dynamic fields
    final knownKeys = {'status', 'token', 'user', 'message', 'errors'};
    final extra = Map<String, dynamic>.from(json)
      ..removeWhere((key, _) => knownKeys.contains(key));

    return SignUpRequestResponse(
      status: status,
      token: token,
      user: user,
      message: message,
      errors: errors,
      extra: extra,
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
      userLogin: json['user_login'],
      name: json['name'],
      email: json['email'],
      phone: json['phone'],
      loginType: json['login_type'],
      country: json['country'],
      state: json['state'],
      updatedAt: json['updated_at'],
      createdAt: json['created_at'],
      id: json['id'],
    );
  }
}