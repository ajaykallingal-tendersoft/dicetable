// To parse this JSON data, do
//
//     final getFavouriteResponse = getFavouriteResponseFromJson(jsonString);

import 'dart:convert';

GetFavouriteResponse getFavouriteResponseFromJson(String str) => GetFavouriteResponse.fromJson(json.decode(str));

String getFavouriteResponseToJson(GetFavouriteResponse data) => json.encode(data.toJson());

class GetFavouriteResponse {
  final bool? status;
  final List<Datum>? data;

  GetFavouriteResponse({
    this.status,
    this.data,
  });

  factory GetFavouriteResponse.fromJson(Map<String, dynamic> json) => GetFavouriteResponse(
    status: json["status"],
    data: json["data"] == null ? [] : List<Datum>.from(json["data"]!.map((x) => Datum.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "data": data == null ? [] : List<dynamic>.from(data!.map((x) => x.toJson())),
  };
}

class Datum {
  final String? name;
  final String? venueDescription;
  final List<String>? tableTypes;
  final String? photo;
  bool isFavorite; // ← add this

  Datum({
    this.name,
    this.venueDescription,
    this.tableTypes,
    this.photo,
    this.isFavorite = false, // default false
  });

  Datum copyWith({
    String? name,
    String? venueDescription,
    List<String>? tableTypes,
    String? photo,
    bool? isFavorite,
  }) => Datum(
    name: name ?? this.name,
    venueDescription: venueDescription ?? this.venueDescription,
    tableTypes: tableTypes ?? this.tableTypes,
    photo: photo ?? this.photo,
    isFavorite: isFavorite ?? this.isFavorite,
  );

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
    name: json["name"],
    venueDescription: json["venue_description"],
    tableTypes: json["table_types"] == null
        ? []
        : List<String>.from(json["table_types"]!.map((x) => x)),
    photo: json["photo"],
    isFavorite: false, // ← initialize from local logic only
  );

  Map<String, dynamic> toJson() => {
    "name": name,
    "venue_description": venueDescription,
    "table_types": tableTypes == null
        ? []
        : List<dynamic>.from(tableTypes!.map((x) => x)),
    "photo": photo,
  };
}

