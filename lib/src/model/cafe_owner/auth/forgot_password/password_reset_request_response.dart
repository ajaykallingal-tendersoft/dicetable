// To parse this JSON data, do
//
//     final forgotPasswordRequestResponse = forgotPasswordRequestResponseFromJson(jsonString);

import 'dart:convert';

PasswordResetRequestResponse forgotPasswordRequestResponseFromJson(String str) => PasswordResetRequestResponse.fromJson(json.decode(str));

String passwordResetRequestResponseToJson(PasswordResetRequestResponse data) => json.encode(data.toJson());

class PasswordResetRequestResponse {
  final bool? status;
  final String? message;
  final Map<String, dynamic>? rawData;

  PasswordResetRequestResponse({
    this.status,
    this.message,
    this.rawData,
  });

  factory PasswordResetRequestResponse.fromJson(Map<String, dynamic> json) {
    return PasswordResetRequestResponse(
      status: json["status"],
      message: json["message"] ?? json["error"] ?? json["detail"],
      rawData: json,
    );
  }

  Map<String, dynamic> toJson() => {
    "status" : status,
    "message": message,
    "rawData": rawData,
  };
}

