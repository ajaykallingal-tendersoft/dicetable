// To parse this JSON data, do
//
//     final favouriteListResponse = favouriteListResponseFromJson(jsonString);

import 'dart:convert';

FavouriteListResponse favouriteListResponseFromJson(String str) => FavouriteListResponse.fromJson(json.decode(str));

String favouriteListResponseToJson(FavouriteListResponse data) => json.encode(data.toJson());

class FavouriteListResponse {
  final bool? status;
  final List<FavCafe>? cafes;
  final String? message;

  FavouriteListResponse({
    this.status,
    this.cafes,
    this.message,
  });

  FavouriteListResponse copyWith({
    bool? status,
    List<FavCafe>? cafes,
    String? message,
  }) =>
      FavouriteListResponse(
        status: status ?? this.status,
        cafes: cafes ?? this.cafes,
        message: message ?? this.message,
      );

  factory FavouriteListResponse.fromJson(Map<String, dynamic> json) => FavouriteListResponse(
    status: json["status"],
    cafes: json["data"] == null ? [] : List<FavCafe>.from(json["data"]!.map((x) => FavCafe.fromJson(x))),
    message: json["message"],
  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "data": cafes == null ? [] : List<dynamic>.from(cafes!.map((x) => x.toJson())),
    "message": message,
  };
}

class FavCafe {
  final int? id;
  final String? name;
  final String? venueDescription;
  final List<String>? tableTypes;
  final String? photo;
  final bool? favourites;
  final bool? bookingStatus;
  final List<FavWorkingHour>? workingHours;

  FavCafe({
    this.id,
    this.name,
    this.venueDescription,
    this.tableTypes,
    this.photo,
    this.favourites,
    this.bookingStatus,
    this.workingHours,
  });

  FavCafe copyWith({
    int? id,
    String? name,
    String? venueDescription,
    List<String>? tableTypes,
    String? photo,
    bool? favourites,
    bool? bookingStatus,
    List<FavWorkingHour>? workingHours,
  }) =>
      FavCafe(
        id: id ?? this.id,
        name: name ?? this.name,
        venueDescription: venueDescription ?? this.venueDescription,
        tableTypes: tableTypes ?? this.tableTypes,
        photo: photo ?? this.photo,
        favourites: favourites ?? this.favourites,
        bookingStatus: bookingStatus ?? this.bookingStatus,
        workingHours: workingHours ?? this.workingHours,
      );

  factory FavCafe.fromJson(Map<String, dynamic> json) => FavCafe(
    id: json["id"],
    name: json["name"],
    venueDescription: json["venue_description"],
    tableTypes: json["table_types"] == null ? [] : List<String>.from(json["table_types"]!.map((x) => x)),
    photo: json["photo"],
    favourites: json["favourites"],
    bookingStatus: json["booking_status"],
    workingHours: json["working_hours"] == null ? [] : List<FavWorkingHour>.from(json["working_hours"]!.map((x) => FavWorkingHour.fromJson(x))),
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
  };
}

class FavWorkingHour {
  final String? day;
  final int? isOpen;
  final String? opening;
  final String? closing;

  FavWorkingHour({
    this.day,
    this.isOpen,
    this.opening,
    this.closing,
  });

  FavWorkingHour copyWith({
    String? day,
    int? isOpen,
    String? opening,
    String? closing,
  }) =>
      FavWorkingHour(
        day: day ?? this.day,
        isOpen: isOpen ?? this.isOpen,
        opening: opening ?? this.opening,
        closing: closing ?? this.closing,
      );

  factory FavWorkingHour.fromJson(Map<String, dynamic> json) => FavWorkingHour(
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
