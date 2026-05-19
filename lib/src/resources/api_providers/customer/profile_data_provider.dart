import 'dart:convert';

import 'package:soloseaters/src/model/customer/profile/customer_get_profile_response.dart';
import 'package:soloseaters/src/model/customer/profile/customer_paid_profile_request.dart';
import 'package:soloseaters/src/model/customer/profile/customer_paid_profile_response.dart';
import 'package:soloseaters/src/model/customer/profile/customer_paid_profile_update_response.dart';
import 'package:soloseaters/src/model/customer/profile/customer_profile_update_request.dart';
import 'package:soloseaters/src/model/customer/profile/customer_update_profile_response.dart';
import 'package:soloseaters/src/model/delete_profile_response.dart';
import 'package:soloseaters/src/model/state_model.dart';
import 'package:soloseaters/src/utils/data/object_factory.dart';
import 'package:dio/dio.dart';

class CustomerProfileDataProvider {

  String _extractErrorMessage(dynamic error) {
  if (error == null) return "Unknown error";

  if (error is String) return error;

  if (error is List) return error.join(", ");

  if (error is Map<String, dynamic>) {
    return error.entries
        .map((e) => "${e.key}: ${(e.value as List).join(", ")}")
        .join("\n");
  }

  if (error is MapEntry) {
    return "${error.key}: ${(error.value as List).join(", ")}";
  }

  return error.toString();
}
  Future<StateModel?> getCustomerProfile() async {
    try {
      final response = await ObjectFactory().apiClient.getCustomerProfile();
      if (response.statusCode == 200) {
        print('Profile Response: ${response.data}');
        return StateModel<CustomerGetProfileResponse>.success(
          CustomerGetProfileResponse.fromJson(response.data),
        );
      } else {
        return StateModel.error(
          'Unexpected status code: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      if (e.response != null && e.response!.statusCode == 500) {
        return StateModel.error(
          "The server isn't responding! Please try again later.",
        );
      } else if (e.response != null && e.response!.statusCode == 401) {
        return StateModel.error("UnAuthorized error");
      } else if (e.type == DioExceptionType.connectionError) {
        return StateModel.error("No internet connection");
      } else if (e.response == null) {
        return StateModel.error("Unable to reach server. Try again later.");
      } else {
        return StateModel.error('Network error: ${e.message}');
      }
    } catch (e) {
      print('Parsing Error: $e');
      return StateModel.error('Failed to parse profile data: $e');
    }
  }

  Future<StateModel?> updateCustomerProfile(
    CustomerUpdateProfileRequest request,
  ) async {
    try {
      final response = await ObjectFactory().apiClient.updateCustomerProfile(
        request,
      );
      if (response.statusCode == 200) {
        print('Update Response: ${response.data}');
        // String jsonRequest = jsonEncode(request);
        // print("Request Payload:");
        // print(jsonRequest);
        return StateModel<CustomerUpdateProfileResponse>.success(
          CustomerUpdateProfileResponse.fromJson(response.data),
        );
      } else {
        return StateModel.error(
          'Unexpected status code: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      if (e.response != null && e.response!.statusCode == 500) {
        return StateModel.error(
          "The server isn't responding! Please try again later.",
        );
      } else if (e.response != null && e.response!.statusCode == 408) {
        return StateModel.error(
          "Hello there! It seems like your request took longer than expected to process...",
        );
      } else if (e.response != null && e.response!.statusCode == 401) {
        return StateModel.error("UnAuthorized error");
      } else if (e.response == null) {
        if (e.message == "No internet connection") {
          return StateModel.error("No internet connection");
        }
        return StateModel.error("Unable to reach server. Try again later.");
      } else {
        return StateModel.error('Network error: ${e.message}');
      }
    } catch (e) {
      print('Parsing Error: $e');
      return StateModel.error('Failed to parse update response: $e');
    }
  }

  Future<StateModel?> customerProfileDelete() async {
    try {
      final response = await ObjectFactory().apiClient.customerProfileDelete();
      print(response.toString());
      if (response.statusCode == 200) {
        return StateModel<DeleteProfileResponse>.success(
          DeleteProfileResponse.fromJson(response.data),
        );
      }

      return null;
    } on DioException catch (e) {
      if (e.response != null && e.response!.statusCode == 500) {
        return StateModel.error(
          "The server isn't responding! Please try again later.",
        );
      } else if (e.response != null && e.response!.statusCode == 408) {
        return StateModel.error(
          "Hello there! It seems like your request took longer than expected to process. We apologize for the inconvenience. Please try again later or reach out to our support team for assistance. Thank you for your patience!",
        );
      } else if (e.type.name == "connectionError") {
        if (e.message == "No internet connection") {
          return StateModel.error("No internet connection");
        }
        return StateModel.error("Unable to reach server. Try again later.");
      } else if (e.response != null && e.response!.statusCode == 401) {
        return StateModel.error("UnAuthorized error");
      } else if (e.response == null) {
        if (e.message == "No internet connection") {
          return StateModel.error("No internet connection");
        }
        return StateModel.error("Unable to reach server. Try again later.");
      }
    }
    return null;
  }

  Future<StateModel?> getPaidCustomerProfileById() async {
    try {
      final response =
          await ObjectFactory().apiClient.getPaidCustomerProfileById();
      if (response.statusCode == 200) {
        print('Profile Response: ${response.data}');
        return StateModel<CustomerPaidProfileResponse>.success(
          CustomerPaidProfileResponse.fromJson(response.data),
        );
      } else {
        return StateModel.error(
          'Unexpected status code: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      if (e.response != null && e.response!.statusCode == 500) {
        return StateModel.error(
          "The server isn't responding! Please try again later.",
        );
      } else if (e.response != null && e.response!.statusCode == 401) {
        return StateModel.error("UnAuthorized error");
      } else if (e.response == null) {
        if (e.message == "No internet connection") {
          return StateModel.error("No internet connection");
        }
        return StateModel.error("Unable to reach server. Try again later.");
      } else {
        return StateModel.error('Network error: ${e.message}');
      }
    } catch (e) {
      print('Parsing Error: $e');
      return StateModel.error('Failed to parse profile data: $e');
    }
  }



Future<StateModel<PaidProfileUpdateResponse>?> updatePaidCustomerProfile(
  PaidProfileUpdateRequest request,
) async {
  try {
    final response =
        await ObjectFactory().apiClient.updatePaidCustomerProfile(request);

    print('Profile Response: ${response.data}');

    if (response.statusCode == 200) {
      final parsed = PaidProfileUpdateResponse.fromJson(response.data);

      if (parsed.status == true) {
        return StateModel.success(parsed);
      } else {
        String msg = parsed.message ?? "Profile update failed.";

        // preserve your logic
        if (parsed.errors != null && parsed.errors!.isNotEmpty) {
          final errorDetails = parsed.errors!.entries
              .map((e) => "${e.key}: ${e.value.join(", ")}")
              .join("\n");
          msg = "$msg\n$errorDetails";
        }

        // 🔥 fix: convert errors into string
        final errorMsg = _extractErrorMessage(parsed.errors);

        return StateModel.error(errorMsg);
      }
    }

    return StateModel.error(
      "Unexpected status code: ${response.statusCode}",
    );
  } on DioException catch (e) {
    String msg = "Network error occurred.";

    if (e.response != null) {
      msg = e.response!.data.toString();
    } else if (e.message != null) {
      msg = e.message!;
    }

    return StateModel.error(msg);
  } catch (e) {
    return StateModel.error("Failed to parse response: $e");
  }
}

}
