import 'dart:convert';

import 'package:dicetable/src/model/cafe_owner/auth/forgot_password/forgot_password_request.dart';
import 'package:dicetable/src/model/cafe_owner/auth/forgot_password/forgot_password_request_response.dart';
import 'package:dicetable/src/model/cafe_owner/auth/forgot_password/password_reset_request.dart';
import 'package:dicetable/src/model/cafe_owner/auth/forgot_password/password_reset_request_response.dart';
import 'package:dicetable/src/model/cafe_owner/auth/login/login_request.dart';
import 'package:dicetable/src/model/cafe_owner/auth/login/login_request_response.dart';
import 'package:dicetable/src/model/cafe_owner/auth/signUp/sign_up_request.dart';
import 'package:dicetable/src/model/cafe_owner/auth/signUp/sign_up_request_response.dart';
import 'package:dicetable/src/model/state_model.dart';
import 'package:dicetable/src/utils/data/object_factory.dart';
import 'package:dio/dio.dart';

class AuthDataProvider {
  ///Register
  Future<StateModel?> registerUser(SignUpRequest signUpRequest) async {
    try {
      final response =
      await ObjectFactory().apiClient.registerUser(signUpRequest);
      print(response.toString());
      if (response.statusCode == 200) {
        return StateModel<SignUpRequestResponse>.success(
            SignUpRequestResponse.fromJson(response.data));
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

  ///Login
///
  Future<StateModel<dynamic>> loginUser(LoginRequest loginRequest) async {
    print("loginUser called with: $loginRequest");
    try {
      final response = await ObjectFactory().apiClient.loginUser(loginRequest);
      print("Response status code: ${response.statusCode}");
      print("Response data: ${response.data}");
      if (response.data != null) {

        if (response.statusCode == 200) {
          print(response);
          final loginResponse = LoginRequestResponse.fromJson(response.data);
          return StateModel.success(loginResponse);
        }

        else {

          final errorResponse = LoginRequestResponse.fromJson(response.data);

          if (response.statusCode == 422 && errorResponse.errors != null) {
            String errorMessage = "Validation failed: ";
            errorResponse.errors!.forEach((key, value) {
              if (value is List) {
                errorMessage += value.join(", ");
              } else if (value is String) {
                errorMessage += value;
              }
            });
            return StateModel.error(errorMessage);
          }

          else if (errorResponse.error != null) {
            return StateModel.error(errorResponse.error!);
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
          final errorResponse = LoginRequestResponse.fromJson(e.response!.data);

          if (errorResponse.error != null) {
            return StateModel.error(errorResponse.error!);
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
          return StateModel.error("Invalid credentials provided");
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

  ///ForgotPassword
  Future<StateModel?> forgotPassword(ForgotPasswordRequest forgotPasswordRequest) async {
    try {
      final response = await ObjectFactory().apiClient.forgotPassword(forgotPasswordRequest);
      print(response.toString());

      final responseData = response.data is Map<String, dynamic>
          ? response.data
          : json.decode(response.data.toString());

      final parsedResponse = ForgotPasswordRequestResponse.fromJson(responseData);

      if (response.statusCode == 200) {
        return StateModel<ForgotPasswordRequestResponse>.success(parsedResponse);
      } else {
        String errorMessage = parsedResponse.message ?? "Unexpected error occurred (${response.statusCode})";
        return StateModel.error(errorMessage);
      }
    } on DioException catch (e) {
      final statusCode = e.response?.statusCode;
      final responseData = e.response?.data;

      String fallbackMessage = "Something went wrong";

      if (responseData != null && responseData is Map<String, dynamic>) {
        final parsedError = ForgotPasswordRequestResponse.fromJson(responseData);
        fallbackMessage = parsedError.message ?? fallbackMessage;
      }

      if (statusCode == 500) {
        return StateModel.error("Server error. Please try again later.");
      } else if (statusCode == 408) {
        return StateModel.error("Request timed out. Please try again later.");
      } else if (e.type == DioExceptionType.connectionError) {
        return StateModel.error("Connection error. Please check your internet.");
      }

      return StateModel.error(fallbackMessage);
    } catch (e) {
      return StateModel.error("Unexpected error: ${e.toString()}");
    }
  }

  ///PasswordReset
  Future<StateModel?> passwordReset(PasswordResetRequest passwordReset) async {
    try {
      final response = await ObjectFactory().apiClient.passwordReset(passwordReset);
      print(response.toString());

      final responseData = response.data is Map<String, dynamic>
          ? response.data
          : json.decode(response.data.toString());

      final parsedResponse = PasswordResetRequestResponse.fromJson(responseData);

      if (response.statusCode == 200) {
        return StateModel<PasswordResetRequestResponse>.success(parsedResponse);
      } else {
        String errorMessage = parsedResponse.message ?? "Unexpected error occurred (${response.statusCode})";
        return StateModel.error(errorMessage);
      }
    } on DioException catch (e) {
      final statusCode = e.response?.statusCode;
      final responseData = e.response?.data;

      String fallbackMessage = "Something went wrong";

      if (responseData != null && responseData is Map<String, dynamic>) {
        final parsedError = PasswordResetRequestResponse.fromJson(responseData);
        fallbackMessage = parsedError.message ?? fallbackMessage;
      }

      if (statusCode == 500) {
        return StateModel.error("Server error. Please try again later.");
      } else if (statusCode == 408) {
        return StateModel.error("Request timed out. Please try again later.");
      } else if (e.type == DioExceptionType.connectionError) {
        return StateModel.error("Connection error. Please check your internet.");
      }

      return StateModel.error(fallbackMessage);
    } catch (e) {
      return StateModel.error("Unexpected error: ${e.toString()}");
    }
  }
















}