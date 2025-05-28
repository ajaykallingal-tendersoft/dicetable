// To parse this JSON data, do
//
//     final cafeSearchRequest = cafeSearchRequestFromJson(jsonString);

import 'package:meta/meta.dart';
import 'dart:convert';

CafeSearchRequest cafeSearchRequestFromJson(String str) => CafeSearchRequest.fromJson(json.decode(str));

String cafeSearchRequestToJson(CafeSearchRequest data) => json.encode(data.toJson());

class CafeSearchRequest {
  final String search;

  CafeSearchRequest({
    required this.search,
  });

  factory CafeSearchRequest.fromJson(Map<String, dynamic> json) => CafeSearchRequest(
    search: json["search"],
  );

  Map<String, dynamic> toJson() => {
    "search": search,
  };
}
