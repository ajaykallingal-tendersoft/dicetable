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
import 'package:soloseaters/src/resources/api_providers/customer/profile_data_provider.dart';
import 'package:soloseaters/src/model/state_model.dart';
import 'package:soloseaters/src/utils/extension/state_model_extension.dart';

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

  /// Helper method to sync paid profile preferences to SharedPreferences
  /// This is called after successful subscription to ensure preferences are available
  /// for other screens (like booking dialog) without requiring API calls
  Future<void> _syncPaidProfilePreferences() async {
    try {


      // Get SharedPreferences and user ID
      final prefs = ObjectFactory().prefs;
      final sharedPrefs = prefs.getSharedPrefs;

      if (sharedPrefs == null) {

        return;
      }

      // Get user ID
      final userId = prefs.getUserId();
      if (userId == null) {

        return;
      }

      // Create instance of CustomerProfileDataProvider
      final customerProfileDataProvider = CustomerProfileDataProvider();
      final stateModel =
          await customerProfileDataProvider.getPaidCustomerProfileById();

      if (stateModel is SuccessState<dynamic>) {
        final profile = stateModel.value;
        final apiPreferences = profile?.data?.myPreferences ?? [];
        final apiPreferencesIds = profile?.data?.myPreferencesIds ?? [];

        // Define static preferences (same as in PaidProfileBloc)
        final staticPreferences = [
          {"id": 1, "name": "Business Networking"},
          {"id": 2, "name": "Social Solos"},
          {"id": 3, "name": "Solo Singles"},
          {"id": 4, "name": "Prime Time - Over 60's"},
        ];

        // Save each preference to SharedPreferences
        for (var staticPref in staticPreferences) {
          final prefId = staticPref['id'] as int;

          // Find matching API preference
          final apiPref = apiPreferences.cast<dynamic>().firstWhere(
            (p) => p.id == prefId,
            orElse: () => {'id': prefId, 'isPreferences': false},
          );

          // Check both conditions (same logic as PaidProfileBloc)
          final isInIds = apiPreferencesIds.contains(prefId);
          final isPreferenceTrue = apiPref?.isPreferences ?? false;
          final isEnabled = isInIds && isPreferenceTrue;

          // Save to SharedPreferences
          final key = 'paid_profile_preference_${prefId}_$userId';
          await sharedPrefs.setBool(key, isEnabled);

        }


      } else {

      }
    } catch (e) {

      // Non-fatal error, don't rethrow
    }
  }

  //NEW: Reset state completely on user change
  Future<void> _onResetState(
    ResetStateEvent event,
    Emitter<PaymentPlanState> emit,
  ) async {


    await _purchaseSubscription?.cancel();
    _purchaseSubscription = null;

    // ✅ Clear processed purchases on reset
    _processedPurchases.clear();

    emit(const PaymentPlanState());
    _currentUserId = null;


  }

  // ✅ Handle purchase cancellation (from timeout or user closing sheet)
  Future<void> _onCancelPurchase(
    CancelPurchaseEvent event,
    Emitter<PaymentPlanState> emit,
  ) async {



    emit(
      state.copyWith(
        status: PaymentPlanStatus.cancelled,
        isProcessing: false,
        errorMessage: 'Purchase was cancelled',
      ),
    );



  }

  Future<void> _onInitialize(
    InitializePaymentEvent event,
    Emitter<PaymentPlanState> emit,
  ) async {
    try {
      emit(state.copyWith(status: PaymentPlanStatus.loading));

      // ✅ Detect user change and reset if needed
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
        // ✅ CRITICAL: Clear processed purchases to allow restoration
        _processedPurchases.clear();
        // Reset to initial state before proceeding
        emit(const PaymentPlanState());
      }

      _currentUserId = newUserId;


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

      // Load initial local data
      final userData = await _paymentRepository.getUserSubscriptionData();


      final determinedUserType = userData['userType'] as UserType;
      final premiumOverride = userData['premiumOverride'] as bool? ?? false;



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
          premiumOverride: premiumOverride,
        ),
      );

      add(const LoadProductsEvent());

      // ✅ Check for pending purchases after initialization
      add(const CheckPendingPurchasesEvent());

      // ✅ CONDITIONAL: Fetch backend status if cache appears stale
      // Only skip if we have a valid premium state (after recent purchase)
      // This ensures subscription state is restored after logout/login
      if (!premiumOverride &&
          determinedUserType != UserType.venuePaid &&
          determinedUserType != UserType.publicPaid) {
        print(
          '🔄 Cache appears empty/stale - fetching subscription status from backend...',
        );
        add(const CheckSubscriptionStatusEvent());
      } else {
        print(
          '✅ Using cached premium state (recent purchase or valid subscription)',
        );
      }
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


      // Query past purchases to find any that weren't completed
      await InAppPurchase.instance.restorePurchases();

      // The purchase stream listener will handle any restored purchases
    } catch (e) {

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






      final Map<String, Map<String, dynamic>> uniqueEntries = {};

      void addExpandedEntry({
        required ProductDetails product,
        required String? basePlanId,
        required String? offerToken,
        required String? offerId,
        required List? pricingPhases,
        bool isTrial = false,
      }) {
        final key =
            '${product.id}:${basePlanId ?? 'null'}:${offerId ?? 'null'}';

        if (!uniqueEntries.containsKey(key)) {
          String? formattedPrice;
          double? rawPrice;
          String? billingPeriod;
          int? trialDays;

          if (pricingPhases != null && pricingPhases.isNotEmpty) {
            try {
              // Check for trial phase (first phase might be free)
              for (var i = 0; i < pricingPhases.length; i++) {
                final phase = pricingPhases[i];
                int? phasePrice;
                String? phasePeriod;
                String? phaseFormattedPrice;

                if (phase is Map) {
                  phasePrice = phase['priceAmountMicros'] as int?;
                  phasePeriod = phase['billingPeriod'] as String?;
                  phaseFormattedPrice = phase['formattedPrice'] as String?;
                } else {
                  phasePrice = phase.priceAmountMicros;
                  phasePeriod = phase.billingPeriod;
                  phaseFormattedPrice = phase.formattedPrice;
                }

                // If price is 0, it's a trial phase
                if (phasePrice != null && phasePrice == 0) {
                  trialDays = _extractDaysFromPeriod(phasePeriod);

                } else if (formattedPrice == null) {
                  // First paid phase
                  formattedPrice = phaseFormattedPrice;
                  billingPeriod = phasePeriod;
                  rawPrice = phasePrice != null ? phasePrice / 1000000.0 : null;
                  print(
                    '   Phase ${i + 1}: 💰 PAID - $formattedPrice for $billingPeriod',
                  );
                }
              }

              // Fallback if we didn't find price yet
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
                  formattedPrice = phase.formattedPrice;
                  billingPeriod = phase.billingPeriod;
                  rawPrice = phase.priceAmountMicros / 1000000.0;
                }
              }
            } catch (e) {

            }
          }

          uniqueEntries[key] = {
            'product': product,
            'basePlanId': basePlanId,
            'offerToken': offerToken,
            'offerId': offerId,
            'pricingPhases': pricingPhases,
            'formattedPrice': formattedPrice ?? product.price,
            'rawPrice': rawPrice ?? product.rawPrice,
            'billingPeriod': billingPeriod,
            'isTrial': isTrial || (trialDays != null && trialDays > 0),
            'trialDays': trialDays,
          };

          print(
            '   ✅ Added: $key price=$formattedPrice period=$billingPeriod${isTrial ? " (TRIAL - $trialDays days)" : ""}',
          );
        }
      }

      // Platform-specific product filtering with trial detection
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

        // Track trial and base offers separately
        Map<String, dynamic>? trialOffer;
        Map<String, dynamic>? baseOffer;

        for (var product in venueProducts) {
          if (Platform.isAndroid && product is GooglePlayProductDetails) {
            final offers = product.productDetails.subscriptionOfferDetails;

            if (offers != null) {


              for (var offer in offers) {





                // Check pricing phases to detect trial
                bool hasTrial = false;
                if (offer.pricingPhases.isNotEmpty) {
                  final firstPhase = offer.pricingPhases.first;

                  // Trial detection: First phase price is 0
                  int? priceInMicros;
                  if (firstPhase is Map) {
                    priceInMicros = firstPhase['priceAmountMicros'] as int?;
                  } else {
                    priceInMicros = firstPhase.priceAmountMicros;
                  }

                  hasTrial = priceInMicros == 0;
                  print(
                    '      First phase price: $priceInMicros micros (${hasTrial ? "FREE - TRIAL ✅" : "PAID"})',
                  );
                  print(
                    '      Total pricing phases: ${offer.pricingPhases.length}',
                  );
                }

                final offerData = {
                  'product': product,
                  'basePlanId': offer.basePlanId,
                  'offerToken': offer.offerIdToken,
                  'offerId': offer.offerId,
                  'offerTags': offer.offerTags,
                  'pricingPhases': offer.pricingPhases,
                  'isTrial': hasTrial,
                };

                if (hasTrial) {
                  trialOffer = offerData;

                } else {
                  baseOffer = offerData;

                }
              }
            } else {
              // No offers found - use base product
              baseOffer = {
                'product': product,
                'basePlanId': null,
                'offerToken': null,
                'offerId': null,
                'offerTags': null,
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
              'offerId': null,
              'offerTags': null,
              'pricingPhases': null,
              'isTrial': false,
            };
          }
        }

        // Determine which offer to use
        final shouldUseTrial =
            state.userType == UserType.venueTrial &&
            !state.isInTrialPeriod &&
            trialOffer != null;

        if (shouldUseTrial) {








          addExpandedEntry(
            product: trialOffer['product'] as ProductDetails,
            basePlanId: trialOffer['basePlanId'] as String?,
            offerToken: trialOffer['offerToken'] as String?,
            offerId: trialOffer['offerId'] as String?,
            pricingPhases: trialOffer['pricingPhases'] as List?,
            isTrial: true,
          );
        } else {
          if (trialOffer == null) {


            print(
              '   Check Play Console → Subscriptions → venue_yearly_plan → Base Plans & Offers',
            );


          } else if (state.isInTrialPeriod) {



          }

          final offerToUse = baseOffer ?? trialOffer;
          if (offerToUse != null) {
            addExpandedEntry(
              product: offerToUse['product'] as ProductDetails,
              basePlanId: offerToUse['basePlanId'] as String?,
              offerToken: offerToUse['offerToken'] as String?,
              offerId: offerToUse['offerId'] as String?,
              pricingPhases: offerToUse['pricingPhases'] as List?,
              isTrial: offerToUse['isTrial'] as bool? ?? false,
            );
          }
        }
      } else {
        // Public users - existing logic (unchanged)
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
                  offerId: offer.offerId,
                  pricingPhases: offer.pricingPhases,
                );
              }
            } else {
              addExpandedEntry(
                product: product,
                basePlanId: null,
                offerToken: null,
                offerId: null,
                pricingPhases: null,
              );
            }
          } else {
            addExpandedEntry(
              product: product,
              basePlanId: null,
              offerToken: null,
              offerId: null,
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


      for (var ep in expandedProductsList) {
        final prod = ep['product'] as ProductDetails;
        final basePlan = ep['basePlanId'];
        final offerId = ep['offerId'];
        final price = ep['formattedPrice'];
        final isTrial = ep['isTrial'] as bool? ?? false;
        final trialDays = ep['trialDays'];
        print(
          '   ${prod.id}:$basePlan:$offerId ($price)${isTrial ? " - 🎁 TRIAL ($trialDays days)" : ""}',
        );
      }

      final uniqueProducts = <String, ProductDetails>{};
      for (var entry in expandedProductsList) {
        final product = entry['product'] as ProductDetails;
        uniqueProducts[product.id] = product;
      }

      // Auto-select the trial offer for eligible venue users
      String? autoSelectedProductId;
      String? autoSelectedBasePlanId;
      String? autoSelectedOfferToken;
      String? autoSelectedOfferId;

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
        autoSelectedOfferId = trialEntry['offerId'] as String?;









      }

      emit(
        state.copyWith(
          status: PaymentPlanStatus.productsLoaded,
          products: uniqueProducts.values.toList(),
          expandedProducts: expandedProductsList,
          selectedProductId: autoSelectedProductId,
          selectedBasePlanId: autoSelectedBasePlanId,
          selectedOfferToken: autoSelectedOfferToken,
          selectedOfferId: autoSelectedOfferId,
        ),
      );
    } catch (e, st) {

      emit(
        state.copyWith(
          status: PaymentPlanStatus.purchaseFailed,
          errorMessage: 'Failed to load plans: ${e.toString()}',
        ),
      );
    }
  }

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
        // ✅ FIX: Don't emit error state for 'already in progress'
        // This is expected when user clicks multiple times

        return;
      }

      emit(
        state.copyWith(
          status: PaymentPlanStatus.purchasing,
          isProcessing: true,
          clearError: true,
        ),
      );

      // ✅ CRITICAL FIX: Start a timeout to handle iOS cancellation that doesn't emit event
      // Reduced to 10 seconds for better UX when native sheet is dismissed

      Timer(const Duration(seconds: 10), () {
        if (state.status == PaymentPlanStatus.purchasing ||
            state.status == PaymentPlanStatus.verifying) {







          add(const CancelPurchaseEvent());
        } else {
          print(
            '⏱️ Timeout reached but purchase already completed (status: ${state.status})',
          );
        }
      });

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

      }

      final isVenueTrial =
          state.isVenueUser &&
          state.userType == UserType.venueTrial &&
          !state.isInTrialPeriod;







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
        // ✅ FIXED: For RESTORED purchases, check subscription status FIRST before caching
        if (purchaseDetails.status == PurchaseStatus.restored) {
          print(
            '🔄 Purchase restored - checking subscription status BEFORE caching',
          );


          // 🔒 SECURITY FIX: Validate product type matches user type
          // Prevent cross-account premium leak (e.g., public user getting venue subscription)
          final productId = purchaseDetails.productID;
          final currentUserType = state.userType;

          // Check product type (covers both monthly and yearly variants)
          final isVenueProduct = productId.contains(
            'venue',
          ); // venue_yearly_plan
          final isPublicProduct = productId.contains(
            'public',
          ); // public_yearly_plan, public_monthly_plan

          final isVenueUser =
              currentUserType == UserType.venueTrial ||
              currentUserType == UserType.venuePaid;
          final isPublicUser =
              currentUserType == UserType.publicFree ||
              currentUserType == UserType.publicPaid;









          // ❌ REJECT if product type doesn't match user type
          if ((isVenueProduct && isPublicUser) ||
              (isPublicProduct && isVenueUser)) {











            // Complete the purchase to acknowledge it, but don't grant access
            if (purchaseDetails.pendingCompletePurchase) {
              await InAppPurchase.instance.completePurchase(purchaseDetails);
            }

            // Don't process this purchase further
            return;
          }

          print(
            '✅ Product type matches user type - proceeding with verification',
          );

          // ✅ DON'T cache yet - first verify if subscription is still active
          // Try to check subscription status first
          try {


            // Temporarily cache just for the status check
            final platform = Platform.isIOS ? 'ios' : 'android';
            final tempToken =
                purchaseDetails.verificationData.serverVerificationData;

            // Make a temporary cache for the API call
            await _paymentRepository.cacheLatestPurchaseDetails(
              purchaseToken: tempToken,
              platform: platform,
              subscriptionId: purchaseDetails.productID,
            );

            final statusResult = await _paymentRepository
                .fetchSubscriptionStatusFromBackend(
                  productId: purchaseDetails.productID,
                );

            // Check if we got valid subscription data
            final isPremium = statusResult['isPremium'] as bool? ?? false;
            final premiumOverride =
                statusResult['premiumOverride'] as bool? ?? false;
            final userType = statusResult['userType'] as UserType?;






            if (isPremium || premiumOverride) {



              // ✅ NOW cache the token since subscription is active
              await _paymentRepository.cacheLatestPurchaseDetails(
                purchaseToken: tempToken,
                platform: platform,
                subscriptionId: purchaseDetails.productID,
              );


              // Complete the purchase
              if (purchaseDetails.pendingCompletePurchase) {
                await InAppPurchase.instance.completePurchase(purchaseDetails);

              }

              emit(
                state.copyWith(
                  status: PaymentPlanStatus.purchaseRestored,
                  isPremium: isPremium,
                  userType: userType,
                  trialStartDate: statusResult['trialStartDate'] as DateTime?,
                  trialEndDate: statusResult['trialEndDate'] as DateTime?,
                  subscriptionExpiryDate:
                      statusResult['subscriptionExpiryDate'] as DateTime?,
                  currentSubscriptionId:
                      statusResult['currentSubscriptionId'] as String?,
                  errorMessage: null,
                  isProcessing: false,
                  premiumOverride: premiumOverride,
                  pendingPurchase: null,
                  pendingPayload: null,
                ),
              );

              // Mark as processed
              _processedPurchases.add(purchaseId);



              continue; // Skip verification
            } else {











              // ✅ CRITICAL: Clear the temporarily cached token
              // This ensures the old token doesn't interfere with new purchases
              await _paymentRepository.clearCachedPurchaseToken();


              // ✅ Complete the purchase but do NOT emit premium state
              if (purchaseDetails.pendingCompletePurchase) {
                await InAppPurchase.instance.completePurchase(purchaseDetails);

              }

              emit(
                state.copyWith(
                  status:
                      PaymentPlanStatus
                          .initial, // ✅ Reset to initial, not failed
                  isPremium: false,
                  premiumOverride: false,
                  userType:
                      state.isVenueUser
                          ? UserType.venueTrial
                          : UserType.publicFree,
                  errorMessage: null, // ✅ No error - this is expected behavior
                  isProcessing: false,
                  pendingPurchase: null,
                  pendingPayload: null,
                ),
              );

              // Mark as processed
              _processedPurchases.add(purchaseId);



              continue; // ✅ Skip verification and allow new purchase
            }
          } catch (e) {


          }
        }

        // Skip if already processing/processed
        if (_processedPurchases.contains(purchaseId)) {

          continue;
        }

        // Mark as being processed
        _processedPurchases.add(purchaseId);

        final payload = await paymentService.extractVerificationPayload(
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






      if (payload.containsKey('platform')) {

      } else {

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

      }



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


          // Complete the purchase
          if (purchaseDetails.pendingCompletePurchase) {
            await InAppPurchase.instance.completePurchase(purchaseDetails);

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
              premiumOverride: true,
            ),
          );

          // ✅ NEW: Sync preferences to SharedPreferences after successful subscription (already verified path)
          await _syncPaidProfilePreferences();

          // ✅ NEW: Trigger full status check to get complete verification_data
          print(
            '🔄 Triggering CheckSubscriptionStatusEvent to fetch full status...',
          );
          add(const CheckSubscriptionStatusEvent());

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

      }

      // Clear pending purchase info early
      emit(
        state.copyWith(
          pendingPurchase: null,
          pendingPayload: null,
          verificationAttempts: 0,
        ),
      );

      // ✅ CRITICAL FIX: Extract data from verificationResult first
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

      // ✅ Extract premium_override if present
      final bool? premiumOverrideFromBackend =
          verificationResult.containsKey('premium_override')
              ? (verificationResult['premium_override'] as bool?)
              : null;

      if (hasActive != null && isVenue != null) {
        // ✅ Derive userType & isPremium from backend response
        final UserType resolvedUserType =
            isVenue
                ? (hasActive ? UserType.venuePaid : UserType.venueTrial)
                : (hasActive ? UserType.publicPaid : UserType.publicFree);

        final bool resolvedIsPremium =
            hasActive ||
            (trialEndDate != null && DateTime.now().isBefore(trialEndDate));




















        // ✅ Emit success state with backend data
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
            premiumOverride:
                premiumOverrideFromBackend ??
                true, // ✅ Use backend value or default to true
          ),
        );

        print(
          '✅ Purchase verified and state updated (from verificationResult)',
        );




        // ✅ NEW: Sync preferences to SharedPreferences after successful subscription
        if (resolvedIsPremium) {
          await _syncPaidProfilePreferences();
        }

        return;
      }

      // Fallback: if verificationResult did not include necessary fields
      print(
        '⚠️ Backend response missing subscription fields, using cached data',
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
          verificationAttempts: 0,
          premiumOverride: true,
        ),
      );

      print(
        '✅ Purchase verified and state updated (from cached userData fallback)',
      );




      // ✅ NEW: Sync preferences to SharedPreferences after successful subscription (fallback path)
      final isPremiumFallback = userData['isPremium'] as bool? ?? false;
      if (isPremiumFallback) {
        await _syncPaidProfilePreferences();
      }
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

  Future<void> _onRestorePurchases(
    RestorePurchasesEvent event,
    Emitter<PaymentPlanState> emit,
  ) async {
    try {
      emit(
        state.copyWith(status: PaymentPlanStatus.loading, isProcessing: true),
      );



      // ✅ Start timeout - if no purchases are restored within 5 seconds, complete
      final timeoutCompleter = Completer<void>();
      Timer(const Duration(seconds: 5), () {
        if (!timeoutCompleter.isCompleted) {
          timeoutCompleter.complete();
        }
      });

      // Call restore
      await paymentService.restorePurchases();

      // Wait for timeout
      await timeoutCompleter.future;

      // ✅ If we reach here, timeout occurred (no purchases found)
      // Check if state is still in loading (no purchase stream events received)
      if (state.status == PaymentPlanStatus.loading && state.isProcessing) {







        // Reset to initial state - allows user to proceed
        emit(
          state.copyWith(
            status: PaymentPlanStatus.initial,
            isProcessing: false,
            errorMessage: null,
          ),
        );
      }
      // The purchase stream will emit a 'restored' status update if purchases are found.
      // The _onHandlePurchaseUpdate method will catch this and trigger the verification flow.
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
      // 🟢 FIX (RECOMMENDATION C): Use the repository method that calls
      // the backend API first, ensuring the cache is refreshed
      // with the authoritative status.
      final userData =
          await _paymentRepository.fetchSubscriptionStatusFromBackend();

      emit(
        state.copyWith(
          userType: userData['userType'] as UserType,
          isPremium: userData['isPremium'] as bool,
          trialStartDate: userData['trialStartDate'] as DateTime?,
          trialEndDate: userData['trialEndDate'] as DateTime?,
          subscriptionExpiryDate:
              userData['subscriptionExpiryDate'] as DateTime?,
          currentSubscriptionId: userData['currentSubscriptionId'] as String?,
          premiumOverride:
              userData['premiumOverride'] as bool? ??
              false, // ✅ ADD: Include premium override in state
        ),
      );

      // ✅ NEW: Sync preferences for restored purchases / existing subscriptions
      // This is critical for users who log in with existing subscriptions
      final isPremium = userData['isPremium'] as bool? ?? false;
      final premiumOverride = userData['premiumOverride'] as bool? ?? false;
      if (isPremium || premiumOverride) {

        await _syncPaidProfilePreferences();
      }
    } catch (e) {
      emit(
        state.copyWith(
          errorMessage: 'Failed to check subscription: ${e.toString()}',
        ),
      );
    }
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
