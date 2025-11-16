// // lib/src/features/customer/payment_plan/services/payment_service.dart

// import 'dart:async';
// import 'dart:io';
// import 'package:in_app_purchase/in_app_purchase.dart';
// import 'package:in_app_purchase_android/in_app_purchase_android.dart';
// import 'package:in_app_purchase_storekit/in_app_purchase_storekit.dart';
// import 'package:in_app_purchase_storekit/store_kit_wrappers.dart';

// class PaymentService {
//   // Product IDs - MUST match exactly with Google Play Console
//   static const String monthlyPublicId = 'public_premium_subscription';
//   static const String yearlyPublicId = 'yearly_premium_subscription';
//   static const String venueYearlyId = 'venue_yearly_subscription';
  
//   final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  
//   List<ProductDetails> _products = [];
//   List<ProductDetails> get products => _products;
  
//   Stream<List<PurchaseDetails>> get purchaseStream => 
//       _inAppPurchase.purchaseStream;
  
//   /// Initialize the payment service
//   Future<bool> initialize() async {
//     try {
//       final isAvailable = await _inAppPurchase.isAvailable();
      
//       if (!isAvailable) {
//         print('❌ In-app purchase not available');
//         return false;
//       }
      
//       if (Platform.isAndroid) {
//         await _initializeAndroid();
//       } else if (Platform.isIOS) {
//         await _initializeIOS();
//       }
      
//       print('✅ Payment service initialized successfully');
//       return true;
//     } catch (e) {
//       print('❌ Failed to initialize payment service: $e');
//       return false;
//     }
//   }
  
//   Future<void> _initializeAndroid() async {
//     final androidAddition = _inAppPurchase
//         .getPlatformAddition<InAppPurchaseAndroidPlatformAddition>();
    
//     // Note: enablePendingPurchases() is no longer needed in newer versions
//     // The plugin handles pending purchases automatically
    
//     print('✅ Android IAP initialized');
//   }
  
//   Future<void> _initializeIOS() async {
//     final iosAddition = _inAppPurchase
//         .getPlatformAddition<InAppPurchaseStoreKitPlatformAddition>();
//     await iosAddition.setDelegate(_PaymentQueueDelegate());
//     print('✅ iOS IAP initialized');
//   }
  
//   /// Load available products from store
//   Future<List<ProductDetails>> loadProducts() async {
//     try {
//       final Set<String> productIds = {
//         monthlyPublicId,
//         yearlyPublicId,
//         venueYearlyId,
//       };
      
//       print('📦 Loading products: $productIds');
      
//       final response = await _inAppPurchase.queryProductDetails(productIds);
      
//       if (response.error != null) {
//         print('❌ Error loading products: ${response.error}');
//         throw Exception('Failed to load products: ${response.error}');
//       }
      
//       if (response.notFoundIDs.isNotEmpty) {
//         print('⚠️ Products not found: ${response.notFoundIDs}');
//       }
      
//       if (response.productDetails.isEmpty) {
//         print('❌ No products found');
//         throw Exception('No subscription plans available');
//       }
      
//       _products = response.productDetails;
//       _products.sort((a, b) => a.rawPrice.compareTo(b.rawPrice));
      
//       print('✅ Loaded ${_products.length} products:');
//       for (var product in _products) {
//         print('  - ${product.id}: ${product.title} - ${product.price}');
//       }
      
//       return _products;
//     } catch (e) {
//       print('❌ Error loading products: $e');
//       rethrow;
//     }
//   }
  
//   /// Purchase a product
//   Future<bool> purchaseProduct(String productId) async {
//     try {
//       final product = _products
//           .cast<ProductDetails?>()
//           .firstWhere(
//             (p) => p?.id == productId,
//             orElse: () => null,
//           );
      
//       if (product == null) {
//         print('❌ Product not found: $productId');
//         return false;
//       }
      
//       print('💳 Initiating purchase for: ${product.id}');
      
//       final purchaseParam = PurchaseParam(productDetails: product);
      
//       final success = await _inAppPurchase.buyNonConsumable(
//         purchaseParam: purchaseParam,
//       );
      
//       print('Purchase initiated: ${success ? '✅' : '❌'}');
//       return success;
//     } catch (e) {
//       print('❌ Purchase error: $e');
//       return false;
//     }
//   }
  
//   /// Restore previous purchases
//   Future<void> restorePurchases() async {
//     try {
//       print('🔄 Restoring purchases...');
//       await _inAppPurchase.restorePurchases();
//       print('✅ Restore completed');
//     } catch (e) {
//       print('❌ Error restoring purchases: $e');
//       rethrow;
//     }
//   }
  
//   /// Complete a purchase
//   Future<void> completePurchase(PurchaseDetails purchaseDetails) async {
//     try {
//       await _inAppPurchase.completePurchase(purchaseDetails);
//       print('✅ Purchase completed: ${purchaseDetails.productID}');
//     } catch (e) {
//       print('❌ Error completing purchase: $e');
//       rethrow;
//     }
//   }
  
//   /// Get product by ID
//   ProductDetails? getProductById(String productId) {
//     try {
//       return _products.firstWhere((product) => product.id == productId);
//     } catch (e) {
//       return null;
//     }
//   }
  
//   /// Get formatted price for display
//   String getFormattedPrice(String productId) {
//     final product = getProductById(productId);
//     return product?.price ?? 'N/A';
//   }
  
//   /// Get price value for calculations
//   double getRawPrice(String productId) {
//     final product = getProductById(productId);
//     return product?.rawPrice ?? 0.0;
//   }
  
//   /// Dispose resources
//   void dispose() {
//     print('🧹 Payment service disposed');
//   }
// }

// /// iOS Payment Queue Delegate
// class _PaymentQueueDelegate implements SKPaymentQueueDelegateWrapper {
//   @override
//   bool shouldContinueTransaction(
//     SKPaymentTransactionWrapper transaction,
//     SKStorefrontWrapper storefront,
//   ) {
//     return true;
//   }

//   @override
//   bool shouldShowPriceConsent() {
//     return false;
//   }
// }



import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
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

      _subscription =
          _inAppPurchase.purchaseStream.listen(_onPurchaseUpdated);

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
        price: "\$4.99",
        rawPrice: 4.99,
        currencyCode: "USD",
      ),
      ProductDetails(
        id: yearlyPublicId,
        title: "Public Yearly Plan",
        description: "Yearly subscription for public users",
        price: "\$49.99",
        rawPrice: 49.99,
        currencyCode: "USD",
      ),
      ProductDetails(
        id: venueYearlyId,
        title: "Venue Yearly Plan",
        description: "Venue yearly subscription with 1-month free trial",
        price: "\$99.00",
        rawPrice: 99.0,
        currencyCode: "USD",
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
      await _inAppPurchase.buyNonConsumable(purchaseParam: param);

      return null;
    } catch (e) {
      print("❌ Error during purchase: $e");
      return e.toString();
    }
  }

  // =====================================================
  // REAL PURCHASE STREAM HANDLER (RELEASE ONLY)
  // =====================================================

  void _onPurchaseUpdated(List<PurchaseDetails> purchases) async {
    for (var purchase in purchases) {
      print("🔄 Purchase update: ${purchase.productID} — ${purchase.status}");

      if (purchase.status == PurchaseStatus.purchased ||
          purchase.status == PurchaseStatus.restored) {
        // notify bloc
        _fakePurchaseController.add([purchase]);
      }

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

  final pastPurchases = await _inAppPurchase.restorePurchases();
  // print("🔄 Restoring $pastPurchases past purchases");
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
