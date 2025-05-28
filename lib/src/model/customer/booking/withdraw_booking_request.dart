// To parse this JSON data, do
//
//     final withdrawBookingRequest = withdrawBookingRequestFromJson(jsonString);

import 'package:meta/meta.dart';
import 'dart:convert';

WithdrawBookingRequest withdrawBookingRequestFromJson(String str) => WithdrawBookingRequest.fromJson(json.decode(str));

String withdrawBookingRequestToJson(WithdrawBookingRequest data) => json.encode(data.toJson());

class WithdrawBookingRequest {
  final String cafeId;

  WithdrawBookingRequest({
    required this.cafeId,
  });

  factory WithdrawBookingRequest.fromJson(Map<String, dynamic> json) => WithdrawBookingRequest(
    cafeId: json["cafe_id"],
  );

  Map<String, dynamic> toJson() => {
    "cafe_id": cafeId,
  };
}
