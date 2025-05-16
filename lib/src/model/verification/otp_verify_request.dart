// To parse this JSON data, do
//
//     final otpVerifyRequest = otpVerifyRequestFromJson(jsonString);

import 'package:meta/meta.dart';
import 'dart:convert';

OtpVerifyRequest otpVerifyRequestFromJson(String str) => OtpVerifyRequest.fromJson(json.decode(str));

String otpVerifyRequestToJson(OtpVerifyRequest data) => json.encode(data.toJson());

class OtpVerifyRequest {
  final String email;
  final String otp;

  OtpVerifyRequest({
    required this.email,
    required this.otp,
  });

  factory OtpVerifyRequest.fromJson(Map<String, dynamic> json) => OtpVerifyRequest(
    email: json["email"],
    otp: json["otp"],
  );

  Map<String, dynamic> toJson() => {
    "email": email,
    "otp": otp,
  };
}
