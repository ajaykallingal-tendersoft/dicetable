// To parse this JSON data, do
//
//     final bookingRequestResponse = bookingRequestResponseFromJson(jsonString);

import 'dart:convert';

BookingRequestResponse bookingRequestResponseFromJson(String str) => BookingRequestResponse.fromJson(json.decode(str));

String bookingRequestResponseToJson(BookingRequestResponse data) => json.encode(data.toJson());

class BookingRequestResponse {
  final Data? data;
  final int? status;
  final String? message;

  BookingRequestResponse({
    this.data,
    this.status,
    this.message,
  });

  factory BookingRequestResponse.fromJson(Map<String, dynamic> json) => BookingRequestResponse(
    data: json["data"] == null ? null : Data.fromJson(json["data"]),
    status: json["status"],
    message: json["message"],
  );

  Map<String, dynamic> toJson() => {
    "data": data?.toJson(),
    "status": status,
    "message": message,
  };
}

class Data {
  Data();

  factory Data.fromJson(Map<String, dynamic> json) => Data(
  );

  Map<String, dynamic> toJson() => {
  };
}
