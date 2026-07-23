// lib/src/purchase/services/purchase_service.dart

import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_android/billing_client_wrappers.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';
import 'package:in_app_purchase_storekit/in_app_purchase_storekit.dart';
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
        return true;
      }

      final isAvailable = await _inAppPurchase.isAvailable();

      if (!isAvailable) {
        final diag = await diagnoseStore();

        return false;
      }

      // This ensures iOS events reach the bloc even in debug mode

      _subscription = _inAppPurchase.purchaseStream.listen(
        (purchases) {
          try {
            print(
              '📡 Purchase stream event received: ${purchases.length} purchases',
            );
            for (var p in purchases) {}

            // Forward to fake controller so bloc receives events
            _fakePurchaseController.add(purchases);
            _onPurchaseUpdated(purchases);
          } catch (e, st) {}
        },
        onError: (err, st) => print('⚠️ purchaseStream onError: $err\n$st'),
        cancelOnError: false,
      );

      return true;
    } catch (e, st) {
      return false;
    }
  }

  // =====================================================
  //  FAKE PRODUCTS (DEBUG MODE)
  // =====================================================

  List<ProductDetails> _fakeProducts() {
    return [
      //  FIRST: Yearly plan
      ProductDetails(
        id: yearlyPublicProductId, //  Use yearly ID
        title: "Public Yearly Plan",
        description: "Yearly subscription for public users",
        price: "\$99.99",
        rawPrice: 99.0,
        currencyCode: "NZD",
      ),
      //  SECOND: Venue plan
      ProductDetails(
        id: venueYearlyProductId,
        title: "Venue Yearly Plan",
        description: "Venue yearly subscription with 1-month free trial",
        price: "\$99.99",
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

        return _products;
      }

      Set<String> productIds;

      if (Platform.isAndroid) {
        productIds = {venueYearlyProductId, yearlyPublicProductId};
      } else if (Platform.isIOS) {
        productIds = {yearlyPublic, yearlyVenueProductId};

        for (var id in productIds) {}
      } else {
        throw Exception('Unsupported platform');
      }

      ProductDetailsResponse response;
      int attempt = 0;

      while (true) {
        attempt++;

        if (Platform.isIOS) {
        } else {}

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
            await Future.delayed(retryDelay * attempt);
            continue;
          }
          throw Exception('No products returned.');
        }

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
              print(
                '   Fix: Edit Scheme → Run → Options → StoreKit Configuration',
              );
            } else {
              // iOS specific details
              if (product is AppStoreProductDetails) {}
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
      if (Platform.isAndroid) {}

      final bool started = await _inAppPurchase.buyNonConsumable(
        purchaseParam: purchaseParam,
      );

      if (!started) {
        return 'Failed to start purchase flow.';
      }
      return null;
    } catch (e, st) {
      return e.toString();
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

      // serverVerificationData is specifically designed for server-side verification
      // localVerificationData is for on-device validation only
      String receiptData = '';
      try {
        print(
          '   serverVerificationData length: ${ver.serverVerificationData.length}',
        );
        print(
          '   localVerificationData length: ${ver.localVerificationData.length}',
        );

        // Use serverVerificationData - this contains the correct format for /verifyReceipt
        // Works in StoreKit Testing, Sandbox, and Production
        if (ver.serverVerificationData.isNotEmpty) {
          receiptData = ver.serverVerificationData;
        } else if (ver.localVerificationData.isNotEmpty) {
          // Fallback (should not happen in normal flow)
          receiptData = ver.localVerificationData;
          print(
            '⚠️ serverVerificationData empty, using localVerificationData as fallback',
          );
        } else {}
      } catch (e, st) {
        // Fallback to serverVerificationData if error occurs
        receiptData = ver.serverVerificationData ?? '';
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

      // DEBUG: Print entire iOS verification payload
      payload.forEach((key, value) {
        if (key == 'receipt_data' || key == 'purchase_token') {
          // Don't print full receipt data (too long), just show length
        } else if (key == 'verification_data') {
          // Print verification_data details

          if (value is Map) {
            value.forEach((subKey, subValue) {
              if (subKey == 'local_verification_data' ||
                  subKey == 'server_verification_data') {
              } else {}
            });
          }
        } else {}
      });
      print(
        '   Original Transaction ID: ${payload['original_transaction_id']}',
      );
      // Also save to file for testing environments where console is not accessible
      if (kDebugMode) {
        final filePath = await PurchaseDebugLogger.logPayloadToFile(payload);
        if (filePath != null) {
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
