// To parse this JSON data, do
//
//     final forgotPasswordRequestResponse = forgotPasswordRequestResponseFromJson(jsonString);

import 'dart:convert';

PasswordResetRequestResponse forgotPasswordRequestResponseFromJson(String str) => PasswordResetRequestResponse.fromJson(json.decode(str));

String passwordResetRequestResponseToJson(PasswordResetRequestResponse data) => json.encode(data.toJson());

class PasswordResetRequestResponse {
  final String? message;
  final Map<String, dynamic>? rawData;

  PasswordResetRequestResponse({
    this.message,
    this.rawData,
  });

  factory PasswordResetRequestResponse.fromJson(Map<String, dynamic> json) {
    return PasswordResetRequestResponse(
      message: json["message"] ?? json["error"] ?? json["detail"],
      rawData: json,
    );
  }

  Map<String, dynamic> toJson() => {
    "message": message,
    "rawData": rawData,
  };
}

