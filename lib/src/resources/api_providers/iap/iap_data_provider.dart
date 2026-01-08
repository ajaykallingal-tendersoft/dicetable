import 'package:dio/dio.dart';
import 'package:soloseaters/src/model/payment/subscription_status_request.dart';
import 'package:soloseaters/src/model/payment/subscription_status_response.dart';
import 'package:soloseaters/src/model/payment/verify_purchase_request.dart';
import 'package:soloseaters/src/model/payment/verify_purchase_response.dart';
import 'package:soloseaters/src/model/state_model.dart';
import 'package:soloseaters/src/utils/data/object_factory.dart';

class IapDataProvider {
  /// Generic dio → readable error mapper
  StateModel<T> _handleDioError<T>(DioException e) {
    print('❌ Dio Error: ${e.message}');
    print('❌ Dio Error Type: ${e.type}');
    print('❌ Dio Error Response: ${e.response}');

    final status = e.response?.statusCode;
    final responseData = e.response?.data;

    // ✅ CHECK FOR DUPLICATE PURCHASE TOKEN ERROR FIRST (before generic 500 handling)
    if (status == 500 && responseData is Map<String, dynamic>) {
      final message = responseData['message']?.toString() ?? '';

      // Check for duplicate entry constraint violation
      if (message.contains('Duplicate entry') ||
          message.contains('purchases_purchase_token_unique')) {
        print('⚠️ Detected duplicate purchase token error in response');
        // Return the specific error so purchase_repository can catch it
        return StateModel.error(
          "Duplicate entry - This subscription belongs to another user",
        );
      }
    }

    // Generic 500 error
    if (status == 500) {
      return StateModel.error("Server error. Please try again later.");
    }

    if (status == 401) {
      return StateModel.error("Unauthorized. Please login again.");
    }
    if (status == 409) {
      // Handle conflicts, like "already verified"
      // We can pass a special success state or a specific error message
      return StateModel.error("Purchase has already been verified.");
    }

    if (e.type == DioExceptionType.connectionError ||
        e.type == DioExceptionType.unknown ||
        e.type == DioExceptionType.connectionTimeout) {
      return StateModel.error(
        "Connection error. Check your internet connection.",
      );
    }

    if (e.response == null) {
      return StateModel.error("Unable to reach server. Try again later.");
    }

    // Try to get a more specific error from the response body
    if (responseData is Map<String, dynamic> &&
        responseData.containsKey('message')) {
      return StateModel.error(responseData['message']);
    }

    return StateModel.error(e.message ?? "Something went wrong.");
  }

  /// Safe JSON decode
  T? _safeParse<T>(dynamic json, T Function(Map<String, dynamic>) parser) {
    try {
      if (json is Map<String, dynamic>) {
        return parser(json);
      }
      return null;
    } catch (e, stacktrace) {
      print('❌ JSON Parse Error: $e');
      print('❌ Stacktrace: $stacktrace');
      return null;
    }
  }

  /// Verify purchase with backend
  Future<StateModel<VerifyPurchaseResponse>> verifyPurchase(
    VerifyPurchaseRequest request,
  ) async {
    try {
      print('📡 Verifying purchase - ${request.productId}');

      final response = await ObjectFactory().apiClient.verifyPurchase(request);

      print('✅ Raw verify response: ${response.data}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final parsed = _safeParse(
          response.data,
          (json) => VerifyPurchaseResponse.fromJson(json),
        );

        if (parsed == null) {
          return StateModel.error("Invalid server response format.");
        }

        if (parsed.valid) {
          return StateModel.success(parsed);
        }

        // Check for "already verified" message from a successful response
        if (parsed.message?.toLowerCase().contains('already verified') ==
            true) {
          return StateModel.success(parsed);
        }

        return StateModel.error(
          parsed.message ?? "Purchase verification failed",
        );
      }

      return StateModel.error(
        "Verification failed with status ${response.statusCode}",
      );
    } on DioException catch (e) {
      return _handleDioError(e);
    } catch (e) {
      print("❌ Unexpected error in verifyPurchase: $e");
      return StateModel.error("Unexpected error: ${e.toString()}");
    }
  }

  /// Fetch subscription status
  Future<StateModel<SubscriptionStatusResponse>> getSubscriptionStatus(
    SubscriptionStatusRequest request,
  ) async {
    try {
      print('📡 Fetching subscription status');

      final response = await ObjectFactory().apiClient.getSubscriptionStatus(
        request,
      );

      print('✅ Raw subscription response: ${response.data}');

      if (response.statusCode == 200) {
        final parsed = _safeParse(
          response.data,
          (json) => SubscriptionStatusResponse.fromJson(json),
        );

        if (parsed == null) {
          return StateModel.error("Invalid server response format.");
        }

        if (parsed.success == true) {
          return StateModel.success(parsed);
        }

        return StateModel.error(
          parsed.message ?? "Failed to fetch subscription",
        );
      }

      return StateModel.error(
        "Request failed with status ${response.statusCode}",
      );
    } on DioException catch (e) {
      // ✅ NEW: Special handling for 400 responses with canceled/expired subscriptions
      if (e.response?.statusCode == 400) {
        final responseData = e.response?.data;

        if (responseData is Map<String, dynamic>) {
          // Try to parse the response even though it's a 400 error
          try {
            final parsed = _safeParse(
              responseData,
              (json) => SubscriptionStatusResponse.fromJson(json),
            );

            // ✅ CRITICAL: If we got verification_data with CANCELED or EXPIRED state,
            // return it as "success" so the repository can process the cancellation/expiration
            final subscriptionState =
                parsed?.verificationData?.subscriptionState?.toUpperCase() ??
                '';

            if (subscriptionState.contains('CANCEL') ||
                subscriptionState.contains('EXPIRED')) {
              print(
                '⚠️ Detected $subscriptionState subscription in 400 response',
              );
              print(
                '   Subscription state: ${parsed!.verificationData!.subscriptionState}',
              );
              print('   Returning as success for processing');

              // Return success with the cancellation/expiration data
              return StateModel.success(parsed);
            }
          } catch (parseError) {
            print('❌ Failed to parse 400 response: $parseError');
            // Fall through to regular error handling
          }

          // Regular 400 error handling
          final message = responseData['message']?.toString() ?? 'Bad request';
          print('❌ 400 error without cancellation/expiration data: $message');
        }
      }

      return _handleDioError(e);
    } catch (e) {
      print("❌ Unexpected error in getSubscriptionStatus: $e");
      return StateModel.error("Unexpected error: ${e.toString()}");
    }
  }
}
