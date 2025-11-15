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
  cancelled,
}

enum UserType {
  publicFree,
  publicPaid,
  venueTrial,
  venuePaid,
}

class PaymentPlanState extends Equatable {
  final PaymentPlanStatus status;
  final List<ProductDetails> products;
  final String? selectedProductId;
  final String? errorMessage;
  final bool isProcessing;
  final UserType userType;
  final bool isPremium;
  final DateTime? trialStartDate;
  final DateTime? trialEndDate;
  final DateTime? subscriptionExpiryDate;
  final String? currentSubscriptionId;

  const PaymentPlanState({
    this.status = PaymentPlanStatus.initial,
    this.products = const [],
    this.selectedProductId,
    this.errorMessage,
    this.isProcessing = false,
    this.userType = UserType.publicFree,
    this.isPremium = false,
    this.trialStartDate,
    this.trialEndDate,
    this.subscriptionExpiryDate,
    this.currentSubscriptionId,
  });

  PaymentPlanState copyWith({
    PaymentPlanStatus? status,
    List<ProductDetails>? products,
    String? selectedProductId,
    String? errorMessage,
    bool? isProcessing,
    UserType? userType,
    bool? isPremium,
    DateTime? trialStartDate,
    DateTime? trialEndDate,
    DateTime? subscriptionExpiryDate,
    String? currentSubscriptionId,
    bool clearError = false,
  }) {
    return PaymentPlanState(
      status: status ?? this.status,
      products: products ?? this.products,
      selectedProductId: selectedProductId ?? this.selectedProductId,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      isProcessing: isProcessing ?? this.isProcessing,
      userType: userType ?? this.userType,
      isPremium: isPremium ?? this.isPremium,
      trialStartDate: trialStartDate ?? this.trialStartDate,
      trialEndDate: trialEndDate ?? this.trialEndDate,
      subscriptionExpiryDate: subscriptionExpiryDate ?? this.subscriptionExpiryDate,
      currentSubscriptionId: currentSubscriptionId ?? this.currentSubscriptionId,
    );
  }

  // Helper methods
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

  bool get isSubscriptionActive {
    if (subscriptionExpiryDate == null) return false;
    return DateTime.now().isBefore(subscriptionExpiryDate!);
  }

  bool get isVenueUser {
    return userType == UserType.venueTrial || userType == UserType.venuePaid;
  }

  bool get isPublicUser {
    return userType == UserType.publicFree || userType == UserType.publicPaid;
  }

  bool get canAccessPremiumFeatures {
    return isPremium || isInTrialPeriod;
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
        selectedProductId,
        errorMessage,
        isProcessing,
        userType,
        isPremium,
        trialStartDate,
        trialEndDate,
        subscriptionExpiryDate,
        currentSubscriptionId,
      ];
}