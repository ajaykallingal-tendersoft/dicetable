// To parse this JSON data, do
//
//     final guestUserRequest = guestUserRequestFromJson(jsonString);

import 'dart:convert';

GuestUserRequest guestUserRequestFromJson(String str) => GuestUserRequest.fromJson(json.decode(str));

String guestUserRequestToJson(GuestUserRequest data) => json.encode(data.toJson());

class GuestUserRequest {
  final String? deviceToken;
  final double? latitude;
  final double? longitude;

  GuestUserRequest({
    this.deviceToken,
    this.latitude,
    this.longitude,
  });

  factory GuestUserRequest.fromJson(Map<String, dynamic> json) => GuestUserRequest(
    deviceToken: json["device_token"],
    latitude: json["latitude"]?.toDouble(),
    longitude: json["longitude"]?.toDouble(),
  );

  Map<String, dynamic> toJson() => {
    "device_token": deviceToken,
    "latitude": latitude,
    "longitude": longitude,
  };
}
