// To parse this JSON data, do
//
//     final profileViewResponse = profileViewResponseFromJson(jsonString);

import 'dart:convert';

ProfileViewResponse profileViewResponseFromJson(String str) => ProfileViewResponse.fromJson(json.decode(str));

String profileViewResponseToJson(ProfileViewResponse data) => json.encode(data.toJson());

class ProfileViewResponse {
  final bool? status;
  final Data? data;
  final String? message;

  ProfileViewResponse({
    this.status,
    this.data,
    this.message,
  });

  ProfileViewResponse copyWith({
    bool? status,
    Data? data,
    String? message,
  }) =>
      ProfileViewResponse(
        status: status ?? this.status,
        data: data ?? this.data,
        message: message ?? this.message,
      );

  factory ProfileViewResponse.fromJson(Map<String, dynamic> json) => ProfileViewResponse(
    status: json["status"],
    data: json["data"] == null ? null : Data.fromJson(json["data"]),
    message: json["message"],
  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "data": data?.toJson(),
    "message": message,
  };
}

class Data {
  final int? id;
  final String? name;
  final String? venueDescription;
  final String? email;
  final String? phone;
  final String? address;
  final String? city;
  final String? postcode;
  final String? photo;
  final String? venueType;
  final List<OpeningHour>? openingHours;

  Data({
    this.id,
    this.name,
    this.venueDescription,
    this.email,
    this.phone,
    this.address,
    this.city,
    this.postcode,
    this.photo,
    this.venueType,
    this.openingHours,
  });

  Data copyWith({
    int? id,
    String? name,
    String? venueDescription,
    String? email,
    String? phone,
    String? address,
    String? city,
    String? postcode,
    String? photo,
    String? venueType,
    List<OpeningHour>? openingHours,
  }) =>
      Data(
        id: id ?? this.id,
        name: name ?? this.name,
        venueDescription: venueDescription ?? this.venueDescription,
        email: email ?? this.email,
        phone: phone ?? this.phone,
        address: address ?? this.address,
        city: city ?? this.city,
        postcode: postcode ?? this.postcode,
        photo: photo ?? this.photo,
        venueType: venueType ?? this.venueType,
        openingHours: openingHours ?? this.openingHours,
      );

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    id: json["id"],
    name: json["name"],
    venueDescription: json["venue_description"],
    email: json["email"],
    phone: json["phone"],
    address: json["address"],
    city: json["city"],
    postcode: json["postcode"],
    photo: json["photo"],
    venueType: json["venue_type"],
    openingHours: json["opening_hours"] == null ? [] : List<OpeningHour>.from(json["opening_hours"]!.map((x) => OpeningHour.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "venue_description": venueDescription,
    "email": email,
    "phone": phone,
    "address": address,
    "city": city,
    "postcode": postcode,
    "photo": photo,
    "venue_type": venueType,
    "opening_hours": openingHours == null ? [] : List<dynamic>.from(openingHours!.map((x) => x.toJson())),
  };
}

class OpeningHour {
  final int? id;
  final String? day;
  final bool? isOpen;
  final String? opening;
  final String? closing;

  OpeningHour({
    this.id,
    this.day,
    this.isOpen,
    this.opening,
    this.closing,
  });

  OpeningHour copyWith({
    int? id,
    String? day,
    bool? isOpen,
    String? opening,
    String? closing,
  }) =>
      OpeningHour(
        id: id ?? this.id,
        day: day ?? this.day,
        isOpen: isOpen ?? this.isOpen,
        opening: opening ?? this.opening,
        closing: closing ?? this.closing,
      );

  factory OpeningHour.fromJson(Map<String, dynamic> json) => OpeningHour(
    id: json["id"],
    day: json["day"],
    isOpen: json["is_open"],
    opening: json["opening"],
    closing: json["closing"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "day": day,
    "is_open": isOpen,
    "opening": opening,
    "closing": closing,
  };
}
