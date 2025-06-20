import 'package:dicetable/src/model/customer/profile/customer_get_profile_response.dart';
import 'package:dicetable/src/model/customer/profile/customer_profile_update_request.dart';
import 'package:dicetable/src/model/customer/profile/customer_update_profile_response.dart';
import 'package:dicetable/src/model/delete_profile_response.dart';
import 'package:dicetable/src/model/state_model.dart';
import 'package:dicetable/src/utils/data/object_factory.dart';
import 'package:dio/dio.dart';
import 'dart:convert';


class CustomerProfileDataProvider {
  Future<StateModel?> getCustomerProfile() async {
    try {

      final response = await ObjectFactory().apiClient.getCustomerProfile();
      if (response.statusCode == 200) {
        print('Profile Response: ${response.data}');
        return StateModel<CustomerGetProfileResponse>.success(
            CustomerGetProfileResponse.fromJson(response.data));
      } else {
        return StateModel.error('Unexpected status code: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.response != null && e.response!.statusCode == 500) {
        return StateModel.error("The server isn't responding! Please try again later.");
      } else if (e.response != null && e.response!.statusCode == 408) {
        return StateModel.error(
            "Hello there! It seems like your request took longer than expected to process...");
      } else {
        return StateModel.error('Network error: ${e.message}');
      }
    } catch (e) {
      print('Parsing Error: $e');
      return StateModel.error('Failed to parse profile data: $e');
    }
  }

  Future<StateModel?> updateCustomerProfile( CustomerUpdateProfileRequest request) async {
    try {
      final response = await ObjectFactory().apiClient.updateCustomerProfile(request);
      if (response.statusCode == 200) {
        print('Update Response: ${response.data}');
        String jsonRequest = jsonEncode(request);
        print("Request Payload:");
        print(jsonRequest);
        return StateModel<CustomerUpdateProfileResponse>.success(
            CustomerUpdateProfileResponse.fromJson(response.data));
      } else {
        return StateModel.error('Unexpected status code: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.response != null && e.response!.statusCode == 500) {
        return StateModel.error("The server isn't responding! Please try again later.");
      } else if (e.response != null && e.response!.statusCode == 408) {
        return StateModel.error(
            "Hello there! It seems like your request took longer than expected to process...");
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
      final response =
      await ObjectFactory().apiClient.customerProfileDelete();
      print(response.toString());
      if (response.statusCode == 200) {
        return StateModel<DeleteProfileResponse>.success(
            DeleteProfileResponse.fromJson(response.data));
      }
      return null;
    } on DioException catch (e) {

      if (e.response!.statusCode == 500) {
        return StateModel.error(
            "The server isn't responding! Please try again later.");
        // return response!;
      } else if (e.response!.statusCode == 408) {
        return StateModel.error(
            "Hello there! It seems like your request took longer than expected to process. We apologize for the inconvenience. Please try again later or reach out to our support team for assistance. Thank you for your patience!");
        // Something happened in setting up or sending the request that triggered an Error
      } else if (e.type.name == "connectionError") {
        return StateModel.error(
            "Connection refused This indicates an error which most likely cannot be solved by the library.Please try again later or reach out to our support team for assistance. Thank you for your patience!");
        // Something happened in setting up or sending the request that triggered an Error
      }

    }
    return null;
  }


}