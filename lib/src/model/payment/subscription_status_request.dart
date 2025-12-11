import 'dart:convert';

SubscriptionStatusRequest subscriptionStatusRequestFromJson(String str) => SubscriptionStatusRequest.fromJson(json.decode(str));

String subscriptionStatusRequestToJson(SubscriptionStatusRequest data) => json.encode(data.toJson());

class SubscriptionStatusRequest {
  final String purchaseToken;
  final String productId;
  final String platform;

  SubscriptionStatusRequest({
    required this.purchaseToken,
    required this.productId,
    required this.platform,
  });

  factory SubscriptionStatusRequest.fromJson(Map<String, dynamic> json) => SubscriptionStatusRequest(
    purchaseToken: json["purchase_token"],
    productId: json["product_id"],
    platform: json["platform"],
  );

  Map<String, dynamic> toJson() => {
    "purchase_token": purchaseToken,
    "product_id": productId,
    "platform": platform,
  };
}