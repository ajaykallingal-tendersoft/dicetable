import 'package:dicetable/src/model/cafe_owner/profile/profile_edit_view_response.dart';
import 'package:dicetable/src/model/cafe_owner/profile/profile_update_request.dart';
import 'package:dicetable/src/model/cafe_owner/profile/profile_update_response.dart';
import 'package:dicetable/src/model/cafe_owner/profile/profile_view_response.dart';
import 'package:dicetable/src/model/delete_profile_response.dart';
import 'package:dicetable/src/model/state_model.dart';
import 'package:dicetable/src/utils/data/object_factory.dart';
import 'package:dio/dio.dart';
import 'dart:convert';


class ProfileDataProvider {

///Profile view
  Future<StateModel?> getCafeProfileById() async {
    try {
      final response =
      await ObjectFactory().apiClient.getCafeProfileById();
      print(response.toString());
      if (response.statusCode == 200) {
        return StateModel<ProfileViewResponse>.success(
            ProfileViewResponse.fromJson(response.data));
      }
      return null;
    } on DioException catch (e) {

      if (e.response!.statusCode == 500) {
        return StateModel.error(
            "The server isn't responding! Please try again later.");
      } else if (e.response!.statusCode == 408) {
        return StateModel.error(
            "Hello there! It seems like your request took longer than expected to process. We apologize for the inconvenience. Please try again later or reach out to our support team for assistance. Thank you for your patience!");
      }else if (e.response!.statusCode == 401) {
        return StateModel.error(
            "UnAuthorized error");
      } else if (e.type.name == "connectionError") {
        return StateModel.error(
            "Connection refused This indicates an error which most likely cannot be solved by the library.Please try again later or reach out to our support team for assistance. Thank you for your patience!");
      }else if(e.response == null) {
        return StateModel.error(
            "The server isn't responding! Please try again later.");
      }

    }
    return null;
  }

///Profile edit view
  Future<StateModel?> getCafeEditProfileById() async {
    try {
      final response =
      await ObjectFactory().apiClient.getCafeEditProfileById();
      print(response.toString());
      if (response.statusCode == 200) {
        return StateModel<ProfileEditViewResponse>.success(
            ProfileEditViewResponse.fromJson(response.data));
      }
      return null;
    } on DioException catch (e) {

      if (e.response!.statusCode == 500) {
        return StateModel.error(
            "The server isn't responding! Please try again later.");
      } else if (e.response!.statusCode == 408) {
        return StateModel.error(
            "Hello there! It seems like your request took longer than expected to process. We apologize for the inconvenience. Please try again later or reach out to our support team for assistance. Thank you for your patience!");
      } else if (e.response!.statusCode == 401) {
        return StateModel.error(
            "UnAuthorized error");
      } else if (e.type.name == "connectionError") {
        return StateModel.error(
            "Connection refused This indicates an error which most likely cannot be solved by the library.Please try again later or reach out to our support team for assistance. Thank you for your patience!");
      }else if(e.response == null) {
        return StateModel.error(
            "The server isn't responding! Please try again later.");
      }

    }
    return null;
  }

  ///ProfileUpdate
  Future<StateModel<dynamic>> profileUpdateById(ProfileUpdateRequest request) async {
    print("loginUser called with: $request");
    try {
      final response = await ObjectFactory().apiClient.profileUpdateById(request);
      String jsonRequest = jsonEncode(request);
      // print("Request Payload:");
      // print(jsonRequest);
      // print("Response status code: ${response.statusCode}");
      print("Response data: ${response.data}");
      if (response.data != null) {

        if (response.statusCode == 200) {
          print(response);
          final updateProfileResponse = ProfileUpdateResponse.fromJson(response.data);
          return StateModel.success(updateProfileResponse);
        }

        else {

          final errorResponse = ProfileUpdateResponse.fromJson(response.data);

          if (response.statusCode == 422 && errorResponse.errors != null) {
            String errorMessage = "Validation failed: ";
            errorResponse.errors!.forEach((key, value) {
              if (value is List) {
                errorMessage += value.join(", ");
              } else if (value is String) {
                errorMessage += value.first;
              }
            });
            return StateModel.error(errorMessage);
          }

          else if (errorResponse.errors != null) {
            return StateModel.error(errorResponse.errors!);
          } else if (errorResponse.message != null) {
            return StateModel.error(errorResponse.message!);
          } else {
            return StateModel.error("Error: ${response.statusCode}");
          }
        }
      } else {
        return StateModel.error("Invalid response from server");
      }
    } on DioException catch (e) {
      if (e.response != null) {
        // Try to parse the error response
        try {
          final errorResponse = ProfileUpdateResponse.fromJson(e.response!.data);

          if (errorResponse.errors != null) {
            return StateModel.error(errorResponse.errors!);
          } else if (errorResponse.message != null) {
            return StateModel.error(errorResponse.message!);
          }
        } catch (_) {

        }

        // Status code based error handling
        if (e.response!.statusCode == 500) {
          return StateModel.error("The server isn't responding! Please try again later.");
        } else if (e.response!.statusCode == 408) {
          return StateModel.error("Request timed out. Please try again later.");
        } else if (e.response!.statusCode == 401) {
          return StateModel.error("UnAuthorized error");
        } else if (e.response!.statusCode == 403) {
          return StateModel.error("Email not verified");
        } else if (e.response!.statusCode == 422) {
          return StateModel.error("Validation failed. Please check your inputs.");
        } else {
          return StateModel.error("Error: ${e.response!.statusCode}");
        }
      } else if (e.type.name == "connectionError") {
        return StateModel.error("Connection refused. Please check your internet connection.");
      }

      // Generic error fallback
      return StateModel.error("An unexpected error occurred: ${e.message ?? e.toString()}");
    } catch (e) {
      return StateModel.error("An unexpected error occurred: ${e.toString()}");
    }
  }


  Future<StateModel?> cafeProfileDelete() async {
    try {
      final response =
      await ObjectFactory().apiClient.cafeProfileDelete();
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
      } else if (e.response!.statusCode == 408) {
        return StateModel.error(
            "Hello there! It seems like your request took longer than expected to process. We apologize for the inconvenience. Please try again later or reach out to our support team for assistance. Thank you for your patience!");
      } else if (e.response!.statusCode == 401) {
        return StateModel.error(
            "UnAuthorized error");
      } else if (e.type.name == "connectionError") {
        return StateModel.error(
            "Connection refused This indicates an error which most likely cannot be solved by the library.Please try again later or reach out to our support team for assistance. Thank you for your patience!");
      }else if(e.response == null) {
        return StateModel.error(
            "The server isn't responding! Please try again later.");
      }

    }
    return null;
  }

}