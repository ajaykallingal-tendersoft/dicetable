// To parse this JSON data, do
//
//     final googleLoginRequest = googleLoginRequestFromJson(jsonString);
import 'dart:convert';

GoogleLoginRequest googleLoginRequestFromJson(String str) => GoogleLoginRequest.fromJson(json.decode(str));

String googleLoginRequestToJson(GoogleLoginRequest data) => json.encode(data.toJson());

class GoogleLoginRequest {
  final String email;
  final int loginType;
  final String fcmToken;

  GoogleLoginRequest({
    required this.email,
    required this.loginType,
    required this.fcmToken,
  });

  factory GoogleLoginRequest.fromJson(Map<String, dynamic> json) => GoogleLoginRequest(
    email: json["email"],
    loginType: json["login_type"],
    fcmToken: json["fcm_token"]
  );

  Map<String, dynamic> toJson() => {
    "email": email,
    "login_type": loginType,
    "fcm_token": fcmToken,
  };
}
