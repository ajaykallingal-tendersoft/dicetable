// lib/src/purchase/services/purchase_service.dart

import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_android/billing_client_wrappers.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';
import 'package:in_app_purchase_storekit/in_app_purchase_storekit.dart';
import 'package:in_app_purchase_storekit/store_kit_wrappers.dart';
import '../utils/debug_logger.dart';

/// Simple delegate to enable StoreKit 1 mode
/// This forces the plugin to use AppStorePurchaseDetails with legacy receipt
class _StoreKit1Delegate extends SKPaymentQueueDelegateWrapper {
  @override
  bool shouldContinueTransaction(
    SKPaymentTransactionWrapper transaction,
    SKStorefrontWrapper storefront,
  ) {
    // Return true to continue all transactions
    // This is the default behavior
    return true;
  }

  @override
  bool shouldShowPriceConsent() {
    // Return false - we handle price consent in the UI
    return false;
  }
}

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
        return true;
      }

      // ✅ CRITICAL: Force StoreKit 1 API usage on iOS
      // This ensures AppStorePurchaseDetails with legacy receipt is used
      // instead of SK2PurchaseDetails which doesn't provide the receipt file
      if (Platform.isIOS) {
        // Get the StoreKit platform addition to access payment queue
        final platform =
            _inAppPurchase
                .getPlatformAddition<InAppPurchaseStoreKitPlatformAddition>();

        // Setting a payment queue delegate forces StoreKit 1 mode
        // This ensures we get AppStorePurchaseDetails with receipt data
        await platform.setDelegate(_StoreKit1Delegate());
      }

      final isAvailable = await _inAppPurchase.isAvailable();

      if (!isAvailable) {
        final diag = await diagnoseStore();

        return false;
      }

      // ✅ CRITICAL FIX: Subscribe to real purchase stream AND forward to controller
      // This ensures iOS events reach the bloc even in debug mode

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
    return [
      //  FIRST: Monthly plan (should appear first)
      ProductDetails(
        id: monthlyPublic, //  Use monthly ID
        title: "Public Monthly Plan",
        description: "Monthly subscription for public users",
        price: "\$9.00",
        rawPrice: 9.0,
        currencyCode: "NZD",
      ),
      //  SECOND: Yearly plan
      ProductDetails(
        id: yearlyPublicProductId, //  Use yearly ID
        title: "Public Yearly Plan",
        description: "Yearly subscription for public users",
        price: "\$99.00",
        rawPrice: 99.0,
        currencyCode: "NZD",
      ),
      //  THIRD: Venue plan
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
      } else if (Platform.isIOS) {
        productIds = {yearlyPublic, monthlyPublic, yearlyVenueProductId};
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
        } else if (Platform.isIOS) {
          if (response.notFoundIDs.isNotEmpty) {
            for (var id in response.notFoundIDs) {}
          }
        }

        if (response.error != null) {
          if (attempt < retryCount) {
            await Future.delayed(retryDelay * attempt);
            continue;
          }
          throw Exception('Store error: ${response.error}');
        }

        if (response.productDetails.isEmpty) {
          if (Platform.isIOS) {}

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
          for (var i = 0; i < _products.length; i++) {
            final product = _products[i];

            // Detect fake products
            final isFake =
                product.id.toLowerCase().contains('fake') ||
                product.title.toLowerCase().contains('fake') ||
                product.price == '\$0.00' ||
                product.price == '0';

            if (isFake) {
            } else {
              // iOS specific details
              if (product is AppStoreProductDetails) {
                print('      Raw Price: ${product.rawPrice}');
              }
            }
          }
        } else {
          // Android logging (existing)

          for (var i = 0; i < _products.length; i++) {
            final product = _products[i];

            if (product is GooglePlayProductDetails) {
              final offers = product.productDetails.subscriptionOfferDetails;
              if (offers != null && offers.isNotEmpty) {
                for (var offer in offers) {
                  if (offer.pricingPhases.isNotEmpty) {}
                }
              }
            }
          }
        }

        return _products;
      }
    } catch (e, st) {
      rethrow;
    }
  }

  // =====================================================
  //  FAKE PURCHASE SIMULATOR
  // =====================================================

  Future<void> _simulateFakePurchase(ProductDetails product) async {
    if (_fakePurchaseAlreadyDispatched) {
      return;
    }

    _fakePurchaseAlreadyDispatched = true;

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

      late PurchaseParam purchaseParam;

      if (Platform.isAndroid) {
        if (productDetails is! GooglePlayProductDetails) {
          return 'Invalid product type for Android.';
        }

        // Log available offers for debugging
        final offers = productDetails.productDetails.subscriptionOfferDetails;
        if (offers != null) {
          for (var offer in offers) {
            if (offer.pricingPhases.isNotEmpty) {}
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

          purchaseParam = GooglePlayPurchaseParam(
            productDetails: productDetails,
            applicationUserName: null,
            offerToken: offerToken, // 🟢 CRITICAL
          );
        }
      }
      // iOS purchase flow (no base plans or offer tokens)
      else if (Platform.isIOS) {
        purchaseParam = PurchaseParam(
          productDetails: productDetails,
          applicationUserName: null,
        );
      } else {
        return 'Unsupported platform.';
      }

      final bool started;
      try {
        started = await _inAppPurchase.buyNonConsumable(
          purchaseParam: purchaseParam,
        );
      } on PlatformException catch (e) {
        // ✅ CRITICAL FIX: Gracefully handle Apple ID/Sandbox popup cancellations
        // These exceptions are thrown synchronously and bypass the purchase stream.
        final isCancelled =
            e.code == 'userCancelled' ||
            e.code == 'E_USER_CANCELLED' ||
            e.message?.contains('userCancelled') == true ||
            e.message?.contains('SKErrorDomain code 2') == true;

        if (isCancelled) {
          print('');
          print('🛡️ PURCHASE CANCELLED: Detected Auth popup cancellation');
          print('   Code: ${e.code}');
          print(
            '   This is handled as a standard cancellation, not a failure.',
          );
          print('');
          return 'user_cancelled'; // Signal to bloc to handle as cancellation
        }

        rethrow; // Re-throw other platform exceptions
      }

      if (!started) {
        return 'Failed to start purchase flow.';
      }

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
      var receiptData = await SKReceiptManager.retrieveReceiptData();

      // ✅ CRITICAL FIX: If receipt is empty, refresh it from Apple
      // This commonly happens on fresh installs or after restore purchases
      if (receiptData == null || receiptData.isEmpty) {
        try {
          // Request receipt refresh from Apple
          // Using SKRequestMaker to refresh the receipt
          print('🔄 Requesting receipt refresh...');
          final requestMaker = SKRequestMaker();
          await requestMaker.startRefreshReceiptRequest();

          // Wait a moment for receipt to be written to disk
          await Future.delayed(const Duration(seconds: 2));

          // Try to retrieve again
          receiptData = await SKReceiptManager.retrieveReceiptData();

          if (receiptData != null && receiptData.isNotEmpty) {
          } else {
            return null;
          }
        } catch (refreshError, st) {
          return null;
        }
      } else {}

      if (receiptData.isEmpty) {
        return null;
      }

      return receiptData; // Already base64 encoded
    } catch (e, st) {
      // ✅ CRITICAL FIX: Check if error is "file not found" (error code 2/260)
      // This happens on fresh installs before first purchase
      final errorString = e.toString();
      final isFileNotFound =
          errorString.contains('code: 2') ||
          errorString.contains('code=2') ||
          errorString.contains('260');

      if (isFileNotFound) {
        try {
          final requestMaker = SKRequestMaker();
          await requestMaker.startRefreshReceiptRequest();

          // Wait for receipt to be generated
          await Future.delayed(const Duration(seconds: 3));

          // Try retrieving again
          final receiptData = await SKReceiptManager.retrieveReceiptData();

          if (receiptData != null && receiptData.isNotEmpty) {
            print('✅ Receipt successfully generated!');
            print('   Receipt length: ${receiptData.length} characters');
            return receiptData;
          } else {
            print('❌ Receipt still missing after refresh');
            return null;
          }
        } catch (refreshError) {
          return null;
        }
      } else {
        return null;
      }
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
      'platform': resolvedPlatform,
    };

    // ---------------- ANDROID ----------------
    if (isAndroid && purchase is GooglePlayPurchaseDetails) {
      final billing = purchase.billingClientPurchase;

      payload.addAll({
        // platform already included above
        'purchase_token': ver.serverVerificationData ?? '',
        'original_json': ver.localVerificationData ?? '',
        // Android includes verification_data (iOS does not)
        'verification_data': {
          'local_verification_data': ver.localVerificationData,
          'server_verification_data': ver.serverVerificationData,
          'source': ver.source,
        },
        // keep optional additional Android fields to help backend if it needs them
        'package_name': billing?.packageName,
        'order_id': purchase.purchaseID ?? billing?.orderId,
        // add signature if available in localVerificationData (some backends expect 'signature')
        'signature': ver.localVerificationData,
      });

      return payload;
    }

    // ---------------- iOS ----------------

    if (isIOS) {
      print('✅ ENTERING iOS SECTION (StoreKit 1 mode)');
      final tx =
          purchase is AppStorePurchaseDetails
              ? purchase.skPaymentTransaction
              : null;

      //  ✅ STOREKIT 1: Receipt is available in verificationData.serverVerificationData
      // With StoreKit 1, the receipt is provided directly by the plugin
      // No need to read from file system like StoreKit 2
      String receiptData = '';
      try {
        // ✅ CRITICAL: Always read from receipt FILE, not verificationData
        // Reason: verificationData.serverVerificationData may contain:
        // - Base64 receipt (AppStorePurchaseDetails/StoreKit 1)
        // - JWS token (SK2PurchaseDetails/StoreKit 2) ❌ Backend rejects this
        // The app receipt FILE always contains the correct base64 format

        print(
          '🔄 Reading app receipt from bundle (always use file for iOS)...',
        );
        final appReceipt = await _getAppReceiptData();
        print(
          '   _getAppReceiptData() returned: ${appReceipt != null ? "${appReceipt.length} chars" : "null"}',
        );

        if (appReceipt != null && appReceipt.isNotEmpty) {
          receiptData = appReceipt;
          print('');
          print('✅✅✅ SUCCESS: Using base64 app receipt from file');
          print('   Receipt length: ${receiptData.length} characters');
          print(
            '   Format: Base64 encoded app receipt (legacy /verifyReceipt)',
          );
          print('   Source: App receipt file via SKReceiptManager');
          print('   This will be sent to backend for verification');
          print('');
        } else {
          // Fallback: Try verificationData (may be JWS token)
          print('⚠️ App receipt file is empty');
          print(
            '   Falling back to verificationData.serverVerificationData...',
          );
          print(
            '   ⚠️ WARNING: This may be a JWS token and cause backend errors',
          );

          final verificationReceipt = ver.serverVerificationData;
          print('   Length: ${verificationReceipt?.length ?? 0} characters');

          if (verificationReceipt != null && verificationReceipt.isNotEmpty) {
            receiptData = verificationReceipt;
            print('');
            print('⚠️ Using verificationData (may be JWS, not base64 receipt)');
            print('   Receipt length: ${receiptData.length} characters');
            print('   If this fails, receipt file needs to be refreshed');
            print('');
          } else {
            // No receipt available at all
            print('');
            print('❌❌❌ CRITICAL: No receipt available!');
            print('   Possible reasons:');
            print('   1. Receipt file missing from app bundle');
            print('   2. Receipt refresh failed');
            print('   3. No purchases exist for this Apple ID');
            print('   4. Sandbox/StoreKit configuration issue');
            print('');
            print('⚠️ VERIFICATION WILL FAIL WITHOUT RECEIPT!');
            print('');
          }
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

      // ✅ NOTE: We do NOT include verification_data for iOS
      // The backend expects base64 app receipt only, not JWT tokens
      // Including serverVerificationData (JWT) causes 400 "malformed receipt" errors

      // ✅ DEBUG: Print entire iOS verification payload

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

      // ✅ CRITICAL: Save to file for TestFlight testing (force enabled for iOS)
      // This allows inspecting the receipt payload via Xcode's Download Container
      // even when console logs are not accessible in TestFlight builds
      final filePath = await PurchaseDebugLogger.logPayloadToFile(
        payload,
        forceLog: Platform.isIOS, // ✅ Force enable for iOS TestFlight debugging
      );
      if (filePath != null) {
      } else {
        print('⚠️ Failed to save payload to file');
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
