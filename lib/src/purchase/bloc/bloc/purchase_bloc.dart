// lib/src/features/customer/payment_plan/bloc/payment_plan_bloc.dart

import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:soloseaters/src/purchase/bloc/bloc/purchase_event.dart';
import 'package:soloseaters/src/purchase/bloc/bloc/purchase_state.dart';
import 'package:soloseaters/src/purchase/repository/purchase_repository.dart';
import 'package:soloseaters/src/purchase/services/purchase_service.dart';


class PaymentPlanBloc extends Bloc<PaymentPlanEvent, PaymentPlanState> {
  final PaymentService _paymentService;
  final PaymentRepository _paymentRepository;
  StreamSubscription<List<PurchaseDetails>>? _purchaseSubscription;

  PaymentPlanBloc({
    required PaymentService paymentService,
    required PaymentRepository paymentRepository,
  })  : _paymentService = paymentService,
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
      final isAvailable = await _paymentService.initialize();
      
      if (!isAvailable) {
        emit(state.copyWith(
          status: PaymentPlanStatus.purchaseFailed,
          errorMessage: 'In-app purchases are not available on this device',
        ));
        return;
      }

      // Listen to purchase stream
      _purchaseSubscription = _paymentService.purchaseStream.listen(
        (purchaseDetailsList) {
          add(HandlePurchaseUpdateEvent(purchaseDetailsList));
        },
        onError: (error) {
          add(const ClearErrorEvent());
        },
      );

      // Load user subscription status
      final userData = await _paymentRepository.getUserSubscriptionData();
      
      emit(state.copyWith(
        status: PaymentPlanStatus.initial,
        userType: userData['userType'] as UserType,
        isPremium: userData['isPremium'] as bool,
        trialStartDate: userData['trialStartDate'] as DateTime?,
        trialEndDate: userData['trialEndDate'] as DateTime?,
        subscriptionExpiryDate: userData['subscriptionExpiryDate'] as DateTime?,
        currentSubscriptionId: userData['currentSubscriptionId'] as String?,
      ));

      // Auto-load products
      add(const LoadProductsEvent());
    } catch (e) {
      emit(state.copyWith(
        status: PaymentPlanStatus.purchaseFailed,
        errorMessage: 'Failed to initialize: ${e.toString()}',
      ));
    }
  }

  Future<void> _onLoadProducts(
    LoadProductsEvent event,
    Emitter<PaymentPlanState> emit,
  ) async {
    try {
      emit(state.copyWith(status: PaymentPlanStatus.loading));

      final products = await _paymentService.loadProducts();

      if (products.isEmpty) {
        emit(state.copyWith(
          status: PaymentPlanStatus.purchaseFailed,
          errorMessage: 'No subscription plans available. Please try again later.',
        ));
        return;
      }

      emit(state.copyWith(
        status: PaymentPlanStatus.productsLoaded,
        products: products,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: PaymentPlanStatus.purchaseFailed,
        errorMessage: 'Failed to load plans: ${e.toString()}',
      ));
    }
  }

  void _onSelectPlan(
    SelectPlanEvent event,
    Emitter<PaymentPlanState> emit,
  ) {
    emit(state.copyWith(
      selectedProductId: event.productId,
      clearError: true,
    ));
  }

  Future<void> _onPurchaseSelectedPlan(
    PurchaseSelectedPlanEvent event,
    Emitter<PaymentPlanState> emit,
  ) async {
    if (state.selectedProductId == null) {
      emit(state.copyWith(
        status: PaymentPlanStatus.purchaseFailed,
        errorMessage: 'Please select a plan first',
      ));
      return;
    }

    add(PurchaseProductEvent(state.selectedProductId!));
  }

  Future<void> _onPurchaseProduct(
    PurchaseProductEvent event,
    Emitter<PaymentPlanState> emit,
  ) async {
    try {
      emit(state.copyWith(
        status: PaymentPlanStatus.purchasing,
        isProcessing: true,
        clearError: true,
      ));

      final success = await _paymentService.purchaseProduct(event.productId);

      if (!success) {
        emit(state.copyWith(
          status: PaymentPlanStatus.purchaseFailed,
          errorMessage: 'Failed to initiate purchase. Please try again.',
          isProcessing: false,
        ));
      }
      // Success will be handled by HandlePurchaseUpdateEvent
    } catch (e) {
      emit(state.copyWith(
        status: PaymentPlanStatus.purchaseFailed,
        errorMessage: 'Purchase error: ${e.toString()}',
        isProcessing: false,
      ));
    }
  }

  Future<void> _onHandlePurchaseUpdate(
    HandlePurchaseUpdateEvent event,
    Emitter<PaymentPlanState> emit,
  ) async {
    for (final purchaseDetails in event.purchaseDetailsList) {
      if (purchaseDetails.status == PurchaseStatus.purchased ||
          purchaseDetails.status == PurchaseStatus.restored) {
        // Verify the purchase
        add(VerifyPurchaseEvent(purchaseDetails));
      } else if (purchaseDetails.status == PurchaseStatus.error) {
        emit(state.copyWith(
          status: PaymentPlanStatus.purchaseFailed,
          errorMessage: purchaseDetails.error?.message ?? 'Purchase failed',
          isProcessing: false,
        ));
      } else if (purchaseDetails.status == PurchaseStatus.canceled) {
        emit(state.copyWith(
          status: PaymentPlanStatus.cancelled,
          errorMessage: 'Purchase was cancelled',
          isProcessing: false,
        ));
      } else if (purchaseDetails.status == PurchaseStatus.pending) {
        emit(state.copyWith(
          status: PaymentPlanStatus.purchasing,
          isProcessing: true,
        ));
      }

      // Complete the purchase
      if (purchaseDetails.pendingCompletePurchase) {
        await InAppPurchase.instance.completePurchase(purchaseDetails);
      }
    }
  }

  Future<void> _onVerifyPurchase(
    VerifyPurchaseEvent event,
    Emitter<PaymentPlanState> emit,
  ) async {
    try {
      emit(state.copyWith(status: PaymentPlanStatus.verifying));

      final purchaseDetails = event.purchaseDetails;
      
      // Verify purchase with backend
      final verified = await _paymentRepository.verifyPurchase(
        productId: purchaseDetails.productID,
        purchaseToken: purchaseDetails.verificationData.serverVerificationData,
        platform: purchaseDetails.verificationData.source,
      );

      if (!verified) {
        emit(state.copyWith(
          status: PaymentPlanStatus.purchaseFailed,
          errorMessage: 'Purchase verification failed. Please contact support.',
          isProcessing: false,
        ));
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

      // Update subscription status
      await _paymentRepository.updateSubscriptionStatus(
        productId: purchaseDetails.productID,
        isActive: true,
        userType: newUserType,
      );

      // Get updated subscription data
      final userData = await _paymentRepository.getUserSubscriptionData();

      emit(state.copyWith(
        status: PaymentPlanStatus.purchaseSuccess,
        isPremium: isPremium,
        userType: newUserType,
        subscriptionExpiryDate: userData['subscriptionExpiryDate'] as DateTime?,
        currentSubscriptionId: purchaseDetails.productID,
        isProcessing: false,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: PaymentPlanStatus.purchaseFailed,
        errorMessage: 'Verification error: ${e.toString()}',
        isProcessing: false,
      ));
    }
  }

  Future<void> _onRestorePurchases(
    RestorePurchasesEvent event,
    Emitter<PaymentPlanState> emit,
  ) async {
    try {
      emit(state.copyWith(
        status: PaymentPlanStatus.loading,
        isProcessing: true,
      ));

      await _paymentService.restorePurchases();

      emit(state.copyWith(
        status: PaymentPlanStatus.purchaseRestored,
        isProcessing: false,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: PaymentPlanStatus.purchaseFailed,
        errorMessage: 'Failed to restore purchases: ${e.toString()}',
        isProcessing: false,
      ));
    }
  }

  Future<void> _onCheckSubscriptionStatus(
    CheckSubscriptionStatusEvent event,
    Emitter<PaymentPlanState> emit,
  ) async {
    try {
      final userData = await _paymentRepository.getUserSubscriptionData();
      
      emit(state.copyWith(
        userType: userData['userType'] as UserType,
        isPremium: userData['isPremium'] as bool,
        trialStartDate: userData['trialStartDate'] as DateTime?,
        trialEndDate: userData['trialEndDate'] as DateTime?,
        subscriptionExpiryDate: userData['subscriptionExpiryDate'] as DateTime?,
        currentSubscriptionId: userData['currentSubscriptionId'] as String?,
      ));
    } catch (e) {
      emit(state.copyWith(
        errorMessage: 'Failed to check subscription: ${e.toString()}',
      ));
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

      emit(state.copyWith(
        userType: UserType.venueTrial,
        isPremium: false,
        trialStartDate: trialStartDate,
        trialEndDate: trialEndDate,
      ));
    } catch (e) {
      emit(state.copyWith(
        errorMessage: 'Failed to start trial: ${e.toString()}',
      ));
    }
  }

  void _onCancelPurchase(
    CancelPurchaseEvent event,
    Emitter<PaymentPlanState> emit,
  ) {
    emit(state.copyWith(
      status: PaymentPlanStatus.initial,
      isProcessing: false,
      clearError: true,
    ));
  }

  void _onClearError(
    ClearErrorEvent event,
    Emitter<PaymentPlanState> emit,
  ) {
    emit(state.copyWith(clearError: true));
  }

  @override
  Future<void> close() {
    _purchaseSubscription?.cancel();
    _paymentService.dispose();
    return super.close();
  }
}