// lib/data/models/iap/verify_purchase_response.dart

import 'package:equatable/equatable.dart';

class VerifyPurchaseResponse extends Equatable {
  final bool valid;
  final String? message;
  final bool hasActiveSubscription;
  final bool isVenueUser;
  final String? trialStartDate;
  final String? trialEndDate;
  final String? subscriptionExpiryDate;
  final String? currentSubscriptionId;

  const VerifyPurchaseResponse({
    required this.valid,
    this.message,
    required this.hasActiveSubscription,
    required this.isVenueUser,
    this.trialStartDate,
    this.trialEndDate,
    this.subscriptionExpiryDate,
    this.currentSubscriptionId,
  });

  factory VerifyPurchaseResponse.fromJson(Map<String, dynamic> json) {
    return VerifyPurchaseResponse(
      valid: json['valid'] as bool? ?? false,
      message: json['message'] as String?,
      hasActiveSubscription: json['has_active_subscription'] as bool? ?? false,
      isVenueUser: json['is_venue_user'] as bool? ?? false,
      trialStartDate: json['trial_start_date'] as String?,
      trialEndDate: json['trial_end_date'] as String?,
      subscriptionExpiryDate: json['subscription_expiry_date'] as String?,
      currentSubscriptionId: json['current_subscription_id'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'valid': valid,
      'message': message,
      'has_active_subscription': hasActiveSubscription,
      'is_venue_user': isVenueUser,
      'trial_start_date': trialStartDate,
      'trial_end_date': trialEndDate,
      'subscription_expiry_date': subscriptionExpiryDate,
      'current_subscription_id': currentSubscriptionId,
    };
  }

  @override
  List<Object?> get props => [
        valid,
        message,
        hasActiveSubscription,
        isVenueUser,
        trialStartDate,
        trialEndDate,
        subscriptionExpiryDate,
        currentSubscriptionId,
      ];
}