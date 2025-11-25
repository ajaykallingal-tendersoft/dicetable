// lib/src/purchase/services/purchase_service.dart

import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';
import 'package:in_app_purchase_storekit/in_app_purchase_storekit.dart';

class PaymentService {
  // ====== REAL product IDs (already defined by you) ======
  static const String monthlyPublicId = "public_monthly_plan";
  static const String yearlyPublicId = "public_yearly_plan";
  static const String venueYearlyId = "venue_yearly_plan";

  final InAppPurchase _inAppPurchase = InAppPurchase.instance;

  late StreamSubscription<List<PurchaseDetails>> _subscription;

  /// Controller for fake purchase stream (debug mode)
  final StreamController<List<PurchaseDetails>> _fakePurchaseController =
      StreamController<List<PurchaseDetails>>.broadcast();

  Stream<List<PurchaseDetails>> get purchaseStream =>
      kDebugMode ? _fakePurchaseController.stream : _inAppPurchase.purchaseStream;

  List<ProductDetails> _products = [];

  List<ProductDetails> get products => _products;

  // =====================================================
  // INITIALIZATION
  // =====================================================

  Future<bool> initialize() async {
    try {
      if (kDebugMode) {
        print("🧪 DEBUG MODE: Using Fake In-App Purchase environment");
        return true;
      }

      print("⚙️ Initializing REAL In-App Purchase environment...");
      final isAvailable = await _inAppPurchase.isAvailable();

      if (!isAvailable) {
        print("❌ Store not available");
        return false;
      }

      print("✅ Store available, listening to real purchase stream...");

      _subscription = _inAppPurchase.purchaseStream.listen(_onPurchaseUpdated);

      return true;
    } catch (e) {
      print("❌ Error initializing IAP service: $e");
      return false;
    }
  }

  // =====================================================
  //  FAKE PRODUCTS (DEBUG MODE)
  // =====================================================

  List<ProductDetails> _fakeProducts() {
    print("🧪 Returning FAKE products...");

    return [
      ProductDetails(
        id: monthlyPublicId,
        title: "Public Monthly Plan",
        description: "Monthly subscription for public users",
        price: "\$9.00",
        rawPrice: 9.0,
        currencyCode: "NZD",
      ),
      ProductDetails(
        id: yearlyPublicId,
        title: "Public Yearly Plan",
        description: "Yearly subscription for public users",
        price: "\$99.00",
        rawPrice: 99.0,
        currencyCode: "NZD",
      ),
      ProductDetails(
        id: venueYearlyId,
        title: "Venue Yearly Plan",
        description: "Venue yearly subscription with 1-month free trial",
        price: "\$99.00",
        rawPrice: 99.0,
        currencyCode: "NZD",
      ),
    ];
  }

  // =====================================================
  // LOAD PRODUCTS (FAKE IN DEBUG / REAL IN RELEASE)
  // =====================================================

  Future<List<ProductDetails>> loadProducts() async {
    try {
      if (kDebugMode) {
        await Future.delayed(const Duration(milliseconds: 500));
        _products = _fakeProducts();
        print("🧪 Loaded FAKE products (${_products.length})");
        return _products;
      }

      // REAL store logic for release
      final Set<String> productIds = {
        monthlyPublicId,
        yearlyPublicId,
        venueYearlyId
      };

      print('📦 Loading REAL products: $productIds');

      final response = await _inAppPurchase.queryProductDetails(productIds);

      if (response.error != null) {
        throw Exception('Store error: ${response.error}');
      }

      if (response.productDetails.isEmpty) {
        throw Exception("No products returned from store");
      }

      _products = response.productDetails;
      return _products;
    } catch (e) {
      print('❌ Error loading products: $e');
      rethrow;
    }
  }

  // =====================================================
  //  FAKE PURCHASE SIMULATOR FOR DEBUG MODE
  // =====================================================

  Future<void> _simulateFakePurchase(ProductDetails product) async {
    print("🧪 Simulating fake purchase for: ${product.id}");

    await Future.delayed(const Duration(seconds: 1));

    final PurchaseDetails fakePurchase = PurchaseDetails(
      purchaseID: "FAKE_${DateTime.now().millisecondsSinceEpoch}",
      productID: product.id,
      status: PurchaseStatus.purchased,
      verificationData: PurchaseVerificationData(
        localVerificationData: "FAKE_LOCAL_DATA",
        serverVerificationData: "FAKE_SERVER_DATA",
        source: "fake",
      ),
      transactionDate: DateTime.now().millisecondsSinceEpoch.toString(),
    );

    // Push fake purchase through fake stream
    _fakePurchaseController.add([fakePurchase]);

    print("🧪 Fake purchase dispatched to purchase stream");
  }

  // =====================================================
  //  PURCHASE PRODUCT (FAKE IN DEBUG / REAL IN RELEASE)
  // =====================================================

 Future<String?> purchaseProduct(ProductDetails productDetails) async {
  try {
    // -----------------------------
    // 1. Handle local fake purchases
    // -----------------------------
    if (kDebugMode) {
      await _simulateFakePurchase(productDetails);
      return null;
    }

    // -----------------------------
    // 2. Build platform-specific params
    // -----------------------------
    late PurchaseParam purchaseParam;

    if (Platform.isAndroid) {
      // For future upgrade/downgrade support:
      // pass ChangeSubscriptionParam(oldPurchaseDetails: ...)
      purchaseParam = GooglePlayPurchaseParam(productDetails: productDetails);
    } else {
      purchaseParam = PurchaseParam(productDetails: productDetails);
    }

    // -----------------------------
    // 3. Start the purchase flow
    // -----------------------------
    final bool started = await _inAppPurchase.buyNonConsumable(
      purchaseParam: purchaseParam,
    );

    if (!started) {
      return 'Failed to start purchase flow';
    }

    // -----------------------------
    // 4. purchaseStream will deliver:
    //    - pending
    //    - error
    //    - purchased/restored
    //    BLoC handles verification.
    // -----------------------------
    return null; // success
  } catch (e, st) {
    print('❌ purchaseProduct error: $e\n$st');
    return e.toString();
  }
}


  // =====================================================
  //  HELPER: BUILD VERIFICATION PAYLOAD (Option A)
  // =====================================================

  /// Extract platform-correct payload for backend verification (Option A)
  ///
  /// IMPORTANT:
  /// - For Android: purchase.verificationData.serverVerificationData typically contains the purchase token.
  ///   localVerificationData often contains raw JSON.
  /// - For iOS: purchase.verificationData.serverVerificationData is the base64 receipt.
Map<String, dynamic> extractVerificationPayload(PurchaseDetails purchase) {
  final ver = purchase.verificationData;

  // Determine platform safely
  final bool isIOS = defaultTargetPlatform == TargetPlatform.iOS;
  final bool isAndroid = defaultTargetPlatform == TargetPlatform.android;

  // ---------------------------
  // Common purchase fields
  // ---------------------------
  final Map<String, dynamic> payload = <String, dynamic>{
    'product_id': purchase.productID,
    'order_id': purchase.purchaseID,
    'transaction_date': purchase.transactionDate,
    'status': purchase.status.toString(),
    'verification_data': {
      'local_verification_data': ver.localVerificationData,
      'server_verification_data': ver.serverVerificationData,
      'source': ver.source, // google_play / app_store
    }
  };

  // ---------------------------------------------------------
  // ANDROID (Google Play Billing)
  // serverVerificationData = purchaseToken
  // localVerificationData  = originalJson
  // ---------------------------------------------------------
  if (isAndroid && purchase is GooglePlayPurchaseDetails) {
    final billing = purchase.billingClientPurchase;

    payload.addAll({
      'platform': 'android',
      'purchase_token': ver.serverVerificationData, // raw token
      'original_json': ver.localVerificationData,   // raw JSON
      'signature': billing?.signature,
      'package_name': billing?.packageName,
      'developer_payload': billing?.developerPayload,
      'acknowledged': billing?.isAcknowledged,
      'auto_renewing': billing?.isAutoRenewing,
      'platform_original_json': billing?.originalJson,
    });

    return payload;
  }

  // ---------------------------------------------------------
  // iOS (StoreKit)
  // serverVerificationData = base64 receipt
  // ---------------------------------------------------------
  if (isIOS && purchase is AppStorePurchaseDetails) {
    final tx = purchase.skPaymentTransaction;

    payload.addAll({
      'platform': 'ios',
      'receipt_data': ver.serverVerificationData,
      'transaction_id': purchase.purchaseID,
      'original_transaction_id': tx?.originalTransaction?.transactionIdentifier,
      'bundle_id': null, // backend will validate receipt and extract this
      'platform_transaction_identifier': tx?.transactionIdentifier,
      'platform_transaction_state': tx?.transactionState?.index,
    });

    return payload;
  }

  // ---------------------------------------------------------
  // Fallback (Web/Fake/Beta devices)
  // ---------------------------------------------------------
  payload.addAll({
    'platform': ver.source ?? 'unknown',
    'purchase_token': ver.serverVerificationData,
    'original_json': ver.localVerificationData,
  });

  return payload;
}


  // =====================================================
  // REAL PURCHASE STREAM HANDLER (RELEASE ONLY)
  // =====================================================

  void _onPurchaseUpdated(List<PurchaseDetails> purchases) async {
    for (var purchase in purchases) {
      print("🔄 Purchase update: ${purchase.productID} — ${purchase.status}");

      // Forward ALL purchase updates to bloc (including cancelled, failed, pending)
      // The bloc will handle each status appropriately
      _fakePurchaseController.add([purchase]);

      // Complete the purchase if needed (required for both platforms)
      if (purchase.pendingCompletePurchase) {
        await _inAppPurchase.completePurchase(purchase);
      }
    }
  }

  Future<void> restorePurchases() async {
    if (kDebugMode) {
      print("🧪 DEBUG: Simulating restore purchases...");

      await Future.delayed(const Duration(seconds: 1));

      // Simulate one restored purchase (triggering full flow)
      final fakeRestored = PurchaseDetails(
        purchaseID: "FAKE_RESTORE_${DateTime.now().millisecondsSinceEpoch}",
        productID: PaymentService.yearlyPublicId, // choose any plan
        status: PurchaseStatus.restored,
        verificationData: PurchaseVerificationData(
          localVerificationData: "FAKE_LOCAL_DATA",
          serverVerificationData: "FAKE_SERVER_DATA",
          source: "fake",
        ),
        transactionDate: DateTime.now().millisecondsSinceEpoch.toString(),
      );

      _fakePurchaseController.add([fakeRestored]);
      return;
    }

    // REAL restore flow
    final available = await _inAppPurchase.isAvailable();
    if (!available) throw Exception("Store unavailable");

    // Restore purchases - the purchase stream will receive restored purchases
    await _inAppPurchase.restorePurchases();
    print("🔄 Restore purchases initiated - waiting for purchase stream updates");
  }

  // =====================================================
  // CLEANUP
  // =====================================================

  void dispose() {
    if (!kDebugMode) {
      _subscription.cancel();
    }
    _fakePurchaseController.close();
  }
}
