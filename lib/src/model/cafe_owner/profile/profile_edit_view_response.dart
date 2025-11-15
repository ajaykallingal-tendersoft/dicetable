// To parse this JSON data, do
//
//     final profileEditViewResponse = profileEditViewResponseFromJson(jsonString);

import 'dart:convert';

ProfileEditViewResponse profileEditViewResponseFromJson(String str) => ProfileEditViewResponse.fromJson(json.decode(str));

String profileEditViewResponseToJson(ProfileEditViewResponse data) => json.encode(data.toJson());

class ProfileEditViewResponse {
    final bool? status;
    final Data? data;

    ProfileEditViewResponse({
        this.status,
        this.data,
    });

    ProfileEditViewResponse copyWith({
        bool? status,
        Data? data,
    }) => 
        ProfileEditViewResponse(
            status: status ?? this.status,
            data: data ?? this.data,
        );

    factory ProfileEditViewResponse.fromJson(Map<String, dynamic> json) => ProfileEditViewResponse(
        status: json["status"],
        data: json["data"] == null ? null : Data.fromJson(json["data"]),
    );

    Map<String, dynamic> toJson() => {
        "status": status,
        "data": data?.toJson(),
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
    final List<VenueType>? venueType;
    final List<int>? venueTypeIds;
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
        this.venueType,
        this.venueTypeIds,
        this.openingHours,
        this.cafeSince,
    });

    Data copyWith({
        int? id,
        String? name,
        String? venueDescription,
        String? email,
        bool? showEmail,
        String? phone,
        bool? showPhone,
        String? address,
        String? country,
        String? countryName,
        String? city,
        String? postcode,
        String? photo,
        List<String>? gallery,
        List<String>? galleryIds,
        List<VenueType>? venueType,
        List<int>? venueTypeIds,
        OpeningHours? openingHours,
        String? cafeSince,
    }) => 
        Data(
            id: id ?? this.id,
            name: name ?? this.name,
            venueDescription: venueDescription ?? this.venueDescription,
            email: email ?? this.email,
            showEmail: showEmail ?? this.showEmail,
            phone: phone ?? this.phone,
            showPhone: showPhone ?? this.showPhone,
            address: address ?? this.address,
            country: country ?? this.country,
            countryName: countryName ?? this.countryName,
            city: city ?? this.city,
            postcode: postcode ?? this.postcode,
            photo: photo ?? this.photo,
            gallery: gallery ?? this.gallery,
            galleryIds: galleryIds ?? this.galleryIds,
            venueType: venueType ?? this.venueType,
            venueTypeIds: venueTypeIds ?? this.venueTypeIds,
            openingHours: openingHours ?? this.openingHours,
            cafeSince: cafeSince ?? this.cafeSince,
        );

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
        venueType: json["venue_type"] == null ? [] : List<VenueType>.from(json["venue_type"]!.map((x) => VenueType.fromJson(x))),
        venueTypeIds: json["venue_type_ids"] == null ? [] : List<int>.from(json["venue_type_ids"]!.map((x) => x)),
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
        "venue_type": venueType == null ? [] : List<dynamic>.from(venueType!.map((x) => x.toJson())),
        "venue_type_ids": venueTypeIds == null ? [] : List<dynamic>.from(venueTypeIds!.map((x) => x)),
        "opening_hours": openingHours?.toJson(),
        "cafe_since": cafeSince,
    };
}

class OpeningHours {
    final OpeningHourDay? mon;
    final OpeningHourDay? tue;
    final OpeningHourDay? wed;
    final OpeningHourDay? thu;
    final OpeningHourDay? fri;
    final OpeningHourDay? sat;
    final OpeningHourDay? sun;

    OpeningHours({
        this.mon,
        this.tue,
        this.wed,
        this.thu,
        this.fri,
        this.sat,
        this.sun,
    });

    OpeningHours copyWith({
        OpeningHourDay? mon,
        OpeningHourDay? tue,
        OpeningHourDay? wed,
        OpeningHourDay? thu,
        OpeningHourDay? fri,
        OpeningHourDay? sat,
        OpeningHourDay? sun,
    }) => 
        OpeningHours(
            mon: mon ?? this.mon,
            tue: tue ?? this.tue,
            wed: wed ?? this.wed,
            thu: thu ?? this.thu,
            fri: fri ?? this.fri,
            sat: sat ?? this.sat,
            sun: sun ?? this.sun,
        );

    factory OpeningHours.fromJson(Map<String, dynamic> json) => OpeningHours(
        mon: json["mon"] == null ? null : OpeningHourDay.fromJson(json["mon"]),
        tue: json["tue"] == null ? null : OpeningHourDay.fromJson(json["tue"]),
        wed: json["wed"] == null ? null : OpeningHourDay.fromJson(json["wed"]),
        thu: json["thu"] == null ? null : OpeningHourDay.fromJson(json["thu"]),
        fri: json["fri"] == null ? null : OpeningHourDay.fromJson(json["fri"]),
        sat: json["sat"] == null ? null : OpeningHourDay.fromJson(json["sat"]),
        sun: json["sun"] == null ? null : OpeningHourDay.fromJson(json["sun"]),
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

class OpeningHourDay {
    final int? id;
    final bool? isOpen;
    final String? open;
    final String? close;

    OpeningHourDay({
        this.id,
        this.isOpen,
        this.open,
        this.close,
    });

    OpeningHourDay copyWith({
        int? id,
        bool? isOpen,
        String? open,
        String? close,
    }) => 
        OpeningHourDay(
            id: id ?? this.id,
            isOpen: isOpen ?? this.isOpen,
            open: open ?? this.open,
            close: close ?? this.close,
        );

    factory OpeningHourDay.fromJson(Map<String, dynamic> json) => OpeningHourDay(
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

class VenueType {
    final int? id;
    final String? title;
    final bool? status;

    VenueType({
        this.id,
        this.title,
        this.status,
    });

    VenueType copyWith({
        int? id,
        String? title,
        bool? status,
    }) => 
        VenueType(
            id: id ?? this.id,
            title: title ?? this.title,
            status: status ?? this.status,
        );

    factory VenueType.fromJson(Map<String, dynamic> json) => VenueType(
        id: json["id"],
        title: json["title"],
        status: json["status"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "title": title,
        "status": status,
    };
}
