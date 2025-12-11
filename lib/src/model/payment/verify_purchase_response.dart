// verify_purchase_response.dart

import 'dart:convert';

VerifyPurchaseResponse verifyPurchaseResponseFromJson(String str) =>
    VerifyPurchaseResponse.fromJson(json.decode(str));

String verifyPurchaseResponseToJson(VerifyPurchaseResponse data) =>
    json.encode(data.toJson());

class VerifyPurchaseResponse {
  final bool? success;
  final String? message;
  final Purchase? purchase; // ✅ Added purchase field
  final VerificationData? verificationData;

  VerifyPurchaseResponse({
    this.success,
    this.message,
    this.purchase,
    this.verificationData,
  });

  // ✅ Helper getters for backward compatibility
  bool get valid => success ?? false;
  
  bool get hasActiveSubscription {
    if (verificationData == null) return false;
    // Check if subscription is active based on state
    final state = verificationData!.subscriptionState?.toUpperCase() ?? '';
    return state == 'SUBSCRIPTION_STATE_ACTIVE' || 
           state == 'ACTIVE' ||
           state == '1';
  }

  String? get currentSubscriptionId => 
      verificationData?.productId ?? purchase?.productId;
  
  String? get subscriptionExpiryDate => verificationData?.expiryTime;
  
  String? get trialStartDate => verificationData?.startTime;
  
  // ✅ For venue users: expiry_time represents subscription end (trial or full subscription)
  // For test accounts, this might be 30 minutes; for production, it's 1 year
  String? get trialEndDate => verificationData?.expiryTime;

  bool get isVenueUser {
    // Determine based on product ID
    final productId = 
        verificationData?.productId?.toLowerCase() ?? 
        purchase?.productId?.toLowerCase() ?? 
        '';
    return productId.contains('venue');
  }

  bool get inTrial {
    // For venue users, check if subscription is currently active
    if (verificationData?.startTime != null && 
        verificationData?.expiryTime != null) {
      try {
        final expiry = DateTime.parse(_fixDateFormat(verificationData!.expiryTime!));
        final now = DateTime.now();
        
        // Active if current time is before expiry
        return now.isBefore(expiry);
      } catch (e) {
        return false;
      }
    }
    
    return false;
  }

  String _fixDateFormat(String input) {
    if (input.contains(' ') && !input.contains('T')) {
      return input.replaceFirst(' ', 'T');
    }
    return input;
  }

  factory VerifyPurchaseResponse.fromJson(Map<String, dynamic> json) =>
      VerifyPurchaseResponse(
        success: json["success"],
        message: json["message"],
        purchase: json["purchase"] == null
            ? null
            : Purchase.fromJson(json["purchase"]),
        verificationData: json["verification_data"] == null
            ? null
            : VerificationData.fromJson(json["verification_data"]),
      );

  Map<String, dynamic> toJson() => {
        "success": success,
        "message": message,
        "purchase": purchase?.toJson(),
        "verification_data": verificationData?.toJson(),
      };
}

// ✅ Added Purchase class to match backend response
class Purchase {
  final int? id;
  final int? userId;
  final String? productId;
  final String? purchaseToken;
  final String? platform;
  final String? status;
  final String? createdAt;
  final String? updatedAt;

  Purchase({
    this.id,
    this.userId,
    this.productId,
    this.purchaseToken,
    this.platform,
    this.status,
    this.createdAt,
    this.updatedAt,
  });

  factory Purchase.fromJson(Map<String, dynamic> json) => Purchase(
        id: json["id"],
        userId: json["user_id"],
        productId: json["product_id"],
        purchaseToken: json["purchase_token"],
        platform: json["platform"],
        status: json["status"],
        createdAt: json["created_at"],
        updatedAt: json["updated_at"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "user_id": userId,
        "product_id": productId,
        "purchase_token": purchaseToken,
        "platform": platform,
        "status": status,
        "created_at": createdAt,
        "updated_at": updatedAt,
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
        expiryTime: json["expiry_time"],
        startTime: json["start_time"],
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

// ... rest of the classes remain the same (Raw, CanceledStateContext, LineItem, etc.)

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
        canceledStateContext: json["canceledStateContext"] == null
            ? null
            : CanceledStateContext.fromJson(json["canceledStateContext"]),
        testPurchase: json["testPurchase"] == null
            ? []
            : List<dynamic>.from(json["testPurchase"]!.map((x) => x)),
        lineItems: json["lineItems"] == null
            ? []
            : List<LineItem>.from(
                json["lineItems"]!.map((x) => LineItem.fromJson(x))),
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
        "testPurchase": testPurchase == null
            ? []
            : List<dynamic>.from(testPurchase!.map((x) => x)),
        "lineItems": lineItems == null
            ? []
            : List<dynamic>.from(lineItems!.map((x) => x.toJson())),
      };
}

class CanceledStateContext {
  final List<dynamic>? replacementCancellation;

  CanceledStateContext({
    this.replacementCancellation,
  });

  factory CanceledStateContext.fromJson(Map<String, dynamic> json) =>
      CanceledStateContext(
        replacementCancellation: json["replacementCancellation"] == null
            ? []
            : List<dynamic>.from(json["replacementCancellation"]!.map((x) => x)),
      );

  Map<String, dynamic> toJson() => {
        "replacementCancellation": replacementCancellation == null
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
        autoRenewingPlan: json["autoRenewingPlan"] == null
            ? null
            : AutoRenewingPlan.fromJson(json["autoRenewingPlan"]),
        offerDetails: json["offerDetails"] == null
            ? null
            : OfferDetails.fromJson(json["offerDetails"]),
        itemReplacement: json["itemReplacement"] == null
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

  AutoRenewingPlan({
    this.autoRenewEnabled,
    this.recurringPrice,
  });

  factory AutoRenewingPlan.fromJson(Map<String, dynamic> json) =>
      AutoRenewingPlan(
        autoRenewEnabled: json["autoRenewEnabled"],
        recurringPrice: json["recurringPrice"] == null
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

  RecurringPrice({
    this.currencyCode,
    this.nanos,
    this.units,
  });

  factory RecurringPrice.fromJson(Map<String, dynamic> json) =>
      RecurringPrice(
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

  OfferDetails({
    this.basePlanId,
    this.offerId,
    this.offerTags,
  });

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