// To parse this JSON data, do
//
//     final historyListResponse = historyListResponseFromJson(jsonString);

import 'dart:convert';

HistoryListResponse historyListResponseFromJson(String str) => HistoryListResponse.fromJson(json.decode(str));

String historyListResponseToJson(HistoryListResponse data) => json.encode(data.toJson());

class HistoryListResponse {
  final bool? status;
  final List<Datum>? data;
  final String? message;

  HistoryListResponse({
    this.status,
    this.data,
    this.message,
  });

  HistoryListResponse copyWith({
    bool? status,
    List<Datum>? data,
    String? message,
  }) =>
      HistoryListResponse(
        status: status ?? this.status,
        data: data ?? this.data,
        message: message ?? this.message,
      );

  factory HistoryListResponse.fromJson(Map<String, dynamic> json) => HistoryListResponse(
    status: json["status"],
    data: json["data"] == null ? [] : List<Datum>.from(json["data"]!.map((x) => Datum.fromJson(x))),
    message: json["message"],
  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "data": data == null ? [] : List<dynamic>.from(data!.map((x) => x.toJson())),
    "message": message,
  };
}

class Datum {
  final String? title;
  final String? description;
  final String? dateTime;
  final List<String>? diceTables;

  Datum({
    this.title,
    this.description,
    this.dateTime,
    this.diceTables,
  });

  Datum copyWith({
    String? title,
    String? description,
    String? dateTime,
    List<String>? diceTables,
  }) =>
      Datum(
        title: title ?? this.title,
        description: description ?? this.description,
        dateTime: dateTime ?? this.dateTime,
        diceTables: diceTables ?? this.diceTables,
      );

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
    title: json["title"],
    description: json["description"],
    dateTime: json["date_time"],
    diceTables: json["dice_tables"] == null ? [] : List<String>.from(json["dice_tables"]!.map((x) => x)),
  );

  Map<String, dynamic> toJson() => {
    "title": title,
    "description": description,
    "date_time": dateTime,
    "dice_tables": diceTables == null ? [] : List<dynamic>.from(diceTables!.map((x) => x)),
  };
}
