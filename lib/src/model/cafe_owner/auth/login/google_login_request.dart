// To parse this JSON data, do
//
//     final googleLoginRequest = googleLoginRequestFromJson(jsonString);
import 'dart:convert';

GoogleLoginRequest googleLoginRequestFromJson(String str) => GoogleLoginRequest.fromJson(json.decode(str));

String googleLoginRequestToJson(GoogleLoginRequest data) => json.encode(data.toJson());

class GoogleLoginRequest {
  final String email;
  final int loginType;

  GoogleLoginRequest({
    required this.email,
    required this.loginType,
  });

  factory GoogleLoginRequest.fromJson(Map<String, dynamic> json) => GoogleLoginRequest(
    email: json["email"],
    loginType: json["login_type"],
  );

  Map<String, dynamic> toJson() => {
    "email": email,
    "login_type": loginType,
  };
}
