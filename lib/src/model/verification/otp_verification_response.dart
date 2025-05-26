// To parse this JSON data, do
//
//     final otpVerificationResponse = otpVerificationResponseFromJson(jsonString);

import 'dart:convert';

OtpVerificationResponse otpVerificationResponseFromJson(String str) => OtpVerificationResponse.fromJson(json.decode(str));

String otpVerificationResponseToJson(OtpVerificationResponse data) => json.encode(data.toJson());

class OtpVerificationResponse {
  final bool? status;
  final User? user;
  final String? token;
  final String? message;

  OtpVerificationResponse({
    this.status,
    this.user,
    this.token,
    this.message,
  });

  factory OtpVerificationResponse.fromJson(Map<String, dynamic> json) => OtpVerificationResponse(
    status: json["status"],
    user: json["user"] == null ? null : User.fromJson(json["user"]),
    token: json["token"],
    message: json["message"],
  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "user": user?.toJson(),
    "token": token,
    "message": message,
  };
}

class User {
  User();

  factory User.fromJson(Map<String, dynamic> json) => User(
  );

  Map<String, dynamic> toJson() => {
  };
}
