// To parse this JSON data, do
//
//     final resendOtpRequest = resendOtpRequestFromJson(jsonString);

import 'package:meta/meta.dart';
import 'dart:convert';

ResendOtpRequest resendOtpRequestFromJson(String str) => ResendOtpRequest.fromJson(json.decode(str));

String resendOtpRequestToJson(ResendOtpRequest data) => json.encode(data.toJson());

class ResendOtpRequest {
  final String email;

  ResendOtpRequest({
    required this.email,
  });

  factory ResendOtpRequest.fromJson(Map<String, dynamic> json) => ResendOtpRequest(
    email: json["email"],
  );

  Map<String, dynamic> toJson() => {
    "email": email,
  };
}
