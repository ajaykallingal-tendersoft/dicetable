// lib/src/purchase/bloc/payment_plan_bloc.dart

import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_android/billing_client_wrappers.dart';
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
  //NEW: Track current user to detect switches
  String? _currentUserId;
  final Set<String> _processedPurchases = {};

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

  //NEW: Reset state completely on user change
  Future<void> _onResetState(
    ResetStateEvent event,
    Emitter<PaymentPlanState> emit,
  ) async {
    print('🔄 Resetting PaymentPlanBloc state...');

    await _purchaseSubscription?.cancel();
    _purchaseSubscription = null;

    // ✅ Clear processed purchases on reset
    _processedPurchases.clear();

    emit(const PaymentPlanState());
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

  // ============================================================================
  // UPDATED _onLoadProducts METHOD IN PaymentPlanBloc
  // Replace your existing _onLoadProducts method with this version
  // ============================================================================

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
      print('📦 Is in trial period: ${state.isInTrialPeriod}');
      print('📦 Total product instances: ${allProducts.length}');

      final Map<String, Map<String, dynamic>> uniqueEntries = {};

      void addExpandedEntry({
        required ProductDetails product,
        required String? basePlanId,
        required String? offerToken,
        required List? pricingPhases,
        bool isTrial = false, // ✅ NEW: Flag to mark trial offers
      }) {
        final key = '${product.id}:${basePlanId ?? 'null'}';

        if (!uniqueEntries.containsKey(key)) {
          String? formattedPrice;
          double? rawPrice;
          String? billingPeriod;
          int? trialDays; // ✅ NEW: Track trial days

          // Extract price and billing period from pricing phases
          if (pricingPhases != null && pricingPhases.isNotEmpty) {
            try {
              // ✅ Check for trial phase (first phase might be free)
              for (var phase in pricingPhases) {
                if (phase is Map) {
                  final phasePrice = phase['priceAmountMicros'] as int?;
                  final phasePeriod = phase['billingPeriod'] as String?;

                  // If price is 0 or very low, it's likely a trial
                  if (phasePrice != null && phasePrice == 0) {
                    trialDays = _extractDaysFromPeriod(phasePeriod);
                    print('  🎁 Found trial phase: $trialDays days');
                  } else if (formattedPrice == null) {
                    // First paid phase
                    formattedPrice = phase['formattedPrice'] as String?;
                    billingPeriod = phasePeriod;
                    rawPrice =
                        phasePrice != null ? phasePrice / 1000000.0 : null;
                  }
                } else {
                  // PricingPhaseWrapper object
                  final phasePrice = phase.priceAmountMicros as int?;
                  if (phasePrice != null && phasePrice == 0) {
                    trialDays = _extractDaysFromPeriod(
                      phase.billingPeriod as String?,
                    );
                    print('  🎁 Found trial phase: $trialDays days');
                  } else if (formattedPrice == null) {
                    formattedPrice = phase.formattedPrice as String;
                    billingPeriod = phase.billingPeriod as String;
                    rawPrice =
                        phasePrice != null ? phasePrice / 1000000.0 : null;
                  }
                }
              }

              // If we didn't find price yet, use first phase
              if (formattedPrice == null && pricingPhases.isNotEmpty) {
                final phase = pricingPhases.first;
                if (phase is Map) {
                  formattedPrice = phase['formattedPrice'] as String?;
                  billingPeriod = phase['billingPeriod'] as String?;
                  final priceAmountMicros = phase['priceAmountMicros'] as int?;
                  if (priceAmountMicros != null) {
                    rawPrice = priceAmountMicros / 1000000.0;
                  }
                } else {
                  formattedPrice = phase.formattedPrice as String;
                  billingPeriod = phase.billingPeriod as String;
                  rawPrice = phase.priceAmountMicros / 1000000.0;
                }
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
            'isTrial': isTrial || (trialDays != null && trialDays > 0), // ✅ NEW
            'trialDays': trialDays, // ✅ NEW
          };

          print(
            '  ✅ Added: $key price=$formattedPrice period=$billingPeriod${isTrial ? " (TRIAL)" : ""}',
          );
        }
      }

      // ✅ FIXED: Platform-specific product filtering with trial detection
      if (state.isVenueUser) {
        final venueProducts =
            allProducts.where((p) {
              if (Platform.isAndroid) {
                return p.id == PaymentService.venueYearlyProductId;
              } else {
                return p.id == PaymentService.yearlyVenueProductId;
              }
            }).toList();

        print(
          '📦 Found ${venueProducts.length} venue products for ${Platform.isAndroid ? "Android" : "iOS"}',
        );

        // ✅ NEW: Track trial and base offers separately
        Map<String, dynamic>? trialOffer;
        Map<String, dynamic>? baseOffer;

        for (var product in venueProducts) {
          if (Platform.isAndroid && product is GooglePlayProductDetails) {
            final offers = product.productDetails.subscriptionOfferDetails;
            if (offers != null) {
              for (var offer in offers) {
                // ✅ Check if this offer has a trial phase
                bool hasTrial = false;
                if (offer.pricingPhases.isNotEmpty) {
                  // Check first phase for trial (price = 0)
                  final firstPhase = offer.pricingPhases.first;
                  if (firstPhase is Map) {
                    hasTrial = (firstPhase['priceAmountMicros'] as int?) == 0;
                  } else {
                    hasTrial = firstPhase.priceAmountMicros == 0;
                  }
                }

                final offerData = {
                  'product': product,
                  'basePlanId': offer.basePlanId,
                  'offerToken': offer.offerIdToken,
                  'pricingPhases': offer.pricingPhases,
                  'isTrial': hasTrial,
                };

                if (hasTrial) {
                  trialOffer = offerData;
                  print('  🎁 Found TRIAL offer: ${offer.basePlanId}');
                } else {
                  baseOffer = offerData;
                  print('  💰 Found BASE offer: ${offer.basePlanId}');
                }
              }
            } else {
              baseOffer = {
                'product': product,
                'basePlanId': null,
                'offerToken': null,
                'pricingPhases': null,
                'isTrial': false,
              };
            }
          } else {
            // iOS products
            baseOffer = {
              'product': product,
              'basePlanId': null,
              'offerToken': null,
              'pricingPhases': null,
              'isTrial': false,
            };
          }
        }

        // ✅ CRITICAL: For venue trial users who haven't started trial yet,
        // prioritize the trial offer
        final shouldUseTrial =
            state.userType == UserType.venueTrial &&
            !state.isInTrialPeriod &&
            trialOffer != null;

        if (shouldUseTrial) {
          print('🎯 Venue user eligible for trial - selecting trial offer');
          addExpandedEntry(
            product: trialOffer!['product'] as ProductDetails,
            basePlanId: trialOffer['basePlanId'] as String?,
            offerToken: trialOffer['offerToken'] as String?,
            pricingPhases: trialOffer['pricingPhases'] as List?,
            isTrial: true,
          );
        } else {
          // Add base offer (or trial if that's all we have)
          final offerToUse = baseOffer ?? trialOffer;
          if (offerToUse != null) {
            addExpandedEntry(
              product: offerToUse['product'] as ProductDetails,
              basePlanId: offerToUse['basePlanId'] as String?,
              offerToken: offerToUse['offerToken'] as String?,
              pricingPhases: offerToUse['pricingPhases'] as List?,
              isTrial: offerToUse['isTrial'] as bool? ?? false,
            );
          }
        }
      } else {
        // Public users - existing logic
        final publicProducts =
            allProducts.where((p) {
              if (Platform.isAndroid) {
                return p.id == PaymentService.yearlyPublicProductId;
              } else {
                return p.id == PaymentService.yearlyPublic ||
                    p.id == PaymentService.monthlyPublic;
              }
            }).toList();

        print(
          '📦 Found ${publicProducts.length} public products for ${Platform.isAndroid ? "Android" : "iOS"}',
        );

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
        print('❌ No products matched the filter criteria!');
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
        final isTrial = ep['isTrial'] as bool? ?? false;
        final trialDays = ep['trialDays'];
        print(
          '   ${prod.id}:$basePlan ($price)${isTrial ? " - TRIAL ($trialDays days)" : ""}',
        );
      }

      final uniqueProducts = <String, ProductDetails>{};
      for (var entry in expandedProductsList) {
        final product = entry['product'] as ProductDetails;
        uniqueProducts[product.id] = product;
      }

      // ✅ NEW: Auto-select the trial offer for eligible venue users
      String? autoSelectedProductId;
      String? autoSelectedBasePlanId;
      String? autoSelectedOfferToken;

      if (state.isVenueUser &&
          state.userType == UserType.venueTrial &&
          !state.isInTrialPeriod) {
        // Find the trial entry
        final trialEntry = expandedProductsList.firstWhere(
          (e) => e['isTrial'] == true,
          orElse: () => expandedProductsList.first,
        );

        final product = trialEntry['product'] as ProductDetails;
        autoSelectedProductId = product.id;
        autoSelectedBasePlanId = trialEntry['basePlanId'] as String?;
        autoSelectedOfferToken = trialEntry['offerToken'] as String?;

        print('🎯 Auto-selected trial offer for venue user:');
        print('   Product: $autoSelectedProductId');
        print('   Base Plan: $autoSelectedBasePlanId');
        print('   Offer Token: $autoSelectedOfferToken');
      }

      emit(
        state.copyWith(
          status: PaymentPlanStatus.productsLoaded,
          products: uniqueProducts.values.toList(),
          expandedProducts: expandedProductsList,
          selectedProductId: autoSelectedProductId, // ✅ Auto-select
          selectedBasePlanId: autoSelectedBasePlanId, // ✅ Auto-select
          selectedOfferToken: autoSelectedOfferToken, // ✅ Auto-select
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

  // ✅ NEW: Helper method to extract days from billing period
  int? _extractDaysFromPeriod(String? period) {
    if (period == null) return null;

    // Period format: P1W (1 week), P1M (1 month), P1Y (1 year), P7D (7 days)
    final match = RegExp(r'P(\d+)([DWMY])').firstMatch(period);
    if (match == null) return null;

    final value = int.tryParse(match.group(1) ?? '0') ?? 0;
    final unit = match.group(2);

    switch (unit) {
      case 'D':
        return value;
      case 'W':
        return value * 7;
      case 'M':
        return value * 30;
      case 'Y':
        return value * 365;
      default:
        return null;
    }
  }

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

      // ✅ CRITICAL FIX: Check if we've already processed this purchase
      final purchaseId = purchaseDetails.purchaseID ?? '';

      if (purchaseDetails.status == PurchaseStatus.purchased ||
          purchaseDetails.status == PurchaseStatus.restored) {
        // ✅ Skip if already processing/processed
        if (_processedPurchases.contains(purchaseId)) {
          print('⏭️ Skipping duplicate purchase event for: $purchaseId');
          continue;
        }

        // ✅ Mark as being processed
        _processedPurchases.add(purchaseId);

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

      // Debug logging
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

        // ✅ Check if this is a "already verified" message (not an actual error)
        if (errorMessage.contains('already verified') ||
            errorMessage.contains('Purchase already verified')) {
          print('ℹ️ Purchase was already verified, treating as success');

          // Complete the purchase
          if (purchaseDetails.pendingCompletePurchase) {
            await InAppPurchase.instance.completePurchase(purchaseDetails);
            print('✅ Purchase completed on store');
          }

          // Fetch fresh user data and emit success (fallback safe path)
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
              currentSubscriptionId:
                  userData['currentSubscriptionId'] as String?,
              isProcessing: false,
              pendingPurchase: null,
              pendingPayload: null,
              verificationAttempts: 0,
            ),
          );

          return;
        }

        // Check if this is a retryable error
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

        return;
      }

      // SUCCESS: complete the purchase if pending
      if (purchaseDetails.pendingCompletePurchase) {
        await InAppPurchase.instance.completePurchase(purchaseDetails);
        print('✅ Purchase completed on store');
      }

      // ✅ Ask for a background subscription refresh (keeps cache & server synced)
      add(const CheckSubscriptionStatusEvent());

      // Clear pending purchase info early
      emit(
        state.copyWith(
          pendingPurchase: null,
          pendingPayload: null,
          verificationAttempts: 0,
        ),
      );

      // ---------- NEW: Prefer verificationResult fields to update Bloc state immediately ----------
      // Attempt to extract authoritative fields from verificationResult
      final bool? hasActive =
          verificationResult.containsKey('has_active_subscription')
              ? (verificationResult['has_active_subscription'] == true)
              : null;

      final bool? isVenue =
          verificationResult.containsKey('is_venue_user')
              ? (verificationResult['is_venue_user'] == true)
              : null;

      final String? expiryStr =
          verificationResult.containsKey('subscription_expiry_date')
              ? (verificationResult['subscription_expiry_date'] as String?)
              : null;

      final String? trialStartStr =
          verificationResult.containsKey('trial_start_date')
              ? (verificationResult['trial_start_date'] as String?)
              : null;

      final String? trialEndStr =
          verificationResult.containsKey('trial_end_date')
              ? (verificationResult['trial_end_date'] as String?)
              : null;

      final String? currentSubId =
          verificationResult.containsKey('current_subscription_id')
              ? (verificationResult['current_subscription_id'] as String?)
              : null;

      // Parse dates if present
      DateTime? subscriptionExpiryDate =
          expiryStr != null
              ? DateTime.tryParse(_fixDateFormat(expiryStr))
              : null;

      DateTime? trialStartDate =
          trialStartStr != null
              ? DateTime.tryParse(_fixDateFormat(trialStartStr))
              : null;

      DateTime? trialEndDate =
          trialEndStr != null
              ? DateTime.tryParse(_fixDateFormat(trialEndStr))
              : null;

      if (hasActive != null && isVenue != null) {
        // If we have authoritative fields, derive userType & isPremium from them
        final UserType resolvedUserType =
            isVenue
                ? (hasActive ? UserType.venuePaid : UserType.venueTrial)
                : (hasActive ? UserType.publicPaid : UserType.publicFree);

        final bool resolvedIsPremium =
            hasActive ||
            (trialEndDate != null && DateTime.now().isBefore(trialEndDate));

        emit(
          state.copyWith(
            status: PaymentPlanStatus.purchaseSuccess,
            isPremium: resolvedIsPremium,
            userType: resolvedUserType,
            trialStartDate: trialStartDate,
            trialEndDate: trialEndDate,
            subscriptionExpiryDate: subscriptionExpiryDate,
            currentSubscriptionId: currentSubId,
            isProcessing: false,
            verificationAttempts: 0,
          ),
        );

        print(
          '✅ Purchase verified and state updated (from verificationResult)',
        );
        print('   User type: $resolvedUserType');
        print('   Is premium: $resolvedIsPremium');
        print('   Trial end: $trialEndDate');

        return;
      }

      // ---------- Fallback: if verificationResult did not include necessary fields ----------
      // This preserves current behaviour and ensures compatibility in debug or older backends
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
          verificationAttempts: 0,
        ),
      );

      print(
        '✅ Purchase verified and state updated (from cached userData fallback)',
      );
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

  String _fixDateFormat(String input) {
    if (input.contains(' ') && !input.contains('T')) {
      return input.replaceFirst(' ', 'T');
    }
    return input;
  }

  /*Future<void> _onVerifyPurchase(
    VerifyPurchaseEvent event,
    Emitter<PaymentPlanState> emit,
  ) async {
    try {
      emit(state.copyWith(status: PaymentPlanStatus.verifying));

      final purchaseDetails = event.purchaseDetails;
      final payload = Map<String, dynamic>.from(event.verificationPayload);

      // Debug logging
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

        // ✅ Check if this is a "already verified" message (not an actual error)
        if (errorMessage.contains('already verified') ||
            errorMessage.contains('Purchase already verified')) {
          print('ℹ️ Purchase was already verified, treating as success');

          // Complete the purchase
          if (purchaseDetails.pendingCompletePurchase) {
            await InAppPurchase.instance.completePurchase(purchaseDetails);
            print('✅ Purchase completed on store');
          }

          // Fetch fresh user data and emit success
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
              currentSubscriptionId:
                  userData['currentSubscriptionId'] as String?,
              isProcessing: false,
              pendingPurchase: null,
              pendingPayload: null,
              verificationAttempts: 0,
            ),
          );

          return;
        }

        // Check if this is a retryable error
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

        return;
      }

      // SUCCESS: complete the purchase if pending
      if (purchaseDetails.pendingCompletePurchase) {
        await InAppPurchase.instance.completePurchase(purchaseDetails);
        print('✅ Purchase completed on store');
      }

      // ✅ Check subscription status after successful verification
      add(const CheckSubscriptionStatusEvent());

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
    _processedPurchases.clear();
    return super.close();
  }
}

extension PricingPhaseWrapperMapAccess on PricingPhaseWrapper {
  dynamic operator [](String key) {
    switch (key) {
      case 'priceAmountMicros':
        return priceAmountMicros;
      case 'formattedPrice':
        return formattedPrice;
      case 'billingPeriod':
        return billingPeriod;
      default:
        return null;
    }
  }
}
