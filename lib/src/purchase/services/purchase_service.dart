import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_android/billing_client_wrappers.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';
import 'package:in_app_purchase_storekit/in_app_purchase_storekit.dart';

class PaymentService {
  // ====== CORRECT PRODUCT IDs FOR GOOGLE PLAY ======
  // For Android: product IDs
  static const String yearlyPublicProductId = "public_yearly_plan";
  static const String venueYearlyProductId = "venue_yearly_plan";

  // For iOS: Use product IDs
  static const String monthlyPublicProductId = "public_monthly_plan";
  static const String yearlyPublicProductIdIos = "venue_yearly_product";

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

      // Subscribe to real purchase stream
      _subscription = _inAppPurchase.purchaseStream.listen(
        (purchases) {
          try {
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
        id: monthlyPublicProductId, // ✅ Use monthly ID
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
        productIds = {
          venueYearlyProductId,
          yearlyPublicProductIdIos,
          monthlyPublicProductId,
        };
        print('📦 Loading iOS product IDs: $productIds');
      } else {
        throw Exception('Unsupported platform');
      }

      ProductDetailsResponse response;
      int attempt = 0;

      while (true) {
        attempt++;
        response = await _inAppPurchase.queryProductDetails(productIds);

        print('📦 queryProductDetails attempt #$attempt');
        print('  productDetails.length = ${response.productDetails.length}');
        print('  notFoundIDs = ${response.notFoundIDs}');

        if (response.error != null) {
          if (attempt < retryCount) {
            print('⚠️ Error, retrying...');
            await Future.delayed(retryDelay * attempt);
            continue;
          }
          throw Exception('Store error: ${response.error}');
        }

        if (response.productDetails.isEmpty) {
          if (attempt < retryCount) {
            print('⚠️ Empty, retrying...');
            await Future.delayed(retryDelay * attempt);
            continue;
          }
          throw Exception('No products returned.');
        }

        // ✅ CRITICAL: Keep ALL instances, don't deduplicate
        // Each instance represents a different base plan
        _products = response.productDetails;

        print('✅ Loaded ${_products.length} product instance(s)');

        // Log each instance with its offers
        for (var i = 0; i < _products.length; i++) {
          final product = _products[i];
          print('  Instance $i: ${product.id}');
          print('    Price: ${product.price}');

          if (product is GooglePlayProductDetails) {
            final offers = product.productDetails.subscriptionOfferDetails;
            if (offers != null && offers.isNotEmpty) {
              // Usually each instance has ONE primary offer
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

        return _products;
      }
    } catch (e, st) {
      print('❌ Error loading products: $e\n$st');
      rethrow;
    }
  }

  /*Future<List<ProductDetails>> loadProducts({
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

      // Platform-specific product IDs
      Set<String> productIds;
      
      if (Platform.isAndroid) {
        // Android: Use base plan IDs
        productIds = {
          venueYearlyProductId,
          yearlyPublicProductId,
          
        };
        print('📦 Loading ANDROID base plan IDs: $productIds');
      } else if (Platform.isIOS) {
        // iOS: Use product IDs
        productIds = {
          venueYearlyProductId,
          yearlyPublicProductId,
        };
        print('📦 Loading iOS product IDs: $productIds');
      } else {
        throw Exception('Unsupported platform');
      }

      ProductDetailsResponse response;
      int attempt = 0;

      while (true) {
        attempt++;
        response = await _inAppPurchase.queryProductDetails(productIds);

        print('📦 queryProductDetails attempt #$attempt');
        print('  productDetails.length = ${response.productDetails.length}');
        print('  notFoundIDs = ${response.notFoundIDs}');
        print('  response.error = ${response.error}');

        if (response.error != null) {
          if (attempt < retryCount) {
            print('⚠️ queryProductDetails returned error. Retrying in ${retryDelay.inSeconds * attempt}s');
            await Future.delayed(retryDelay * attempt);
            continue;
          }
          throw Exception('Store error: ${response.error}');
        }

        if (response.productDetails.isEmpty) {
          if (attempt < retryCount) {
            print('⚠️ queryProductDetails returned empty. notFoundIDs=${response.notFoundIDs}. Retrying...');
            await Future.delayed(retryDelay * attempt);
            continue;
          }
          throw Exception('No products returned from store. notFoundIDs=${response.notFoundIDs}');
        }

        _products = response.productDetails;
        print('✅ Loaded products: ${_products.map((p) => p.id).toList()}');
        
        // Log product details for debugging
        for (var product in _products) {
          print('  Product: ${product.id}');
          print('    Title: ${product.title}');
          print('    Price: ${product.price}');
          print('    Description: ${product.description}');
        }
        
        return _products;
      }
    } catch (e, st) {
      print('❌ Error loading products: $e\n$st');
      rethrow;
    }
  }
  */

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
        purchaseParam = PurchaseParam(
          productDetails: productDetails,
          applicationUserName: null,
        );
      } else {
        return 'Unsupported platform.';
      }

      print('🚀 Launching Google Play purchase flow…');
      print('   Selected plan price: ${productDetails.price}');
      print('   Offer Token Applied: $offerToken');

      final bool started = await _inAppPurchase.buyNonConsumable(
        purchaseParam: purchaseParam,
      );

      if (!started) {
        print('❌ Purchase flow failed to start');
        return 'Failed to start purchase flow.';
      }

      print('✅ Purchase flow started successfully');
      return null;
    } catch (e, st) {
      print('❌ purchaseProduct() ERROR: $e\n$st');
      return e.toString();
    }
  }

  // Future<String?> purchaseProduct(
  //   ProductDetails productDetails, {
  //   PurchaseDetails? oldPurchaseDetails,
  //   bool isVenueTrial = false,
  //   String? basePlanId,
  //   String? offerToken,
  // }) async {
  //   try {
  //     if (kDebugMode) {
  //       await _simulateFakePurchase(productDetails);
  //       return null;
  //     }

  //     print('🛒 Starting purchase:');
  //     print('  Product ID: ${productDetails.id}');
  //     print('  Product Title: ${productDetails.title}');
  //     print('  Base Plan ID: $basePlanId');
  //     print('  Offer Token: $offerToken');

  //     late PurchaseParam purchaseParam;

  //     if (Platform.isAndroid) {
  //       if (productDetails is! GooglePlayProductDetails) {
  //         return 'Invalid product type for Android';
  //       }

  //       // Log available offers in this product instance
  //       final offers = productDetails.productDetails.subscriptionOfferDetails;
  //       if (offers != null) {
  //         print('  📦 This product instance has ${offers.length} offer(s):');
  //         for (var offer in offers) {
  //           print('    - Base Plan: ${offer.basePlanId}');
  //           print('      Offer Token: ${offer.offerIdToken}');
  //           if (offer.pricingPhases.isNotEmpty) {
  //             print('      Price: ${offer.pricingPhases.first.formattedPrice}');
  //           }
  //         }
  //       }

  //       if (oldPurchaseDetails != null &&
  //           oldPurchaseDetails is GooglePlayPurchaseDetails) {
  //         // Upgrade/Downgrade scenario
  //         print('🔄 Upgrade/downgrade subscription');

  //         purchaseParam = GooglePlayPurchaseParam(
  //           productDetails: productDetails,
  //           changeSubscriptionParam: ChangeSubscriptionParam(
  //             oldPurchaseDetails: oldPurchaseDetails,
  //             replacementMode: ReplacementMode.withTimeProration,
  //           ),
  //         );
  //       } else {
  //         // ✅ NEW PURCHASE: Simply use the productDetails as-is
  //         // Since we passed the CORRECT instance from the bloc,
  //         // it already contains the right offer information
  //         print('📦 New subscription purchase');

  //         purchaseParam = GooglePlayPurchaseParam(
  //           productDetails: productDetails,
  //           applicationUserName: null,
  //         );
  //       }
  //     } else if (Platform.isIOS) {
  //       // iOS handles subscriptions automatically
  //       purchaseParam = PurchaseParam(
  //         productDetails: productDetails,
  //         applicationUserName: null,
  //       );
  //     } else {
  //       return 'Unsupported platform';
  //     }

  //     // Start the purchase flow
  //     print('🚀 Initiating purchase with Google Play Billing...');
  //     print('   Using product: ${productDetails.id}');
  //     print('   Product price: ${productDetails.price}');

  //     final bool started = await _inAppPurchase.buyNonConsumable(
  //       purchaseParam: purchaseParam,
  //     );

  //     if (!started) {
  //       print('❌ Purchase flow failed to start');
  //       return 'Failed to start purchase flow';
  //     }

  //     print('✅ Purchase flow started successfully');
  //     print('   Google Play should show: ${productDetails.price}');
  //     return null;
  //   } catch (e, st) {
  //     print('❌ purchaseProduct error: $e\n$st');
  //     return e.toString();
  //   }
  // }

  /*Future<String?> purchaseProduct(
    ProductDetails productDetails, {
    PurchaseDetails? oldPurchaseDetails,
    bool isVenueTrial = false,
  }) async {
    try {
      if (kDebugMode) {
        await _simulateFakePurchase(productDetails);
        return null;
      }

      late PurchaseParam purchaseParam;

      if (Platform.isAndroid) {
        GooglePlayPurchaseParam? googleParam;

        // Check if this is venue trial purchase
        if (isVenueTrial && productDetails.id == venueYearlyProductId) {
          // print('🎁 Initiating venue trial purchase with offer: $venueYearlyTrialOfferId');
          
          googleParam = GooglePlayPurchaseParam(
            productDetails: productDetails,
            applicationUserName: null, // Optional: Add user ID for tracking
          );
          
          // For trials, you may need to specify the offer token
          // This depends on how your offers are configured in Google Play Console
        } else if (oldPurchaseDetails != null && 
                   oldPurchaseDetails is GooglePlayPurchaseDetails) {
          // Upgrade/Downgrade existing subscription
          print('🔄 Upgrading/downgrading subscription');
          googleParam = GooglePlayPurchaseParam(
            productDetails: productDetails,
            changeSubscriptionParam: ChangeSubscriptionParam(
              oldPurchaseDetails: oldPurchaseDetails,
              replacementMode: ReplacementMode.withTimeProration,
            ),
          );
        } else {
          // Standard new purchase
          googleParam = GooglePlayPurchaseParam(
            productDetails: productDetails,
          );
        }

        purchaseParam = googleParam;
      } else if (Platform.isIOS) {
        // iOS handles trials and upgrades automatically via App Store
        purchaseParam = PurchaseParam(
          productDetails: productDetails,
          applicationUserName: null, // Optional: Add user ID
        );
      } else {
        return 'Unsupported platform';
      }

      // Start the purchase flow (use buyNonConsumable for subscriptions)
      final bool started = await _inAppPurchase.buyNonConsumable(
        purchaseParam: purchaseParam,
      );

      if (!started) {
        return 'Failed to start purchase flow';
      }

      print('✅ Purchase flow started successfully');
      return null;
    } catch (e, st) {
      print('❌ purchaseProduct error: $e\n$st');
      return e.toString();
    }
  }*/

  // =====================================================
  // HELPER: BUILD VERIFICATION PAYLOAD
  // =====================================================

  Map<String, dynamic> extractVerificationPayload(PurchaseDetails purchase) {
    final ver = purchase.verificationData;
    final bool isIOS = defaultTargetPlatform == TargetPlatform.iOS;
    final bool isAndroid = defaultTargetPlatform == TargetPlatform.android;

    final Map<String, dynamic> payload = <String, dynamic>{
      'product_id': purchase.productID,
      'order_id': purchase.purchaseID,
      'transaction_date': purchase.transactionDate,
      'status': purchase.status.toString(),
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
        'platform': 'android',
        'purchase_token': ver.serverVerificationData,
        'original_json': ver.localVerificationData,

        // NEW optional fields for your updated request model
        'package_name': billing?.packageName,
        'order_id': purchase.purchaseID,
      });

      return payload;
    }

    // ---------------- iOS ----------------
    if (isIOS && purchase is AppStorePurchaseDetails) {
      final tx = purchase.skPaymentTransaction;

      payload.addAll({
        'platform': 'ios',
        'receipt_data': ver.serverVerificationData,

        // NEW optional fields for your updated model
        'transaction_id': purchase.purchaseID,
        'original_transaction_id':
            tx?.originalTransaction?.transactionIdentifier,
      });

      return payload;
    }

    // ---------------- FALLBACK ----------------
    payload.addAll({
      'platform': ver.source ?? 'unknown',
      'purchase_token': ver.serverVerificationData,
      'original_json': ver.localVerificationData,
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
