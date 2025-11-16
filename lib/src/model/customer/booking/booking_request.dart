// To parse this JSON data, do
//
//     final bookingRequest = bookingRequestFromJson(jsonString);

import 'package:meta/meta.dart';
import 'dart:convert';

BookingRequest bookingRequestFromJson(String str) => BookingRequest.fromJson(json.decode(str));

String bookingRequestToJson(BookingRequest data) => json.encode(data.toJson());

class BookingRequest {
  final String cafeId;
  final String diceTableType;
  final DateTime currentDate;
  final String checkInTime;
  final String checkOutTime;
  final String userId;
  final String userName;
  final String userEmail;
  final String deviceId;
  final String additionalInfo;
  // final bool setAsPref;

  BookingRequest({
    required this.cafeId,
    required this.diceTableType,
    required this.currentDate,
    required this.checkInTime,
    required this.checkOutTime,
    required this.userId,
    required this.userName,
    required this.userEmail,
    required this.deviceId,
    required this.additionalInfo,
    // required this.setAsPref,
  });

  factory BookingRequest.fromJson(Map<String, dynamic> json) => BookingRequest(
    cafeId: json["cafe_id"],
    diceTableType: json["dice_table_type"],
    currentDate: DateTime.parse(json["current_date"]),
    checkInTime: json["check_in_time"],
    checkOutTime: json["check_out_time"],
    userId: json["user_id"],
    userName: json["user_name"],
    userEmail: json["user_email"],
    deviceId: json["device_id"],
    additionalInfo: json["additional_info"],
    // setAsPref: json["setAsPref"],
  );

  Map<String, dynamic> toJson() => {
    "cafe_id": cafeId,
    "dice_table_type": diceTableType,
    "current_date": "${currentDate.year.toString().padLeft(4, '0')}-${currentDate.month.toString().padLeft(2, '0')}-${currentDate.day.toString().padLeft(2, '0')}",
    "check_in_time": checkInTime,
    "check_out_time": checkOutTime,
    "user_id": userId,
    "user_name": userName,
    "user_email": userEmail,
    "device_id": deviceId,
    "additional_info": additionalInfo,
    // "setAsPref": setAsPref,
  };
}
