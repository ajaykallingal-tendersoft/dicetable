// To parse this JSON data, do
//
//     final searchRequestResponse = searchRequestResponseFromJson(jsonString);

import 'dart:convert';

SearchRequestResponse searchRequestResponseFromJson(String str) => SearchRequestResponse.fromJson(json.decode(str));

String searchRequestResponseToJson(SearchRequestResponse data) => json.encode(data.toJson());

class SearchRequestResponse {
  final bool? status;
  final String? message;
  final List<Cafe>? cafes;

  SearchRequestResponse({
    this.status,
    this.message,
    this.cafes,
  });

  SearchRequestResponse copyWith({
    bool? status,
    String? message,
    List<Cafe>? cafes,
  }) =>
      SearchRequestResponse(
        status: status ?? this.status,
        message: message ?? this.message,
        cafes: cafes ?? this.cafes,
      );

  factory SearchRequestResponse.fromJson(Map<String, dynamic> json) => SearchRequestResponse(
    status: json["status"],
    message: json["message"],
    cafes: json["cafes"] == null ? [] : List<Cafe>.from(json["cafes"]!.map((x) => Cafe.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "message": message,
    "cafes": cafes == null ? [] : List<dynamic>.from(cafes!.map((x) => x.toJson())),
  };
}

class Cafe {
  final int? id;
  final String? name;
  final String? venueDescription;
  final List<String>? tableTypes;
  final String? photo;
  final bool? favourites;
  final bool? bookingStatus;
  final List<WorkingHour>? workingHours;
  final String? latitude;
  final String? longitude;

  Cafe({
    this.id,
    this.name,
    this.venueDescription,
    this.tableTypes,
    this.photo,
    this.favourites,
    this.bookingStatus,
    this.workingHours,
    this.latitude,
    this.longitude,
  });

  Cafe copyWith({
    int? id,
    String? name,
    String? venueDescription,
    List<String>? tableTypes,
    String? photo,
    bool? favourites,
    bool? bookingStatus,
    List<WorkingHour>? workingHours,
    String? latitude,
    String? longitude,
  }) =>
      Cafe(
        id: id ?? this.id,
        name: name ?? this.name,
        venueDescription: venueDescription ?? this.venueDescription,
        tableTypes: tableTypes ?? this.tableTypes,
        photo: photo ?? this.photo,
        favourites: favourites ?? this.favourites,
        bookingStatus: bookingStatus ?? this.bookingStatus,
        workingHours: workingHours ?? this.workingHours,
        latitude: latitude ?? this.latitude,
        longitude: longitude ?? this.longitude,
      );

  factory Cafe.fromJson(Map<String, dynamic> json) => Cafe(
    id: json["id"],
    name: json["name"],
    venueDescription: json["venue_description"],
    tableTypes: json["table_types"] == null ? [] : List<String>.from(json["table_types"]!.map((x) => x)),
    photo: json["photo"],
    favourites: json["favourites"],
    bookingStatus: json["booking_status"],
    workingHours: json["working_hours"] == null ? [] : List<WorkingHour>.from(json["working_hours"]!.map((x) => WorkingHour.fromJson(x))),
    latitude: json["latitude"],
    longitude: json["longitude"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "venue_description": venueDescription,
    "table_types": tableTypes == null ? [] : List<dynamic>.from(tableTypes!.map((x) => x)),
    "photo": photo,
    "favourites": favourites,
    "booking_status": bookingStatus,
    "working_hours": workingHours == null ? [] : List<dynamic>.from(workingHours!.map((x) => x.toJson())),
    "latitude": latitude,
    "longitude": longitude,
  };
}

class WorkingHour {
  final String? day;
  final int? isOpen;
  final String? opening;
  final String? closing;

  WorkingHour({
    this.day,
    this.isOpen,
    this.opening,
    this.closing,
  });

  WorkingHour copyWith({
    String? day,
    int? isOpen,
    String? opening,
    String? closing,
  }) =>
      WorkingHour(
        day: day ?? this.day,
        isOpen: isOpen ?? this.isOpen,
        opening: opening ?? this.opening,
        closing: closing ?? this.closing,
      );

  factory WorkingHour.fromJson(Map<String, dynamic> json) => WorkingHour(
    day: json["day"],
    isOpen: json["is_open"],
    opening: json["opening"],
    closing: json["closing"],
  );

  Map<String, dynamic> toJson() => {
    "day": day,
    "is_open": isOpen,
    "opening": opening,
    "closing": closing,
  };
}
