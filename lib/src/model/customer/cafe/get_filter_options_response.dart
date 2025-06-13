// To parse this JSON data, do
//
//     final getFilterOptionsResponse = getFilterOptionsResponseFromJson(jsonString);

import 'dart:convert';

GetFilterOptionsResponse getFilterOptionsResponseFromJson(String str) => GetFilterOptionsResponse.fromJson(json.decode(str));

String getFilterOptionsResponseToJson(GetFilterOptionsResponse data) => json.encode(data.toJson());

class GetFilterOptionsResponse {
  final bool? status;
  final List<DiceTable>? diceTables;
  final List<DiceTable>? venueTypes;
  final String? message;

  GetFilterOptionsResponse({
    this.status,
    this.diceTables,
    this.venueTypes,
    this.message,
  });

  GetFilterOptionsResponse copyWith({
    bool? status,
    List<DiceTable>? diceTables,
    List<DiceTable>? venueTypes,
    String? message,
  }) =>
      GetFilterOptionsResponse(
        status: status ?? this.status,
        diceTables: diceTables ?? this.diceTables,
        venueTypes: venueTypes ?? this.venueTypes,
        message: message ?? this.message,
      );

  factory GetFilterOptionsResponse.fromJson(Map<String, dynamic> json) => GetFilterOptionsResponse(
    status: json["status"],
    diceTables: json["dice_tables"] == null ? [] : List<DiceTable>.from(json["dice_tables"]!.map((x) => DiceTable.fromJson(x))),
    venueTypes: json["venue_types"] == null ? [] : List<DiceTable>.from(json["venue_types"]!.map((x) => DiceTable.fromJson(x))),
    message: json["message"],
  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "dice_tables": diceTables == null ? [] : List<dynamic>.from(diceTables!.map((x) => x.toJson())),
    "venue_types": venueTypes == null ? [] : List<dynamic>.from(venueTypes!.map((x) => x.toJson())),
    "message": message,
  };
}

class DiceTable {
  final int? id;
  final String? title;

  DiceTable({
    this.id,
    this.title,
  });

  DiceTable copyWith({
    int? id,
    String? title,
  }) =>
      DiceTable(
        id: id ?? this.id,
        title: title ?? this.title,
      );

  factory DiceTable.fromJson(Map<String, dynamic> json) => DiceTable(
    id: json["id"],
    title: json["title"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "title": title,
  };
}
