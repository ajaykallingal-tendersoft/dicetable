class GoogleSignUpRequestResponse {
  final bool status;
  final String? token;
  final User? user;
  final String? message;
  final Map<String, List<String>>? errors;
  final Map<String, dynamic> extra;

  GoogleSignUpRequestResponse({
    required this.status,
    this.token,
    this.user,
    this.message,
    this.errors,
    this.extra = const {},
  });

  factory GoogleSignUpRequestResponse.fromJson(Map<String, dynamic> json) {
    final knownKeys = {'status', 'token', 'user', 'message', 'errors'};

    return GoogleSignUpRequestResponse(
      status: json['status'] ?? false,
      token: json['token'],
      user: json['user'] != null && json['user'].isNotEmpty
          ? User.fromJson(Map<String, dynamic>.from(json['user']))
          : null,
      message: json['message'],
      errors: json['errors'] != null
          ? Map<String, List<String>>.from(
          json['errors'].map((key, value) =>
              MapEntry(key, List<String>.from(value))))
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
      phone: json['phone'] ?? '',
      loginType: json['login_type'] ?? 0,
      country: json['country'],
      state: json['state'],
      updatedAt: json['updated_at'] ?? '',
      createdAt: json['created_at'] ?? '',
      id: json['id'] ?? 0,
    );
  }
}
