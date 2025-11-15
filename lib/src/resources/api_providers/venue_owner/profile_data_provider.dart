import 'package:soloseaters/src/model/cafe_owner/profile/delete_gallery_image_response.dart';
import 'package:soloseaters/src/model/cafe_owner/profile/delete_image_request.dart';
import 'package:soloseaters/src/model/cafe_owner/profile/multiple_image_upload_response.dart';
import 'package:soloseaters/src/model/cafe_owner/profile/profile_edit_view_response.dart';
import 'package:soloseaters/src/model/cafe_owner/profile/profile_image_upload_request.dart';
import 'package:soloseaters/src/model/cafe_owner/profile/profile_image_upload_response.dart';
import 'package:soloseaters/src/model/cafe_owner/profile/profile_multiple_image_upload_request.dart';
import 'package:soloseaters/src/model/cafe_owner/profile/profile_update_request.dart';
import 'package:soloseaters/src/model/cafe_owner/profile/profile_update_response.dart';
import 'package:soloseaters/src/model/cafe_owner/profile/profile_view_response.dart';
import 'package:soloseaters/src/model/country_response.dart';
import 'package:soloseaters/src/model/delete_profile_response.dart';
import 'package:soloseaters/src/model/state_model.dart';
import 'package:soloseaters/src/utils/data/object_factory.dart';
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
      // ignore: unused_local_variable
      // String jsonR = jsonEncode(request);
      // print("Request Payload:");
      // print(jsonR);
      // print("Response status code: ${response.statusCode}");
      // print("Response data: ${response.data}");
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


/// CafeGalleryUpload
Future<StateModel<dynamic>> uploadCafeGalleryImages(CafeGalleryUploadRequest request) async {
  print("uploadCafeGalleryImages called with: ${request.gallery.length} files");

  // Check file sizes before upload
  int totalSize = 0;
  for (var file in request.gallery) {
    try {
      final fileSize = file.lengthSync(); // Use sync method for file size check
      totalSize += fileSize;
      print("File: ${file.path.split('/').last}, Size: ${(fileSize / 1024 / 1024).toStringAsFixed(2)} MB");
      
      // Check individual file size (e.g., max 10MB per file)
      if (fileSize > 10 * 1024 * 1024) {
        return StateModel.error("File ${file.path.split('/').last} is too large (${(fileSize / 1024 / 1024).toStringAsFixed(2)} MB). Maximum size is 10MB per file.");
      }
    } catch (e) {
      print("Error checking file size for ${file.path}: $e");
      // Continue with upload if size check fails - let server handle it
    }
  }
  
  print("Total upload size: ${(totalSize / 1024 / 1024).toStringAsFixed(2)} MB");
  
  // Check total size (e.g., max 50MB total)
  if (totalSize > 50 * 1024 * 1024) {
    return StateModel.error("Total file size is too large (${(totalSize / 1024 / 1024).toStringAsFixed(2)} MB). Maximum total size is 50MB. Please select fewer or smaller images.");
  }

  try {
    print("Creating FormData...");
    final formData = await request.toFormData();
    print("FormData created, sending request...");

    final response = await ObjectFactory().apiClient.uploadCafeGallery(formData);
    
    print("Response received - Status: ${response.statusCode}");
    print("Response data: ${response.data}");
    print("Response data type: ${response.data.runtimeType}");

    if (response.data != null) {
      if (response.statusCode == 200) {
        try {
          // Handle both Map and dynamic response types
          Map<String, dynamic> responseData;
          if (response.data is Map) {
            responseData = response.data as Map<String, dynamic>;
          } else if (response.data is String) {
            print("Response is string, attempting to parse...");
            return StateModel.error("Unexpected response format: ${response.data}");
          } else {
            responseData = Map<String, dynamic>.from(response.data);
          }
          
          print("Parsing response data: $responseData");
          final successResponse = CafeGalleryUploadResponse.fromJson(responseData);
          print("Success response parsed: ${successResponse.message}");
          return StateModel.success(successResponse);
        } catch (e, stackTrace) {
          print("Error parsing success response: $e");
          print("Stack trace: $stackTrace");
          print("Response data that failed to parse: ${response.data}");
          return StateModel.error("Failed to parse response: ${e.toString()}");
        }
      } else {
        // Handle non-200 responses
        try {
          Map<String, dynamic> responseData;
          if (response.data is Map) {
            responseData = response.data as Map<String, dynamic>;
          } else {
            responseData = Map<String, dynamic>.from(response.data);
          }
          
          final errorResponse = CafeGalleryUploadResponse.fromJson(responseData);

          // 422 Validation Error Handling (uses 'errors' map)
          if (response.statusCode == 422 && errorResponse.errors != null) {
            String errorMessage = "Validation failed: ";
            errorResponse.errors!.forEach((key, value) {
              // Logic to flatten the validation errors
              if (value is List) {
                errorMessage += value.join(", ");
              } else if (value is String) {
                errorMessage += value; // Simplified, assuming value is the error message
              }
            });
            return StateModel.error(errorMessage);
          }
          // Other errors (e.g., 401, 403, using 'message')
          else if (errorResponse.message != null) {
            return StateModel.error(errorResponse.message!);
          } else {
            return StateModel.error("Error: ${response.statusCode}");
          }
        } catch (e) {
          print("Error parsing error response: $e");
          return StateModel.error("Error ${response.statusCode}: Failed to parse response");
        }
      }
    } else {
      print("Response data is null!");
      return StateModel.error("Invalid response from server (No data)");
    }
  } on DioException catch (e) {
    print("DioException caught in uploadCafeGalleryImages: ${e.type}");
    print("Error message: ${e.message}");
    print("Response: ${e.response?.data}");
    print("Status code: ${e.response?.statusCode}");
    print("Error type: ${e.type.name}");
    
    // Standard Dio error handling (connection, timeouts, etc.)
    final errorMessage = _getDioErrorMessage(e);
    print("Returning error: $errorMessage");
    return StateModel.error(errorMessage);
  } catch (e, stackTrace) {
    print("Unexpected error in uploadCafeGalleryImages: $e");
    print("Stack trace: $stackTrace");
    return StateModel.error("An unexpected error occurred: ${e.toString()}");
  }
}

// 💡 You should have a separate function like this to handle common Dio errors:
String _getDioErrorMessage(DioException e) {
  if (e.response != null) {
    if (e.response!.statusCode == 500) {
      return "The server isn't responding! Please try again later.";
    } else if (e.response!.statusCode == 401) {
      // You can try to parse the 401 response body here too if needed
      return "UnAuthorized error";
    } else if (e.response!.statusCode == 408) {
      return "Request timed out. Please try again later.";
    }
    // ... add other specific status code checks ...
    return "Error: ${e.response!.statusCode}";
  } else if (e.type == DioExceptionType.connectionError || 
             e.type == DioExceptionType.connectionTimeout ||
             e.type.name == "connectionError") {
    // Handle connection errors more specifically
    if (e.message?.contains("Connection reset by peer") ?? false) {
      return "Connection was reset by server. The files might be too large or the upload took too long. Please try uploading fewer files or smaller images.";
    } else if (e.message?.contains("timeout") ?? false) {
      return "Upload timed out. Please try again with fewer or smaller files.";
    } else {
      return "Connection error. Please check your internet connection and try again.";
    }
  } else if (e.type == DioExceptionType.sendTimeout) {
    return "Upload timed out. The files might be too large. Please try with smaller images.";
  } else if (e.type == DioExceptionType.receiveTimeout) {
    return "Server response timed out. Please try again.";
  } else {
    return "An unexpected error occurred: ${e.message ?? e.toString()}";
  }
}

// Ensure this function is part of your APIDataProvider class

/// CafePhotoUpload
Future<StateModel<dynamic>> uploadCafePhoto(CafePhotoUploadRequest request) async {
  print("uploadCafePhoto called with file: ${request.image.path}");

  try {
    // 1. Convert the request model to Dio's FormData
    final formData = await request.toFormData();
    print("FormData created, sending request...");

    // 2. Call the API client (assuming ObjectFactory().apiClient.uploadCafePhoto exists)
    final response = await ObjectFactory().apiClient.uploadCafePhoto(formData);
    
    print("Response received - Status: ${response.statusCode}");
    print("Response data: ${response.data}");
    print("Response data type: ${response.data.runtimeType}");

    if (response.data != null) {
      if (response.statusCode == 200) {
        try {
          // Handle both Map and dynamic response types
          Map<String, dynamic> responseData;
          if (response.data is Map) {
            responseData = response.data as Map<String, dynamic>;
          } else if (response.data is String) {
            // If response is a string, try to parse it
            print("Response is string, attempting to parse...");
            return StateModel.error("Unexpected response format: ${response.data}");
          } else {
            responseData = Map<String, dynamic>.from(response.data);
          }
          
          print("Parsing response data: $responseData");
          final successResponse = CafePhotoUploadResponse.fromJson(responseData);
          print("Success response parsed: ${successResponse.message}");
          return StateModel.success(successResponse);
        } catch (e, stackTrace) {
          print("Error parsing success response: $e");
          print("Stack trace: $stackTrace");
          print("Response data that failed to parse: ${response.data}");
          return StateModel.error("Failed to parse response: ${e.toString()}");
        }
      } else {
        // Handle non-200 responses
        try {
          Map<String, dynamic> responseData;
          if (response.data is Map) {
            responseData = response.data as Map<String, dynamic>;
          } else {
            responseData = Map<String, dynamic>.from(response.data);
          }
          
          final errorResponse = CafePhotoUploadResponse.fromJson(responseData);

          // 422 Validation Error Handling (uses 'errors' map)
          if (response.statusCode == 422 && errorResponse.errors != null) {
            String errorMessage = "Validation failed: ";
            // Iterate through the errors map (e.g., {"image": ["The image must be small."]})
            errorResponse.errors!.forEach((key, value) {
              if (value is List) {
                errorMessage += value.join(", ");
              } else if (value is String) {
                errorMessage += value;
              }
            });
            return StateModel.error(errorMessage);
          }
          // Other errors (e.g., 401 using 'message')
          else if (errorResponse.message != null) {
            return StateModel.error(errorResponse.message!);
          } else {
            return StateModel.error("Error: ${response.statusCode}");
          }
        } catch (e) {
          print("Error parsing error response: $e");
          return StateModel.error("Error ${response.statusCode}: Failed to parse response");
        }
      }
    } else {
      print("Response data is null!");
      return StateModel.error("Invalid response from server (No data)");
    }
  } on DioException catch (e) {
    print("DioException caught: ${e.type}");
    print("Error message: ${e.message}");
    print("Response: ${e.response?.data}");
    print("Status code: ${e.response?.statusCode}");
    
    // Rely on your existing _getDioErrorMessage function for status code checks
    final errorMessage = _getDioErrorMessage(e);
    print("Returning error: $errorMessage");
    return StateModel.error(errorMessage);
  } catch (e, stackTrace) {
    print("Unexpected error in uploadCafePhoto: $e");
    print("Stack trace: $stackTrace");
    return StateModel.error("An unexpected error occurred: ${e.toString()}");
  }
}


/// Delete Gallery Photo
Future<StateModel<dynamic>> deleteGalleryPhoto(DeleteGalleryImageRequest photoId) async {
  print("deleteGalleryPhoto called with photoId: $photoId");

  try {
    final response = await ObjectFactory().apiClient.deleteGalleryPhoto(photoId);

    if (response.data != null) {
      if (response.statusCode == 200) {
        final successResponse = CafeGalleryDeleteResponse.fromJson(response.data);
        return StateModel.success(successResponse);
      } else {
        // Handle non-200 responses
        final errorResponse = CafeGalleryDeleteResponse.fromJson(response.data);

        // 422 Validation Error Handling
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
        // Other errors (e.g., 401, 403, 404)
        else if (errorResponse.message != null) {
          return StateModel.error(errorResponse.message!);
        } else {
          return StateModel.error("Error: ${response.statusCode}");
        }
      }
    } else {
      return StateModel.error("Invalid response from server (No data)");
    }
  } on DioException catch (e) {
    final errorMessage = _getDioErrorMessage(e);
    return StateModel.error(errorMessage);
  } catch (e) {
    return StateModel.error("An unexpected error occurred: ${e.toString()}");
  }
}

  Future<StateModel?> getCountryList() async {
    try {
      final response = await ObjectFactory().apiClient.getCountryList();
      if (response.statusCode == 200) {

        print("---> response.data: ${response.data}");

        return StateModel<CountryResponse>.success(
          CountryResponse.fromJson(response.data),
        );
      }
      return null;
    } on DioException catch (e) {
      if (e.response!.statusCode == 500) {
        return StateModel.error(
          "The server isn't responding! Please try again later.",
        );
      } else if (e.response!.statusCode == 408) {
        return StateModel.error(
          "Hello there! It seems like your request took longer than expected to process. We apologize for the inconvenience. Please try again later or reach out to our support team for assistance. Thank you for your patience!",
        );
      } else if (e.type.name == "connectionError") {
        return StateModel.error(
          "Connection refused This indicates an error which most likely cannot be solved by the library.Please try again later or reach out to our support team for assistance. Thank you for your patience!",
        );
      }
    }
    return null;
  }


}