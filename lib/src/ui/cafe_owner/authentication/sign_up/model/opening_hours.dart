import 'package:flutter/material.dart';

class OpeningHours {
  final String day;
  final TimeOfDay from;
  final TimeOfDay to;
  final bool isEnabled;

  OpeningHours({
    required this.day,
    required this.from,
    required this.to,
    required this.isEnabled,
  });

  Map<String, dynamic> toJson() => {
    "day": day,
    "from": '${from.hour.toString().padLeft(2, '0')}:${from.minute.toString().padLeft(2, '0')}',
    "to": '${to.hour.toString().padLeft(2, '0')}:${to.minute.toString().padLeft(2, '0')}',
    "is_enabled": isEnabled,
  };
}