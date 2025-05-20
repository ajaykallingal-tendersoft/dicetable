// To parse this JSON data, do
//
//     final subscriptionOverviewResponse = subscriptionOverviewResponseFromJson(jsonString);

import 'dart:convert';

SubscriptionOverviewResponse subscriptionOverviewResponseFromJson(String str) => SubscriptionOverviewResponse.fromJson(json.decode(str));

String subscriptionOverviewResponseToJson(SubscriptionOverviewResponse data) => json.encode(data.toJson());

class SubscriptionOverviewResponse {
  final bool? status;
  final Data? data;

  SubscriptionOverviewResponse({
    this.status,
    this.data,
  });

  factory SubscriptionOverviewResponse.fromJson(Map<String, dynamic> json) => SubscriptionOverviewResponse(
    status: json["status"],
    data: json["data"] == null ? null : Data.fromJson(json["data"]),
  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "data": data?.toJson(),
  };
}

class Data {
  final SubsriptionOverview? subsriptionOverview;
  final List<PaymentHistory>? paymentHistory;
  final List<String>? paymentMethods;

  Data({
    this.subsriptionOverview,
    this.paymentHistory,
    this.paymentMethods,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    subsriptionOverview: json["subsription_overview"] == null ? null : SubsriptionOverview.fromJson(json["subsription_overview"]),
    paymentHistory: json["payment_history"] == null ? [] : List<PaymentHistory>.from(json["payment_history"]!.map((x) => PaymentHistory.fromJson(x))),
    paymentMethods: json["payment_methods"] == null ? [] : List<String>.from(json["payment_methods"]!.map((x) => x)),
  );

  Map<String, dynamic> toJson() => {
    "subsription_overview": subsriptionOverview?.toJson(),
    "payment_history": paymentHistory == null ? [] : List<dynamic>.from(paymentHistory!.map((x) => x.toJson())),
    "payment_methods": paymentMethods == null ? [] : List<dynamic>.from(paymentMethods!.map((x) => x)),
  };
}

class PaymentHistory {
  final String? date;
  final String? period;
  final String? status;
  final String? amount;

  PaymentHistory({
    this.date,
    this.period,
    this.status,
    this.amount,
  });

  factory PaymentHistory.fromJson(Map<String, dynamic> json) => PaymentHistory(
    date: json["date"],
    period: json["period"],
    status: json["status"],
    amount: json["amount"],
  );

  Map<String, dynamic> toJson() => {
    "date": date,
    "period": period,
    "status": status,
    "amount": amount,
  };
}

class SubsriptionOverview {
  final String? status;
  final String? planName;
  final int? amount;
  final String? duration;
  final String? expiryDate;
  final String? discountCode;
  final bool? autoRenewal;

  SubsriptionOverview({
    this.status,
    this.planName,
    this.amount,
    this.duration,
    this.expiryDate,
    this.discountCode,
    this.autoRenewal,
  });

  factory SubsriptionOverview.fromJson(Map<String, dynamic> json) => SubsriptionOverview(
    status: json["status"],
    planName: json["plan_name"],
    amount: json["amount"],
    duration: json["duration"],
    expiryDate: json["expiry_date"],
    discountCode: json["discount_code"],
    autoRenewal: json["auto_renewal"],
  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "plan_name": planName,
    "amount": amount,
    "duration": duration,
    "expiry_date": expiryDate,
    "discount_code": discountCode,
    "auto_renewal": autoRenewal,
  };
}
