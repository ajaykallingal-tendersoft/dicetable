class VerifyPurchaseRequest {
  final String purchaseToken;
  final dynamic productId; // keep as int or string based on your backend
  final String platform;

  // // Optional Android
  // final String? packageName;
  // final String? orderId;

  // // Optional iOS
  // final String? transactionId;
  // final String? originalTransactionId;

  VerifyPurchaseRequest({
    required this.purchaseToken,
    required this.productId,
    required this.platform,
    // this.packageName,
    // this.orderId,
    // this.transactionId,
    // this.originalTransactionId,
  });

  Map<String, dynamic> toJson() {
    return {
      "purchase_token": purchaseToken,
      "product_id": productId,
      "platform": platform,

      // optional fields only included if not null
      // if (packageName != null) "package_name": packageName,
      // if (orderId != null) "order_id": orderId,
      // if (transactionId != null) "transaction_id": transactionId,
      // if (originalTransactionId != null)
      //   "original_transaction_id": originalTransactionId,
    };
  }
}
