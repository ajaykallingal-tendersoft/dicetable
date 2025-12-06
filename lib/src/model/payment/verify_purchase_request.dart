// lib/data/models/iap/verify_purchase_request.dart

import 'package:equatable/equatable.dart';

class VerifyPurchaseRequest extends Equatable {
  final String platform;
  final String productId;
  final String userType; // ✅ 'venue' or 'public'
  final String? cafeId;  // ✅ For venue users
  final String? userId;  // ✅ For public users
  final String? purchaseToken;
  final String? receiptData;
  final String? originalJson;
  final String? packageName;
  final String? signature;
  final String timestamp;

  const VerifyPurchaseRequest({
    required this.platform,
    required this.productId,
    required this.userType,
    this.cafeId,
    this.userId,
    this.purchaseToken,
    this.receiptData,
    this.originalJson,
    this.packageName,
    this.signature,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = {
      'platform': platform,
      'product_id': productId,
      'user_type': userType,
      'timestamp': timestamp,
    };

    if (cafeId != null) json['cafe_id'] = cafeId;
    if (userId != null) json['user_id'] = userId;
    if (purchaseToken != null) json['purchase_token'] = purchaseToken;
    if (receiptData != null) json['receipt_data'] = receiptData;
    if (originalJson != null) json['original_json'] = originalJson;
    if (packageName != null) json['package_name'] = packageName;
    if (signature != null) json['signature'] = signature;

    // Remove null values
    json.removeWhere((key, value) => value == null);

    return json;
  }

  @override
  List<Object?> get props => [
        platform,
        productId,
        userType,
        cafeId,
        userId,
        purchaseToken,
        receiptData,
        originalJson,
        packageName,
        signature,
        timestamp,
      ];
}