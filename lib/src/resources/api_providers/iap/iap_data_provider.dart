import 'package:dio/dio.dart';
import 'package:soloseaters/src/model/payment/subscription_status_response.dart';
import 'package:soloseaters/src/model/payment/verify_purchase_request.dart';
import 'package:soloseaters/src/model/payment/verify_purchase_response.dart';
import 'package:soloseaters/src/model/state_model.dart';
import 'package:soloseaters/src/utils/data/object_factory.dart';

class IapDataProvider {
  /// Generic dio → readable error mapper
  StateModel<T> _handleDioError<T>(DioException e) {
    print('❌ Dio Error: ${e.message}');

    final status = e.response?.statusCode;

    if (status == 500) {
      return StateModel.error("Server error. Please try again later.");
    }

    if (status == 401) {
      return StateModel.error("Unauthorized. Please login again.");
    }

    if (e.type == DioExceptionType.connectionError ||
        e.type == DioExceptionType.unknown) {
      return StateModel.error(
        "Connection error. Check your internet connection.",
      );
    }

    if (e.response == null) {
      return StateModel.error("Unable to reach server. Try again later.");
    }

    return StateModel.error(e.message ?? "Something went wrong.");
  }

  /// Safe JSON decode
  T? _safeParse<T>(
    dynamic json,
    T Function(Map<String, dynamic>) parser,
  ) {
    try {
      if (json is Map<String, dynamic>) {
        return parser(json);
      }
      return null;
    } catch (e) {
      print('❌ JSON Parse Error: $e');
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

      if (response.statusCode == 200) {
        final parsed = _safeParse(
          response.data,
          (json) => VerifyPurchaseResponse.fromJson(json),
        );

        if (parsed == null) {
          return StateModel.error("Invalid server response.");
        }

        if (parsed.valid) {
          return StateModel.success(parsed);
        }

        return StateModel.error(parsed.message ?? "Purchase verification failed");
      }

      return StateModel.error(
        "Verification failed with status ${response.statusCode}",
      );
    } on DioException catch (e) {
      return _handleDioError(e);
    } catch (e) {
      print("❌ Unexpected error: $e");
      return StateModel.error("Unexpected error: ${e.toString()}");
    }
  }

  /// Fetch subscription status
  Future<StateModel<SubscriptionStatusResponse>> getSubscriptionStatus() async {
    try {
      print('📡 Fetching subscription status');

      final response = await ObjectFactory().apiClient.getSubscriptionStatus();

      print('✅ Raw subscription response: ${response.data}');

      if (response.statusCode == 200) {
        final parsed = _safeParse(
          response.data,
          (json) => SubscriptionStatusResponse.fromJson(json),
        );

        if (parsed == null) {
          return StateModel.error("Invalid server response.");
        }

        if (parsed.status) {
          return StateModel.success(parsed);
        }

        return StateModel.error(parsed.message ?? "Failed to fetch subscription");
      }

      return StateModel.error(
        "Request failed with status ${response.statusCode}",
      );
    } on DioException catch (e) {
      return _handleDioError(e);
    } catch (e) {
      print("❌ Unexpected error: $e");
      return StateModel.error("Unexpected error: ${e.toString()}");
    }
  }
}
