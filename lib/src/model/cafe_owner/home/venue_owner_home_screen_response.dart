
// To parse this JSON data, do
//
//     final venueOwnerHomeScreenResponse = venueOwnerHomeScreenResponseFromJson(jsonString);

import 'dart:convert';

import 'available_days.dart';

VenueOwnerHomeScreenResponse venueOwnerHomeScreenResponseFromJson(String str) => VenueOwnerHomeScreenResponse.fromJson(json.decode(str));

String venueOwnerHomeScreenResponseToJson(VenueOwnerHomeScreenResponse data) => json.encode(data.toJson());

class VenueOwnerHomeScreenResponse {
  final bool? status;
  final List<DiceTable>? diceTables;
  final String? message;

  VenueOwnerHomeScreenResponse({
    this.status,
    this.diceTables,
    this.message,
  });

  factory VenueOwnerHomeScreenResponse.fromJson(Map<String, dynamic> json) => VenueOwnerHomeScreenResponse(
    status: json["status"],
    diceTables: json["dice_tables"] == null ? [] : List<DiceTable>.from(json["dice_tables"]!.map((x) => DiceTable.fromJson(x))),
    message: json["message"],
  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "dice_tables": diceTables == null ? [] : List<dynamic>.from(diceTables!.map((x) => x.toJson())),
    "message": message,
  };
}

class DiceTable {
  final int? id;
  final String? title;
  final String? subTitle;
  final String? description;
  final String? iconImage;
  final String? moreInfo;
  final List<AvailableDay>? availableDays;
  final bool? selected;

  DiceTable({
    this.id,
    this.title,
    this.subTitle,
    this.description,
    this.iconImage,
    this.moreInfo,
    this.availableDays,
    this.selected,
  });

  factory DiceTable.fromJson(Map<String, dynamic> json) => DiceTable(
    id: json["id"],
    title: json["title"],
    subTitle: json["sub_title"],
    description: json["description"],
    iconImage: json["icon_image"],
    moreInfo: json["more_info"],
    availableDays: json["available_days"] == null ? [] : List<AvailableDay>.from(json["available_days"]!.map((x) => AvailableDay.fromJson(x))),
    selected: json["selected"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "title": title,
    "sub_title": subTitle,
    "description": description,
    "icon_image": iconImage,
    "more_info": moreInfo,
    "available_days": availableDays == null ? [] : List<dynamic>.from(availableDays!.map((x) => x.toJson())),
    "selected": selected,
  };
}


