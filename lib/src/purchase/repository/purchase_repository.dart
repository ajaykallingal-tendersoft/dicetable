// lib/src/purchase/repository/purchase_repository.dart

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:soloseaters/src/purchase/bloc/bloc/purchase_state.dart';
import 'package:soloseaters/src/utils/data/object_factory.dart';

class PaymentRepository {
  // SharedPreferences keys
  static const String _userTypeKey = 'user_type';
  static const String _isPremiumKey = 'is_premium';
  static const String _trialStartDateKey = 'trial_start_date';
  static const String _trialEndDateKey = 'trial_end_date';
  static const String _subscriptionExpiryKey = 'subscription_expiry_date';
  static const String _currentSubscriptionIdKey = 'current_subscription_id';
  static const String _purchaseTokenKey = 'purchase_token';

  // Backend URL - Replace with your actual backend
  static const String _backendUrl = 'https://your-backend-api.com/api';

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

  /// Verify purchase with backend (Option A)
  /// Accepts a generic payload map that contains fields for both android and ios.
  Future<bool> verifyPurchase(Map<String, dynamic> payload) async {
    try {
      print('🔐 Verifying purchase payload: $payload');

      // Ensure platform is normalized
      final platformRaw = payload['platform']?.toString().toLowerCase() ?? '';
      String platform = platformRaw;
      if (platformRaw == 'appstore') platform = 'ios';
      if (platformRaw == 'googleplay') platform = 'android';

      // Normalize keys to backend expected names (Option A)
      final body = {
        'platform': platform,
        'product_id': payload['product_id'],
        'order_id': payload['order_id'] ?? payload['transaction_id'] ?? null,
        'purchase_token': payload['purchase_token'] ?? payload['receipt_data'] ?? null,
        'receipt_data': payload['receipt_data'],
        'original_json': payload['original_json'],
        'package_name': payload['package_name'],
        // include any other helpful debug fields
        'timestamp': DateTime.now().toIso8601String(),
      };

      // Remove null values to keep payload clean
      body.removeWhere((key, value) => value == null);

      final response = await http
          .post(
            Uri.parse('$_backendUrl/verify-purchase'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final isValid = data['valid'] == true;
        print(isValid ? '✅ Purchase verified' : '❌ Purchase invalid');
        return isValid;
      }

      print('❌ Verification failed: ${response.statusCode}');
      return false;
    } catch (e) {
      print('❌ Error verifying purchase: $e');
      // In production, return false for security
      // Only return true in debug mode for testing without backend
      if (const bool.fromEnvironment('dart.vm.product') == false) {
        // Debug mode - allow testing without backend
        print('⚠️ DEBUG MODE: Allowing purchase verification without backend');
        return true;
      }
      // Production mode - fail verification if backend is unavailable
      return false;
    }
  }

  /// Update subscription status
  Future<void> updateSubscriptionStatus({
    required String productId,
    required bool isActive,
    required UserType userType,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Calculate expiry date
      DateTime? expiryDate;
      if (isActive) {
        if (productId.contains('monthly')) {
          expiryDate = DateTime.now().add(const Duration(days: 30));
        } else if (productId.contains('yearly')) {
          expiryDate = DateTime.now().add(const Duration(days: 365));
        }
      }

      // Save locally
      await prefs.setBool(_scopedKey(_isPremiumKey), isActive);
      await prefs.setString(_scopedKey(_userTypeKey), userType.name);
      await prefs.setString(_scopedKey(_currentSubscriptionIdKey), productId);

      if (expiryDate != null) {
        await prefs.setString(
          _scopedKey(_subscriptionExpiryKey),
          expiryDate.toIso8601String(),
        );
      }

      print('✅ Subscription status updated locally');

      // Update backend
      await _updateBackend(productId, isActive, userType, expiryDate);
    } catch (e) {
      print('❌ Error updating subscription: $e');
      rethrow;
    }
  }

  /// Update backend with subscription status
  Future<void> _updateBackend(
    String productId,
    bool isActive,
    UserType userType,
    DateTime? expiryDate,
  ) async {
    try {
      await http
          .post(
            Uri.parse('$_backendUrl/update-subscription'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'product_id': productId,
              'is_active': isActive,
              'user_type': userType.name,
              'expiry_date': expiryDate?.toIso8601String(),
              'updated_at': DateTime.now().toIso8601String(),
            }),
          )
          .timeout(const Duration(seconds: 30));

      print('✅ Backend updated');
    } catch (e) {
      print('⚠️ Backend update failed (not critical): $e');
    }
  }

  /// Cache subscription data received from backend (e.g., via login response)
  Future<void> cacheBackendSubscriptionState({
    required bool isPaidUser,
    bool? subscriptionStatus,
    bool isVenueUser = false,
    DateTime? subscriptionExpiryDate,
    String? currentSubscriptionId,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final hasActiveSubscription = isPaidUser || subscriptionStatus == true;
    final resolvedUserType = isVenueUser
        ? (hasActiveSubscription ? UserType.venuePaid : UserType.venueTrial)
        : (hasActiveSubscription ? UserType.publicPaid : UserType.publicFree);

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
  }

  /// Get user subscription data
  Future<Map<String, dynamic>> getUserSubscriptionData() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Determine user type based on login status
      final isVenueLoggedIn = ObjectFactory().prefs.isLoggedIn() == true;
      final isCustomerLoggedIn =
          ObjectFactory().prefs.isCustomerLoggedIn() == true;

      // Get stored subscription data
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

      DateTime? trialStartDate;
      DateTime? trialEndDate;
      DateTime? subscriptionExpiryDate;

      if (trialStartStr != null) {
        trialStartDate = DateTime.parse(trialStartStr);
      }
      if (trialEndStr != null) {
        trialEndDate = DateTime.parse(trialEndStr);
      }
      if (subscriptionExpiryStr != null) {
        subscriptionExpiryDate = DateTime.parse(subscriptionExpiryStr);
      }

      // Check if subscription has expired
      bool subscriptionExpired = false;
      if (subscriptionExpiryDate != null) {
        subscriptionExpired = DateTime.now().isAfter(subscriptionExpiryDate);
        if (subscriptionExpired) {
          // Subscription expired - update local state
          print('⚠️ Subscription expired on $subscriptionExpiryDate');
          await prefs.setBool(_scopedKey(_isPremiumKey), false);
          isPremium = false;
        }
      }

      // Check if trial has expired
      bool trialExpired = false;
      if (trialEndDate != null) {
        trialExpired = DateTime.now().isAfter(trialEndDate);
        if (trialExpired) {
          print('⚠️ Trial expired on $trialEndDate');
        }
      }

      // Determine user type based on login status and subscription
      UserType userType;

      if (isVenueLoggedIn) {
        // Venue user
        if ((isPremium && !subscriptionExpired) ||
            (subscriptionExpiryDate != null && !subscriptionExpired)) {
          // Has active subscription
          userType = UserType.venuePaid;
        } else if (trialEndDate != null && !trialExpired) {
          // In trial period
          userType = UserType.venueTrial;
        } else {
          // No active subscription or trial
          userType = UserType.venueTrial; // Default for venue users
        }
      } else if (isCustomerLoggedIn) {
        // Public/Customer user
        if ((isPremium && !subscriptionExpired) ||
            (subscriptionExpiryDate != null && !subscriptionExpired)) {
          userType = UserType.publicPaid;
        } else {
          // ✅ Public users do not have trials.
          // Clear any stray trial data for this user type.
          trialStartDate = null;
          trialEndDate = null;

          userType = UserType.publicFree;
        }
      } else {
        // Not logged in - check stored type or default to publicFree
        if (userTypeStr != null) {
          userType = UserType.values.firstWhere(
            (e) => e.name == userTypeStr,
            orElse: () => UserType.publicFree,
          );
        } else {
          userType = UserType.publicFree;
        }
      }

      // If we have stored type that conflicts with login status, use stored type for subscription info
      // but prioritize login status for determining if user is venue or public
      if (userTypeStr != null && !isVenueLoggedIn && !isCustomerLoggedIn) {
        // Not logged in, use stored type
        final storedType = UserType.values.firstWhere(
          (e) => e.name == userTypeStr,
          orElse: () => userType,
        );
        userType = storedType;
      }

      print(
        '✅ User type determined: $userType (Venue logged in: $isVenueLoggedIn, Customer logged in: $isCustomerLoggedIn)',
      );

      return {
        'userType': userType,
        'isPremium': isPremium,
        'trialStartDate': trialStartDate,
        'trialEndDate': trialEndDate,
        'subscriptionExpiryDate': subscriptionExpiryDate,
        'currentSubscriptionId': currentSubscriptionId,
      };
    } catch (e) {
      print('❌ Error getting subscription data: $e');
      // Fallback: determine user type from login status
      final isVenueLoggedIn = ObjectFactory().prefs.isLoggedIn() == true;
      final isCustomerLoggedIn =
          ObjectFactory().prefs.isCustomerLoggedIn() == true;

      UserType defaultUserType = UserType.publicFree;
      if (isVenueLoggedIn) {
        defaultUserType = UserType.venueTrial;
      } else if (isCustomerLoggedIn) {
        defaultUserType = UserType.publicFree;
      }

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

  /// Start venue trial
  Future<void> startVenueTrial({
    required DateTime trialStartDate,
    required DateTime trialEndDate,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      await prefs.setString(_scopedKey(_userTypeKey), UserType.venueTrial.name);
      await prefs.setBool(_scopedKey(_isPremiumKey), false);
      await prefs.setString(
        _scopedKey(_trialStartDateKey),
        trialStartDate.toIso8601String(),
      );
      await prefs.setString(
        _scopedKey(_trialEndDateKey),
        trialEndDate.toIso8601String(),
      );

      print('✅ Venue trial started');

      // Notify backend
      await http
          .post(
            Uri.parse('$_backendUrl/start-venue-trial'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'trial_start_date': trialStartDate.toIso8601String(),
              'trial_end_date': trialEndDate.toIso8601String(),
            }),
          )
          .timeout(const Duration(seconds: 30));
    } catch (e) {
      print('❌ Error starting trial: $e');
      rethrow;
    }
  }

  /// Check if user has premium access
  Future<bool> hasPremiumAccess() async {
    final data = await getUserSubscriptionData();
    final isPremium = data['isPremium'] as bool;
    final trialEndDate = data['trialEndDate'] as DateTime?;

    // Premium users have access
    if (isPremium) return true;

    // Trial users have access if trial hasn't expired
    if (trialEndDate != null && DateTime.now().isBefore(trialEndDate)) {
      return true;
    }

    return false;
  }

  /// Set user type (for initial registration)
  Future<void> setUserType(UserType userType) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_scopedKey(_userTypeKey), userType.name);
    print('✅ User type set to: ${userType.name}');
  }

  /// Save purchase token
  Future<void> savePurchaseToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_scopedKey(_purchaseTokenKey), token);
  }

  /// Get purchase token
  Future<String?> getPurchaseToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_scopedKey(_purchaseTokenKey));
  }

  /// Clear all subscription data (for logout or testing)
  Future<void> clearSubscriptionData() async {
    final prefs = await SharedPreferences.getInstance();
    // Remove per-user scoped keys
    await prefs.remove(_scopedKey(_userTypeKey));
    await prefs.remove(_scopedKey(_isPremiumKey));
    await prefs.remove(_scopedKey(_trialStartDateKey));
    await prefs.remove(_scopedKey(_trialEndDateKey));
    await prefs.remove(_scopedKey(_subscriptionExpiryKey));
    await prefs.remove(_scopedKey(_currentSubscriptionIdKey));
    await prefs.remove(_scopedKey(_purchaseTokenKey));

    // Also remove legacy unscoped keys (for backward compatibility)
    await prefs.remove(_userTypeKey);
    await prefs.remove(_isPremiumKey);
    await prefs.remove(_trialStartDateKey);
    await prefs.remove(_trialEndDateKey);
    await prefs.remove(_subscriptionExpiryKey);
    await prefs.remove(_currentSubscriptionIdKey);
    await prefs.remove(_purchaseTokenKey);
    print('✅ Subscription data cleared');
  }
}
