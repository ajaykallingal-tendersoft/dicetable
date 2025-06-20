
// To parse this JSON data, do
//
//     final appleLoginRequestResponse = appleLoginRequestResponseFromJson(jsonString);

import 'dart:convert';

AppleLoginRequestResponse appleLoginRequestResponseFromJson(String str) =>
    AppleLoginRequestResponse.fromJson(json.decode(str));

String appleLoginRequestResponseToJson(AppleLoginRequestResponse data) =>
    json.encode(data.toJson());

class AppleLoginRequestResponse {
  final bool? status;
  final String? token;
  final User? user;
  final String? cafeId;
  final int? type;
  final bool? subscriptionStatus;
  final String? appleId;
  final String? message;

  AppleLoginRequestResponse({
    this.status,
    this.token,
    this.user,
    this.cafeId,
    this.type,
    this.subscriptionStatus,
    this.appleId,
    this.message,
  });

  factory AppleLoginRequestResponse.fromJson(Map<String, dynamic> json) =>
      AppleLoginRequestResponse(
        status: json["status"],
        token: json["token"],
        user: json["user"] == null ? null : User.fromJson(json["user"]),
        cafeId: json["cafe_id"],
        type: json["type"],
        subscriptionStatus: json["subscription_status"],
        appleId: json["apple_id"],
        message: json["message"],
      );

  Map<String, dynamic> toJson() => {
    "status": status,
    "token": token,
    "user": user?.toJson(),
    "cafe_id": cafeId,
    "type": type,
    "subscription_status": subscriptionStatus,
    "apple_id": appleId,
    "message": message,
  };
}

class User {
  final int? id;
  final String? name;
  final String? email;

  User({this.id, this.name, this.email});

  factory User.fromJson(Map<String, dynamic> json) =>
      User(id: json["id"], name: json["name"], email: json["email"]);

  Map<String, dynamic> toJson() => {"id": id, "name": name, "email": email};
}
