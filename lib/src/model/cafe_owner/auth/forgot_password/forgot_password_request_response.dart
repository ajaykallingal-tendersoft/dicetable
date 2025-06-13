// To parse this JSON data, do
//
//     final forgotPasswordRequestResponse = forgotPasswordRequestResponseFromJson(jsonString);

import 'dart:convert';

ForgotPasswordRequestResponse forgotPasswordRequestResponseFromJson(String str) => ForgotPasswordRequestResponse.fromJson(json.decode(str));

String forgotPasswordRequestResponseToJson(ForgotPasswordRequestResponse data) => json.encode(data.toJson());

class ForgotPasswordRequestResponse {
  final bool? status;
  final String? message;
  final String? expiresAt;
  final int? otpLength;
  final int? resendAvailableInSeconds;
  final Map<String, dynamic>? rawData;

  ForgotPasswordRequestResponse({
    this.status,
    this.message,
    this.rawData,
    this.expiresAt,
    this.otpLength,
    this.resendAvailableInSeconds,
  });

  factory ForgotPasswordRequestResponse.fromJson(Map<String, dynamic> json) {
    return ForgotPasswordRequestResponse(
      status: json["status"],
      message: json["message"] ?? json["error"] ?? json["detail"],
      rawData: json,
      expiresAt: json["expiresAt"],
      otpLength: json["otpLength"],
      resendAvailableInSeconds: json["resendAvailableInSeconds"],
    );
  }

  Map<String, dynamic> toJson() => {
    "status" : status,
    "message": message,
    "rawData": rawData,
    "expiresAt": expiresAt,
    "otpLength": otpLength,
    "resendAvailableInSeconds": resendAvailableInSeconds,
  };
}

