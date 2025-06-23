
import 'dart:convert';

LoginRequest loginRequestFromJson(String str) => LoginRequest.fromJson(json.decode(str));

String loginRequestToJson(LoginRequest data) => json.encode(data.toJson());

class LoginRequest {
  final String login;
  final String password;
  final String fcmToken;

  LoginRequest({
    required this.login,
    required this.password,
    required this.fcmToken,
  });

  factory LoginRequest.fromJson(Map<String, dynamic> json) => LoginRequest(
    login: json["login"],
    password: json["password"],
    fcmToken: json["fcm_token"],
  );

  Map<String, dynamic> toJson() => {
    "login": login,
    "password": password,
    "fcm_token": fcmToken,
  };
}
