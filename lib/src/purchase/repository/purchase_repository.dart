// lib/src/features/customer/payment_plan/repositories/payment_repository.dart

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:soloseaters/src/purchase/bloc/bloc/purchase_state.dart';

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
  
  /// Verify purchase with backend
  Future<bool> verifyPurchase({
    required String productId,
    required String purchaseToken,
    required String platform,
  }) async {
    try {
      print('🔐 Verifying purchase: $productId');
      
      final response = await http.post(
        Uri.parse('$_backendUrl/verify-purchase'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'product_id': productId,
          'purchase_token': purchaseToken,
          'platform': platform.toLowerCase(),
          'timestamp': DateTime.now().toIso8601String(),
        }),
      ).timeout(const Duration(seconds: 30));
      
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
      // For testing without backend, return true
      // In production, return false for security
      return true; // CHANGE THIS TO false IN PRODUCTION
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
      await prefs.setBool(_isPremiumKey, isActive);
      await prefs.setString(_userTypeKey, userType.name);
      await prefs.setString(_currentSubscriptionIdKey, productId);
      
      if (expiryDate != null) {
        await prefs.setString(
          _subscriptionExpiryKey,
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
      await http.post(
        Uri.parse('$_backendUrl/update-subscription'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'product_id': productId,
          'is_active': isActive,
          'user_type': userType.name,
          'expiry_date': expiryDate?.toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        }),
      ).timeout(const Duration(seconds: 30));
      
      print('✅ Backend updated');
    } catch (e) {
      print('⚠️ Backend update failed (not critical): $e');
    }
  }
  
  /// Get user subscription data
  Future<Map<String, dynamic>> getUserSubscriptionData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Get user type
      final userTypeStr = prefs.getString(_userTypeKey);
      UserType userType = UserType.publicFree;
      
      if (userTypeStr != null) {
        userType = UserType.values.firstWhere(
          (e) => e.name == userTypeStr,
          orElse: () => UserType.publicFree,
        );
      }
      
      // Get other data
      final isPremium = prefs.getBool(_isPremiumKey) ?? false;
      final currentSubscriptionId = prefs.getString(_currentSubscriptionIdKey);
      
      final trialStartStr = prefs.getString(_trialStartDateKey);
      final trialEndStr = prefs.getString(_trialEndDateKey);
      final subscriptionExpiryStr = prefs.getString(_subscriptionExpiryKey);
      
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
      return {
        'userType': UserType.publicFree,
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
      
      await prefs.setString(_userTypeKey, UserType.venueTrial.name);
      await prefs.setBool(_isPremiumKey, false);
      await prefs.setString(_trialStartDateKey, trialStartDate.toIso8601String());
      await prefs.setString(_trialEndDateKey, trialEndDate.toIso8601String());
      
      print('✅ Venue trial started');
      
      // Notify backend
      await http.post(
        Uri.parse('$_backendUrl/start-venue-trial'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'trial_start_date': trialStartDate.toIso8601String(),
          'trial_end_date': trialEndDate.toIso8601String(),
        }),
      ).timeout(const Duration(seconds: 30));
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
    await prefs.setString(_userTypeKey, userType.name);
    print('✅ User type set to: ${userType.name}');
  }
  
  /// Save purchase token
  Future<void> savePurchaseToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_purchaseTokenKey, token);
  }
  
  /// Get purchase token
  Future<String?> getPurchaseToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_purchaseTokenKey);
  }
  
  /// Clear all subscription data (for logout or testing)
  Future<void> clearSubscriptionData() async {
    final prefs = await SharedPreferences.getInstance();
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