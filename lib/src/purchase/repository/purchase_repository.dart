// lib/src/purchase/repository/purchase_repository.dart

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:soloseaters/src/model/payment/verify_purchase_request.dart';
import 'package:soloseaters/src/purchase/bloc/bloc/purchase_state.dart';
import 'package:soloseaters/src/resources/api_providers/iap/iap_data_provider.dart';
import 'package:soloseaters/src/utils/data/object_factory.dart';
import 'package:soloseaters/src/utils/extension/state_model_extension.dart';

class PaymentRepository {
  final IapDataProvider _iapDataProvider;

  PaymentRepository({required IapDataProvider iapDataProvider})
    : _iapDataProvider = iapDataProvider;

  // SharedPreferences keys
  static const String _userTypeKey = 'user_type';
  static const String _isPremiumKey = 'is_premium';
  static const String _trialStartDateKey = 'trial_start_date';
  static const String _trialEndDateKey = 'trial_end_date';
  static const String _subscriptionExpiryKey = 'subscription_expiry_date';
  static const String _currentSubscriptionIdKey = 'current_subscription_id';

  String _currentUserScope() {
    final prefs = ObjectFactory().prefs;
    return prefs.getUserId() ??
        prefs.getCafeUserId() ??
        prefs.getCustomerUserMail() ??
        prefs.getCustomerMail() ??
        prefs.getCafeUserMail() ??
        'anonymous';
  }

  String _scopedKey(String base) => '${base}_${_currentUserScope()}';

  /// ========================================
  /// VERIFY PURCHASE WITH BACKEND
  /// ========================================
  ///

  // Updated verifyPurchase method in PaymentRepository
  // Replace your existing verifyPurchase method with this

  Future<Map<String, dynamic>> verifyPurchase(
    Map<String, dynamic> payload,
  ) async {
    try {
      print('🔍 Repository: Verifying purchase payload: $payload');

      // Normalize platform field
      final platformRaw = (payload['platform']?.toString() ?? '').toLowerCase();
      String platform;
      if (platformRaw == 'appstore' || platformRaw == 'ios') {
        platform = 'ios';
      } else if (platformRaw == 'googleplay' || platformRaw == 'android') {
        platform = 'android';
      } else {
        if ((payload['receipt_data'] ?? '').toString().isNotEmpty) {
          platform = 'ios';
        } else {
          platform = 'android';
        }
      }

      final verificationPayload = Map<String, dynamic>.from(payload);
      verificationPayload['platform'] = platform;

      final purchaseToken =
          verificationPayload['purchase_token'] ??
          verificationPayload['receipt_data'] ??
          '';

      final request = VerifyPurchaseRequest(
        purchaseToken: purchaseToken,
        productId: verificationPayload['product_id'],
        platform: verificationPayload['platform'],
      );

      final prefs = ObjectFactory().prefs;

      // ✅ DEBUG MODE SIMULATION
      if (kDebugMode) {
        print('🧪 DEBUG MODE: Simulating successful verification');
        await cacheBackendSubscriptionState(
          isPaidUser: true,
          subscriptionExpiryDate: DateTime.now().add(const Duration(days: 365)),
          currentSubscriptionId: verificationPayload['product_id'] as String?,
          trialStartDate: DateTime.now(),
          trialEndDate: DateTime.now().add(const Duration(days: 30)),
          isVenueUser: prefs.isLoggedIn() == true,
        );

        return {
          'valid': true,
          'message': 'DEBUG: Bypassed backend verification',
          'has_active_subscription': true,
          'is_venue_user': prefs.isLoggedIn() == true,
          'trial_start_date': DateTime.now().toIso8601String(),
          'trial_end_date':
              DateTime.now().add(const Duration(days: 30)).toIso8601String(),
          'subscription_expiry_date':
              DateTime.now().add(const Duration(days: 365)).toIso8601String(),
          'current_subscription_id': verificationPayload['product_id'],
        };
      }

      print('📤 Verifying purchase - ${verificationPayload['product_id']}');
      print('   Platform: ${verificationPayload['platform']}');
      print('   Purchase token length: ${purchaseToken.toString().length}');

      // ✅ CALL API
      final stateModel = await _iapDataProvider.verifyPurchase(request);

      if (stateModel == null) {
        print('❌ Repository: verifyPurchase returned null stateModel');
        return {'valid': false, 'message': 'Verification failed'};
      }

      if (stateModel.isSuccess) {
        final response = stateModel.data!;
        print('✅ Purchase verification response received');
        print('   Success: ${response.success}');
        print('   Message: ${response.message}');

        // ✅ NEW: Treat "already verified" as success
        final isAlreadyVerified =
            response.message?.toLowerCase().contains('already verified') ??
            false;

        if (response.valid || isAlreadyVerified) {
          print(
            '✅ Verification successful ${isAlreadyVerified ? "(already verified)" : ""}',
          );
          print(
            '   Has active subscription: ${response.hasActiveSubscription}',
          );
          print('   Is venue user: ${response.isVenueUser}');
          print('   Product ID: ${response.currentSubscriptionId}');

          // Parse dates from verification data
          DateTime? subscriptionExpiryDate;
          DateTime? trialStartDate;
          DateTime? trialEndDate;

          if (response.subscriptionExpiryDate != null) {
            try {
              subscriptionExpiryDate = DateTime.parse(
                response.subscriptionExpiryDate!,
              );
            } catch (e) {
              print('⚠️ Failed to parse expiry date: $e');
            }
          }

          if (response.trialStartDate != null) {
            try {
              trialStartDate = DateTime.parse(response.trialStartDate!);
            } catch (e) {
              print('⚠️ Failed to parse trial start date: $e');
            }
          }

          if (response.trialEndDate != null) {
            try {
              trialEndDate = DateTime.parse(response.trialEndDate!);
            } catch (e) {
              print('⚠️ Failed to parse trial end date: $e');
            }
          }

          // Cache the subscription state
          await cacheBackendSubscriptionState(
            isPaidUser: response.hasActiveSubscription,
            subscriptionExpiryDate: subscriptionExpiryDate,
            currentSubscriptionId: response.currentSubscriptionId,
            trialStartDate: trialStartDate,
            trialEndDate: trialEndDate,
            isVenueUser: response.isVenueUser,
          );

          return {
            'valid': true,
            'has_active_subscription': response.hasActiveSubscription,
            'is_venue_user': response.isVenueUser,
            'trial_start_date': response.trialStartDate,
            'trial_end_date': response.trialEndDate,
            'subscription_expiry_date': response.subscriptionExpiryDate,
            'current_subscription_id': response.currentSubscriptionId,
            'in_trial': response.inTrial,
          };
        }

        return {
          'valid': false,
          'message': response.message ?? 'Verification failed',
        };
      }

      // Not success
      print('❌ Repository: stateModel indicates failure: ${stateModel.error}');

      // ✅ NEW: Check if error contains "already verified" or duplicate constraint
      final errorMessage = stateModel.error ?? '';
      if (errorMessage.contains('already verified') ||
          errorMessage.contains('Duplicate entry') ||
          errorMessage.contains('purchases_purchase_token_unique')) {
        print(
          'ℹ️ Duplicate/Already verified error - fetching existing subscription data',
        );

        // Return success and let the bloc fetch fresh user data
        return {'valid': true, 'message': 'Purchase already verified'};
      }

      return {'valid': false, 'message': errorMessage};
    } catch (e, st) {
      print('❌ Repository: verifyPurchase exception: $e\n$st');

      // ✅ NEW: Check exception message for duplicate/already verified
      final errorMessage = e.toString();
      if (errorMessage.contains('already verified') ||
          errorMessage.contains('Duplicate entry') ||
          errorMessage.contains('purchases_purchase_token_unique')) {
        print('ℹ️ Exception indicates duplicate - treating as success');
        return {'valid': true, 'message': 'Purchase already verified'};
      }

      return {'valid': false, 'message': 'Error: ${e.toString()}'};
    }
  }

  /// ========================================
  /// FETCH SUBSCRIPTION STATUS FROM BACKEND
  /// ========================================
  Future<Map<String, dynamic>> fetchSubscriptionStatusFromBackend() async {
    try {
      print('🔄 Repository: Fetching subscription status');

      final prefs = ObjectFactory().prefs;
      final userId = prefs.getUserId();
      final cafeId = prefs.getCafeId();

      if (userId == null && cafeId == null) {
        return {
          'userType': UserType.publicFree,
          'isPremium': false,
          'trialStartDate': null,
          'trialEndDate': null,
          'subscriptionExpiryDate': null,
          'currentSubscriptionId': null,
        };
      }

      if (kDebugMode) {
        return await getUserSubscriptionData();
      }

      final stateModel = await _iapDataProvider.getSubscriptionStatus();

      if (stateModel == null) {
        return await getUserSubscriptionData();
      }

      if (stateModel.isSuccess) {
        final response = stateModel.data!;

        final isVenueUser = response.userType == 'venue';
        final hasActiveSub = response.hasActiveSubscription;
        final inTrial = response.inTrial;

        final userType =
            isVenueUser
                ? (hasActiveSub ? UserType.venuePaid : UserType.venueTrial)
                : (hasActiveSub ? UserType.publicPaid : UserType.publicFree);

        final result = {
          'userType': userType,
          'isPremium': hasActiveSub || inTrial,
          'trialStartDate':
              response.trialStartDate != null
                  ? DateTime.tryParse(response.trialStartDate!)
                  : null,
          'trialEndDate':
              response.trialEndDate != null
                  ? DateTime.tryParse(response.trialEndDate!)
                  : null,
          'subscriptionExpiryDate':
              response.subscriptionExpiryDate != null
                  ? DateTime.tryParse(response.subscriptionExpiryDate!)
                  : null,
          'currentSubscriptionId': response.currentSubscriptionId,
        };

        await cacheBackendSubscriptionState(
          isPaidUser: hasActiveSub,
          isVenueUser: isVenueUser,
          subscriptionExpiryDate: result['subscriptionExpiryDate'] as DateTime?,
          trialStartDate: result['trialStartDate'] as DateTime?,
          trialEndDate: result['trialEndDate'] as DateTime?,
          currentSubscriptionId: result['currentSubscriptionId'] as String?,
        );

        return result;
      }

      return await getUserSubscriptionData();
    } catch (e) {
      return await getUserSubscriptionData();
    }
  }

  /// ========================================
  /// LOCAL CACHE
  /// ========================================
  Future<void> cacheBackendSubscriptionState({
    required bool isPaidUser,
    bool? subscriptionStatus,
    bool isVenueUser = false,
    DateTime? subscriptionExpiryDate,
    DateTime? trialStartDate,
    DateTime? trialEndDate,
    String? currentSubscriptionId,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    final hasActiveSubscription = isPaidUser || subscriptionStatus == true;

    final resolvedUserType =
        isVenueUser
            ? (hasActiveSubscription ? UserType.venuePaid : UserType.venueTrial)
            : (hasActiveSubscription
                ? UserType.publicPaid
                : UserType.publicFree);

    await prefs.setBool(_scopedKey(_isPremiumKey), hasActiveSubscription);
    await prefs.setString(_scopedKey(_userTypeKey), resolvedUserType.name);

    if (subscriptionExpiryDate != null) {
      await prefs.setString(
        _scopedKey(_subscriptionExpiryKey),
        subscriptionExpiryDate.toIso8601String(),
      );
    } else {
      await prefs.remove(_scopedKey(_subscriptionExpiryKey));
    }

    if (currentSubscriptionId != null) {
      await prefs.setString(
        _scopedKey(_currentSubscriptionIdKey),
        currentSubscriptionId,
      );
    } else {
      await prefs.remove(_scopedKey(_currentSubscriptionIdKey));
    }

    if (trialStartDate != null) {
      await prefs.setString(
        _scopedKey(_trialStartDateKey),
        trialStartDate.toIso8601String(),
      );
    } else {
      await prefs.remove(_scopedKey(_trialStartDateKey));
    }

    if (trialEndDate != null) {
      await prefs.setString(
        _scopedKey(_trialEndDateKey),
        trialEndDate.toIso8601String(),
      );
    } else {
      await prefs.remove(_scopedKey(_trialEndDateKey));
    }
  }

  /// ========================================
  /// READ LOCAL CACHE
  /// ========================================
  Future<Map<String, dynamic>> getUserSubscriptionData() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final isVenueLoggedIn = ObjectFactory().prefs.isLoggedIn() == true;
      final isCustomerLoggedIn =
          ObjectFactory().prefs.isCustomerLoggedIn() == true;

      final userTypeStr = prefs.getString(_scopedKey(_userTypeKey));
      bool isPremium = prefs.getBool(_scopedKey(_isPremiumKey)) ?? false;

      final currentSubscriptionId = prefs.getString(
        _scopedKey(_currentSubscriptionIdKey),
      );

      final trialStartStr = prefs.getString(_scopedKey(_trialStartDateKey));
      final trialEndStr = prefs.getString(_scopedKey(_trialEndDateKey));
      final subscriptionExpiryStr = prefs.getString(
        _scopedKey(_subscriptionExpiryKey),
      );

      DateTime? trialStartDate =
          trialStartStr != null ? DateTime.parse(trialStartStr) : null;
      DateTime? trialEndDate =
          trialEndStr != null ? DateTime.parse(trialEndStr) : null;
      DateTime? subscriptionExpiryDate =
          subscriptionExpiryStr != null
              ? DateTime.parse(subscriptionExpiryStr)
              : null;

      bool subscriptionExpired = false;
      if (subscriptionExpiryDate != null) {
        subscriptionExpired = DateTime.now().isAfter(subscriptionExpiryDate);
        if (subscriptionExpired) {
          await prefs.setBool(_scopedKey(_isPremiumKey), false);
          isPremium = false;
        }
      }

      bool trialExpired = false;
      if (trialEndDate != null) {
        trialExpired = DateTime.now().isAfter(trialEndDate);
      }

      UserType userType;

      if (isVenueLoggedIn) {
        final hasActiveSubscription =
            isPremium && subscriptionExpiryDate != null && !subscriptionExpired;
        final isInTrial = trialEndDate != null && !trialExpired;

        if (hasActiveSubscription) {
          userType = UserType.venuePaid;
        } else if (isInTrial) {
          userType = UserType.venueTrial;
        } else {
          userType = UserType.venueTrial;
        }
      } else if (isCustomerLoggedIn) {
        final hasActiveSubscription = isPremium && !subscriptionExpired;

        userType =
            hasActiveSubscription ? UserType.publicPaid : UserType.publicFree;

        if (!hasActiveSubscription) {
          trialStartDate = null;
          trialEndDate = null;
        }
      } else {
        userType =
            userTypeStr != null
                ? UserType.values.firstWhere(
                  (e) => e.name == userTypeStr,
                  orElse: () => UserType.publicFree,
                )
                : UserType.publicFree;
      }

      return {
        'userType': userType,
        'isPremium': isPremium,
        'trialStartDate': trialStartDate,
        'trialEndDate': trialEndDate,
        'subscriptionExpiryDate': subscriptionExpiryDate,
        'currentSubscriptionId': currentSubscriptionId,
      };
    } catch (e) {
      final isVenueLoggedIn = ObjectFactory().prefs.isLoggedIn() == true;
      final isCustomerLoggedIn =
          ObjectFactory().prefs.isCustomerLoggedIn() == true;

      UserType defaultUserType = UserType.publicFree;
      if (isVenueLoggedIn) defaultUserType = UserType.venueTrial;

      return {
        'userType': defaultUserType,
        'isPremium': false,
        'trialStartDate': null,
        'trialEndDate': null,
        'subscriptionExpiryDate': null,
        'currentSubscriptionId': null,
      };
    }
  }

  /// ========================================
  /// PREMIUM CHECK
  /// ========================================
  Future<bool> hasPremiumAccess() async {
    final data = await getUserSubscriptionData();
    final isPremium = data['isPremium'] as bool;
    final trialEndDate = data['trialEndDate'] as DateTime?;
    final expiryDate = data['subscriptionExpiryDate'] as DateTime?;

    return (isPremium &&
            expiryDate != null &&
            DateTime.now().isBefore(expiryDate)) ||
        (trialEndDate != null && DateTime.now().isBefore(trialEndDate));
  }

  /// ========================================
  /// CLEAR CACHE
  /// ========================================
  Future<void> clearSubscriptionData() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove(_scopedKey(_userTypeKey));
    await prefs.remove(_scopedKey(_isPremiumKey));
    await prefs.remove(_scopedKey(_trialStartDateKey));
    await prefs.remove(_scopedKey(_trialEndDateKey));
    await prefs.remove(_scopedKey(_subscriptionExpiryKey));
    await prefs.remove(_scopedKey(_currentSubscriptionIdKey));
  }
}
