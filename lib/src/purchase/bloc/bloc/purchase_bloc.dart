// lib/src/purchase/bloc/payment_plan_bloc.dart

import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';
import 'package:soloseaters/src/purchase/bloc/bloc/purchase_event.dart';
import 'package:soloseaters/src/purchase/bloc/bloc/purchase_state.dart';
import 'package:soloseaters/src/purchase/repository/purchase_repository.dart';
import 'package:soloseaters/src/purchase/services/purchase_service.dart';
import 'package:soloseaters/src/utils/data/object_factory.dart';

class PaymentPlanBloc extends Bloc<PaymentPlanEvent, PaymentPlanState> {
  final PaymentService paymentService;
  final PaymentRepository _paymentRepository;
  StreamSubscription<List<PurchaseDetails>>? _purchaseSubscription;
  // ✅ NEW: Track current user to detect switches
  String? _currentUserId;

  PaymentPlanBloc({
    required PaymentService paymentService,
    required PaymentRepository paymentRepository,
  }) : paymentService = paymentService,
       _paymentRepository = paymentRepository,
       super(const PaymentPlanState()) {
    on<InitializePaymentEvent>(_onInitialize);
    on<LoadProductsEvent>(_onLoadProducts);
    on<SelectPlanEvent>(_onSelectPlan);
    on<PurchaseSelectedPlanEvent>(_onPurchaseSelectedPlan);
    on<PurchaseProductEvent>(_onPurchaseProduct);
    on<HandlePurchaseUpdateEvent>(_onHandlePurchaseUpdate);
    on<VerifyPurchaseEvent>(_onVerifyPurchase);
    on<RestorePurchasesEvent>(_onRestorePurchases);
    on<CheckSubscriptionStatusEvent>(_onCheckSubscriptionStatus);
    on<CancelPurchaseEvent>(_onCancelPurchase);
    on<ClearErrorEvent>(_onClearError);
    on<RetryVerificationEvent>(_onRetryVerification); // NEW
    on<CheckPendingPurchasesEvent>(_onCheckPendingPurchases); // NEW
    on<ResetStateEvent>(_onResetState);
  }

  // ✅ NEW: Reset state completely on user change
  Future<void> _onResetState(
    ResetStateEvent event,
    Emitter<PaymentPlanState> emit,
  ) async {
    print('🔄 Resetting PaymentPlanBloc state...');

    // Cancel existing subscriptions
    await _purchaseSubscription?.cancel();
    _purchaseSubscription = null;

    // Reset to initial state
    emit(const PaymentPlanState());

    // Clear current user tracking
    _currentUserId = null;

    print('✅ PaymentPlanBloc state reset complete');
  }

  Future<void> _onInitialize(
    InitializePaymentEvent event,
    Emitter<PaymentPlanState> emit,
  ) async {
    try {
      emit(state.copyWith(status: PaymentPlanStatus.loading));
      // ✅ NEW: Detect user change and reset if needed
      final prefs = ObjectFactory().prefs;
      final newUserId =
          prefs.getCafeUserId() ??
          prefs.getUserId() ??
          prefs.getCustomerUserMail() ??
          'anonymous';

      if (_currentUserId != null && _currentUserId != newUserId) {
        print(
          '⚠️ User changed from $_currentUserId to $newUserId - resetting state',
        );
        // Cancel old subscription
        await _purchaseSubscription?.cancel();
        _purchaseSubscription = null;

        // Reset to initial state before proceeding
        emit(const PaymentPlanState());
      }

      _currentUserId = newUserId;
      print('👤 Current user ID: $_currentUserId');
      final isAvailable = await paymentService.initialize();

      if (!isAvailable) {
        emit(
          state.copyWith(
            status: PaymentPlanStatus.purchaseFailed,
            errorMessage: 'In-app purchases are not available on this device',
          ),
        );
        return;
      }

      _purchaseSubscription = paymentService.purchaseStream.listen(
        (purchaseDetailsList) {
          add(HandlePurchaseUpdateEvent(purchaseDetailsList));
        },
        onError: (error) {
          add(const ClearErrorEvent());
        },
      );

      final userData = await _paymentRepository.getUserSubscriptionData();
      print("DEBUG USER DATA: $userData");

      final determinedUserType = userData['userType'] as UserType;
      print("✅ Determined user type: $determinedUserType");

      emit(
        state.copyWith(
          status: PaymentPlanStatus.initial,
          userType: determinedUserType,
          isPremium: userData['isPremium'] as bool,
          trialStartDate: userData['trialStartDate'] as DateTime?,
          trialEndDate: userData['trialEndDate'] as DateTime?,
          subscriptionExpiryDate:
              userData['subscriptionExpiryDate'] as DateTime?,
          currentSubscriptionId: userData['currentSubscriptionId'] as String?,
        ),
      );

      add(const LoadProductsEvent());

      // ✅ NEW: Check for pending purchases after initialization
      add(const CheckPendingPurchasesEvent());
    } catch (e) {
      emit(
        state.copyWith(
          status: PaymentPlanStatus.purchaseFailed,
          errorMessage: 'Failed to initialize: ${e.toString()}',
        ),
      );
    }
  }

  // ✅ NEW: Check for pending/unverified purchases
  Future<void> _onCheckPendingPurchases(
    CheckPendingPurchasesEvent event,
    Emitter<PaymentPlanState> emit,
  ) async {
    try {
      print('🔍 Checking for pending purchases...');

      // Query past purchases to find any that weren't completed
      await InAppPurchase.instance.restorePurchases();

      // The purchase stream listener will handle any restored purchases
    } catch (e) {
      print('⚠️ Error checking pending purchases: $e');
      // Don't fail initialization, just log
    }
  }

  // _onLoadProducts fixed version

  Future<void> _onLoadProducts(
  LoadProductsEvent event,
  Emitter<PaymentPlanState> emit,
) async {
  try {
    emit(state.copyWith(status: PaymentPlanStatus.loading));

    final allProducts = await paymentService.loadProducts();

    if (allProducts.isEmpty) {
      emit(
        state.copyWith(
          status: PaymentPlanStatus.purchaseFailed,
          errorMessage: 'No subscription plans available.',
        ),
      );
      return;
    }

    print('📦 Processing products for user type: ${state.userType}');
    print('📦 Is venue user: ${state.isVenueUser}');
    print('📦 Total product instances: ${allProducts.length}');

    final Map<String, Map<String, dynamic>> uniqueEntries = {};

    void addExpandedEntry({
      required ProductDetails product,
      required String? basePlanId,
      required String? offerToken,
      required List? pricingPhases,
    }) {
      final key = '${product.id}:${basePlanId ?? 'null'}';

      if (!uniqueEntries.containsKey(key)) {
        String? formattedPrice;
        double? rawPrice;
        String? billingPeriod;

        // Extract price and billing period from pricing phases
        if (pricingPhases != null && pricingPhases.isNotEmpty) {
          try {
            final phase = pricingPhases.first;
            
            if (phase is Map) {
              formattedPrice = phase['formattedPrice'] as String?;
              billingPeriod = phase['billingPeriod'] as String?;
              final priceAmountMicros = phase['priceAmountMicros'] as int?;
              if (priceAmountMicros != null) {
                rawPrice = priceAmountMicros / 1000000.0;
              }
            } else {
              // PricingPhaseWrapper object
              formattedPrice = phase.formattedPrice as String;
              billingPeriod = phase.billingPeriod as String;
              rawPrice = phase.priceAmountMicros / 1000000.0;
            }
          } catch (e) {
            print("❌ Error extracting pricing phase: $e");
          }
        }

        uniqueEntries[key] = {
          'product': product,
          'basePlanId': basePlanId,
          'offerToken': offerToken,
          'pricingPhases': pricingPhases,
          'formattedPrice': formattedPrice ?? product.price,
          'rawPrice': rawPrice ?? product.rawPrice,
          'billingPeriod': billingPeriod,
        };

        print('  ✅ Added: $key price=$formattedPrice period=$billingPeriod');
      }
    }

    // ✅ FIXED: Platform-specific product filtering
    if (state.isVenueUser) {
      // Filter for venue products using platform-specific constants
      final venueProducts = allProducts.where((p) {
        if (Platform.isAndroid) {
          return p.id == PaymentService.venueYearlyProductId; // "venue_yearly_plan"
        } else {
          return p.id == PaymentService.yearlyVenueProductId; // "venue_yearly_product"
        }
      }).toList();
      
      print('📦 Found ${venueProducts.length} venue products for ${Platform.isAndroid ? "Android" : "iOS"}');
      
      for (var product in venueProducts) {
        if (Platform.isAndroid && product is GooglePlayProductDetails) {
          final offers = product.productDetails.subscriptionOfferDetails;
          if (offers != null) {
            for (var offer in offers) {
              addExpandedEntry(
                product: product,
                basePlanId: offer.basePlanId,
                offerToken: offer.offerIdToken,
                pricingPhases: offer.pricingPhases,
              );
            }
          } else {
            addExpandedEntry(
              product: product,
              basePlanId: null,
              offerToken: null,
              pricingPhases: null,
            );
          }
        } else {
          // iOS products
          addExpandedEntry(
            product: product,
            basePlanId: null,
            offerToken: null,
            pricingPhases: null,
          );
        }
      }
    } else {
      // ✅ FIXED: Platform-specific filtering for public products
      final publicProducts = allProducts.where((p) {
        if (Platform.isAndroid) {
          return p.id == PaymentService.yearlyPublicProductId; // "public_yearly_plan"
        } else {
          // iOS has both yearly and monthly
          return p.id == PaymentService.yearlyPublic ||  // "public_yearly"
                 p.id == PaymentService.monthlyPublic;   // "public_monthly"
        }
      }).toList();

      print('📦 Found ${publicProducts.length} public products for ${Platform.isAndroid ? "Android" : "iOS"}');

      for (var product in publicProducts) {
        if (Platform.isAndroid && product is GooglePlayProductDetails) {
          final offers = product.productDetails.subscriptionOfferDetails;
          if (offers != null) {
            for (var offer in offers) {
              addExpandedEntry(
                product: product,
                basePlanId: offer.basePlanId,
                offerToken: offer.offerIdToken,
                pricingPhases: offer.pricingPhases,
              );
            }
          } else {
            addExpandedEntry(
              product: product,
              basePlanId: null,
              offerToken: null,
              pricingPhases: null,
            );
          }
        } else {
          // iOS products
          addExpandedEntry(
            product: product,
            basePlanId: null,
            offerToken: null,
            pricingPhases: null,
          );
        }
      }
    }

    if (uniqueEntries.isEmpty) {
      print('❌ No products matched the filter criteria!');
      print('   User type: ${state.userType}');
      print('   Is venue: ${state.isVenueUser}');
      print('   Product IDs received: ${allProducts.map((p) => p.id).toList()}');
      print('   Looking for venue: ${PaymentService.yearlyVenueProductId}');
      print('   Looking for public: ${PaymentService.yearlyPublic}, ${PaymentService.monthlyPublic}');
      
      emit(
        state.copyWith(
          status: PaymentPlanStatus.purchaseFailed,
          errorMessage: 'No subscription plans available.',
        ),
      );
      return;
    }

    final expandedProductsList = uniqueEntries.values.toList();

    print('✅ Final expanded products: ${expandedProductsList.length}');
    for (var ep in expandedProductsList) {
      final prod = ep['product'] as ProductDetails;
      final basePlan = ep['basePlanId'];
      final price = ep['formattedPrice'];
      print('   ${prod.id}:$basePlan ($price)');
    }

    // Keep unique ProductDetails
    final uniqueProducts = <String, ProductDetails>{};
    for (var entry in expandedProductsList) {
      final product = entry['product'] as ProductDetails;
      uniqueProducts[product.id] = product;
    }

    emit(
      state.copyWith(
        status: PaymentPlanStatus.productsLoaded,
        products: uniqueProducts.values.toList(),
        expandedProducts: expandedProductsList,
      ),
    );
  } catch (e, st) {
    print('❌ Error loading products: $e\n$st');
    emit(
      state.copyWith(
        status: PaymentPlanStatus.purchaseFailed,
        errorMessage: 'Failed to load plans: ${e.toString()}',
      ),
    );
  }
}

/*Future<void> _onLoadProducts(
  LoadProductsEvent event,
  Emitter<PaymentPlanState> emit,
) async {
  try {
    emit(state.copyWith(status: PaymentPlanStatus.loading));

      final allProducts = await paymentService.loadProducts();

      if (allProducts.isEmpty) {
        emit(
          state.copyWith(
            status: PaymentPlanStatus.purchaseFailed,
            errorMessage: 'No subscription plans available.',
          ),
        );
        return;
      }

      print('📦 Processing products for user type: ${state.userType}');
      print('📦 Is venue user: ${state.isVenueUser}');
      print('📦 Total product instances: ${allProducts.length}');

      final Map<String, Map<String, dynamic>> uniqueEntries = {};

      void addExpandedEntry({
        required ProductDetails product,
        required String? basePlanId,
        required String? offerToken,
        required List? pricingPhases,
      }) {
        final key = '${product.id}:${basePlanId ?? 'null'}';

        if (!uniqueEntries.containsKey(key)) {
          String? formattedPrice;
          double? rawPrice;
          String? billingPeriod;

          // ✅ Extract price and billing period from pricing phases
          if (pricingPhases != null && pricingPhases.isNotEmpty) {
            try {
              final phase = pricingPhases.first;

              if (phase is Map) {
                formattedPrice = phase['formattedPrice'] as String?;
                billingPeriod = phase['billingPeriod'] as String?;
                final priceAmountMicros = phase['priceAmountMicros'] as int?;
                if (priceAmountMicros != null) {
                  rawPrice = priceAmountMicros / 1000000.0;
                }
              } else {
                // PricingPhaseWrapper object
                formattedPrice = phase.formattedPrice as String;
                billingPeriod = phase.billingPeriod as String;
                rawPrice = phase.priceAmountMicros / 1000000.0;
              }
            } catch (e) {
              print("❌ Error extracting pricing phase: $e");
            }
          }

          uniqueEntries[key] = {
            'product': product,
            'basePlanId': basePlanId,
            'offerToken': offerToken,
            'pricingPhases': pricingPhases,
            'formattedPrice': formattedPrice ?? product.price,
            'rawPrice': rawPrice ?? product.rawPrice,
            'billingPeriod': billingPeriod, // ✅ Store billing period
          };

          print('  ✅ Added: $key price=$formattedPrice period=$billingPeriod');
        }
      }

      if (state.isVenueUser) {
        final venueProducts =
            allProducts
                .where((p) => p.id == PaymentService.venueYearlyProductId)
                .toList();

        for (var product in venueProducts) {
          if (Platform.isAndroid && product is GooglePlayProductDetails) {
            final offers = product.productDetails.subscriptionOfferDetails;
            if (offers != null) {
              for (var offer in offers) {
                addExpandedEntry(
                  product: product,
                  basePlanId: offer.basePlanId,
                  offerToken: offer.offerIdToken,
                  pricingPhases: offer.pricingPhases,
                );
              }
            } else {
              addExpandedEntry(
                product: product,
                basePlanId: null,
                offerToken: null,
                pricingPhases: null,
              );
            }
          } else {
            addExpandedEntry(
              product: product,
              basePlanId: null,
              offerToken: null,
              pricingPhases: null,
            );
          }
        }
      } else {
        // Public users
        final publicProducts =
            allProducts
                .where((p) => p.id == PaymentService.yearlyPublicProductId)
                .toList();

        for (var product in publicProducts) {
          if (Platform.isAndroid && product is GooglePlayProductDetails) {
            final offers = product.productDetails.subscriptionOfferDetails;
            if (offers != null) {
              for (var offer in offers) {
                addExpandedEntry(
                  product: product,
                  basePlanId: offer.basePlanId,
                  offerToken: offer.offerIdToken,
                  pricingPhases: offer.pricingPhases,
                );
              }
            } else {
              addExpandedEntry(
                product: product,
                basePlanId: null,
                offerToken: null,
                pricingPhases: null,
              );
            }
          } else {
            addExpandedEntry(
              product: product,
              basePlanId: null,
              offerToken: null,
              pricingPhases: null,
            );
          }
        }
      }

      if (uniqueEntries.isEmpty) {
        emit(
          state.copyWith(
            status: PaymentPlanStatus.purchaseFailed,
            errorMessage: 'No subscription plans available.',
          ),
        );
        return;
      }

      final expandedProductsList = uniqueEntries.values.toList();

      print('✅ Final expanded products: ${expandedProductsList.length}');
      for (var ep in expandedProductsList) {
        final prod = ep['product'] as ProductDetails;
        final basePlan = ep['basePlanId'];
        final price = ep['formattedPrice']; // ✅ Use stored price
        print('   ${prod.id}:$basePlan ($price)');
      }

      // Keep unique ProductDetails
      final uniqueProducts = <String, ProductDetails>{};
      for (var entry in expandedProductsList) {
        final product = entry['product'] as ProductDetails;
        uniqueProducts[product.id] = product;
      }

    emit(
      state.copyWith(
        status: PaymentPlanStatus.productsLoaded,
        products: uniqueProducts.values.toList(),
        expandedProducts: expandedProductsList,
      ),
    );
  } catch (e, st) {
    print('❌ Error loading products: $e\n$st');
    emit(
      state.copyWith(
        status: PaymentPlanStatus.purchaseFailed,
        errorMessage: 'Failed to load plans: ${e.toString()}',
      ),
    );
  }
}*/

  void _onSelectPlan(SelectPlanEvent event, Emitter<PaymentPlanState> emit) {
    print('✅ Selecting plan:');
    print('   Product: ${event.productId}');
    print('   Base Plan: ${event.basePlanId}');
    print('   Offer Token: ${event.offerToken}');

    emit(
      state.copyWith(
        selectedProductId: event.productId,
        selectedBasePlanId: event.basePlanId,
        selectedOfferToken: event.offerToken, // ✅ NEW
        clearError: true,
      ),
    );
  }

  Future<void> _onPurchaseSelectedPlan(
    PurchaseSelectedPlanEvent event,
    Emitter<PaymentPlanState> emit,
  ) async {
    if (state.selectedProductId == null) {
      emit(
        state.copyWith(
          status: PaymentPlanStatus.purchaseFailed,
          errorMessage: 'Please select a plan first',
        ),
      );
      return;
    }

    add(PurchaseProductEvent(state.selectedProductId!));
  }

  // Replace _onPurchaseProduct in PaymentPlanBloc

  Future<void> _onPurchaseProduct(
    PurchaseProductEvent event,
    Emitter<PaymentPlanState> emit,
  ) async {
    try {
      if (state.isProcessing == true) {
        emit(
          state.copyWith(
            status: PaymentPlanStatus.purchaseFailed,
            errorMessage: 'Purchase already in progress',
          ),
        );
        return;
      }

      emit(
        state.copyWith(
          status: PaymentPlanStatus.purchasing,
          isProcessing: true,
          clearError: true,
        ),
      );

      // ✅ CRITICAL FIX: Find the EXACT product instance that matches
      // both the product ID AND the selected base plan
      ProductDetails? targetProduct;

      if (state.selectedBasePlanId != null && state.expandedProducts != null) {
        // Find the expanded product that matches our selection
        final matchingExpanded = state.expandedProducts!.firstWhere((ep) {
          final prod = ep['product'] as ProductDetails;
          final basePlan = ep['basePlanId'] as String?;
          return prod.id == event.productId &&
              basePlan == state.selectedBasePlanId;
        }, orElse: () => <String, dynamic>{});

        if (matchingExpanded.isNotEmpty) {
          targetProduct = matchingExpanded['product'] as ProductDetails;
          print(
            '✅ Found exact product for base plan: ${state.selectedBasePlanId}',
          );
        }
      }

      // Fallback: use first product with matching ID
      if (targetProduct == null) {
        targetProduct = state.products.firstWhere(
          (p) => p.id == event.productId,
          orElse:
              () => throw Exception("Product not found: ${event.productId}"),
        );
        print('⚠️ Using fallback product (base plan might not match)');
      }

      final isVenueTrial =
          state.isVenueUser &&
          state.userType == UserType.venueTrial &&
          !state.isInTrialPeriod;

      print('🛒 Purchasing:');
      print('   Product: ${targetProduct.id}');
      print('   Selected base plan: ${state.selectedBasePlanId}');
      print('   Selected offer token: ${state.selectedOfferToken}');
      print('   Is venue trial: $isVenueTrial');

      // ✅ Pass the CORRECT product instance and offer token
      final errorMessage = await paymentService.purchaseProduct(
        targetProduct, // Use the specific instance
        isVenueTrial: isVenueTrial,
        basePlanId: state.selectedBasePlanId,
        offerToken: state.selectedOfferToken,
      );

      if (errorMessage != null) {
        if (errorMessage.contains('ITEM_ALREADY_OWNED') ||
            errorMessage.contains('already subscribed')) {
          print('⚠️ Item already owned, triggering restore...');

          emit(
            state.copyWith(
              status: PaymentPlanStatus.needsRestore,
              errorMessage:
                  'You already have an active subscription. Restoring...',
              isProcessing: false,
            ),
          );

          add(const RestorePurchasesEvent());
        } else {
          emit(
            state.copyWith(
              status: PaymentPlanStatus.purchaseFailed,
              errorMessage: errorMessage,
              isProcessing: false,
            ),
          );
        }
      }
    } catch (e) {
      emit(
        state.copyWith(
          status: PaymentPlanStatus.purchaseFailed,
          errorMessage: 'Purchase error: ${e.toString()}',
          isProcessing: false,
        ),
      );
    }
  }

  Future<void> _onHandlePurchaseUpdate(
    HandlePurchaseUpdateEvent event,
    Emitter<PaymentPlanState> emit,
  ) async {
    for (final purchaseDetails in event.purchaseDetailsList) {
      print(
        '📱 Purchase status: ${purchaseDetails.status} for ${purchaseDetails.productID}',
      );

      if (purchaseDetails.status == PurchaseStatus.purchased ||
          purchaseDetails.status == PurchaseStatus.restored) {
        // ✅ Store purchase details for retry capability
        final payload = paymentService.extractVerificationPayload(
          purchaseDetails,
        );

        emit(
          state.copyWith(
            pendingPurchase: purchaseDetails,
            pendingPayload: payload,
          ),
        );

        add(VerifyPurchaseEvent(purchaseDetails, payload));
      } else if (purchaseDetails.status == PurchaseStatus.error) {
        final errorCode = purchaseDetails.error?.code;
        final errorMessage =
            purchaseDetails.error?.message ?? 'Purchase failed';

        // ✅ Handle specific error codes
        if (errorCode == 'ITEM_ALREADY_OWNED') {
          emit(
            state.copyWith(
              status: PaymentPlanStatus.needsRestore,
              errorMessage:
                  'You already have an active subscription. Restoring...',
              isProcessing: false,
            ),
          );
          add(const RestorePurchasesEvent());
        } else {
          emit(
            state.copyWith(
              status: PaymentPlanStatus.purchaseFailed,
              errorMessage: errorMessage,
              isProcessing: false,
            ),
          );
        }
      } else if (purchaseDetails.status == PurchaseStatus.canceled) {
        emit(
          state.copyWith(
            status: PaymentPlanStatus.cancelled,
            errorMessage: 'Purchase was cancelled',
            isProcessing: false,
          ),
        );
      } else if (purchaseDetails.status == PurchaseStatus.pending) {
        emit(
          state.copyWith(
            status: PaymentPlanStatus.purchasing,
            isProcessing: true,
          ),
        );
      }

      // ✅ Only complete purchase AFTER successful verification
      // Don't complete here - do it in _onVerifyPurchase
    }
  }

  // ✅ NEW: Retry verification with exponential backoff
  Future<void> _onRetryVerification(
    RetryVerificationEvent event,
    Emitter<PaymentPlanState> emit,
  ) async {
    if (state.pendingPurchase == null || state.pendingPayload == null) {
      emit(
        state.copyWith(
          status: PaymentPlanStatus.purchaseFailed,
          errorMessage: 'No pending purchase to verify',
        ),
      );
      return;
    }

    print('🔄 Retrying verification (attempt ${event.attemptNumber})...');

    // Exponential backoff: 2s, 4s, 8s
    final delay = Duration(seconds: 2 * event.attemptNumber);
    await Future.delayed(delay);

    add(VerifyPurchaseEvent(state.pendingPurchase!, state.pendingPayload!));
  }

  Future<void> _onVerifyPurchase(
    VerifyPurchaseEvent event,
    Emitter<PaymentPlanState> emit,
  ) async {
    try {
      emit(state.copyWith(status: PaymentPlanStatus.verifying));

      final purchaseDetails = event.purchaseDetails;
      final payload = Map<String, dynamic>.from(event.verificationPayload);

      // --- DEBUG: print the payload and ensure platform is present ---
      print('');
      print('═══════════════════════════════════════════');
      print('🔍 VERIFICATION PAYLOAD DEBUG');
      print('═══════════════════════════════════════════');
      print('📦 Payload keys: ${payload.keys.toList()}');
      print('📦 Has platform? ${payload.containsKey('platform')}');
      if (payload.containsKey('platform')) {
        print('📦 Platform value: ${payload['platform']}');
      } else {
        print('⚠️ MISSING platform field, attempting to infer now...');
        // attempt to infer platform from purchaseDetails/ver.source
        final inferredPlatform =
            (purchaseDetails.verificationData?.source ?? '')
                .toString()
                .toLowerCase();
        if (inferredPlatform.contains('appstore') ||
            inferredPlatform.contains('ios')) {
          payload['platform'] = 'ios';
        } else if (inferredPlatform.contains('googleplay') ||
            inferredPlatform.contains('android')) {
          payload['platform'] = 'android';
        } else {
          // final fallback: use runtime target
          payload['platform'] =
              defaultTargetPlatform == TargetPlatform.iOS ? 'ios' : 'android';
        }
        print('✅ Inferred platform: ${payload['platform']}');
      }
      print('═══════════════════════════════════════════');
      print('');

      Map<String, dynamic> verificationResult = {'valid': true};

      if (!kDebugMode) {
        verificationResult = await _paymentRepository.verifyPurchase(payload);
      }

      final verified = verificationResult['valid'] == true;

      if (!verified) {
        final errorMessage =
            verificationResult['message'] as String? ??
            'Purchase verification failed';

        // Check if this is a server/network retryable error
        final isRetryable =
            errorMessage.contains('500') ||
            errorMessage.contains('SQLSTATE') ||
            errorMessage.toLowerCase().contains('network') ||
            errorMessage.toLowerCase().contains('timeout') ||
            errorMessage.toLowerCase().contains('connection');

        if (isRetryable && (state.verificationAttempts ?? 0) < 3) {
          print(
            '⚠️ Verification failed with retryable error, will retry... (attempt ${state.verificationAttempts ?? 0 + 1})',
          );

          emit(
            state.copyWith(
              status: PaymentPlanStatus.verificationFailed,
              errorMessage:
                  'Verification failed. Retrying... (${state.verificationAttempts ?? 0 + 1}/3)',
              verificationAttempts: (state.verificationAttempts ?? 0) + 1,
            ),
          );

          // add retry event – keep your existing RetryVerificationEvent logic
          add(RetryVerificationEvent(state.verificationAttempts ?? 1));
          return;
        }

        // Non-retryable or max retries exceeded
        emit(
          state.copyWith(
            status: PaymentPlanStatus.verificationFailed,
            errorMessage:
                'Unable to verify your purchase. Please contact support with your order ID: ${purchaseDetails.purchaseID}',
            isProcessing: false,
            verificationAttempts: 0,
          ),
        );

        // Do not complete the purchase here; let the user contact support if needed
        return;
      }

      // SUCCESS: complete the purchase if pending
      if (purchaseDetails.pendingCompletePurchase) {
        await InAppPurchase.instance.completePurchase(purchaseDetails);
        print('✅ Purchase completed on store');
      }

      // Clear pending purchase info
      emit(
        state.copyWith(
          pendingPurchase: null,
          pendingPayload: null,
          verificationAttempts: 0,
        ),
      );

      final userData = await _paymentRepository.getUserSubscriptionData();

      emit(
        state.copyWith(
          status: PaymentPlanStatus.purchaseSuccess,
          isPremium: userData['isPremium'] as bool?,
          userType: userData['userType'] as UserType?,
          trialStartDate: userData['trialStartDate'] as DateTime?,
          trialEndDate: userData['trialEndDate'] as DateTime?,
          subscriptionExpiryDate:
              userData['subscriptionExpiryDate'] as DateTime?,
          currentSubscriptionId: userData['currentSubscriptionId'] as String?,
          isProcessing: false,
        ),
      );

      print('✅ Purchase verified and state updated');
      print('   User type: ${userData['userType']}');
      print('   Is premium: ${userData['isPremium']}');
      print('   Trial end: ${userData['trialEndDate']}');
    } catch (e) {
      final isRetryable =
          e.toString().contains('SocketException') ||
          e.toString().contains('TimeoutException') ||
          e.toString().contains('Connection');

      if (isRetryable && (state.verificationAttempts ?? 0) < 3) {
        emit(
          state.copyWith(
            status: PaymentPlanStatus.verificationFailed,
            errorMessage:
                'Connection error. Retrying... (${state.verificationAttempts ?? 0 + 1}/3)',
            verificationAttempts: (state.verificationAttempts ?? 0) + 1,
          ),
        );

        add(RetryVerificationEvent(state.verificationAttempts ?? 1));
        return;
      }

      emit(
        state.copyWith(
          status: PaymentPlanStatus.verificationFailed,
          errorMessage:
              'Unable to verify purchase. Please contact support with order ID: ${event.purchaseDetails.purchaseID}',
          isProcessing: false,
          verificationAttempts: 0,
        ),
      );
    }
  }

  /*Future<void> _onVerifyPurchase(
    VerifyPurchaseEvent event,
    Emitter<PaymentPlanState> emit,
  ) async {
    try {
      emit(state.copyWith(status: PaymentPlanStatus.verifying));

      final purchaseDetails = event.purchaseDetails;
      final payload = Map<String, dynamic>.from(event.verificationPayload);

      Map<String, dynamic> verificationResult = {'valid': true};

      if (!kDebugMode) {
        verificationResult = await _paymentRepository.verifyPurchase(payload);
      }

      final verified = verificationResult['valid'] == true;

      if (!verified) {
        final errorMessage =
            verificationResult['message'] as String? ??
            'Purchase verification failed';

        // ✅ Check if this is a server error (500, network issue)
        final isRetryable =
            errorMessage.contains('500') ||
            errorMessage.contains('SQLSTATE') ||
            errorMessage.contains('network') ||
            errorMessage.contains('timeout');

        if (isRetryable && (state.verificationAttempts ?? 0) < 3) {
          print(
            '⚠️ Verification failed with retryable error, will retry... (attempt ${state.verificationAttempts ?? 0 + 1})',
          );

          emit(
            state.copyWith(
              status: PaymentPlanStatus.verificationFailed,
              errorMessage:
                  'Verification failed. Retrying... (${state.verificationAttempts ?? 0 + 1}/3)',
              verificationAttempts: (state.verificationAttempts ?? 0) + 1,
            ),
          );

          // ✅ Retry with backoff
          add(RetryVerificationEvent(state.verificationAttempts ?? 1));
          return;
        }

        // ✅ Max retries exceeded or non-retryable error
        emit(
          state.copyWith(
            status: PaymentPlanStatus.verificationFailed,
            errorMessage:
                'Unable to verify your purchase. Please contact support with your order ID: ${purchaseDetails.purchaseID}',
            isProcessing: false,
            verificationAttempts: 0,
          ),
        );

        // ✅ DON'T complete the purchase - let user contact support
        // The purchase will remain in "pending" state and can be verified later
        return;
      }

      // ✅ SUCCESS: Complete the purchase transaction
      if (purchaseDetails.pendingCompletePurchase) {
        await InAppPurchase.instance.completePurchase(purchaseDetails);
        print('✅ Purchase completed on store');
      }

      // Clear pending purchase info
      emit(
        state.copyWith(
          pendingPurchase: null,
          pendingPayload: null,
          verificationAttempts: 0,
        ),
      );

      final userData = await _paymentRepository.getUserSubscriptionData();

      emit(
        state.copyWith(
          status: PaymentPlanStatus.purchaseSuccess,
          isPremium: userData['isPremium'] as bool?,
          userType: userData['userType'] as UserType?,
          trialStartDate: userData['trialStartDate'] as DateTime?,
          trialEndDate: userData['trialEndDate'] as DateTime?,
          subscriptionExpiryDate:
              userData['subscriptionExpiryDate'] as DateTime?,
          currentSubscriptionId: userData['currentSubscriptionId'] as String?,
          isProcessing: false,
        ),
      );

      print('✅ Purchase verified and state updated');
      print('   User type: ${userData['userType']}');
      print('   Is premium: ${userData['isPremium']}');
      print('   Trial end: ${userData['trialEndDate']}');
    } catch (e) {
      // ✅ Handle unexpected errors with retry logic
      final isRetryable =
          e.toString().contains('SocketException') ||
          e.toString().contains('TimeoutException') ||
          e.toString().contains('Connection');

      if (isRetryable && (state.verificationAttempts ?? 0) < 3) {
        emit(
          state.copyWith(
            status: PaymentPlanStatus.verificationFailed,
            errorMessage:
                'Connection error. Retrying... (${state.verificationAttempts ?? 0 + 1}/3)',
            verificationAttempts: (state.verificationAttempts ?? 0) + 1,
          ),
        );

        add(RetryVerificationEvent(state.verificationAttempts ?? 1));
        return;
      }

      emit(
        state.copyWith(
          status: PaymentPlanStatus.verificationFailed,
          errorMessage:
              'Unable to verify purchase. Please contact support with order ID: ${event.purchaseDetails.purchaseID}',
          isProcessing: false,
          verificationAttempts: 0,
        ),
      );
    }
  }*/

  Future<void> _onRestorePurchases(
    RestorePurchasesEvent event,
    Emitter<PaymentPlanState> emit,
  ) async {
    try {
      emit(
        state.copyWith(status: PaymentPlanStatus.loading, isProcessing: true),
      );

      print('🔄 Restoring purchases...');
      await paymentService.restorePurchases();

      // ✅ Also fetch subscription status from backend
      final userData = await _paymentRepository.getUserSubscriptionData();

      emit(
        state.copyWith(
          status: PaymentPlanStatus.purchaseRestored,
          isPremium: userData['isPremium'] as bool?,
          userType: userData['userType'] as UserType?,
          trialStartDate: userData['trialStartDate'] as DateTime?,
          trialEndDate: userData['trialEndDate'] as DateTime?,
          subscriptionExpiryDate:
              userData['subscriptionExpiryDate'] as DateTime?,
          currentSubscriptionId: userData['currentSubscriptionId'] as String?,
          isProcessing: false,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: PaymentPlanStatus.purchaseFailed,
          errorMessage: 'Failed to restore purchases: ${e.toString()}',
          isProcessing: false,
        ),
      );
    }
  }

  Future<void> _onCheckSubscriptionStatus(
    CheckSubscriptionStatusEvent event,
    Emitter<PaymentPlanState> emit,
  ) async {
    try {
      final userData = await _paymentRepository.getUserSubscriptionData();

      emit(
        state.copyWith(
          userType: userData['userType'] as UserType,
          isPremium: userData['isPremium'] as bool,
          trialStartDate: userData['trialStartDate'] as DateTime?,
          trialEndDate: userData['trialEndDate'] as DateTime?,
          subscriptionExpiryDate:
              userData['subscriptionExpiryDate'] as DateTime?,
          currentSubscriptionId: userData['currentSubscriptionId'] as String?,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          errorMessage: 'Failed to check subscription: ${e.toString()}',
        ),
      );
    }
  }

  void _onCancelPurchase(
    CancelPurchaseEvent event,
    Emitter<PaymentPlanState> emit,
  ) {
    emit(
      state.copyWith(
        status: PaymentPlanStatus.initial,
        isProcessing: false,
        clearError: true,
      ),
    );
  }

  void _onClearError(ClearErrorEvent event, Emitter<PaymentPlanState> emit) {
    emit(state.copyWith(clearError: true));
  }

  @override
  Future<void> close() {
    _purchaseSubscription?.cancel();
    paymentService.dispose();
    return super.close();
  }
}
