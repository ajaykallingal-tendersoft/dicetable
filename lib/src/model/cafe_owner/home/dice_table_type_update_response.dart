// To parse this JSON data, do
//
//     final diceTableTypeUpdateResponse = diceTableTypeUpdateResponseFromJson(jsonString);

import 'dart:convert';

import 'available_days.dart';

DiceTableTypeUpdateResponse diceTableTypeUpdateResponseFromJson(String str) => DiceTableTypeUpdateResponse.fromJson(json.decode(str));

String diceTableTypeUpdateResponseToJson(DiceTableTypeUpdateResponse data) => json.encode(data.toJson());

class DiceTableTypeUpdateResponse {
  final bool? status;
  final String? message;
  final List<Datum>? data;

  DiceTableTypeUpdateResponse({
    this.status,
    this.message,
    this.data,
  });

  factory DiceTableTypeUpdateResponse.fromJson(Map<String, dynamic> json) => DiceTableTypeUpdateResponse(
    status: json["status"],
    message: json["message"],
    data: json["data"] == null ? [] : List<Datum>.from(json["data"]!.map((x) => Datum.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "message": message,
    "data": data == null ? [] : List<dynamic>.from(data!.map((x) => x.toJson())),
  };
}

class Datum {
  final int? cafeId;
  final int? diceTableId;
  final String? moreInfo;
  final List<AvailableDay>? availableDays;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Datum({
    this.cafeId,
    this.diceTableId,
    this.moreInfo,
    this.availableDays,
    this.createdAt,
    this.updatedAt,
  });

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
    cafeId: json["cafe_id"],
    diceTableId: json["dice_table_id"],
    moreInfo: json["more_info"],
    availableDays: json["available_days"] == null ? [] : List<AvailableDay>.from(json["available_days"]!.map((x) => AvailableDay.fromJson(x))),
    createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
    updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
  );

  Map<String, dynamic> toJson() => {
    "cafe_id": cafeId,
    "dice_table_id": diceTableId,
    "more_info": moreInfo,
    "available_days": availableDays == null ? [] : List<dynamic>.from(availableDays!.map((x) => x.toJson())),
    "created_at": createdAt?.toIso8601String(),
    "updated_at": updatedAt?.toIso8601String(),
  };
}

