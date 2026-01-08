// To parse this JSON data, do
//
//     final subscriptionStatusResponse = subscriptionStatusResponseFromJson(jsonString);

import 'dart:convert';

SubscriptionStatusResponse subscriptionStatusResponseFromJson(String str) =>
    SubscriptionStatusResponse.fromJson(json.decode(str));

String subscriptionStatusResponseToJson(SubscriptionStatusResponse data) =>
    json.encode(data.toJson());

class SubscriptionStatusResponse {
  final bool? success;
  final String? message;
  final VerificationData? verificationData;

  SubscriptionStatusResponse({
    this.success,
    this.message,
    this.verificationData,
  });

  factory SubscriptionStatusResponse.fromJson(Map<String, dynamic> json) =>
      SubscriptionStatusResponse(
        success: json["success"],
        message: json["message"],
        verificationData:
            json["verification_data"] == null
                ? null
                : VerificationData.fromJson(json["verification_data"]),
      );

  Map<String, dynamic> toJson() => {
    "success": success,
    "message": message,
    "verification_data": verificationData?.toJson(),
  };
}

class VerificationData {
  final String? productId;
  final dynamic basePlanId;
  final dynamic offerId;
  final dynamic offerTags;
  final String? subscriptionState;
  final String? regionCode;
  final String? orderId;
  final String? linkedPurchaseToken;
  final String? expiryTime;
  final String? startTime;
  final bool? autoRenewing;
  final dynamic priceAmountMicros;
  final dynamic priceCurrencyCode;
  final dynamic priceAmount;
  final Raw? raw;

  VerificationData({
    this.productId,
    this.basePlanId,
    this.offerId,
    this.offerTags,
    this.subscriptionState,
    this.regionCode,
    this.orderId,
    this.linkedPurchaseToken,
    this.expiryTime,
    this.startTime,
    this.autoRenewing,
    this.priceAmountMicros,
    this.priceCurrencyCode,
    this.priceAmount,
    this.raw,
  });

  factory VerificationData.fromJson(Map<String, dynamic> json) =>
      VerificationData(
        productId: json["product_id"],
        basePlanId: json["base_plan_id"],
        offerId: json["offer_id"],
        offerTags: json["offerTags"],
        subscriptionState: json["subscription_state"],
        regionCode: json["region_code"],
        orderId: json["order_id"],
        linkedPurchaseToken: json["linked_purchase_token"],
        // ✅ Handle both int (milliseconds) and String formats
        expiryTime: json["expiry_time"]?.toString(),
        startTime: json["start_time"]?.toString(),
        autoRenewing: json["auto_renewing"],
        priceAmountMicros: json["price_amount_micros"],
        priceCurrencyCode: json["price_currency_code"],
        priceAmount: json["price_amount"],
        raw: json["raw"] == null ? null : Raw.fromJson(json["raw"]),
      );

  Map<String, dynamic> toJson() => {
    "product_id": productId,
    "base_plan_id": basePlanId,
    "offer_id": offerId,
    "offerTags": offerTags,
    "subscription_state": subscriptionState,
    "region_code": regionCode,
    "order_id": orderId,
    "linked_purchase_token": linkedPurchaseToken,
    "expiry_time": expiryTime,
    "start_time": startTime,
    "auto_renewing": autoRenewing,
    "price_amount_micros": priceAmountMicros,
    "price_currency_code": priceCurrencyCode,
    "price_amount": priceAmount,
    "raw": raw?.toJson(),
  };
}

class Raw {
  final String? acknowledgementState;
  final String? kind;
  final String? latestOrderId;
  final String? linkedPurchaseToken;
  final String? regionCode;
  final String? startTime;
  final String? subscriptionState;
  final CanceledStateContext? canceledStateContext;
  final List<dynamic>? testPurchase;
  final List<LineItem>? lineItems;

  Raw({
    this.acknowledgementState,
    this.kind,
    this.latestOrderId,
    this.linkedPurchaseToken,
    this.regionCode,
    this.startTime,
    this.subscriptionState,
    this.canceledStateContext,
    this.testPurchase,
    this.lineItems,
  });

  factory Raw.fromJson(Map<String, dynamic> json) => Raw(
    acknowledgementState: json["acknowledgementState"],
    kind: json["kind"],
    latestOrderId: json["latestOrderId"],
    linkedPurchaseToken: json["linkedPurchaseToken"],
    regionCode: json["regionCode"],
    startTime: json["startTime"],
    subscriptionState: json["subscriptionState"],
    canceledStateContext:
        json["canceledStateContext"] == null
            ? null
            : CanceledStateContext.fromJson(json["canceledStateContext"]),
    testPurchase:
        json["testPurchase"] == null
            ? []
            : List<dynamic>.from(json["testPurchase"]!.map((x) => x)),
    lineItems:
        json["lineItems"] == null
            ? []
            : List<LineItem>.from(
              json["lineItems"]!.map((x) => LineItem.fromJson(x)),
            ),
  );

  Map<String, dynamic> toJson() => {
    "acknowledgementState": acknowledgementState,
    "kind": kind,
    "latestOrderId": latestOrderId,
    "linkedPurchaseToken": linkedPurchaseToken,
    "regionCode": regionCode,
    "startTime": startTime,
    "subscriptionState": subscriptionState,
    "canceledStateContext": canceledStateContext?.toJson(),
    "testPurchase":
        testPurchase == null
            ? []
            : List<dynamic>.from(testPurchase!.map((x) => x)),
    "lineItems":
        lineItems == null
            ? []
            : List<dynamic>.from(lineItems!.map((x) => x.toJson())),
  };
}

class CanceledStateContext {
  final List<dynamic>? replacementCancellation;

  CanceledStateContext({this.replacementCancellation});

  factory CanceledStateContext.fromJson(Map<String, dynamic> json) =>
      CanceledStateContext(
        replacementCancellation:
            json["replacementCancellation"] == null
                ? []
                : List<dynamic>.from(
                  json["replacementCancellation"]!.map((x) => x),
                ),
      );

  Map<String, dynamic> toJson() => {
    "replacementCancellation":
        replacementCancellation == null
            ? []
            : List<dynamic>.from(replacementCancellation!.map((x) => x)),
  };
}

class LineItem {
  final String? expiryTime;
  final String? latestSuccessfulOrderId;
  final String? productId;
  final AutoRenewingPlan? autoRenewingPlan;
  final OfferDetails? offerDetails;
  final ItemReplacement? itemReplacement;

  LineItem({
    this.expiryTime,
    this.latestSuccessfulOrderId,
    this.productId,
    this.autoRenewingPlan,
    this.offerDetails,
    this.itemReplacement,
  });

  factory LineItem.fromJson(Map<String, dynamic> json) => LineItem(
    expiryTime: json["expiryTime"],
    latestSuccessfulOrderId: json["latestSuccessfulOrderId"],
    productId: json["productId"],
    autoRenewingPlan:
        json["autoRenewingPlan"] == null
            ? null
            : AutoRenewingPlan.fromJson(json["autoRenewingPlan"]),
    offerDetails:
        json["offerDetails"] == null
            ? null
            : OfferDetails.fromJson(json["offerDetails"]),
    itemReplacement:
        json["itemReplacement"] == null
            ? null
            : ItemReplacement.fromJson(json["itemReplacement"]),
  );

  Map<String, dynamic> toJson() => {
    "expiryTime": expiryTime,
    "latestSuccessfulOrderId": latestSuccessfulOrderId,
    "productId": productId,
    "autoRenewingPlan": autoRenewingPlan?.toJson(),
    "offerDetails": offerDetails?.toJson(),
    "itemReplacement": itemReplacement?.toJson(),
  };
}

class AutoRenewingPlan {
  final dynamic autoRenewEnabled;
  final RecurringPrice? recurringPrice;

  AutoRenewingPlan({this.autoRenewEnabled, this.recurringPrice});

  factory AutoRenewingPlan.fromJson(Map<String, dynamic> json) =>
      AutoRenewingPlan(
        autoRenewEnabled: json["autoRenewEnabled"],
        recurringPrice:
            json["recurringPrice"] == null
                ? null
                : RecurringPrice.fromJson(json["recurringPrice"]),
      );

  Map<String, dynamic> toJson() => {
    "autoRenewEnabled": autoRenewEnabled,
    "recurringPrice": recurringPrice?.toJson(),
  };
}

class RecurringPrice {
  final String? currencyCode;
  final dynamic nanos;
  final String? units;

  RecurringPrice({this.currencyCode, this.nanos, this.units});

  factory RecurringPrice.fromJson(Map<String, dynamic> json) => RecurringPrice(
    currencyCode: json["currencyCode"],
    nanos: json["nanos"],
    units: json["units"],
  );

  Map<String, dynamic> toJson() => {
    "currencyCode": currencyCode,
    "nanos": nanos,
    "units": units,
  };
}

class ItemReplacement {
  final String? basePlanId;
  final dynamic offerId;
  final String? productId;
  final String? replacementMode;

  ItemReplacement({
    this.basePlanId,
    this.offerId,
    this.productId,
    this.replacementMode,
  });

  factory ItemReplacement.fromJson(Map<String, dynamic> json) =>
      ItemReplacement(
        basePlanId: json["basePlanId"],
        offerId: json["offerId"],
        productId: json["productId"],
        replacementMode: json["replacementMode"],
      );

  Map<String, dynamic> toJson() => {
    "basePlanId": basePlanId,
    "offerId": offerId,
    "productId": productId,
    "replacementMode": replacementMode,
  };
}

class OfferDetails {
  final String? basePlanId;
  final dynamic offerId;
  final dynamic offerTags;

  OfferDetails({this.basePlanId, this.offerId, this.offerTags});

  factory OfferDetails.fromJson(Map<String, dynamic> json) => OfferDetails(
    basePlanId: json["basePlanId"],
    offerId: json["offerId"],
    offerTags: json["offerTags"],
  );

  Map<String, dynamic> toJson() => {
    "basePlanId": basePlanId,
    "offerId": offerId,
    "offerTags": offerTags,
  };
}
