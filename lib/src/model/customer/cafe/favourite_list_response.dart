// To parse this JSON data, do
//
//     final favouriteListResponse = favouriteListResponseFromJson(jsonString);

import 'dart:convert';

FavouriteListResponse favouriteListResponseFromJson(String str) =>
    FavouriteListResponse.fromJson(json.decode(str));

String favouriteListResponseToJson(FavouriteListResponse data) =>
    json.encode(data.toJson());

class FavouriteListResponse {
  final bool? status;
  final List<FavCafe>? cafes;
  final String? message;

  FavouriteListResponse({this.status, this.cafes, this.message});

  FavouriteListResponse copyWith({
    bool? status,
    List<FavCafe>? cafes,
    String? message,
  }) => FavouriteListResponse(
    status: status ?? this.status,
    cafes: cafes ?? this.cafes,
    message: message ?? this.message,
  );

  factory FavouriteListResponse.fromJson(Map<String, dynamic> json) =>
      FavouriteListResponse(
        status: json["status"],
        cafes:
            json["data"] == null
                ? []
                : List<FavCafe>.from(
                  json["data"]!.map((x) => FavCafe.fromJson(x)),
                ),
        message: json["message"],
      );

  Map<String, dynamic> toJson() => {
    "status": status,
    "data":
        cafes == null ? [] : List<dynamic>.from(cafes!.map((x) => x.toJson())),
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
  final List<FavAttende>? attendes;
  final List<FavUpcomingEvent>? upcomingEvents;
  final List<String>? gallery;

  FavCafe({
    this.id,
    this.name,
    this.venueDescription,
    this.tableTypes,
    this.photo,
    this.favourites,
    this.bookingStatus,
    this.workingHours,
    this.attendes,
    this.upcomingEvents,
    this.gallery,
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
    List<FavAttende>? attendes,
    List<FavUpcomingEvent>? upcomingEvents,
    List<String>? gallery,
  }) => FavCafe(
    id: id ?? this.id,
    name: name ?? this.name,
    venueDescription: venueDescription ?? this.venueDescription,
    tableTypes: tableTypes ?? this.tableTypes,
    photo: photo ?? this.photo,
    favourites: favourites ?? this.favourites,
    bookingStatus: bookingStatus ?? this.bookingStatus,
    workingHours: workingHours ?? this.workingHours,
    attendes: attendes ?? this.attendes,
    upcomingEvents: upcomingEvents ?? this.upcomingEvents,
    gallery: gallery ?? this.gallery,
  );

  factory FavCafe.fromJson(Map<String, dynamic> json) => FavCafe(
    id: json["id"],
    name: json["name"],
    venueDescription: json["venue_description"],
    tableTypes:
        json["table_types"] == null
            ? []
            : List<String>.from(json["table_types"]!.map((x) => x)),
    photo: json["photo"],
    favourites: json["favourites"],
    bookingStatus: json["booking_status"],
    workingHours:
        json["working_hours"] == null
            ? []
            : List<FavWorkingHour>.from(
              json["working_hours"]!.map((x) => FavWorkingHour.fromJson(x)),
            ),
    attendes:
        json["attendes"] == null
            ? []
            : List<FavAttende>.from(
              json["attendes"]!.map((x) => FavAttende.fromJson(x)),
            ),
    upcomingEvents:
        json["upcoming_events"] == null
            ? []
            : List<FavUpcomingEvent>.from(
              json["upcoming_events"]!.map((x) => FavUpcomingEvent.fromJson(x)),
            ),
    gallery:
        json["gallery"] == null
            ? []
            : List<String>.from(json["gallery"]!.map((x) => x)),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "venue_description": venueDescription,
    "table_types":
        tableTypes == null ? [] : List<dynamic>.from(tableTypes!.map((x) => x)),
    "photo": photo,
    "favourites": favourites,
    "booking_status": bookingStatus,
    "working_hours":
        workingHours == null
            ? []
            : List<dynamic>.from(workingHours!.map((x) => x.toJson())),
    "attendes":
        attendes == null
            ? []
            : List<dynamic>.from(attendes!.map((x) => x.toJson())),
    "upcoming_events":
        upcomingEvents == null
            ? []
            : List<dynamic>.from(upcomingEvents!.map((x) => x.toJson())),
    "gallery":
        gallery == null ? [] : List<dynamic>.from(gallery!.map((x) => x)),
  };
}

class FavAttende {
  final String? name;
  final String? email;
  final dynamic profilePhoto;
  final dynamic additionalInfo;

  FavAttende({this.name, this.email, this.profilePhoto, this.additionalInfo});

  FavAttende copyWith({
    String? name,
    String? email,
    dynamic profilePhoto,
    dynamic additionalInfo,
  }) => FavAttende(
    name: name ?? this.name,
    email: email ?? this.email,
    profilePhoto: profilePhoto ?? this.profilePhoto,
    additionalInfo: additionalInfo ?? this.additionalInfo,
  );

  factory FavAttende.fromJson(Map<String, dynamic> json) => FavAttende(
    name: json["name"],
    email: json["email"],
    profilePhoto: json["profile_photo"],
    additionalInfo: json["additional_info"],
  );

  Map<String, dynamic> toJson() => {
    "name": name,
    "email": email,
    "profile_photo": profilePhoto,
    "additional_info": additionalInfo,
  };
}

class FavUpcomingEvent {
  final int? id;
  final String? name;
  final String? description;
  final List<dynamic>? availableDays;

  FavUpcomingEvent({this.id, this.name, this.description, this.availableDays});

  FavUpcomingEvent copyWith({
    int? id,
    String? name,
    String? description,
    List<dynamic>? availableDays,
  }) => FavUpcomingEvent(
    id: id ?? this.id,
    name: name ?? this.name,
    description: description ?? this.description,
    availableDays: availableDays ?? this.availableDays,
  );

  factory FavUpcomingEvent.fromJson(Map<String, dynamic> json) =>
      FavUpcomingEvent(
        id: json["id"],
        name: json["name"],
        description: json["description"],
        availableDays:
            json["available_days"] == null
                ? []
                : List<dynamic>.from(json["available_days"]!.map((x) => x)),
      );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "description": description,
    "available_days":
        availableDays == null
            ? []
            : List<dynamic>.from(availableDays!.map((x) => x)),
  };
}

class FavWorkingHour {
  final String? day;
  final int? isOpen;
  final String? opening;
  final String? closing;

  FavWorkingHour({this.day, this.isOpen, this.opening, this.closing});

  FavWorkingHour copyWith({
    String? day,
    int? isOpen,
    String? opening,
    String? closing,
  }) => FavWorkingHour(
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
