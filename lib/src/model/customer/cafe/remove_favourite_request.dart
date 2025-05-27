// To parse this JSON data, do
//
//     final removeFavouriteRequest = removeFavouriteRequestFromJson(jsonString);

import 'package:meta/meta.dart';
import 'dart:convert';

RemoveFavouriteRequest removeFavouriteRequestFromJson(String str) => RemoveFavouriteRequest.fromJson(json.decode(str));

String removeFavouriteRequestToJson(RemoveFavouriteRequest data) => json.encode(data.toJson());

class RemoveFavouriteRequest {
  final int cafeId;

  RemoveFavouriteRequest({
    required this.cafeId,
  });

  factory RemoveFavouriteRequest.fromJson(Map<String, dynamic> json) => RemoveFavouriteRequest(
    cafeId: json["cafe_id"],
  );

  Map<String, dynamic> toJson() => {
    "cafe_id": cafeId,
  };
}
