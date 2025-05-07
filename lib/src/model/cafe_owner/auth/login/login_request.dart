
import 'dart:convert';

LoginRequest loginRequestFromJson(String str) => LoginRequest.fromJson(json.decode(str));

String loginRequestToJson(LoginRequest data) => json.encode(data.toJson());

class LoginRequest {
  final String login;
  final String password;

  LoginRequest({
    required this.login,
    required this.password,
  });

  factory LoginRequest.fromJson(Map<String, dynamic> json) => LoginRequest(
    login: json["login"],
    password: json["password"],
  );

  Map<String, dynamic> toJson() => {
    "login": login,
    "password": password,
  };
}
