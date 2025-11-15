// lib/src/features/customer/payment_plan/services/payment_service.dart

import 'dart:async';
import 'dart:io';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';
import 'package:in_app_purchase_storekit/in_app_purchase_storekit.dart';
import 'package:in_app_purchase_storekit/store_kit_wrappers.dart';

class PaymentService {
  // Product IDs - MUST match exactly with Google Play Console
  static const String monthlyPublicId = 'monthly_premium_subscription';
  static const String yearlyPublicId = 'yearly_premium_subscription';
  static const String venueMonthlyId = 'venue_monthly_subscription';
  
  final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  
  List<ProductDetails> _products = [];
  List<ProductDetails> get products => _products;
  
  Stream<List<PurchaseDetails>> get purchaseStream => 
      _inAppPurchase.purchaseStream;
  
  /// Initialize the payment service
  Future<bool> initialize() async {
    try {
      final isAvailable = await _inAppPurchase.isAvailable();
      
      if (!isAvailable) {
        print('❌ In-app purchase not available');
        return false;
      }
      
      if (Platform.isAndroid) {
        await _initializeAndroid();
      } else if (Platform.isIOS) {
        await _initializeIOS();
      }
      
      print('✅ Payment service initialized successfully');
      return true;
    } catch (e) {
      print('❌ Failed to initialize payment service: $e');
      return false;
    }
  }
  
  Future<void> _initializeAndroid() async {
    final androidAddition = _inAppPurchase
        .getPlatformAddition<InAppPurchaseAndroidPlatformAddition>();
    
    // Note: enablePendingPurchases() is no longer needed in newer versions
    // The plugin handles pending purchases automatically
    
    print('✅ Android IAP initialized');
  }
  
  Future<void> _initializeIOS() async {
    final iosAddition = _inAppPurchase
        .getPlatformAddition<InAppPurchaseStoreKitPlatformAddition>();
    await iosAddition.setDelegate(_PaymentQueueDelegate());
    print('✅ iOS IAP initialized');
  }
  
  /// Load available products from store
  Future<List<ProductDetails>> loadProducts() async {
    try {
      final Set<String> productIds = {
        monthlyPublicId,
        yearlyPublicId,
        venueMonthlyId,
      };
      
      print('📦 Loading products: $productIds');
      
      final response = await _inAppPurchase.queryProductDetails(productIds);
      
      if (response.error != null) {
        print('❌ Error loading products: ${response.error}');
        throw Exception('Failed to load products: ${response.error}');
      }
      
      if (response.notFoundIDs.isNotEmpty) {
        print('⚠️ Products not found: ${response.notFoundIDs}');
      }
      
      if (response.productDetails.isEmpty) {
        print('❌ No products found');
        throw Exception('No subscription plans available');
      }
      
      _products = response.productDetails;
      _products.sort((a, b) => a.rawPrice.compareTo(b.rawPrice));
      
      print('✅ Loaded ${_products.length} products:');
      for (var product in _products) {
        print('  - ${product.id}: ${product.title} - ${product.price}');
      }
      
      return _products;
    } catch (e) {
      print('❌ Error loading products: $e');
      rethrow;
    }
  }
  
  /// Purchase a product
  Future<bool> purchaseProduct(String productId) async {
    try {
      final product = _products
          .cast<ProductDetails?>()
          .firstWhere(
            (p) => p?.id == productId,
            orElse: () => null,
          );
      
      if (product == null) {
        print('❌ Product not found: $productId');
        return false;
      }
      
      print('💳 Initiating purchase for: ${product.id}');
      
      final purchaseParam = PurchaseParam(productDetails: product);
      
      final success = await _inAppPurchase.buyNonConsumable(
        purchaseParam: purchaseParam,
      );
      
      print('Purchase initiated: ${success ? '✅' : '❌'}');
      return success;
    } catch (e) {
      print('❌ Purchase error: $e');
      return false;
    }
  }
  
  /// Restore previous purchases
  Future<void> restorePurchases() async {
    try {
      print('🔄 Restoring purchases...');
      await _inAppPurchase.restorePurchases();
      print('✅ Restore completed');
    } catch (e) {
      print('❌ Error restoring purchases: $e');
      rethrow;
    }
  }
  
  /// Complete a purchase
  Future<void> completePurchase(PurchaseDetails purchaseDetails) async {
    try {
      await _inAppPurchase.completePurchase(purchaseDetails);
      print('✅ Purchase completed: ${purchaseDetails.productID}');
    } catch (e) {
      print('❌ Error completing purchase: $e');
      rethrow;
    }
  }
  
  /// Get product by ID
  ProductDetails? getProductById(String productId) {
    try {
      return _products.firstWhere((product) => product.id == productId);
    } catch (e) {
      return null;
    }
  }
  
  /// Get formatted price for display
  String getFormattedPrice(String productId) {
    final product = getProductById(productId);
    return product?.price ?? 'N/A';
  }
  
  /// Get price value for calculations
  double getRawPrice(String productId) {
    final product = getProductById(productId);
    return product?.rawPrice ?? 0.0;
  }
  
  /// Dispose resources
  void dispose() {
    print('🧹 Payment service disposed');
  }
}

/// iOS Payment Queue Delegate
class _PaymentQueueDelegate implements SKPaymentQueueDelegateWrapper {
  @override
  bool shouldContinueTransaction(
    SKPaymentTransactionWrapper transaction,
    SKStorefrontWrapper storefront,
  ) {
    return true;
  }

  @override
  bool shouldShowPriceConsent() {
    return false;
  }
}