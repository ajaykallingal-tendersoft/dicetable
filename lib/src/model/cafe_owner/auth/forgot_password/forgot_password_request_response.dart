// To parse this JSON data, do
//
//     final forgotPasswordRequestResponse = forgotPasswordRequestResponseFromJson(jsonString);

import 'dart:convert';

ForgotPasswordRequestResponse forgotPasswordRequestResponseFromJson(String str) => ForgotPasswordRequestResponse.fromJson(json.decode(str));

String forgotPasswordRequestResponseToJson(ForgotPasswordRequestResponse data) => json.encode(data.toJson());

class ForgotPasswordRequestResponse {
  final bool? status;
  final String? message;
  final Map<String, dynamic>? rawData;

  ForgotPasswordRequestResponse({
    this.status,
    this.message,
    this.rawData,
  });

  factory ForgotPasswordRequestResponse.fromJson(Map<String, dynamic> json) {
    return ForgotPasswordRequestResponse(
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

