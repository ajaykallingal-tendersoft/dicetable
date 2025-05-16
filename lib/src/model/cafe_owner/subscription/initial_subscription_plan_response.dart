// To parse this JSON data, do
//
//     final initialSubscriptionPlanResponse = initialSubscriptionPlanResponseFromJson(jsonString);

import 'dart:convert';

InitialSubscriptionPlanResponse initialSubscriptionPlanResponseFromJson(String str) => InitialSubscriptionPlanResponse.fromJson(json.decode(str));

String initialSubscriptionPlanResponseToJson(InitialSubscriptionPlanResponse data) => json.encode(data.toJson());

class InitialSubscriptionPlanResponse {
  final bool? status;
  final Data? data;
  final String? message;

  InitialSubscriptionPlanResponse({
    this.status,
    this.data,
    this.message,
  });

  factory InitialSubscriptionPlanResponse.fromJson(Map<String, dynamic> json) => InitialSubscriptionPlanResponse(
    status: json["status"],
    data: json["data"] == null ? null : Data.fromJson(json["data"]),
    message: json["message"],
  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "data": data?.toJson(),
    "message": message,
  };
}

class Data {
  final int? cafeId;
  final int? subscriptionTypeId;
  final String? title;
  final String? amount;
  final String? type;
  final int? period;
  final int? isTrial;
  final int? trialDuration;
  final String? trialType;
  final int? paymentMethod;

  Data({
    this.cafeId,
    this.subscriptionTypeId,
    this.title,
    this.amount,
    this.type,
    this.period,
    this.isTrial,
    this.trialDuration,
    this.trialType,
    this.paymentMethod,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    cafeId: json["cafe_id"],
    subscriptionTypeId: json["subscription_type_id"],
    title: json["title"],
    amount: json["amount"],
    type: json["type"],
    period: json["period"],
    isTrial: json["is_trial"],
    trialDuration: json["trial_duration"],
    trialType: json["trial_type"],
    paymentMethod: json["payment_method"],
  );

  Map<String, dynamic> toJson() => {
    "cafe_id": cafeId,
    "subscription_type_id": subscriptionTypeId,
    "title": title,
    "amount": amount,
    "type": type,
    "period": period,
    "is_trial": isTrial,
    "trial_duration": trialDuration,
    "trial_type": trialType,
    "payment_method": paymentMethod,
  };
}
