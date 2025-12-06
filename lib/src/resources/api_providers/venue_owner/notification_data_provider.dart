import 'package:soloseaters/src/model/state_model.dart';
import 'package:soloseaters/src/ui/cafe_owner/notification/notification_item.dart';
import 'package:soloseaters/src/utils/data/object_factory.dart';
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
      final statusCode = e.response?.statusCode;
      if (statusCode == 500) {
        return StateModel.error(
            "The server isn't responding! Please try again later.");
      } else if (statusCode == 408) {
        return StateModel.error(
            "Hello there! It seems like your request took longer than expected to process. Please try again later.");
      } else if (statusCode == 401) {
        return StateModel.error("UnAuthorized error");
      } else if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        return StateModel.error(
            "The request timed out. Please check your connection and try again.");
      } else if (e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.unknown) {
        return StateModel.error(
            "Connection error. Please check your internet connection and try again.");
      }
    }
    return StateModel.error(
        "Unexpected error occurred. Please try again later.");
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
      final statusCode = e.response?.statusCode;
      if (statusCode == 500) {
        return StateModel.error(
            "The server isn't responding! Please try again later.");
      } else if (statusCode == 408) {
        return StateModel.error(
            "Hello there! It seems like your request took longer than expected to process. Please try again later.");
      } else if (statusCode == 401) {
        return StateModel.error("UnAuthorized error");
      } else if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        return StateModel.error(
            "The request timed out. Please check your connection and try again.");
      } else if (e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.unknown) {
        return StateModel.error(
            "Connection error. Please check your internet connection and try again.");
      }
    }
    return StateModel.error(
        "Unexpected error occurred. Please try again later.");
  }

  /// Mark notification as read
  Future<StateModel<dynamic>> markNotificationAsRead(NotificationReadRequest request) async {
    try {
      final response = await ObjectFactory().apiClient.markNotificationAsRead(request);

      if (response.data != null) {
        if (response.statusCode == 200) {
          final readResponse = NotificationReadResponse.fromJson(response.data);
          return StateModel.success(readResponse);
        } else {
          final errorResponse = NotificationReadResponse.fromJson(response.data);

          if (errorResponse.message?.isNotEmpty ?? false) {
            return StateModel.error(errorResponse.message?? "Error");
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
            return StateModel.error(errorResponse.message ?? "Error");
          }
        } catch (_) {
          // Silent error while parsing error response
        }

        if (e.response!.statusCode == 500) {
          return StateModel.error("The server isn't responding! Please try again later.");
        } else if (e.response!.statusCode == 408) {
          return StateModel.error("Request timed out. Please try again later.");
        } else if (e.response!.statusCode == 401) {
          return StateModel.error(
              "UnAuthorized error");
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

  /// Update notification status
  Future<StateModel<dynamic>> updateNotificationStatus(NotificationStatusRequest request) async {
    print("updateNotificationStatus called with: $request");

    try {
      final response = await ObjectFactory().apiClient.notificationStatus(request);

      // final String jsonRequest = jsonEncode(request.toJson());
      // print("Request Payload:");
      // print(jsonRequest);
      // print("Response status code: ${response.statusCode}");
      // print("Response data: ${response.data}");

      if (response.data != null) {
        if (response.statusCode == 200) {
          final statusResponse = NotificationStatusResponse.fromJson(response.data);
          return StateModel.success(statusResponse);
        } else {
          final errorResponse = NotificationStatusResponse.fromJson(response.data);

          if (errorResponse.message?.isNotEmpty ?? false) {
            return StateModel.error(errorResponse.message ?? "Error");
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
          final errorResponse = NotificationStatusResponse.fromJson(e.response!.data);

          if (errorResponse.message?.isNotEmpty ?? false) {
            return StateModel.error(errorResponse.message ?? "Error");
          }
        } catch (_) {
          // Silent parse error
        }

        if (e.response!.statusCode == 500) {
          return StateModel.error("The server isn't responding! Please try again later.");
        } else if (e.response!.statusCode == 408) {
          return StateModel.error("Request timed out. Please try again later.");
        } else if (e.response!.statusCode == 401) {
          return StateModel.error(
              "UnAuthorized error");
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