// To parse this JSON data, do
//
//     final addFavouriteRequest = addFavouriteRequestFromJson(jsonString);

import 'package:meta/meta.dart';
import 'dart:convert';

AddFavouriteRequest addFavouriteRequestFromJson(String str) => AddFavouriteRequest.fromJson(json.decode(str));

String addFavouriteRequestToJson(AddFavouriteRequest data) => json.encode(data.toJson());

class AddFavouriteRequest {
  final int cafeId;
  final String? deviceToken;

  AddFavouriteRequest({
    required this.cafeId,
    this.deviceToken,
  });

  factory AddFavouriteRequest.fromJson(Map<String, dynamic> json) => AddFavouriteRequest(
    cafeId: json["cafe_id"],
    deviceToken: json["device_token"]
  );

  Map<String, dynamic> toJson() => {
    "cafe_id": cafeId,
    "device_token": deviceToken,
  };
}
