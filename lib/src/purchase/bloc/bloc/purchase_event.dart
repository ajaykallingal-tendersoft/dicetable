import 'package:equatable/equatable.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

abstract class PaymentPlanEvent extends Equatable {
  const PaymentPlanEvent();

  @override
  List<Object?> get props => [];
}

class InitializePaymentEvent extends PaymentPlanEvent {
  const InitializePaymentEvent();
}

class LoadProductsEvent extends PaymentPlanEvent {
  const LoadProductsEvent();
}

class SelectPlanEvent extends PaymentPlanEvent {
  final String productId;
  final String? basePlanId;
  final String? offerToken; // ✅ NEW: Add offer token

  const SelectPlanEvent(
    this.productId, {
    this.basePlanId,
    this.offerToken, // ✅ NEW
  });

  @override
  List<Object?> get props => [productId, basePlanId, offerToken];
}

class PurchaseSelectedPlanEvent extends PaymentPlanEvent {
  const PurchaseSelectedPlanEvent();
}

class PurchaseProductEvent extends PaymentPlanEvent {
  final String productId;

  const PurchaseProductEvent(this.productId);

  @override
  List<Object?> get props => [productId];
}

class HandlePurchaseUpdateEvent extends PaymentPlanEvent {
  final List<PurchaseDetails> purchaseDetailsList;

  const HandlePurchaseUpdateEvent(this.purchaseDetailsList);

  @override
  List<Object?> get props => [purchaseDetailsList];
}

class VerifyPurchaseEvent extends PaymentPlanEvent {
  final PurchaseDetails purchaseDetails;
  final Map<String, dynamic> verificationPayload;

  const VerifyPurchaseEvent(this.purchaseDetails, this.verificationPayload);

  @override
  List<Object?> get props => [purchaseDetails, verificationPayload];
}

class RestorePurchasesEvent extends PaymentPlanEvent {
  const RestorePurchasesEvent();
}

class CheckSubscriptionStatusEvent extends PaymentPlanEvent {
  const CheckSubscriptionStatusEvent();
}

class CancelPurchaseEvent extends PaymentPlanEvent {
  const CancelPurchaseEvent();
}

class ClearErrorEvent extends PaymentPlanEvent {
  const ClearErrorEvent();
}

// ✅ NEW: Retry verification event
class RetryVerificationEvent extends PaymentPlanEvent {
  final int attemptNumber;

  const RetryVerificationEvent(this.attemptNumber);

  @override
  List<Object?> get props => [attemptNumber];
}

// ✅ NEW: Check for pending purchases
class CheckPendingPurchasesEvent extends PaymentPlanEvent {
  const CheckPendingPurchasesEvent();
}
class ResetStateEvent extends PaymentPlanEvent {
  const ResetStateEvent();
}