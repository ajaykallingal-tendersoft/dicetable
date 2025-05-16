// To parse this JSON data, do
//
//     final subscriptionStartRequest = subscriptionStartRequestFromJson(jsonString);

import 'package:meta/meta.dart';
import 'dart:convert';

SubscriptionStartRequest subscriptionStartRequestFromJson(String str) => SubscriptionStartRequest.fromJson(json.decode(str));

String subscriptionStartRequestToJson(SubscriptionStartRequest data) => json.encode(data.toJson());

class SubscriptionStartRequest {
  final int cafeId;
  final int subscriptionTypeId;
  final int paymentMethod;
  final double amount;
  final bool autoRenew;

  SubscriptionStartRequest({
    required this.cafeId,
    required this.subscriptionTypeId,
    required this.paymentMethod,
    required this.amount,
    required this.autoRenew,
  });

  factory SubscriptionStartRequest.fromJson(Map<String, dynamic> json) => SubscriptionStartRequest(
    cafeId: json["cafe_id"],
    subscriptionTypeId: json["subscription_type_id"],
    paymentMethod: json["payment_method"],
    amount: json["amount"].toDouble(),
    autoRenew: json["auto_renew"],
  );

  Map<String, dynamic> toJson() => {
    "cafe_id": cafeId,
    "subscription_type_id": subscriptionTypeId,
    "payment_method": paymentMethod,
    "amount": amount,
    "auto_renew": autoRenew,
  };
}
