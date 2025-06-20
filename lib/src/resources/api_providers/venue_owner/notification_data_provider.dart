import 'dart:convert';

import 'package:dicetable/src/model/state_model.dart';
import 'package:dicetable/src/ui/cafe_owner/notification/notification_item.dart';
import 'package:dicetable/src/utils/data/object_factory.dart';
import 'package:dio/dio.dart';

class NotificationDataProvider {

  /// Cafe notification data by id
  Future<StateModel?> getCafeNotificationDataById() async {
    try {
      final response =
      await ObjectFactory().apiClient.getCafeNotificationDataById();

      if (response.statusCode == 200) {
        return StateModel<NotificationItems>.success(
            NotificationItems.fromJson(response.data));
      }
      return null;
    } on DioException catch (e) {

      if (e.response?.statusCode == 500) {
        return StateModel.error(
            "The server isn't responding! Please try again later.");
        // return response!;
      } else if (e.response?.statusCode == 408) {
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

  /// Customer notification data by id
  Future<StateModel?> getCustomerNotificationDataById() async {
    try {
      final response =
      await ObjectFactory().apiClient.getCustomerNotificationDataById();

      if (response.statusCode == 200) {
        return StateModel<NotificationItems>.success(
            NotificationItems.fromJson(response.data));
      }
      return null;
    } on DioException catch (e) {

      if (e.response?.statusCode == 500) {
        return StateModel.error(
            "The server isn't responding! Please try again later.");
        // return response!;
      } else if (e.response?.statusCode == 408) {
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

  /// Mark notification as read
  Future<StateModel<dynamic>> markNotificationAsRead(NotificationReadRequest request) async {
    print("markNotificationAsRead called with: $request");
    try {
      final response = await ObjectFactory().apiClient.markNotificationAsRead(request);

      final String jsonRequest = jsonEncode(request);
      print("Request Payload:");
      print(jsonRequest);
      print("Response status code: ${response.statusCode}");
      print("Response data: ${response.data}");

      if (response.data != null) {
        if (response.statusCode == 200) {
          final readResponse = NotificationReadResponse.fromJson(response.data);
          return StateModel.success(readResponse);
        } else {
          final errorResponse = NotificationReadResponse.fromJson(response.data);

          if (errorResponse.message?.isNotEmpty ?? false) {
            return StateModel.error(errorResponse.message);
          } else {
            return StateModel.error("Error: ${response.statusCode}");
          }
        }
      } else {
        return StateModel.error("Invalid response from server");
      }
    } on DioException catch (e) {
      if (e.response != null) {
        try {
          final errorResponse = NotificationReadResponse.fromJson(e.response!.data);

          if (errorResponse.message?.isNotEmpty ?? false) {
            return StateModel.error(errorResponse.message);
          }
        } catch (_) {
          // Silent error while parsing error response
        }

        if (e.response!.statusCode == 500) {
          return StateModel.error("The server isn't responding! Please try again later.");
        } else if (e.response!.statusCode == 408) {
          return StateModel.error("Request timed out. Please try again later.");
        } else if (e.response!.statusCode == 401) {
          return StateModel.error("Unauthorized access.");
        } else if (e.response!.statusCode == 422) {
          return StateModel.error("Validation failed. Please check your input.");
        } else {
          return StateModel.error("Error: ${e.response!.statusCode}");
        }
      } else if (e.type.name == "connectionError") {
        return StateModel.error("Connection error. Please check your internet connection.");
      }

      return StateModel.error("An unexpected error occurred: ${e.message ?? e.toString()}");
    } catch (e) {
      return StateModel.error("An unexpected error occurred: ${e.toString()}");
    }
  }


}