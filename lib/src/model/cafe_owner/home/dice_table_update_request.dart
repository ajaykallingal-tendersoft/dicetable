// To parse this JSON data, do
//
//     final diceTableTypeUpdateRequest = diceTableTypeUpdateRequestFromJson(jsonString);

import 'package:meta/meta.dart';
import 'dart:convert';

import 'available_days.dart';

DiceTableTypeUpdateRequest diceTableTypeUpdateRequestFromJson(String str) => DiceTableTypeUpdateRequest.fromJson(json.decode(str));

String diceTableTypeUpdateRequestToJson(DiceTableTypeUpdateRequest data) => json.encode(data.toJson());

class DiceTableTypeUpdateRequest {
  final int cafeId;
  final List<int> diceTableId;
  final List<String> moreInfo;
  final List<AvailableDay> availableDays;

  DiceTableTypeUpdateRequest({
    required this.cafeId,
    required this.diceTableId,
    required this.moreInfo,
    required this.availableDays,
  });

  factory DiceTableTypeUpdateRequest.fromJson(Map<String, dynamic> json) => DiceTableTypeUpdateRequest(
    cafeId: json["cafe_id"],
    diceTableId: List<int>.from(json["dice_table_id"].map((x) => x)),
    moreInfo: List<String>.from(json["more_info"].map((x) => x)),
    availableDays: List<AvailableDay>.from(json["available_days"].map((x) => AvailableDay.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "cafe_id": cafeId,
    "dice_table_id": List<dynamic>.from(diceTableId.map((x) => x)),
    "more_info": List<dynamic>.from(moreInfo.map((x) => x)),
    "available_days": List<dynamic>.from(availableDays.map((x) => x.toJson())),
  };
}


