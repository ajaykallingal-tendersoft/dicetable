// lib/src/purchase/bloc/payment_plan_bloc.dart

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:soloseaters/src/purchase/bloc/bloc/purchase_event.dart';
import 'package:soloseaters/src/purchase/bloc/bloc/purchase_state.dart';
import 'package:soloseaters/src/purchase/repository/purchase_repository.dart';
import 'package:soloseaters/src/purchase/services/purchase_service.dart';

class PaymentPlanBloc extends Bloc<PaymentPlanEvent, PaymentPlanState> {
  final PaymentService paymentService;
  final PaymentRepository _paymentRepository;
  StreamSubscription<List<PurchaseDetails>>? _purchaseSubscription;

  PaymentPlanBloc({
    required PaymentService paymentService,
    required PaymentRepository paymentRepository,
  })  : paymentService = paymentService,
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
    on<StartVenueTrialEvent>(_onStartVenueTrial);
    on<CancelPurchaseEvent>(_onCancelPurchase);
    on<ClearErrorEvent>(_onClearError);
  }

  Future<void> _onInitialize(
    InitializePaymentEvent event,
    Emitter<PaymentPlanState> emit,
  ) async {
    try {
      emit(state.copyWith(status: PaymentPlanStatus.loading));

      // Initialize payment service
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

      // Listen to purchase stream
      _purchaseSubscription = paymentService.purchaseStream.listen(
        (purchaseDetailsList) {
          add(HandlePurchaseUpdateEvent(purchaseDetailsList));
        },
        onError: (error) {
          add(const ClearErrorEvent());
        },
      );

      // Load user subscription status
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
          subscriptionExpiryDate: userData['subscriptionExpiryDate'] as DateTime?,
          currentSubscriptionId: userData['currentSubscriptionId'] as String?,
        ),
      );

      // Auto-load products (will be filtered based on user type)
      add(const LoadProductsEvent());
    } catch (e) {
      emit(
        state.copyWith(
          status: PaymentPlanStatus.purchaseFailed,
          errorMessage: 'Failed to initialize: ${e.toString()}',
        ),
      );
    }
  }

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
            errorMessage:
                'No subscription plans available. Please try again later.',
          ),
        );
        return;
      }

      // Filter products based on user type
      List<ProductDetails> filteredProducts;

      if (state.isVenueUser) {
        // Venue users should only see venue yearly plan
        filteredProducts = allProducts.where(
          (product) => product.id == PaymentService.venueYearlyId,
        ).toList();
        print('✅ Filtered products for venue user: ${filteredProducts.length} product(s)');
      } else {
        // Public users see public plans (monthly and yearly)
        filteredProducts = allProducts.where(
          (product) =>
              product.id == PaymentService.monthlyPublicId ||
              product.id == PaymentService.yearlyPublicId,
        ).toList();
        print('✅ Filtered products for public user: ${filteredProducts.length} product(s)');
      }

      if (filteredProducts.isEmpty) {
        emit(
          state.copyWith(
            status: PaymentPlanStatus.purchaseFailed,
            errorMessage:
                'No subscription plans available for your account type.',
          ),
        );
        return;
      }

      emit(
        state.copyWith(
          status: PaymentPlanStatus.productsLoaded,
          products: filteredProducts,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: PaymentPlanStatus.purchaseFailed,
          errorMessage: 'Failed to load plans: ${e.toString()}',
        ),
      );
    }
  }

  void _onSelectPlan(SelectPlanEvent event, Emitter<PaymentPlanState> emit) {
    emit(state.copyWith(selectedProductId: event.productId, clearError: true));
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

  Future<void> _onPurchaseProduct(
    PurchaseProductEvent event,
    Emitter<PaymentPlanState> emit,
  ) async {
    try {
       // Prevent multiple purchase attempts while one is already running.
    if (state.isProcessing == true) {
      emit(state.copyWith(
        status: PaymentPlanStatus.purchaseFailed,
        errorMessage: 'Purchase already in progress',
      ));
      return;
    }
      emit(
        state.copyWith(
          status: PaymentPlanStatus.purchasing,
          isProcessing: true,
          clearError: true,
        ),
      );

      // FIX: Product ID -> ProductDetails
      final product = state.products.firstWhere(
        (p) => p.id == event.productId,
        orElse: () => throw Exception("Product not found: ${event.productId}"),
      );

      final errorMessage = await paymentService.purchaseProduct(product);

      if (errorMessage != null) {
        emit(
          state.copyWith(
            status: PaymentPlanStatus.purchaseFailed,
            errorMessage: errorMessage,
            isProcessing: false,
          ),
        );
      }
      // Success will be handled by HandlePurchaseUpdateEvent
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
      if (purchaseDetails.status == PurchaseStatus.purchased ||
          purchaseDetails.status == PurchaseStatus.restored) {
        // Build the verification payload using PaymentService helper.
        final payload = paymentService.extractVerificationPayload(purchaseDetails);

        // Optionally fill runtime values (package/bundle id) if you have them available
        // e.g. payload['package_name'] = 'com.your.app';
        // or add the user's id/email for backend correlation if required.

        // Dispatch verify event with both purchaseDetails and payload
        add(VerifyPurchaseEvent(purchaseDetails, payload));
      } else if (purchaseDetails.status == PurchaseStatus.error) {
        emit(
          state.copyWith(
            status: PaymentPlanStatus.purchaseFailed,
            errorMessage: purchaseDetails.error?.message ?? 'Purchase failed',
            isProcessing: false,
          ),
        );
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

      // Complete the purchase
      if (purchaseDetails.pendingCompletePurchase) {
        await InAppPurchase.instance.completePurchase(purchaseDetails);
      }
    }
  }

  Future<void>  _onVerifyPurchase(
    VerifyPurchaseEvent event,
    Emitter<PaymentPlanState> emit,
  ) async {
    try {
      emit(state.copyWith(status: PaymentPlanStatus.verifying));

      final purchaseDetails = event.purchaseDetails;
      final payload = Map<String, dynamic>.from(event.verificationPayload);

      // If you have runtime info like package/bundle id, attach it here.
      // Example:
      // payload['package_name'] = 'com.your.app';
      // payload['bundle_id'] = 'com.your.app';

      bool verified = true;

      // Skip backend verification in fake mode
      if (!kDebugMode) {
        verified = await _paymentRepository.verifyPurchase(payload);
      }

      if (!verified) {
        emit(
          state.copyWith(
            status: PaymentPlanStatus.purchaseFailed,
            errorMessage:
                'Purchase verification failed. Please contact support.',
            isProcessing: false,
          ),
        );
        return;
      }

      // Determine user type based on product
      UserType newUserType = state.userType;
      bool isPremium = true;

      if (purchaseDetails.productID.contains('venue')) {
        newUserType = UserType.venuePaid;
      } else {
        newUserType = UserType.publicPaid;
      }

      // Update subscription status (local + backend update)
      await _paymentRepository.updateSubscriptionStatus(
        productId: purchaseDetails.productID,
        isActive: true,
        userType: newUserType,
      );

      // Get updated subscription data
      final userData = await _paymentRepository.getUserSubscriptionData();

      emit(
        state.copyWith(
          status: PaymentPlanStatus.purchaseSuccess,
          isPremium: isPremium,
          userType: newUserType,
          subscriptionExpiryDate:
              userData['subscriptionExpiryDate'] as DateTime?,
          currentSubscriptionId: purchaseDetails.productID,
          isProcessing: false,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: PaymentPlanStatus.purchaseFailed,
          errorMessage: 'Verification error: ${e.toString()}',
          isProcessing: false,
        ),
      );
    }
  }

  Future<void> _onRestorePurchases(
    RestorePurchasesEvent event,
    Emitter<PaymentPlanState> emit,
  ) async {
    try {
      emit(
        state.copyWith(status: PaymentPlanStatus.loading, isProcessing: true),
      );

      await paymentService.restorePurchases();

      emit(
        state.copyWith(
          status: PaymentPlanStatus.purchaseRestored,
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

  Future<void> _onStartVenueTrial(
    StartVenueTrialEvent event,
    Emitter<PaymentPlanState> emit,
  ) async {
    try {
      final trialStartDate = DateTime.now();
      final trialEndDate = trialStartDate.add(const Duration(days: 30));

      await _paymentRepository.startVenueTrial(
        trialStartDate: trialStartDate,
        trialEndDate: trialEndDate,
      );

      emit(
        state.copyWith(
          userType: UserType.venueTrial,
          isPremium: false,
          trialStartDate: trialStartDate,
          trialEndDate: trialEndDate,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(errorMessage: 'Failed to start trial: ${e.toString()}'),
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
