// lib/src/purchase/services/purchase_service.dart

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

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
      if (kDebugMode) {
        await _simulateFakePurchase(productDetails);
        return null;
      }

      // REAL purchase flow
      final PurchaseParam param = PurchaseParam(productDetails: productDetails);

      // NOTE: Some platforms may require different buy* calls; keep this as-is if your products are configured as non-consumable/subscriptions.
      await _inAppPurchase.buyNonConsumable(purchaseParam: param);

      return null;
    } catch (e) {
      print("❌ Error during purchase: $e");
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
    // determine platform more reliably than using verificationData.source
    final isIOS = defaultTargetPlatform == TargetPlatform.iOS;
    final isAndroid = defaultTargetPlatform == TargetPlatform.android;

    // Common fields
    final Map<String, dynamic> payload = <String, dynamic>{
      'product_id': purchase.productID,
    };

    // Purchase ID (orderId / transactionId) if present
    if (purchase.purchaseID != null) {
      payload['order_id'] = purchase.purchaseID;
    }

    // Platform-specific fields
    if (isAndroid) {
      payload.addAll({
        'platform': 'android',
        // serverVerificationData holds the token on Android (BillingClient)
        'purchase_token': purchase.verificationData.serverVerificationData,
        // local verification data contains raw JSON string on Android
        'original_json': purchase.verificationData.localVerificationData,
        // package_name should be supplied from runtime or app config
        // keep null here; BLoC or repository can add the package name before send
        'package_name': null,
        // signature may be available in localVerificationData if you parse it
        'signature': null,
      });
    } else if (isIOS) {
      payload.addAll({
        'platform': 'ios',
        // Apple requires the receipt base64
        'receipt_data': purchase.verificationData.serverVerificationData,
        // transaction identifiers
        'transaction_id': purchase.purchaseID,
        'original_transaction_id': null,
        'bundle_id': null,
      });
    } else {
      // Unknown platform: still include the serverVerificationData as fallback
      payload.addAll({
        'platform': purchase.verificationData.source ?? 'unknown',
        'purchase_token': purchase.verificationData.serverVerificationData,
        'original_json': purchase.verificationData.localVerificationData,
      });
    }

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
