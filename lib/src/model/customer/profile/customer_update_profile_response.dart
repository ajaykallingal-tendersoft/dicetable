// To parse this JSON data, do
//
//     final customerUpdateProfileResponse = customerUpdateProfileResponseFromJson(jsonString);

import 'dart:convert';

CustomerUpdateProfileResponse customerUpdateProfileResponseFromJson(String str) => CustomerUpdateProfileResponse.fromJson(json.decode(str));

String customerUpdateProfileResponseToJson(CustomerUpdateProfileResponse data) => json.encode(data.toJson());

class CustomerUpdateProfileResponse {
  final bool? status;
  final String? message;

  CustomerUpdateProfileResponse({
    this.status,
    this.message,
  });

  CustomerUpdateProfileResponse copyWith({
    bool? status,
    String? message,
  }) =>
      CustomerUpdateProfileResponse(
        status: status ?? this.status,
        message: message ?? this.message,
      );

  factory CustomerUpdateProfileResponse.fromJson(Map<String, dynamic> json) => CustomerUpdateProfileResponse(
    status: json["status"],
    message: json["message"],
  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "message": message,
  };
}
