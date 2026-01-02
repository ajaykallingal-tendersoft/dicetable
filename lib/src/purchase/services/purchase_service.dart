// lib/src/purchase/services/purchase_service.dart

import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_android/billing_client_wrappers.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';
import 'package:in_app_purchase_storekit/in_app_purchase_storekit.dart';
import 'package:in_app_purchase_storekit/store_kit_wrappers.dart';
import '../utils/debug_logger.dart';

class PaymentService {
  // ====== CORRECT PRODUCT IDs FOR GOOGLE PLAY ======
  // For Android: product IDs
  static const String yearlyPublicProductId = "public_yearly_plan";
  static const String venueYearlyProductId = "venue_yearly_plan";

  // For iOS: Use product IDs
  static const String yearlyPublic = "public_yearly";
  static const String monthlyPublic = "public_monthly";
  static const String yearlyVenueProductId = "venue_yearly_product";

  final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  late StreamSubscription<List<PurchaseDetails>> _subscription;

  /// Controller for fake purchase stream (debug mode)
  final StreamController<List<PurchaseDetails>> _fakePurchaseController =
      StreamController<List<PurchaseDetails>>.broadcast();

  bool _fakePurchaseAlreadyDispatched = false;

  Stream<List<PurchaseDetails>> get purchaseStream =>
      kDebugMode
          ? _fakePurchaseController.stream
          : _inAppPurchase.purchaseStream;

  List<ProductDetails> _products = [];
  List<ProductDetails> get products => _products;

  // =====================================================
  // INITIALIZATION
  // =====================================================

  Future<bool> initialize({bool forceReal = false}) async {
    try {
      if (kDebugMode && !forceReal) {
        print("🧪 DEBUG MODE: Using Fake In-App Purchase environment");
        return true;
      }

      print("⚙️ Initializing REAL In-App Purchase environment...");
      final isAvailable = await _inAppPurchase.isAvailable();
      print("⚙️ isAvailable => $isAvailable");

      if (!isAvailable) {
        final diag = await diagnoseStore();
        print("❌ Store not available. diagnoseStore => $diag");
        return false;
      }

      // ✅ CRITICAL FIX: Subscribe to real purchase stream AND forward to controller
      // This ensures iOS events reach the bloc even in debug mode
      print('🔗 Setting up purchase stream forwarding...');
      _subscription = _inAppPurchase.purchaseStream.listen(
        (purchases) {
          try {
            print(
              '📡 Purchase stream event received: ${purchases.length} purchases',
            );
            for (var p in purchases) {
              print('   - Product: ${p.productID}, Status: ${p.status}');
            }

            // ✅ Forward to fake controller so bloc receives events
            _fakePurchaseController.add(purchases);
            _onPurchaseUpdated(purchases);
          } catch (e, st) {
            print('⚠️ purchase stream handling error: $e\n$st');
          }
        },
        onError: (err, st) => print('⚠️ purchaseStream onError: $err\n$st'),
        cancelOnError: false,
      );

      print("✅ Store initialized and listening to purchase stream.");
      print("✅ Purchase events will be forwarded to bloc");
      return true;
    } catch (e, st) {
      print("❌ Error initializing IAP service: $e\n$st");
      return false;
    }
  }

  // =====================================================
  //  FAKE PRODUCTS (DEBUG MODE)
  // =====================================================

  List<ProductDetails> _fakeProducts() {
    print("🧪 Returning FAKE products...");

    return [
      // ✅ FIRST: Monthly plan (should appear first)
      ProductDetails(
        id: monthlyPublic, // ✅ Use monthly ID
        title: "Public Monthly Plan",
        description: "Monthly subscription for public users",
        price: "\$9.00",
        rawPrice: 9.0,
        currencyCode: "NZD",
      ),
      // ✅ SECOND: Yearly plan
      ProductDetails(
        id: yearlyPublicProductId, // ✅ Use yearly ID
        title: "Public Yearly Plan",
        description: "Yearly subscription for public users",
        price: "\$99.00",
        rawPrice: 99.0,
        currencyCode: "NZD",
      ),
      // ✅ THIRD: Venue plan
      ProductDetails(
        id: venueYearlyProductId,
        title: "Venue Yearly Plan",
        description: "Venue yearly subscription with 1-month free trial",
        price: "\$99.00",
        rawPrice: 199.0,
        currencyCode: "NZD",
      ),
    ];
  }

  Future<String> diagnoseStore() async {
    try {
      final fakeSet = <String>{'__nonexistent_sku_for_diag__'};
      final response = await _inAppPurchase.queryProductDetails(fakeSet);
      return 'diagnose: productDetails=${response.productDetails.length}, notFound=${response.notFoundIDs}, error=${response.error}';
    } catch (e) {
      return 'diagnose exception: $e';
    }
  }

  // =====================================================
  // LOAD PRODUCTS (PLATFORM-SPECIFIC)
  // =====================================================

  // Replace the loadProducts method in PaymentService

  // COMPLETE REPLACEMENT for loadProducts in PaymentService

  Future<List<ProductDetails>> loadProducts({
    int retryCount = 3,
    Duration retryDelay = const Duration(seconds: 2),
  }) async {
    try {
      if (kDebugMode) {
        await Future.delayed(const Duration(milliseconds: 500));
        _products = _fakeProducts();
        print("🧪 Loaded FAKE products (${_products.length})");
        return _products;
      }

      Set<String> productIds;

      if (Platform.isAndroid) {
        productIds = {venueYearlyProductId, yearlyPublicProductId};
        print('📦 Loading ANDROID parent subscription IDs: $productIds');
      } else if (Platform.isIOS) {
        productIds = {yearlyPublic, monthlyPublic, yearlyVenueProductId};
        print('');
        print('═══════════════════════════════════════════');
        print('🍎 iOS IAP - LOADING PRODUCTS');
        print('═══════════════════════════════════════════');
        print('📤 Requesting Product IDs:');
        for (var id in productIds) {
          print('   • "$id"');
        }
        print('');
      } else {
        throw Exception('Unsupported platform');
      }

      ProductDetailsResponse response;
      int attempt = 0;

      while (true) {
        attempt++;

        if (Platform.isIOS) {
          print('⏳ Querying App Store (Attempt #$attempt)...');
        } else {
          print('📦 queryProductDetails attempt #$attempt');
        }

        response = await _inAppPurchase.queryProductDetails(productIds);

        if (Platform.isAndroid) {
          print('  productDetails.length = ${response.productDetails.length}');
          print('  notFoundIDs = ${response.notFoundIDs}');
        } else if (Platform.isIOS) {
          print('');
          print('📥 App Store Response:');
          print('   Products Found: ${response.productDetails.length}');
          print('   Products Not Found: ${response.notFoundIDs.length}');

          if (response.notFoundIDs.isNotEmpty) {
            print('');
            print('⚠️ MISSING PRODUCTS:');
            for (var id in response.notFoundIDs) {
              print('   ❌ "$id" not in StoreKit Configuration');
            }
          }
        }

        if (response.error != null) {
          print('⚠️ Store error: ${response.error}');
          if (attempt < retryCount) {
            print('   Retrying in ${(retryDelay * attempt).inSeconds}s...');
            await Future.delayed(retryDelay * attempt);
            continue;
          }
          throw Exception('Store error: ${response.error}');
        }

        if (response.productDetails.isEmpty) {
          if (Platform.isIOS) {
            print('⚠️ No products returned!');
            print('   Possible causes:');
            print('   1. StoreKit Configuration not selected in scheme');
            print('   2. Product IDs mismatch');
            print('   3. StoreKit file not in project');
          }

          if (attempt < retryCount) {
            print('   Retrying in ${(retryDelay * attempt).inSeconds}s...');
            await Future.delayed(retryDelay * attempt);
            continue;
          }
          throw Exception('No products returned.');
        }

        // ✅ CRITICAL: Keep ALL instances, don't deduplicate
        // Each instance represents a different base plan
        _products = response.productDetails;

        if (Platform.isIOS) {
          print('');
          print('✅ PRODUCTS SUCCESSFULLY LOADED:');

          for (var i = 0; i < _products.length; i++) {
            final product = _products[i];

            // Detect fake products
            final isFake =
                product.id.toLowerCase().contains('fake') ||
                product.title.toLowerCase().contains('fake') ||
                product.price == '\$0.00' ||
                product.price == '0';

            if (isFake) {
              print('');
              print('   🚨 FAKE PRODUCT DETECTED!');
              print('   ❌ Product ID: "${product.id}"');
              print('      Title: ${product.title}');
              print('      Price: ${product.price}');
              print('');
              print('   ⚠️ This means StoreKit Configuration is NOT loaded!');
              print(
                '   Fix: Edit Scheme → Run → Options → StoreKit Configuration',
              );
              print('');
            } else {
              print('');
              print('   ✅ Product ${i + 1}/${_products.length}:');
              print('      ID: "${product.id}"');
              print('      Title: ${product.title}');
              print('      Price: ${product.price}');
              print('      Description: ${product.description}');

              // iOS specific details
              if (product is AppStoreProductDetails) {
                print('      Currency: ${product.currencyCode}');
                print('      Raw Price: ${product.rawPrice}');
              }
            }
          }

          print('');
          print('═══════════════════════════════════════════');
          print('');
        } else {
          // Android logging (existing)
          print('✅ Loaded ${_products.length} product instance(s)');

          for (var i = 0; i < _products.length; i++) {
            final product = _products[i];
            print('  Instance $i: ${product.id}');
            print('    Price: ${product.price}');

            if (product is GooglePlayProductDetails) {
              final offers = product.productDetails.subscriptionOfferDetails;
              if (offers != null && offers.isNotEmpty) {
                print('    Offers in this instance: ${offers.length}');
                for (var offer in offers) {
                  print('      - Base Plan: ${offer.basePlanId}');
                  print('        Offer Token: ${offer.offerIdToken}');
                  if (offer.pricingPhases.isNotEmpty) {
                    print(
                      '        Price: ${offer.pricingPhases.first.formattedPrice}',
                    );
                  }
                }
              }
            }
          }
        }

        return _products;
      }
    } catch (e, st) {
      print('❌ Error loading products: $e\n$st');
      rethrow;
    }
  }

  // =====================================================
  //  FAKE PURCHASE SIMULATOR
  // =====================================================

  Future<void> _simulateFakePurchase(ProductDetails product) async {
    if (_fakePurchaseAlreadyDispatched) {
      print("⚠️ Fake purchase already dispatched. Ignoring duplicate.");
      return;
    }

    _fakePurchaseAlreadyDispatched = true;
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

    _fakePurchaseController.add([fakePurchase]);
    print("🧪 Fake purchase dispatched to purchase stream");
  }

  // =====================================================
  //  PURCHASE PRODUCT (WITH TRIAL & UPGRADE SUPPORT)
  // =====================================================

  // Replace purchaseProduct in PaymentService

  // COMPLETE REPLACEMENT for purchaseProduct in PaymentService

  Future<String?> purchaseProduct(
    ProductDetails productDetails, {
    PurchaseDetails? oldPurchaseDetails,
    String? basePlanId,
    String? offerToken,
    bool isVenueTrial = false,
  }) async {
    try {
      if (kDebugMode) {
        await _simulateFakePurchase(productDetails);
        return null;
      }

      print('🛒 Starting purchase:');
      print('  Product ID: ${productDetails.id}');
      print('  Base Plan ID: $basePlanId');
      print('  Offer Token: $offerToken');

      late PurchaseParam purchaseParam;

      if (Platform.isAndroid) {
        if (productDetails is! GooglePlayProductDetails) {
          return 'Invalid product type for Android.';
        }

        // Log available offers for debugging
        final offers = productDetails.productDetails.subscriptionOfferDetails;
        if (offers != null) {
          print('  📦 Offers available:');
          for (var offer in offers) {
            print('    - basePlanId: ${offer.basePlanId}');
            print('      offerToken: ${offer.offerIdToken}');
            if (offer.pricingPhases.isNotEmpty) {
              print('      price: ${offer.pricingPhases.first.formattedPrice}');
            }
          }
        }

        if (oldPurchaseDetails != null &&
            oldPurchaseDetails is GooglePlayPurchaseDetails) {
          // Upgrade/downgrade flow
          print('🔄 Performing upgrade/downgrade purchase');

          purchaseParam = GooglePlayPurchaseParam(
            productDetails: productDetails,
            changeSubscriptionParam: ChangeSubscriptionParam(
              oldPurchaseDetails: oldPurchaseDetails,
              replacementMode: ReplacementMode.withTimeProration,
            ),
            offerToken: offerToken, // 🟢 CRITICAL
          );
        } else {
          // Normal new purchase
          print('🆕 New subscription purchase');

          purchaseParam = GooglePlayPurchaseParam(
            productDetails: productDetails,
            applicationUserName: null,
            offerToken: offerToken, // 🟢 CRITICAL
          );
        }
      }
      // iOS purchase flow (no base plans or offer tokens)
      else if (Platform.isIOS) {
        print('🍎 iOS Purchase Flow:');
        purchaseParam = PurchaseParam(
          productDetails: productDetails,
          applicationUserName: null,
        );
      } else {
        return 'Unsupported platform.';
      }

      print('🚀 Launching purchase flow for ${productDetails.id}...');
      print('   Platform: ${Platform.isIOS ? "iOS" : "Android"}');
      print('   Selected plan price: ${productDetails.price}');
      if (Platform.isAndroid) {
        print('   Offer Token Applied: $offerToken');
      }

      final bool started = await _inAppPurchase.buyNonConsumable(
        purchaseParam: purchaseParam,
      );

      if (!started) {
        print('❌ Purchase flow failed to start');
        print('   This usually means another purchase is in progress');
        return 'Failed to start purchase flow.';
      }

      print('✅ Purchase flow started successfully');
      print('   Waiting for purchase stream events...');
      print('   iOS: Native sheet should appear now');
      return null;
    } catch (e, st) {
      print('❌ purchaseProduct() ERROR: $e\n$st');
      return e.toString();
    }
  }

  // =====================================================
  // HELPER: GET APP RECEIPT DATA (iOS Legacy Format)
  // =====================================================

  /// Get the app's receipt data as base64 string (legacy format for backend)
  /// This reads the entire app receipt file from the bundle, which contains
  /// all purchase history for this app.
  Future<String?> _getAppReceiptData() async {
    try {
      if (!Platform.isIOS) return null;

      // Access the app's receipt using StoreKit
      // SKReceiptManager.retrieveReceiptData() returns base64-encoded receipt
      final receiptData = await SKReceiptManager.retrieveReceiptData();

      if (receiptData == null || receiptData.isEmpty) {
        print('⚠️ App receipt is empty - this can happen in:');
        print('   1. Fresh TestFlight install (no purchases yet)');
        print('   2. Simulator (no real purchases)');
        print('   3. Receipt needs refresh from App Store');
        print('   4. User canceled purchase before completion');
        return null;
      }

      print('✅ Retrieved app receipt from bundle');
      print('   Receipt length: ${receiptData.length} characters');
      print('   Format: Base64 encoded (legacy /verifyReceipt compatible)');

      return receiptData; // Already base64 encoded
    } catch (e, st) {
      print('❌ Error reading app receipt: $e\n$st');
      print('   This may indicate:');
      print('   1. Receipt file is corrupted');
      print('   2. App sandbox environment issue');
      print('   3. iOS permissions problem');
      return null;
    }
  }

  // =====================================================
  // HELPER: BUILD VERIFICATION PAYLOAD
  // =====================================================

  Future<Map<String, dynamic>> extractVerificationPayload(
    PurchaseDetails purchase,
  ) async {
    final ver = purchase.verificationData;
    // keep using defaultTargetPlatform as your file did originally
    final bool isIOS = defaultTargetPlatform == TargetPlatform.iOS;
    final bool isAndroid = defaultTargetPlatform == TargetPlatform.android;

    // base payload (always include platform)
    final String resolvedPlatform =
        isIOS
            ? 'ios'
            : (isAndroid
                ? 'android'
                : (ver.source?.toLowerCase() ?? 'unknown'));

    final Map<String, dynamic> payload = <String, dynamic>{
      'product_id': purchase.productID,
      'order_id': purchase.purchaseID ?? '0',
      'transaction_date': purchase.transactionDate,
      'status': purchase.status.toString(),
      'platform': resolvedPlatform, //
      'verification_data': {
        'local_verification_data': ver.localVerificationData,
        'server_verification_data': ver.serverVerificationData,
        'source': ver.source,
      },
    };

    // ---------------- ANDROID ----------------
    if (isAndroid && purchase is GooglePlayPurchaseDetails) {
      final billing = purchase.billingClientPurchase;

      payload.addAll({
        // platform already included above
        'purchase_token': ver.serverVerificationData ?? '',
        'original_json': ver.localVerificationData ?? '',
        // keep optional additional Android fields to help backend if it needs them
        'package_name': billing?.packageName,
        'order_id': purchase.purchaseID ?? billing?.orderId,
        // add signature if available in localVerificationData (some backends expect 'signature')
        'signature': ver.localVerificationData,
      });

      return payload;
    }

    // ---------------- iOS ----------------
    if (isIOS && purchase is AppStorePurchaseDetails) {
      final tx = purchase.skPaymentTransaction;

      // ✅ CRITICAL FIX: Read app receipt from bundle (legacy base64 format)
      // Backend requires the full app receipt file, not individual transaction data
      // This contains all purchases and subscriptions for this app
      String receiptData = '';
      try {
        print('');
        print('🍎 iOS Receipt Data Extraction:');

        // ✅ NEW: Get app receipt from bundle
        final appReceipt = await _getAppReceiptData();

        if (appReceipt != null && appReceipt.isNotEmpty) {
          receiptData = appReceipt;
          print('✅ Using app receipt from bundle');
          print('   Receipt length: ${receiptData.length} characters');
          print('   This is the full app receipt in base64 format');
        } else {
          // Receipt is empty - this can happen in TestFlight or fresh installs
          print('⚠️ App receipt is empty');
          print('   Possible reasons:');
          print('   1. Fresh install with no completed purchases');
          print('   2. TestFlight sandbox environment issue');
          print('   3. Restored purchase with no valid receipt');
          print('');
          print('❌ Cannot verify without receipt data');
          print('   Will return empty token - caller should handle gracefully');
        }

        print('');
      } catch (e, st) {
        print('❌ Error extracting App Store receipt: $e\n$st');
        receiptData = ''; // Ensure empty on error
      }

      payload.addAll({
        // platform already included above
        // The full App Store receipt (Base64 encoded entire receipt file)
        'receipt_data': receiptData,
        'purchase_token':
            receiptData, // keep both names for backend compatibility
        'transaction_id': purchase.purchaseID,
        'original_transaction_id':
            tx?.originalTransaction?.transactionIdentifier,
      });

      // ✅ DEBUG: Print entire iOS verification payload
      print('');
      print('═══════════════════════════════════════════════════════════');
      print('🍎 iOS VERIFICATION PAYLOAD - COMPLETE DEBUG OUTPUT');
      print('═══════════════════════════════════════════════════════════');
      print('📦 All Payload Fields:');
      payload.forEach((key, value) {
        if (key == 'receipt_data' || key == 'purchase_token') {
          // Don't print full receipt data (too long), just show length
          print('   $key: [Base64 data, ${value.toString().length} chars]');
        } else if (key == 'verification_data') {
          // Print verification_data details
          print('   $key:');
          if (value is Map) {
            value.forEach((subKey, subValue) {
              if (subKey == 'local_verification_data' ||
                  subKey == 'server_verification_data') {
                print('      $subKey: [${subValue.toString().length} chars]');
              } else {
                print('      $subKey: $subValue');
              }
            });
          }
        } else {
          print('   $key: $value');
        }
      });
      print('');
      print('🔑 Key Fields Summary:');
      print('   Platform: ${payload['platform']}');
      print('   Product ID: ${payload['product_id']}');
      print('   Transaction ID: ${payload['transaction_id']}');
      print(
        '   Original Transaction ID: ${payload['original_transaction_id']}',
      );
      print('   Receipt Data Length: ${receiptData.length} characters');
      print('   Has Receipt Data: ${receiptData.isNotEmpty}');
      print('═══════════════════════════════════════════════════════════');
      print('');

      // ✅ Also save to file for testing environments where console is not accessible
      if (kDebugMode) {
        final filePath = await PurchaseDebugLogger.logPayloadToFile(payload);
        if (filePath != null) {
          print('📁 Payload saved to: $filePath');
          print(
            '   You can retrieve this file from the device to inspect the payload',
          );
        }
      }

      return payload;
    }

    // ---------------- FALLBACK ----------------
    payload.addAll({
      'purchase_token':
          ver.serverVerificationData ?? ver.localVerificationData ?? '',
      'original_json': ver.localVerificationData ?? '',
    });

    return payload;
  }

  // =====================================================
  // PURCHASE STREAM HANDLER
  // =====================================================

  void _onPurchaseUpdated(List<PurchaseDetails> purchases) async {
    for (var purchase in purchases) {
      print("📄 Purchase update: ${purchase.productID} — ${purchase.status}");

      _fakePurchaseController.add([purchase]);

      if (purchase.pendingCompletePurchase) {
        await _inAppPurchase.completePurchase(purchase);
      }
    }
  }

  // =====================================================
  // RESTORE PURCHASES
  // =====================================================

  Future<void> restorePurchases() async {
    if (kDebugMode) {
      print("🧪 DEBUG: Simulating restore purchases...");
      await Future.delayed(const Duration(seconds: 1));

      final fakeRestored = PurchaseDetails(
        purchaseID: "FAKE_RESTORE_${DateTime.now().millisecondsSinceEpoch}",
        productID: yearlyPublicProductId,
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

    final available = await _inAppPurchase.isAvailable();
    if (!available) throw Exception("Store unavailable");

    await _inAppPurchase.restorePurchases();
    print("📄 Restore purchases initiated");
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
