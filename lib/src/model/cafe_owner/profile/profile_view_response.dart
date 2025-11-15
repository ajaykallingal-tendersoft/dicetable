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
    final bool? showEmail;
    final String? phone;
    final bool? showPhone;
    final String? address;
    final String? country;
    final String? countryName;
    final String? city;
    final String? postcode;
    final String? photo;
    final List<String>? gallery;
    final List<String>? galleryIds;
    final String? venueTypes;
    final OpeningHours? openingHours;
    final String? cafeSince;

    Data({
        this.id,
        this.name,
        this.venueDescription,
        this.email,
        this.showEmail,
        this.phone,
        this.showPhone,
        this.address,
        this.country,
        this.countryName,
        this.city,
        this.postcode,
        this.photo,
        this.gallery,
        this.galleryIds,
        this.venueTypes,
        this.openingHours,
        this.cafeSince,
    });

    factory Data.fromJson(Map<String, dynamic> json) => Data(
        id: json["id"],
        name: json["name"],
        venueDescription: json["venue_description"],
        email: json["email"],
        showEmail: json["show_email"],
        phone: json["phone"],
        showPhone: json["show_phone"],
        address: json["address"],
        country: json["country"],
        countryName: json["country_name"],
        city: json["city"],
        postcode: json["postcode"],
        photo: json["photo"],
        gallery: json["gallery"] == null ? [] : List<String>.from(json["gallery"]!.map((x) => x)),
        galleryIds: json["gallery_Ids"] == null ? [] : List<String>.from(json["gallery_Ids"]!.map((x) => x)),
        venueTypes: json["venue_types"],
        openingHours: json["opening_hours"] == null ? null : OpeningHours.fromJson(json["opening_hours"]),
        cafeSince: json["cafe_since"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "venue_description": venueDescription,
        "email": email,
        "show_email": showEmail,
        "phone": phone,
        "show_phone": showPhone,
        "address": address,
        "country": country,
        "country_name": countryName,
        "city": city,
        "postcode": postcode,
        "photo": photo,
        "gallery": gallery == null ? [] : List<dynamic>.from(gallery!.map((x) => x)),
        "gallery_Ids": galleryIds == null ? [] : List<dynamic>.from(galleryIds!.map((x) => x)),
        "venue_types": venueTypes,
        "opening_hours": openingHours?.toJson(),
        "cafe_since": cafeSince,
    };
}

class OpeningHours {
    final Day? mon;
    final Day? tue;
    final Day? wed;
    final Day? thu;
    final Day? fri;
    final Day? sat;
    final Day? sun;

    OpeningHours({
        this.mon,
        this.tue,
        this.wed,
        this.thu,
        this.fri,
        this.sat,
        this.sun,
    });

    factory OpeningHours.fromJson(Map<String, dynamic> json) => OpeningHours(
        mon: json["mon"] == null ? null : Day.fromJson(json["mon"]),
        tue: json["tue"] == null ? null : Day.fromJson(json["tue"]),
        wed: json["wed"] == null ? null : Day.fromJson(json["wed"]),
        thu: json["thu"] == null ? null : Day.fromJson(json["thu"]),
        fri: json["fri"] == null ? null : Day.fromJson(json["fri"]),
        sat: json["sat"] == null ? null : Day.fromJson(json["sat"]),
        sun: json["sun"] == null ? null : Day.fromJson(json["sun"]),
    );

    Map<String, dynamic> toJson() => {
        "mon": mon?.toJson(),
        "tue": tue?.toJson(),
        "wed": wed?.toJson(),
        "thu": thu?.toJson(),
        "fri": fri?.toJson(),
        "sat": sat?.toJson(),
        "sun": sun?.toJson(),
    };
}

class Day {
    final int? id;
    final bool? isOpen;
    final String? open;
    final String? close;

    Day({
        this.id,
        this.isOpen,
        this.open,
        this.close,
    });

    factory Day.fromJson(Map<String, dynamic> json) => Day(
        id: json["id"],
        isOpen: json["is_open"],
        open: json["open"],
        close: json["close"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "is_open": isOpen,
        "open": open,
        "close": close,
    };
}
