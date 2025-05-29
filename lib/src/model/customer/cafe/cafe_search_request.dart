// To parse this JSON data, do
//
//     final cafeSearchRequest = cafeSearchRequestFromJson(jsonString);

import 'package:meta/meta.dart';
import 'dart:convert';

CafeSearchRequest cafeSearchRequestFromJson(String str) => CafeSearchRequest.fromJson(json.decode(str));

String cafeSearchRequestToJson(CafeSearchRequest data) => json.encode(data.toJson());

class CafeSearchRequest {
  final String search;
  final String openTime;
  final String closeTime;
  final List<String> diceTableFilter;
  final List<String> accommodationsFilter;

  CafeSearchRequest({
    required this.search,
    required this.openTime,
    required this.closeTime,
    required this.diceTableFilter,
    required this.accommodationsFilter,
  });

  factory CafeSearchRequest.fromJson(Map<String, dynamic> json) => CafeSearchRequest(
    search: json["search"],
    openTime: json["open_time"],
    closeTime: json["close_time"],
    diceTableFilter: List<String>.from(json["diceTableFilter"].map((x) => x)),
    accommodationsFilter: List<String>.from(json["accommodationsFilter"].map((x) => x)),
  );

  Map<String, dynamic> toJson() => {
    "search": search,
    "open_time": openTime,
    "close_time": closeTime,
    "diceTableFilter": List<dynamic>.from(diceTableFilter.map((x) => x)),
    "accommodationsFilter": List<dynamic>.from(accommodationsFilter.map((x) => x)),
  };
}
