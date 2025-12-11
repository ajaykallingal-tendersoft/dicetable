// lib/src/features/customer/payment_plan/bloc/payment_plan_state.dart

import 'package:equatable/equatable.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

enum PaymentPlanStatus {
  initial,
  loading,
  productsLoaded,
  purchasing,
  purchaseSuccess,
  purchaseRestored,
  purchaseFailed,
  verifying,
  verificationFailed, // ✅ NEW
  needsRestore, // ✅ NEW
  cancelled,
}

enum UserType { publicFree, publicPaid, venueTrial, venuePaid }

class PaymentPlanState extends Equatable {
  final PaymentPlanStatus status;
  final List<ProductDetails> products;
  final List<Map<String, dynamic>>? expandedProducts; // ✅ NEW
  final String? selectedProductId;
  final String? selectedBasePlanId; // ✅ NEW
  final String? selectedOfferToken;
  final String? errorMessage;
  final bool isProcessing;
  final UserType userType;
  final bool isPremium;
  final DateTime? trialStartDate;
  final DateTime? trialEndDate;
  final DateTime? subscriptionExpiryDate;
  final String? currentSubscriptionId;
  final PurchaseDetails? pendingPurchase;
  final Map<String, dynamic>? pendingPayload;
  final int? verificationAttempts;
  final String? selectedOfferId;
  final bool premiumOverride;

  const PaymentPlanState({
    this.status = PaymentPlanStatus.initial,
    this.products = const [],
    this.expandedProducts,
    this.selectedProductId,
    this.selectedBasePlanId,
    this.selectedOfferToken,
    this.errorMessage,
    this.isProcessing = false,
    this.userType = UserType.publicFree,
    this.isPremium = false,
    this.trialStartDate,
    this.trialEndDate,
    this.subscriptionExpiryDate,
    this.currentSubscriptionId,
    this.pendingPurchase,
    this.pendingPayload,
    this.verificationAttempts,
    this.selectedOfferId,
    this.premiumOverride = false,
  });

  PaymentPlanState copyWith({
    PaymentPlanStatus? status,
    List<ProductDetails>? products,
    List<Map<String, dynamic>>? expandedProducts,
    String? selectedProductId,
    String? selectedBasePlanId,
    String? selectedOfferToken,
    String? errorMessage,
    bool? isProcessing,
    UserType? userType,
    bool? isPremium,
    DateTime? trialStartDate,
    DateTime? trialEndDate,
    DateTime? subscriptionExpiryDate,
    String? currentSubscriptionId,
    PurchaseDetails? pendingPurchase,
    Map<String, dynamic>? pendingPayload,
    int? verificationAttempts,
    bool clearError = false,
    String? selectedOfferId,
    bool? premiumOverride,
  }) {
    return PaymentPlanState(
      status: status ?? this.status,
      products: products ?? this.products,
      expandedProducts: expandedProducts ?? this.expandedProducts,
      selectedProductId: selectedProductId ?? this.selectedProductId,
      selectedBasePlanId: selectedBasePlanId ?? this.selectedBasePlanId,
      selectedOfferToken: selectedOfferToken ?? this.selectedOfferToken,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      isProcessing: isProcessing ?? this.isProcessing,
      userType: userType ?? this.userType,
      isPremium: isPremium ?? this.isPremium,
      trialStartDate: trialStartDate ?? this.trialStartDate,
      trialEndDate: trialEndDate ?? this.trialEndDate,
      subscriptionExpiryDate:
          subscriptionExpiryDate ?? this.subscriptionExpiryDate,
      currentSubscriptionId:
          currentSubscriptionId ?? this.currentSubscriptionId,
      pendingPurchase: pendingPurchase ?? this.pendingPurchase,
      pendingPayload: pendingPayload ?? this.pendingPayload,
      verificationAttempts: verificationAttempts ?? this.verificationAttempts,
      selectedOfferId: selectedOfferId ?? this.selectedOfferId,
      premiumOverride: premiumOverride ?? this.premiumOverride,
    );
  }

  ProductDetails? getProductById(String productId) {
    try {
      return products.firstWhere((product) => product.id == productId);
    } catch (e) {
      return null;
    }
  }

  ProductDetails? get selectedProduct {
    if (selectedProductId == null) return null;
    return getProductById(selectedProductId!);
  }

  bool get hasProducts => products.isNotEmpty;

  bool get isInTrialPeriod {
    if (trialEndDate == null) return false;
    return DateTime.now().isBefore(trialEndDate!);
  }

  bool get isTrialExpired {
    if (trialEndDate == null) return false;
    return DateTime.now().isAfter(trialEndDate!);
  }

  bool get isVenueUser {
    return userType == UserType.venueTrial || userType == UserType.venuePaid;
  }

  bool get isSubscriptionActive {
    if (subscriptionExpiryDate == null) return false;
    return DateTime.now().isBefore(subscriptionExpiryDate!);
  }

  bool get isPublicUser {
    return userType == UserType.publicFree || userType == UserType.publicPaid;
  }

  bool get canAccessPremiumFeatures {
    // If explicitly overridden (after purchase/restore)
    if (premiumOverride == true) return true;

    // Fallback computed rule
    return (isPremium == true && isSubscriptionActive) || isInTrialPeriod;
  }

  bool get hasActiveSubscription {
    return isSubscriptionActive || isInTrialPeriod;
  }

  int get daysRemainingInTrial {
    if (trialEndDate == null) return 0;
    final difference = trialEndDate!.difference(DateTime.now());
    return difference.inDays > 0 ? difference.inDays : 0;
  }

  @override
  List<Object?> get props => [
    status,
    products,
    expandedProducts,
    selectedProductId,
    selectedBasePlanId,
    selectedOfferToken,
    errorMessage,
    isProcessing,
    userType,
    isPremium,
    trialStartDate,
    trialEndDate,
    subscriptionExpiryDate,
    currentSubscriptionId,
    pendingPurchase,
    pendingPayload,
    verificationAttempts,
    selectedOfferId,
    premiumOverride,
  ];
}
