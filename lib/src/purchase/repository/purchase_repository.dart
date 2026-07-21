import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:soloseaters/src/model/payment/verify_purchase_request.dart';
import 'package:soloseaters/src/purchase/bloc/bloc/purchase_state.dart';
import 'package:soloseaters/src/resources/api_providers/iap/iap_data_provider.dart';
import 'package:soloseaters/src/utils/data/object_factory.dart';
import 'package:soloseaters/src/utils/extension/state_model_extension.dart';
import 'package:soloseaters/src/model/payment/subscription_status_response.dart';

class PaymentRepository {
  final IapDataProvider _iapDataProvider;

  // ✅ NEW: Debouncing mechanism
  DateTime? _lastStatusCheckTime;
  static const Duration _debounceInterval = Duration(seconds: 5);

  PaymentRepository({required IapDataProvider iapDataProvider})
    : _iapDataProvider = iapDataProvider;

  // SharedPreferences keys
  static const String _userTypeKey = 'user_type';
  static const String _isPremiumKey = 'is_premium';
  static const String _trialStartDateKey = 'trial_start_date';
  static const String _trialEndDateKey = 'trial_end_date';
  static const String _subscriptionExpiryKey = 'subscription_expiry_date';
  static const String _currentSubscriptionIdKey = 'current_subscription_id';
  // NEW: Keys to store the latest purchase token/platform for status requests
  static const String _latestPurchaseTokenKey = 'latest_purchase_token';
  static const String _latestPurchasePlatformKey = 'latest_purchase_platform';
  static const String _premiumOverrideKey = 'premium_override';

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

  // NEW HELPER: Cache latest purchase details for status checks
  Future<void> cacheLatestPurchaseDetails({
    required String purchaseToken,
    required String platform,
    String? subscriptionId, // ✅ NEW: Optional subscription ID
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_scopedKey(_latestPurchaseTokenKey), purchaseToken);
    await prefs.setString(_scopedKey(_latestPurchasePlatformKey), platform);

    // ✅ NEW: Cache subscription ID if provided
    if (subscriptionId != null && subscriptionId.isNotEmpty) {
      await prefs.setString(
        _scopedKey(_currentSubscriptionIdKey),
        subscriptionId,
      );
      print('✅ Cached subscription ID: $subscriptionId');
    }

    print(
      '✅ Cached latest purchase token/platform for status checks: $platform',
    );
  }

  // NEW HELPER: Clear cached purchase details
  Future<void> clearCachedPurchaseToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_scopedKey(_latestPurchaseTokenKey));
    await prefs.remove(_scopedKey(_latestPurchasePlatformKey));
    print('✅ Cleared cached purchase token/platform');
  }

  // Alias helper to cache purchase token/platform
  Future<void> cachePurchaseToken(String purchaseToken, String platform) async {
    await cacheLatestPurchaseDetails(purchaseToken: purchaseToken, platform: platform);
  }

  /// ========================================
  /// VERIFY PURCHASE WITH BACKEND
  /// ========================================
  ///
  // Updated verifyPurchase method in PaymentRepository

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

      // ✅ CRITICAL FIX: For iOS, prioritize receipt_data (base64) over purchase_token (JWT)
      // The backend expects base64 app receipt for iOS, not JWT transaction signatures
      final purchaseToken =
          platform == 'ios'
              ? (verificationPayload['receipt_data'] ??
                  verificationPayload['purchase_token'] ??
                  '')
              : (verificationPayload['purchase_token'] ??
                  verificationPayload['receipt_data'] ??
                  '');

      final productId = verificationPayload['product_id'] as String?;

      final request = VerifyPurchaseRequest(
        purchaseToken: purchaseToken,
        productId: productId,
        platform: platform,
      );

      final prefs = ObjectFactory().prefs;

      // ✅ DEBUG MODE SIMULATION
      if (kDebugMode) {
        print('🧪 DEBUG MODE: Simulating successful verification');

        final isVenueUser = prefs.isLoggedIn() == true;
        final trialStart = DateTime.now();
        final trialEnd = DateTime.now().add(const Duration(minutes: 30));
        final subscriptionExpiry = DateTime.now().add(
          const Duration(days: 365),
        );

        await cacheBackendSubscriptionState(
          isPaidUser: true,
          subscriptionExpiryDate: subscriptionExpiry,
          currentSubscriptionId: productId,
          trialStartDate: trialStart,
          trialEndDate: trialEnd,
          isVenueUser: isVenueUser,
        );

        await cacheLatestPurchaseDetails(
          purchaseToken: 'FAKE_TOKEN',
          platform: platform,
        );

        return {
          'valid': true,
          'message': 'DEBUG: Bypassed backend verification',
          'has_active_subscription': true,
          'is_venue_user': isVenueUser,
          'trial_start_date': trialStart.toIso8601String(),
          'trial_end_date': trialEnd.toIso8601String(),
          'subscription_expiry_date': subscriptionExpiry.toIso8601String(),
          'current_subscription_id': productId,
        };
      }

      print('📤 Verifying purchase - $productId');
      print('   Platform: $platform');
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

        // ✅ Treat "already verified" as success
        final isAlreadyVerified =
            response.message?.toLowerCase().contains('already verified') ??
            false;

        if (response.valid || isAlreadyVerified) {
          print(
            '✅ Verification successful ${isAlreadyVerified ? "(already verified)" : ""}',
          );

          // ✅ CRITICAL: Extract data from verificationData
          final verificationData = response.verificationData;

          // ✅ FIX: If already verified but no verification_data, fetch real-time status
          if (verificationData == null) {
            print(
              '⚠️ Missing verification_data in response (already verified)',
            );
            print(
              '🔄 Fetching latest subscription status from backend to check if still active...',
            );

            // ✅ CRITICAL FIX: Call backend to get real-time subscription status
            // This will check Google Play to see if subscription is still active or canceled
            try {
              final statusData = await fetchSubscriptionStatusFromBackend();

              // Determine user type from product_id
              final purchaseProductId =
                  response.purchase?.productId ?? productId;

              // Use statusData results (which comes from Google Play verification)
              final isPremium = statusData['isPremium'] as bool? ?? false;
              final premiumOverride =
                  statusData['premiumOverride'] as bool? ?? false;
              final userType = statusData['userType'] as UserType?;
              final isVenueUser =
                  userType == UserType.venuePaid ||
                  userType == UserType.venueTrial;

              print('✅ Real-time subscription status received:');
              print('   isPremium: $isPremium');
              print('   premiumOverride: $premiumOverride');
              print('   userType: $userType');
              print('   Product ID: $purchaseProductId');

              // Return the real-time status instead of stale cached data
              return {
                'valid': true,
                'message': 'Purchase already verified',
                'has_active_subscription': isPremium,
                'is_venue_user': isVenueUser,
                'trial_start_date':
                    statusData['trialStartDate']?.toString() ??
                    DateTime.now().toIso8601String(),
                'trial_end_date': statusData['trialEndDate']?.toString(),
                'subscription_expiry_date':
                    statusData['subscriptionExpiryDate']?.toString(),
                'current_subscription_id':
                    statusData['currentSubscriptionId'] as String? ??
                    purchaseProductId,
                'premium_override':
                    premiumOverride, // ✅ Use real-time status, not hardcoded true
              };
            } catch (e) {
              print('❌ Failed to fetch subscription status: $e');
              print('⚠️ Falling back to cache (may be stale)');

              // Fallback to cache if API call fails
              final cachedData = await getUserSubscriptionData();
              final purchaseProductId =
                  response.purchase?.productId ?? productId;
              final isVenueUser =
                  purchaseProductId?.toLowerCase().contains('venue') ?? false;

              return {
                'valid': true,
                'message': 'Purchase already verified (using cache fallback)',
                'has_active_subscription':
                    cachedData['isPremium'] as bool? ?? false,
                'is_venue_user': isVenueUser,
                'trial_start_date': cachedData['trialStartDate']?.toString(),
                'trial_end_date': cachedData['trialEndDate']?.toString(),
                'subscription_expiry_date':
                    cachedData['subscriptionExpiryDate']?.toString(),
                'current_subscription_id':
                    cachedData['currentSubscriptionId'] as String? ??
                    purchaseProductId,
                'premium_override':
                    cachedData['premiumOverride'] as bool? ?? false,
              };
            }
          }

          // Determine subscription status from verification_data
          final subscriptionState =
              verificationData.subscriptionState?.toUpperCase() ?? '';
          final hasActiveSubscription =
              subscriptionState == 'SUBSCRIPTION_STATE_ACTIVE';

          // Determine if venue user from product ID
          final responseProductId =
              verificationData.productId ?? productId ?? '';
          final isVenueUser = responseProductId.toLowerCase().contains('venue');

          print('   Has active subscription: $hasActiveSubscription');
          print('   Is venue user: $isVenueUser');
          print('   Product ID: $responseProductId');
          print('   Subscription state: $subscriptionState');

          // ✅ Cache the token and platform for future status requests
          await cacheLatestPurchaseDetails(
            purchaseToken: purchaseToken,
            platform: platform,
          );

          // Parse dates from verification data
          DateTime? subscriptionExpiryDate;
          DateTime? trialStartDate;
          DateTime? trialEndDate;

          // Parse expiry_time (subscription end date)
          if (verificationData.expiryTime != null) {
            try {
              subscriptionExpiryDate = DateTime.parse(
                _fixDateFormat(verificationData.expiryTime!),
              );
              print('   Subscription expiry: $subscriptionExpiryDate');
            } catch (e) {
              print('⚠️ Failed to parse expiry date: $e');
            }
          }

          // Parse start_time (subscription start date)
          if (verificationData.startTime != null) {
            try {
              trialStartDate = DateTime.parse(
                _fixDateFormat(verificationData.startTime!),
              );
              print('   Subscription start: $trialStartDate');
            } catch (e) {
              print('⚠️ Failed to parse start date: $e');
            }
          }

          // ✅ For venue users: Check if they're in a trial period OR have active subscription
          // The backend returns actual subscription validity period in start_time/expiry_time
          // For test accounts, this could be 30 minutes; for real accounts, it's 1 year
          if (isVenueUser &&
              trialStartDate != null &&
              subscriptionExpiryDate != null) {
            final now = DateTime.now();
            final isActive = now.isBefore(subscriptionExpiryDate);

            if (isActive) {
              final duration = subscriptionExpiryDate.difference(
                trialStartDate,
              );
              print(
                '   Subscription duration: ${duration.inDays} days (${duration.inMinutes} minutes)',
              );
              print('   Subscription is ACTIVE');

              // Set trial end date to subscription expiry for venue users
              // This handles both trial and full subscription periods
              trialEndDate = subscriptionExpiryDate;
            } else {
              print('   Subscription EXPIRED');
              trialEndDate = null;
            }
          }

          // ✅ Cache the subscription state with correct data
          await cacheBackendSubscriptionState(
            isPaidUser: hasActiveSubscription,
            subscriptionExpiryDate: subscriptionExpiryDate,
            currentSubscriptionId: responseProductId,
            trialStartDate: trialStartDate,
            trialEndDate: trialEndDate,
            isVenueUser: isVenueUser,
            premiumOverride: true,
          );

          //  Return all necessary fields for the BLoC
          return {
            'valid': true,
            'has_active_subscription': hasActiveSubscription,
            'is_venue_user': isVenueUser,
            'trial_start_date': verificationData.startTime,
            'trial_end_date':
                verificationData
                    .expiryTime, // For venue, this is subscription expiry
            'subscription_expiry_date': verificationData.expiryTime,
            'current_subscription_id': responseProductId,
            'in_trial':
                isVenueUser && trialStartDate != null && trialEndDate != null,
          };
        }

        return {
          'valid': false,
          'message': response.message ?? 'Verification failed',
        };
      }

      // Not success
      print('❌ Repository: stateModel indicates failure: ${stateModel.error}');

      // ✅ WORKAROUND: Handle expired subscriptions from 400 errors
      // Backend returns 400 for expired subscriptions, but we should treat as success with EXPIRED state
      final errorMessage = stateModel.error ?? '';
      if (errorMessage.toLowerCase().contains('expired')) {
        print('');
        print('╔══════════════════════════════════════════╗');
        print('⚠️ EXPIRED SUBSCRIPTION DETECTED (400 Error)');
        print('╚══════════════════════════════════════════╝');
        print('Backend returned 400 for expired subscription.');
        print(
          'Treating as success with EXPIRED state to allow resubscription.',
        );
        print('');

        // Try to extract verification_data from the error response
        final responseData = stateModel.data;
        final verificationData = responseData?.verificationData;

        if (verificationData != null) {
          print('✅ Extracted verification data from error response');
          print('   Subscription State: ${verificationData.subscriptionState}');
          print('   Expiry Time: ${verificationData.expiryTime}');
          print('   Product ID: ${verificationData.productId}');

          // Cache as expired subscription (premium = false)
          await cacheBackendSubscriptionState(
            isPaidUser: false, // ❌ No premium access for expired
            subscriptionStatus: false,
            subscriptionExpiryDate:
                verificationData.expiryTime != null
                    ? DateTime.fromMillisecondsSinceEpoch(
                      int.tryParse(verificationData.expiryTime!) ?? 0,
                    )
                    : null,

            currentSubscriptionId: verificationData.productId,
            isVenueUser:
                verificationData.productId?.toLowerCase().contains('venue') ??
                false,
            premiumOverride: false, // ❌ Explicitly deny premium
          );

          // Return success with expired state
          return {
            'valid': true, //  Treat as valid (not an error)
            'has_active_subscription': false, // ❌ No active subscription
            'subscription_expired': true, // ⚠️ But it's expired
            'subscription_state': 'SUBSCRIPTION_STATE_EXPIRED',
            'message': 'Subscription expired - user can resubscribe',
          };
        }

        // If no verification_data, still treat as expired
        print('⚠️ No verification data in error response');
        print('   Treating as expired subscription anyway');
        print('╚══════════════════════════════════════════╝');
        print('');

        return {
          'valid': true, // ✅ Treat as valid (not an error)
          'has_active_subscription': false,
          'subscription_expired': true,
          'subscription_state': 'SUBSCRIPTION_STATE_EXPIRED',
          'message': 'Subscription expired - user can resubscribe',
        };
      }

      //  CHECK FOR DUPLICATE PURCHASE TOKEN ERROR (ownership conflict)

      if (errorMessage.contains('Duplicate entry') ||
          errorMessage.contains('purchases_purchase_token_unique') ||
          errorMessage.contains('subscription belongs to another user')) {
        // Return failure - don't grant access
        return {
          'valid': false,
          'message':
              'This subscription is linked to a different user account. '
              'Please log in with the correct account or purchase a new subscription.',
          'error_code': 'PURCHASE_OWNERSHIP_CONFLICT',
        };
      }

      // Check for other "already verified" messages
      if (errorMessage.contains('already verified')) {
        print('ℹ️ Already verified error - returning success');
        return {'valid': true, 'message': 'Purchase already verified'};
      }

      return {'valid': false, 'message': errorMessage};
    } catch (e, st) {
      print('❌ Repository: verifyPurchase exception: $e\n$st');

      // Check exception message for duplicate constraint
      final errorMessage = e.toString();
      if (errorMessage.contains('Duplicate entry') ||
          errorMessage.contains('purchases_purchase_token_unique')) {
        return {
          'valid': false,
          'message':
              'This subscription is linked to a different user account. '
              'Please log in with the correct account or purchase a new subscription.',
          'error_code': 'PURCHASE_OWNERSHIP_CONFLICT',
        };
      }

      if (errorMessage.contains('already verified')) {
        print('ℹ️ Exception indicates already verified - treating as success');
        return {'valid': true, 'message': 'Purchase already verified'};
      }

      return {'valid': false, 'message': 'Error: ${e.toString()}'};
    }
  }

  String _fixDateFormat(String input) {
    if (input.contains(' ') && !input.contains('T')) {
      return input.replaceFirst(' ', 'T');
    }
    return input;
  }

  /// ========================================
  /// FETCH SUBSCRIPTION STATUS FROM BACKEND
  /// ========================================
  /// MODIFIED to fetch active subscription using getActiveSubscription endpoint
  Future<Map<String, dynamic>> fetchSubscriptionStatusFromBackend({
    String? productId,
    String? purchaseToken,
  }) async {
    try {
      print('🔄 Repository: Fetching subscription status using get-token-details');

      final prefs = ObjectFactory().prefs;
      final userId = prefs.getUserId();
      final cafeId = prefs.getCafeId();

      // Check authentication first
      if (userId == null && cafeId == null) {
        print('ℹ️ Not authenticated - returning cache.');
        return await getUserSubscriptionData();
      }

      // Check user category to determine if venue owner or public user
      final userCategory = ObjectFactory().prefs.getUserDecisionName();
      final isPublicUser = userCategory == "PUBLIC_USER";
      final isVenueUser = !isPublicUser;
      
      // Determine platform fallback
      final currentPlatform = defaultTargetPlatform == TargetPlatform.iOS ? 'ios' : 'android';

      // Debouncing - prevent redundant API calls
      final now = DateTime.now();
      if (_lastStatusCheckTime != null) {
        final timeSinceLastCheck = now.difference(_lastStatusCheckTime!);
        if (timeSinceLastCheck < _debounceInterval) {
          print('⏸️ Debouncing: Last status check was ${timeSinceLastCheck.inSeconds}s ago');
          return await getUserSubscriptionData();
        }
      }
      _lastStatusCheckTime = now;

      // 1. Query the new active subscription details endpoint first
      final stateModel = await _iapDataProvider.getActiveSubscription();

      if (stateModel.isSuccess) {
        final SubscriptionStatusResponse response = stateModel.data!;
        
        final verificationData = response.verificationData;

        // If verificationData is null, or success is false, we indicate no subscription
        if (response.success != true || verificationData == null) {
          print('⚠️ Status endpoint success is not true or verification_data is null.');
          print('   Revoking entitlements, defaulting to free tier.');
          return await _revokePremiumEntitlements(isVenueUser);
        }

        // Validate that backend returned subscription status fields
        if (verificationData.subscriptionState == null) {
          print('⚠️ Missing subscription_state field in verification_data.');
          _lastStatusCheckTime = null;
          return await getUserSubscriptionData();
        }

        // Derive status fields from the VerificationData object properties.
        final String? subState = verificationData.subscriptionState?.toLowerCase();

        // Check for canceled/expired subscriptions
        final bool isCanceled =
            subState == 'canceled' ||
            subState == 'subscription_state_canceled' ||
            subState?.contains('cancel') == true;

        final bool isExpired =
            subState == 'expired' ||
            subState == 'subscription_state_expired' ||
            subState?.contains('expired') == true;

        final bool hasActiveSub =
            (subState == 'active' || subState == 'subscription_state_active') &&
            !isCanceled &&
            !isExpired;

        final bool autoRenewing = verificationData.autoRenewing ?? false;

        // Cache latest purchase details (purchase token and product ID)
        final returnedToken = verificationData.linkedPurchaseToken ?? verificationData.orderId ?? '';
        final returnedProductId = verificationData.productId ?? '';
        if (returnedToken.isNotEmpty) {
          await cacheLatestPurchaseDetails(
            purchaseToken: returnedToken,
            platform: currentPlatform,
            subscriptionId: returnedProductId,
          );
        }

        // Distinguish between expired+auto-renewing vs truly cancelled
        if (isCanceled || isExpired) {
          final userType = isVenueUser ? UserType.venueTrial : UserType.publicFree;

          // If subscription is expired BUT auto-renewing, preserve the token
          if (isExpired && autoRenewing) {
            final result = {
              'userType': userType,
              'isPremium': false, // No access until renewed
              'trialStartDate': null,
              'trialEndDate': null,
              'subscriptionExpiryDate':
                  verificationData.expiryTime != null
                      ? DateTime.tryParse(verificationData.expiryTime!)
                      : null,
              'currentSubscriptionId': verificationData.productId,
              'premiumOverride': false, // No override until renewed
              'autoRenewing': true,
              'linkedPurchaseToken': returnedToken,
            };

            await cacheBackendSubscriptionState(
              isPaidUser: false,
              isVenueUser: isVenueUser,
              subscriptionExpiryDate: result['subscriptionExpiryDate'] as DateTime?,
              trialStartDate: null,
              trialEndDate: null,
              currentSubscriptionId: result['currentSubscriptionId'] as String?,
              premiumOverride: false,
            );

            return result;
          } else {
            // Truly cancelled or expired without auto-renew - clear everything
            final result = {
              'userType': userType,
              'isPremium': false,
              'trialStartDate': null,
              'trialEndDate': null,
              'subscriptionExpiryDate': null,
              'currentSubscriptionId': verificationData.productId,
              'premiumOverride': false,
              'autoRenewing': false,
            };

            await cacheBackendSubscriptionState(
              isPaidUser: false,
              isVenueUser: isVenueUser,
              subscriptionExpiryDate: null,
              trialStartDate: null,
              trialEndDate: null,
              currentSubscriptionId: result['currentSubscriptionId'] as String?,
              premiumOverride: false,
            );

            await clearCachedPurchaseToken();
            return result;
          }
        }

        // Active subscription - grant premium access
        final bool inTrial = false;

        final userType = isVenueUser
            ? (hasActiveSub ? UserType.venuePaid : UserType.venueTrial)
            : (hasActiveSub ? UserType.publicPaid : UserType.publicFree);
            
        final result = {
          'userType': userType,
          'isPremium': hasActiveSub || inTrial,
          'trialStartDate':
              verificationData.startTime != null
                  ? DateTime.tryParse(verificationData.startTime!)
                  : null,
          'trialEndDate':
              verificationData.expiryTime != null
                  ? DateTime.tryParse(verificationData.expiryTime!)
                  : null,
          'subscriptionExpiryDate':
              verificationData.expiryTime != null
                  ? DateTime.tryParse(verificationData.expiryTime!)
                  : null,
          'currentSubscriptionId': verificationData.productId,
          'premiumOverride': hasActiveSub,
        };
        
        await cacheBackendSubscriptionState(
          isPaidUser: hasActiveSub,
          isVenueUser: isVenueUser,
          subscriptionExpiryDate: result['subscriptionExpiryDate'] as DateTime?,
          trialStartDate: result['trialStartDate'] as DateTime?,
          trialEndDate: result['trialEndDate'] as DateTime?,
          currentSubscriptionId: result['currentSubscriptionId'] as String?,
          premiumOverride: hasActiveSub,
        );
        
        print('💾 Caching active subscription details complete: User premium access granted.');
        return result;
      } else {
        // The API returned an error state
        final errorMessage = stateModel.error ?? 'Unknown error';
        print('❌ getActiveSubscription API error: $errorMessage');

        // Check if error is due to network or server-side issues (500, SQL, network, timeout, etc.)
        final isServerOrNetworkError = 
            errorMessage.contains('500') ||
            errorMessage.contains('502') ||
            errorMessage.contains('503') ||
            errorMessage.contains('504') ||
            errorMessage.contains('SQLSTATE') ||
            errorMessage.toLowerCase().contains('network') ||
            errorMessage.toLowerCase().contains('timeout') ||
            errorMessage.toLowerCase().contains('connection') ||
            errorMessage.toLowerCase().contains('unable to reach server') ||
            errorMessage.toLowerCase().contains('no internet');

        if (isServerOrNetworkError) {
          print('⚠️ Server/Network error detected. Gracefully falling back to cached state.');
          _lastStatusCheckTime = null; // Reset so next check will query backend
          return await getUserSubscriptionData();
        } else {
          // If it is success: false response or explicitly indicates cancellation/expiration
          // or 401 Unauthorized / 404 Not Found
          print('⚠️ API returned failure or explicit cancellation. Revoking entitlements, defaulting to free tier.');
          return await _revokePremiumEntitlements(isVenueUser);
        }
      }
    } catch (e) {
      print('❌ Unexpected error in fetchSubscriptionStatusFromBackend: $e');
      _lastStatusCheckTime = null;
      return await getUserSubscriptionData();
    }
  }

  /// Helper to revoke premium entitlements and return free/trial state
  Future<Map<String, dynamic>> _revokePremiumEntitlements(bool isVenueUser) async {
    final userType = isVenueUser ? UserType.venueTrial : UserType.publicFree;
    final result = {
      'userType': userType,
      'isPremium': false,
      'trialStartDate': null,
      'trialEndDate': null,
      'subscriptionExpiryDate': null,
      'currentSubscriptionId': null,
      'premiumOverride': false,
      'autoRenewing': false,
    };

    await cacheBackendSubscriptionState(
      isPaidUser: false,
      isVenueUser: isVenueUser,
      subscriptionExpiryDate: null,
      trialStartDate: null,
      trialEndDate: null,
      currentSubscriptionId: null,
      premiumOverride: false,
    );

    await clearCachedPurchaseToken();
    return result;
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
    bool? premiumOverride,
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

    // ✅ Store premiumOverride flag
    if (premiumOverride != null) {
      await prefs.setBool(_scopedKey(_premiumOverrideKey), premiumOverride);
      print('💾 Cached premiumOverride: $premiumOverride');
    }

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

      bool premiumOverride =
          prefs.getBool(_scopedKey(_premiumOverrideKey)) ?? false;
      final currentSubscriptionId = prefs.getString(
        _scopedKey(_currentSubscriptionIdKey),
      );
      // NEW: Reading cached token and platform
      final latestPurchaseToken = prefs.getString(
        _scopedKey(_latestPurchaseTokenKey),
      );
      final latestPurchasePlatform = prefs.getString(
        _scopedKey(_latestPurchasePlatformKey),
      );
      final trialStartStr = prefs.getString(_scopedKey(_trialStartDateKey));
      final trialEndStr = prefs.getString(_scopedKey(_trialEndDateKey));
      final subscriptionExpiryStr = prefs.getString(
        _scopedKey(_subscriptionExpiryKey),
      );
      // DateTime? trialStartDate =
      //     trialStartStr != null ? DateTime.parse(trialStartStr) : null;
      // DateTime? trialEndDate =
      //     trialEndStr != null ? DateTime.parse(trialEndStr) : null;
      // DateTime? subscriptionExpiryDate =
      //     subscriptionExpiryStr != null
      //         ? DateTime.parse(subscriptionExpiryStr)
      //         : null;
      // ✅ Use safe parsing
      DateTime? trialStartDate = _safeParseDateTimeFromBackend(trialStartStr);
      DateTime? trialEndDate = _safeParseDateTimeFromBackend(trialEndStr);
      DateTime? subscriptionExpiryDate = _safeParseDateTimeFromBackend(
        subscriptionExpiryStr,
      );

      bool subscriptionExpired = false;
      if (subscriptionExpiryDate != null) {
        subscriptionExpired = DateTime.now().isAfter(subscriptionExpiryDate);
        if (subscriptionExpired) {
          // ⚠️ IMPORTANT: Do NOT clear premiumOverride here!
          // premiumOverride is set by backend verification and should persist
          // even if local expiry date suggests subscription expired.
          // This is critical for test subscriptions (30 min expiry) and
          // ensures access is only revoked by explicit backend rejection.
          await prefs.setBool(_scopedKey(_isPremiumKey), false);
          isPremium = false;
          // premiumOverride stays as-is (not cleared)
        }
      }

      bool trialExpired = false;
      if (trialEndDate != null) {
        trialExpired = DateTime.now().isAfter(trialEndDate);
        if (trialExpired) {
          print('⚠️ Trial period expired');
        }
      }

      UserType userType;

      if (isVenueLoggedIn) {
        // ✅ CRITICAL FIX: Check premiumOverride first
        if (premiumOverride) {
          // If premiumOverride is set, user has premium access
          userType = UserType.venuePaid;
          isPremium = true; // Ensure isPremium is also true
          print('✅ Premium override active - granting venuePaid status');
        } else {
          final hasActiveSubscription =
              isPremium &&
              subscriptionExpiryDate != null &&
              !subscriptionExpired;
          final isInTrial = trialEndDate != null && !trialExpired;

          if (hasActiveSubscription) {
            userType = UserType.venuePaid;
          } else if (isInTrial) {
            userType = UserType.venueTrial;
          } else {
            userType = UserType.venueTrial;
          }
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
        'latestPurchaseToken': latestPurchaseToken,
        'latestPurchasePlatform': latestPurchasePlatform,
        'premiumOverride': premiumOverride,
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
        'latestPurchaseToken': null,
        'latestPurchasePlatform': null,
        'premiumOverride': false,
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
    // NEW: Clear new cache keys
    await prefs.remove(_scopedKey(_latestPurchaseTokenKey));
    await prefs.remove(_scopedKey(_latestPurchasePlatformKey));
    await prefs.remove(_scopedKey(_premiumOverrideKey));
  }
}

DateTime? _safeParseDateTimeFromBackend(String? dateStr) {
  if (dateStr == null || dateStr.isEmpty) return null;

  try {
    // First, normalize the format by replacing space with 'T'
    String normalized = dateStr.trim();

    // Handle format: "2025-12-11 07:18:08" -> "2025-12-11T07:18:08"
    if (normalized.contains(' ') && !normalized.contains('T')) {
      normalized = normalized.replaceFirst(' ', 'T');
    }

    // Handle fractional seconds: "2025-12-11T07:18:08.000000Z"
    // DateTime.parse handles this automatically

    // Parse with timezone awareness
    final parsed = DateTime.parse(normalized);

    // If it's in UTC (ends with Z), convert to local
    if (dateStr.endsWith('Z') || dateStr.endsWith('+00:00')) {
      return parsed.toLocal();
    }

    return parsed;
  } catch (e) {
    print('⚠️ Failed to parse DateTime from "$dateStr": $e');
    return null;
  }
}

// 🔧 UPDATE: Replace the _fixDateFormat function with this more robust version
String _fixDateFormat(String input) {
  if (input.contains(' ') && !input.contains('T')) {
    return input.replaceFirst(' ', 'T');
  }
  return input;
}
