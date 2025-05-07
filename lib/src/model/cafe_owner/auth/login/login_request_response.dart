// To parse this JSON data, do
//
//     final loginRequestResponse = loginRequestResponseFromJson(jsonString);

import 'dart:convert';

class LoginRequestResponse {
  final bool? status;
  final String? token;
  final String? type;
  final String? message;
  final String? error;
  final Map<String, dynamic>? errors;

  LoginRequestResponse({
    this.status,
    this.token,
    this.type,
    this.message,
    this.error,
    this.errors,
  });

  factory LoginRequestResponse.fromJson(Map<String, dynamic> json) => LoginRequestResponse(
    status: json["status"],
    token: json["token"],
    type: json["type"],
    message: json["message"],
    error: json["error"],
    errors: json["errors"],
  );

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    if (status != null) data["status"] = status;
    if (token != null) data["token"] = token;
    if (type != null) data["type"] = type;
    if (message != null) data["message"] = message;
    if (error != null) data["error"] = error;
    if (errors != null) data["errors"] = errors;
    return data;
  }

  static LoginRequestResponse createFromJson(Map<String, dynamic> json) {
    return LoginRequestResponse.fromJson(json);
  }
}
