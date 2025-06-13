

import 'package:meta/meta.dart';
import 'dart:convert';

CafeListRequest cafeListRequestFromJson(String str) => CafeListRequest.fromJson(json.decode(str));

String cafeListRequestToJson(CafeListRequest data) => json.encode(data.toJson());

class CafeListRequest {
  final double latitude;
  final double longitude;
  final List<String> diceTableFilter;
  final List<String> accommodationsFilter;
  final String openTime;
  final String closeTime;
  final String search;

  CafeListRequest({
    required this.latitude,
    required this.longitude,
    required this.diceTableFilter,
    required this.accommodationsFilter,
    required this.openTime,
    required this.closeTime,
    required this.search,
  });

  CafeListRequest copyWith({
    double? latitude,
    double? longitude,
    List<String>? diceTableFilter,
    List<String>? accommodationsFilter,
    String? openTime,
    String? closeTime,
    String? search,
  }) =>
      CafeListRequest(
        latitude: latitude ?? this.latitude,
        longitude: longitude ?? this.longitude,
        diceTableFilter: diceTableFilter ?? this.diceTableFilter,
        accommodationsFilter: accommodationsFilter ?? this.accommodationsFilter,
        openTime: openTime ?? this.openTime,
        closeTime: closeTime ?? this.closeTime,
        search: search ?? this.search,
      );

  factory CafeListRequest.fromJson(Map<String, dynamic> json) => CafeListRequest(
    latitude: json["latitude"].toDouble(),
    longitude: json["longitude"].toDouble(),
    diceTableFilter: List<String>.from(json["diceTableFilter"].map((x) => x)),
    accommodationsFilter: List<String>.from(json["accommodationsFilter"].map((x) => x)),
    openTime: json["open_time"],
    closeTime: json["close_time"],
    search: json["search"],
  );

  Map<String, dynamic> toJson() => {
    "latitude": latitude,
    "longitude": longitude,
    "diceTableFilter": List<dynamic>.from(diceTableFilter.map((x) => x)),
    "accommodationsFilter": List<dynamic>.from(accommodationsFilter.map((x) => x)),
    "open_time": openTime,
    "close_time": closeTime,
    "search": search,
  };
}
