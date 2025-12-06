// lib/data/models/iap/subscription_status_response.dart

import 'package:equatable/equatable.dart';

class SubscriptionStatusResponse extends Equatable {
  final bool status;
  final String? message;
  final String userType;
  final bool hasActiveSubscription;
  final bool inTrial;
  final String? trialStartDate;
  final String? trialEndDate;
  final String? subscriptionExpiryDate;
  final String? currentSubscriptionId;

  const SubscriptionStatusResponse({
    required this.status,
    this.message,
    required this.userType,
    required this.hasActiveSubscription,
    required this.inTrial,
    this.trialStartDate,
    this.trialEndDate,
    this.subscriptionExpiryDate,
    this.currentSubscriptionId,
  });

  factory SubscriptionStatusResponse.fromJson(Map<String, dynamic> json) {
    return SubscriptionStatusResponse(
      status: json['status'] as bool? ?? false,
      message: json['message'] as String?,
      userType: json['user_type'] as String? ?? 'public',
      hasActiveSubscription: json['has_active_subscription'] as bool? ?? false,
      inTrial: json['in_trial'] as bool? ?? false,
      trialStartDate: json['trial_start_date'] as String?,
      trialEndDate: json['trial_end_date'] as String?,
      subscriptionExpiryDate: json['subscription_expiry_date'] as String?,
      currentSubscriptionId: json['current_subscription_id'] as String?,
    );
  }

  @override
  List<Object?> get props => [
        status,
        message,
        userType,
        hasActiveSubscription,
        inTrial,
        trialStartDate,
        trialEndDate,
        subscriptionExpiryDate,
        currentSubscriptionId,
      ];
} 