// To parse this JSON data, do
//
//     final withdrawBookingResponse = withdrawBookingResponseFromJson(jsonString);

import 'dart:convert';

WithdrawBookingResponse withdrawBookingResponseFromJson(String str) => WithdrawBookingResponse.fromJson(json.decode(str));

String withdrawBookingResponseToJson(WithdrawBookingResponse data) => json.encode(data.toJson());

class WithdrawBookingResponse {
  final bool? status;
  final String? message;

  WithdrawBookingResponse({
    this.status,
    this.message,
  });

  WithdrawBookingResponse copyWith({
    bool? status,
    String? message,
  }) =>
      WithdrawBookingResponse(
        status: status ?? this.status,
        message: message ?? this.message,
      );

  factory WithdrawBookingResponse.fromJson(Map<String, dynamic> json) => WithdrawBookingResponse(
    status: json["status"],
    message: json["message"],
  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "message": message,
  };
}
