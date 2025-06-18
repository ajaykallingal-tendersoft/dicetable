import 'dart:convert';

ForgotPasswordRequestResponse forgotPasswordRequestResponseFromJson(String str) =>
    ForgotPasswordRequestResponse.fromJson(json.decode(str));

String forgotPasswordRequestResponseToJson(ForgotPasswordRequestResponse data) =>
    json.encode(data.toJson());

class ForgotPasswordRequestResponse {
  final bool? status;
  final String? message;
  final String? expiresAt;
  final int? otpLength;
  final int? resendAvailableInSeconds;
  final Map<String, dynamic>? errors;
  final Map<String, dynamic> extra;

  ForgotPasswordRequestResponse({
    this.status,
    this.message,
    this.expiresAt,
    this.otpLength,
    this.resendAvailableInSeconds,
    this.errors,
    this.extra = const {},
  });

  factory ForgotPasswordRequestResponse.fromJson(Map<String, dynamic> json) {
    final status = json['status'] is bool
        ? json['status']
        : json['status'] == null
        ? null
        : json['status'].toString().toLowerCase() == 'true';

    final message = json['message'] ?? json['error'] ?? json['detail'];

    final expiresAt = json['expiresAt'];
    final otpLength = json['otpLength'];
    final resendAvailableInSeconds = json['resendAvailableInSeconds'];

    final errors = json['errors'] != null
        ? Map<String, dynamic>.from(json['errors'])
        : null;

    // Collect any extra fields
    final knownKeys = {
      'status',
      'message',
      'error',
      'detail',
      'expiresAt',
      'otpLength',
      'resendAvailableInSeconds',
      'errors'
    };
    final extra = Map<String, dynamic>.from(json)
      ..removeWhere((key, _) => knownKeys.contains(key));

    return ForgotPasswordRequestResponse(
      status: status,
      message: message,
      expiresAt: expiresAt,
      otpLength: otpLength,
      resendAvailableInSeconds: resendAvailableInSeconds,
      errors: errors,
      extra: extra,
    );
  }

  Map<String, dynamic> toJson() => {
    'status': status,
    'message': message,
    'expiresAt': expiresAt,
    'otpLength': otpLength,
    'resendAvailableInSeconds': resendAvailableInSeconds,
    'errors': errors,
    ...extra, // Include extra fields if needed
  };
}
