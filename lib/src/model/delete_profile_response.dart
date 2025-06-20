// To parse this JSON data, do
//
//     final deleteProfileResponse = deleteProfileResponseFromJson(jsonString);

import 'dart:convert';

DeleteProfileResponse deleteProfileResponseFromJson(String str) => DeleteProfileResponse.fromJson(json.decode(str));

String deleteProfileResponseToJson(DeleteProfileResponse data) => json.encode(data.toJson());

class DeleteProfileResponse {
  final bool? status;
  final String? message;

  DeleteProfileResponse({
    this.status,
    this.message,
  });

  factory DeleteProfileResponse.fromJson(Map<String, dynamic> json) => DeleteProfileResponse(
    status: json["status"],
    message: json["message"],
  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "message": message,
  };
}
