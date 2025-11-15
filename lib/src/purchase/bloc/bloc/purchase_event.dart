// lib/src/features/customer/payment_plan/bloc/payment_plan_event.dart

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

  const SelectPlanEvent(this.productId);

  @override
  List<Object?> get props => [productId];
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

  const VerifyPurchaseEvent(this.purchaseDetails);

  @override
  List<Object?> get props => [purchaseDetails];
}

class RestorePurchasesEvent extends PaymentPlanEvent {
  const RestorePurchasesEvent();
}

class CheckSubscriptionStatusEvent extends PaymentPlanEvent {
  const CheckSubscriptionStatusEvent();
}

class StartVenueTrialEvent extends PaymentPlanEvent {
  const StartVenueTrialEvent();
}

class CancelPurchaseEvent extends PaymentPlanEvent {
  const CancelPurchaseEvent();
}

class ClearErrorEvent extends PaymentPlanEvent {
  const ClearErrorEvent();
}