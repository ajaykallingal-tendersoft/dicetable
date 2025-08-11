// To parse this JSON data, do
//
//     final appleLoginRequest = appleLoginRequestFromJson(jsonString);

import 'package:meta/meta.dart';
import 'dart:convert';

AppleLoginRequest appleLoginRequestFromJson(String str) =>
    AppleLoginRequest.fromJson(json.decode(str));

String appleLoginRequestToJson(AppleLoginRequest data) =>
    json.encode(data.toJson());

class AppleLoginRequest {
  final String email;
  final String identityToken;
  final int loginType;
  final String fcmToken;

  AppleLoginRequest({required this.identityToken, required this.loginType,required this.fcmToken,required this.email,});

  factory AppleLoginRequest.fromJson(Map<String, dynamic> json) =>
      AppleLoginRequest(
        email: json["email"],
        identityToken: json["identity_token"],
        loginType: json["login_type"],
        fcmToken: json["fcm_token"],
      );

  Map<String, dynamic> toJson() => {
    "email": email,
    "identity_token": identityToken,
    "login_type": loginType,
    "fcm_token": fcmToken,
  };
}
