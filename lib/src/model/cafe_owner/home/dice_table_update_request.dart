import 'dart:convert';
import 'available_days.dart';

DiceTableTypeUpdateRequest diceTableTypeUpdateRequestFromJson(String str) =>
    DiceTableTypeUpdateRequest.fromJson(json.decode(str));

String diceTableTypeUpdateRequestToJson(DiceTableTypeUpdateRequest data) =>
    json.encode(data.toJson());

class DiceTableTypeUpdateRequest {
  final int cafeId;
  final List<int>? diceTableId;
  final List<String>? moreInfo;
  final List<AvailableDay>? availableDays;
   final bool alwaysAvailable; 

  DiceTableTypeUpdateRequest({
    required this.cafeId,
    this.diceTableId,
    this.moreInfo,
    this.availableDays,
    required this.alwaysAvailable,
  });

  factory DiceTableTypeUpdateRequest.fromJson(Map<String, dynamic> json) =>
      DiceTableTypeUpdateRequest(
        cafeId: json["cafe_id"],
        diceTableId: (json["dice_table_id"] as List?)?.map((x) => x as int).toList(),
        moreInfo: (json["more_info"] as List?)?.map((x) => x as String).toList(),
        availableDays: (json["available_days"] as List?)
            ?.map((x) => AvailableDay.fromJson(x))
            .toList(),
          alwaysAvailable: json["always_available"]
      );

  Map<String, dynamic> toJson() => {
        "cafe_id": cafeId,
        // ✅ Safely handle null lists — no more null crashes
        "dice_table_id": (diceTableId ?? []).map((x) => x).toList(),
        "more_info": (moreInfo ?? []).map((x) => x).toList(),
        "available_days":
            (availableDays ?? []).map((x) => x.toJson()).toList(),
            'always_available': alwaysAvailable,
      };
}
