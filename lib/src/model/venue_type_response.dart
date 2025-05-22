// To parse this JSON data, do
//
//     final venueTypeResponse = venueTypeResponseFromJson(jsonString);

import 'dart:convert';

VenueTypeResponse venueTypeResponseFromJson(String str) => VenueTypeResponse.fromJson(json.decode(str));

String venueTypeResponseToJson(VenueTypeResponse data) => json.encode(data.toJson());

class VenueTypeResponse {
  final bool? status;
  final List<VenueType>? venueTypes;
  final String? message;

  VenueTypeResponse({
    this.status,
    this.venueTypes,
    this.message,
  });

  factory VenueTypeResponse.fromJson(Map<String, dynamic> json) => VenueTypeResponse(
    status: json["status"],
    venueTypes: json["venue_types"] == null ? [] : List<VenueType>.from(json["venue_types"]!.map((x) => VenueType.fromJson(x))),
    message: json["message"],
  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "venue_types": venueTypes == null ? [] : List<dynamic>.from(venueTypes!.map((x) => x.toJson())),
    "message": message,
  };
}

class VenueType {
  final int? id;
  final String? title;

  VenueType({
    this.id,
    this.title,
  });

  factory VenueType.fromJson(Map<String, dynamic> json) => VenueType(
    id: json["id"],
    title: json["title"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "title": title,
  };
}
