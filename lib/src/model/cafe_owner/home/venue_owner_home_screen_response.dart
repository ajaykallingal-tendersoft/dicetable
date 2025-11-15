// To parse this JSON data, do
//
//     final venueOwnerHomeScreenResponse = venueOwnerHomeScreenResponseFromJson(jsonString);

import 'dart:convert';

import 'package:soloseaters/src/model/cafe_owner/home/available_days.dart';

VenueOwnerHomeScreenResponse venueOwnerHomeScreenResponseFromJson(String str) => VenueOwnerHomeScreenResponse.fromJson(json.decode(str));

String venueOwnerHomeScreenResponseToJson(VenueOwnerHomeScreenResponse data) => json.encode(data.toJson());

class VenueOwnerHomeScreenResponse {
    final bool status;
    final List<DiceTable> diceTables;
    final bool subscriptionStatus;
    final String message;

    VenueOwnerHomeScreenResponse({
        required this.status,
        required this.diceTables,
        required this.subscriptionStatus,
        required this.message,
    });

    factory VenueOwnerHomeScreenResponse.fromJson(Map<String, dynamic> json) => VenueOwnerHomeScreenResponse(
        status: json["status"],
        diceTables: List<DiceTable>.from(json["dice_tables"].map((x) => DiceTable.fromJson(x))),
        subscriptionStatus: json["subscription_status"],
        message: json["message"],
    );

    Map<String, dynamic> toJson() => {
        "status": status,
        "dice_tables": List<dynamic>.from(diceTables.map((x) => x.toJson())),
        "subscription_status": subscriptionStatus,
        "message": message,
    };
}

class DiceTable {
    final int id;
    final String title;
    final String subTitle;
    final String description;
    final String iconImage;
    final String moreInfo;
    final List<AvailableDay> availableDays;
    final bool selected;
    final bool hasBookings;
   final List<Attendee> attendees;
   final bool? alwaysAvailable;

    DiceTable({
        required this.id,
        required this.title,
        required this.subTitle,
        required this.description,
        required this.iconImage,
        required this.moreInfo,
        required this.availableDays,
        required this.selected,
        required this.hasBookings,
        required this.attendees,
         this.alwaysAvailable,
        // required this.alwaysAvailable,
    });

    factory DiceTable.fromJson(Map<String, dynamic> json) => DiceTable(
        id: json["id"],
        title: json["title"],
        subTitle: json["sub_title"],
        description: json["description"],
        iconImage: json["icon_image"],
        moreInfo: json["more_info"],
        availableDays: List<AvailableDay>.from(json["available_days"].map((x) => AvailableDay.fromJson(x))),
        selected: json["selected"],
        hasBookings: json["has_bookings"],
       attendees: List<Attendee>.from(json["attendees"].map((x) => Attendee.fromJson(x))),
      alwaysAvailable: json['always_available'] as bool?,
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "title": title,
        "sub_title": subTitle,
        "description": description,
        "icon_image": iconImage,
        "more_info": moreInfo,
        "available_days": List<dynamic>.from(availableDays.map((x) => x.toJson())),
        "selected": selected,
        "has_bookings": hasBookings,
        "attendees": List<dynamic>.from(attendees.map((x) => x)),
        "alwaysAvailable": alwaysAvailable,
    };
}

class Attendee {
    final int? userId;
    final String? name;
    final String? email;
    final String? profilePhoto;
    final dynamic bookingDate;
    final dynamic bookingTime;
    final String? additionalInfo;
    final bool? isPaidUser;
    final List<String>? preferences;

    Attendee({
        this.userId,
        this.name,
        this.email,
        this.profilePhoto,
        this.bookingDate,
        this.bookingTime,
        this.additionalInfo,
        this.isPaidUser,
        this.preferences,
    });

    factory Attendee.fromJson(Map<String, dynamic> json) => Attendee(
        userId: json["user_id"],
        name: json["name"],
        email: json["email"],
        profilePhoto: json["profile_photo"],
        bookingDate: json["booking_date"],
        bookingTime: json["booking_time"],
        additionalInfo: json["additional_info"],
        isPaidUser: json["isPaidUser"],
         preferences: json["preferences"] != null
            ? List<String>.from(json["preferences"].map((x) => x.toString()))
            : [],
    );

    Map<String, dynamic> toJson() => {
        "user_id": userId,
        "name": name,
        "email": email,
        "profile_photo": profilePhoto,
        "booking_date": bookingDate,
        "booking_time": bookingTime,
        "additional_info": additionalInfo,
        "isPaidUser": isPaidUser,
         "preferences": preferences,
    };
}


