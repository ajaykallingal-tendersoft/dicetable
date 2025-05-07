// To parse this JSON data, do
//
//     final passwordResetRequest = passwordResetRequestFromJson(jsonString);

import 'package:meta/meta.dart';
import 'dart:convert';

PasswordResetRequest passwordResetRequestFromJson(String str) => PasswordResetRequest.fromJson(json.decode(str));

String passwordResetRequestToJson(PasswordResetRequest data) => json.encode(data.toJson());

class PasswordResetRequest {
  final String email;
  final String token;
  final String password;
  final String passwordConfirmation;

  PasswordResetRequest({
    required this.email,
    required this.token,
    required this.password,
    required this.passwordConfirmation,
  });

  factory PasswordResetRequest.fromJson(Map<String, dynamic> json) => PasswordResetRequest(
    email: json["email"],
    token: json["token"],
    password: json["password"],
    passwordConfirmation: json["password_confirmation"],
  );

  Map<String, dynamic> toJson() => {
    "email": email,
    "token": token,
    "password": password,
    "password_confirmation": passwordConfirmation,
  };
}
