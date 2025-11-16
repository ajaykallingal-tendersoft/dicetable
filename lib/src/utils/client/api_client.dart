import 'dart:io';

import 'package:flutter/material.dart';
import 'package:soloseaters/src/model/cafe_owner/auth/forgot_password/forgot_password_request.dart';
import 'package:soloseaters/src/model/cafe_owner/auth/forgot_password/password_reset_request.dart';
import 'package:soloseaters/src/model/cafe_owner/auth/forgot_password/resend_otp_request.dart';
import 'package:soloseaters/src/model/cafe_owner/auth/login/google_login_request.dart';
import 'package:soloseaters/src/model/cafe_owner/auth/login/login_request.dart';
import 'package:soloseaters/src/model/cafe_owner/auth/signUp/apple_sign-up_request.dart';
import 'package:soloseaters/src/model/cafe_owner/auth/signUp/google_sign-up_request.dart';
import 'package:soloseaters/src/model/cafe_owner/auth/signUp/sign_up_request.dart';
import 'package:soloseaters/src/model/cafe_owner/home/dice_table_update_request.dart';
import 'package:soloseaters/src/model/cafe_owner/profile/delete_image_request.dart';
import 'package:soloseaters/src/model/cafe_owner/profile/profile_update_request.dart';
import 'package:soloseaters/src/model/cafe_owner/subscription/subscription_start_request.dart';
import 'package:soloseaters/src/model/customer/booking/booking_request.dart';
import 'package:soloseaters/src/model/customer/booking/withdraw_booking_request.dart';
import 'package:soloseaters/src/model/customer/cafe/add_favourite_request.dart';
import 'package:soloseaters/src/model/customer/cafe/cafe_list_request.dart';
import 'package:soloseaters/src/model/customer/cafe/cafe_search_request.dart';
import 'package:soloseaters/src/model/customer/cafe/remove_favourite_request.dart';
import 'package:soloseaters/src/model/customer/guest/guest_user_request.dart';
import 'package:soloseaters/src/model/customer/profile/customer_paid_profile_request.dart';
import 'package:soloseaters/src/model/customer/profile/customer_profile_update_request.dart';
import 'package:soloseaters/src/model/verification/otp_verify_request.dart';
import 'package:soloseaters/src/ui/cafe_owner/notification/notification_item.dart';
import 'package:soloseaters/src/utils/data/object_factory.dart';
import 'package:soloseaters/src/utils/data/sign_out.dart';
import 'package:soloseaters/src/utils/urls/urls.dart';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';

import '../../model/cafe_owner/auth/login/apple_login_request.dart';

class ApiClient {
  ApiClient() {
    ///Dev
    initClientDiceAppDev();

    ///Live
    // initClientDiceAppLive();
  }

  Dio dioDiceApp = Dio();

  BaseOptions _baseOptionsDiceApp = BaseOptions();

  ///client dev
  initClientDiceAppDev() async {
    _baseOptionsDiceApp = BaseOptions(
      baseUrl: UrlsDiceApp.baseUrlDev,
      connectTimeout: const Duration(
        seconds: 30,
      ), // ⏱ 30s to establish connection
      sendTimeout: const Duration(minutes: 2), // ⬆️ enough for uploads
      receiveTimeout: const Duration(minutes: 5),
      followRedirects: true,
      headers: {
        HttpHeaders.contentTypeHeader: 'application/json',
        HttpHeaders.acceptHeader: 'application/json',
      },
      responseType: ResponseType.json,
      receiveDataWhenStatusError: true,
    );

    dioDiceApp = Dio(_baseOptionsDiceApp);
    dioDiceApp.httpClientAdapter = IOHttpClientAdapter(
      createHttpClient: () {
        // Don't trust any certificate just because their root cert is trusted.
        final HttpClient client = HttpClient(
          context: SecurityContext(withTrustedRoots: false),
        );
        // You can test the intermediate / root cert here. We just ignore it.
        client.badCertificateCallback =
            ((X509Certificate cert, String host, int port) => true);
        return client;
      },
    );

    dioDiceApp.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          print("======= API REQUEST BEGIN =======");
          print("URL → ${options.uri}");
          print("Method → ${options.method}");
          print("Headers → ${options.headers}");

          if (options.data is FormData) {
            final formData = options.data as FormData;

            print("----- FORM FIELDS -----");
            for (var field in formData.fields) {
              print("${field.key} = ${field.value}");
            }

            print("----- FORM FILES -----");
            for (var file in formData.files) {
              final fileData = file.value;
              print("${file.key} -> filename: ${fileData.filename}");
            }
          } else {
            print("Body → ${options.data}");
          }

          print("======= API REQUEST END =======");

          return handler.next(options);
        },

        onError: (dioError, handler) async {
          print("❌ API ERROR: ${dioError.message}");
          print("Response → ${dioError.response?.data}");
          if (dioError.response?.statusCode == 401) {
            final RequestOptions options = dioError.response!.requestOptions;

            // Prevent infinite loop if the tokenRefresh API call also fails with 401
            if (options.path != UrlsDiceApp.tokenRefresh) {
              print("Attempting to refresh token...");

              // Determine the current user type (Cafe Owner or Customer)
              // NOTE: If ObjectFactory().prefs.getUserDecisionName() returns null,
              // the app may be in an unlogged state, but we'll default to Cafe Owner logic here
              final userCategory = ObjectFactory().prefs.getUserDecisionName();
              final isPublicUser = userCategory == "PUBLIC_USER";

              try {
                // 2. Call the token refresh API (your existing function [cite: 17])
                final Response refreshResponse = await tokenRefresh();

                // 3. Extract and save the new token based on the user type
                // Assuming the new token is in refreshResponse.data['data']['authToken']
                final newAuthToken = refreshResponse.data['data']['authToken'];

                String updatedToken;

                if (isPublicUser) {
                  // Save Customer Token
                  ObjectFactory().prefs.setCustomerAuthToken(
                    token: newAuthToken,
                  );
                  updatedToken = ObjectFactory().prefs.getCustomerAuthToken()!;
                  print("Customer Token refreshed and updated.");
                } else {
                  // Save Cafe Owner Token
                  ObjectFactory().prefs.setAuthToken(token: newAuthToken);
                  updatedToken = ObjectFactory().prefs.getAuthToken()!;
                  print("Cafe Owner Token refreshed and updated.");
                }

                // 4. Update the Authorization header for the failed request
                // The structure for both owner and customer tokens is typically 'Bearer <token>'
                options.headers["Authorization"] = updatedToken;

                // 5. Retry the original request with the new token
                print("Retrying original request with new token...");
                return handler.resolve(await dioDiceApp.fetch(options));
              } catch (e) {
                // 6. If token refresh itself fails, log out the user
                print(
                  "Token refresh failed: $e. Logging out user/Session expired.",
                );
                SignOut().logoutFromInterceptor();
                // TODO: Implement a forced logout and navigate to the login/category screen
                // e.g., ObjectFactory().prefs.logoutUser();
                // e.g., NavigatorKey.currentState?.context.go('/category');
                return handler.next(
                  dioError,
                ); // Pass the original 401 error along
              }
            }
          }
          return handler.next(dioError);
        },

        onResponse: (res, handler) {
          print("✅ API RESPONSE: ${res.statusCode}");
          print("Body → ${res.data}");

          return handler.next(res);
        },
      ),
    );

    // dioDiceApp.interceptors.add(
    //   InterceptorsWrapper(
    //     onRequest: (reqOptions, handler) {
    //       return handler.next(reqOptions);
    //     },
    //     onError: (DioException dioError, handler) {
    //       return handler.next(dioError);
    //     },
    //   ),
    // );
  }

  Future<Response> tokenRefresh() {
    final userCategory = ObjectFactory().prefs.getUserDecisionName();
    final isPublicUser = userCategory == "PUBLIC_USER";
    final venueToken = ObjectFactory().prefs.getAuthToken();
    final publicToken = ObjectFactory().prefs.getCustomerAuthToken();
    return dioDiceApp.post(
      UrlsDiceApp.tokenRefresh,
      data: isPublicUser ? publicToken : venueToken,
    );
  }

  ///Cafe Owner
  /// Auth
  //Register
  Future<Response> registerUser(SignUpRequest signupRequest) {
    final formData = signupRequest.toFormData();
    return dioDiceApp.post(
      UrlsDiceApp.register,
      data: formData,
      options: Options(contentType: 'multipart/form-data'),
    );
  }

  // Future<Response> registerUser(SignUpRequest signupRequest) {
  //   return dioDiceApp.post(
  //     UrlsDiceApp.register,
  //     data: signupRequest,
  //   );
  // }
  //Login
  Future<Response> loginUser(LoginRequest loginRequest) {
    return dioDiceApp.post(UrlsDiceApp.login, data: loginRequest);
  }

  //ForgotPassword
  Future<Response> forgotPassword(ForgotPasswordRequest forgotPasswordRequest) {
    return dioDiceApp.post(
      UrlsDiceApp.forgotPassword,
      data: forgotPasswordRequest,
    );
  }

  //Resend Otp
  Future<Response> resendOtp(ResendOtpRequest resendOtpRequest) {
    return dioDiceApp.post(UrlsDiceApp.resendOtp, data: resendOtpRequest);
  }

  //PasswordReset
  Future<Response> passwordReset(PasswordResetRequest passwordResetRequest) {
    return dioDiceApp.post(
      UrlsDiceApp.passwordReset,
      data: passwordResetRequest,
    );
  }

  //Google login
  Future<Response> googleLogin(GoogleLoginRequest googleLoginRequest) {
    return dioDiceApp.post(UrlsDiceApp.googleLogin, data: googleLoginRequest);
  }

  //Google Register
  Future<Response> googleRegisterUser(GoogleSignUpRequest googleSignUpRequest) {
    final formData = googleSignUpRequest.toFormData();
    return dioDiceApp.post(
      UrlsDiceApp.googleSignUp,
      data: formData,
      options: Options(contentType: 'multipart/form-data'),
    );
  }

  //Apple Sign-In
  Future<Response> appleLogin(AppleLoginRequest appleLoginRequest) {
    return dioDiceApp.post(UrlsDiceApp.appleSignIn, data: appleLoginRequest);
  }

  // Register
  Future<Response> appleRegisterUser(AppleSignUpRequest appleSignUpRequest) {
    final formData = appleSignUpRequest.toFormData();
    return dioDiceApp.post(
      UrlsDiceApp.appleSignUp,
      data: formData,
      options: Options(contentType: 'multipart/form-data'),
    );
  }

  //Otp Verify
  Future<Response> verifyOTP(OtpVerifyRequest otpVerifyRequest) {
    return dioDiceApp.post(UrlsDiceApp.otpVerify, data: otpVerifyRequest);
  }

  //Get Venue type
  Future<Response> getVenueTypes() {
    return dioDiceApp.get(UrlsDiceApp.venueType);
  }

  //Get Country List
  Future<Response> getCountryList() {
    return dioDiceApp.get(UrlsDiceApp.countryList);
  }

  ///Subscription
  Future<Response> subscriptionStart(
    SubscriptionStartRequest subscriptionStartRequest,
  ) {
    return dioDiceApp.post(
      UrlsDiceApp.subscriptionStart,
      data: subscriptionStartRequest,
      options: Options(
        headers: {"Authorization": ObjectFactory().prefs.getAuthToken()},
      ),
    );
  }

  //Initial subscription plan
  Future<Response> getInitialSubscription() {
    print("Bearer ${ObjectFactory().prefs.getAuthToken()}");
    return dioDiceApp.get(
      UrlsDiceApp.subscriptionInitial,
      options: Options(
        headers: {"Authorization": ObjectFactory().prefs.getAuthToken()},
      ),
    );
  }

  //Subscription Overview
  Future<Response> getSubscriptionOverview() {
    final token = ObjectFactory().prefs.getAuthToken();
    final cafeID = ObjectFactory().prefs.getCafeId(); // Ensure this exists
    final url = '${UrlsDiceApp.subscriptionOverView}/$cafeID';

    print("Bearer $token");
    print("URL: $url");

    return dioDiceApp.get(
      url,
      options: Options(headers: {"Authorization": token}),
    );
  }

  ///Venue owner home
  Future<Response> getVenueOwnerHomeData() {
    return dioDiceApp.get(
      UrlsDiceApp.venueOwnerHome,
      options: Options(
        headers: {"Authorization": ObjectFactory().prefs.getAuthToken()},
      ),
    );
  }

  //Update DiceTable Type
  Future<Response> updateDiceTableType(
    DiceTableTypeUpdateRequest diceTableUpdateRequest,
  ) {
    return dioDiceApp.post(
      UrlsDiceApp.updateDiceTable,
      data: diceTableUpdateRequest,
      options: Options(
        headers: {"Authorization": ObjectFactory().prefs.getAuthToken()},
      ),
    );
  }

  Future<Response> getCafeProfileById() {
    final token = ObjectFactory().prefs.getAuthToken();
    final cafeID = ObjectFactory().prefs.getCafeId(); // Ensure this exists
    final url = '${UrlsDiceApp.getProfile}$cafeID';

    print("Bearer $token");
    print("URL: $url");

    return dioDiceApp.get(
      url,
      options: Options(headers: {"Authorization": token}),
    );
  }

  Future<Response> getCafeNotificationDataById() {
    final token = ObjectFactory().prefs.getAuthToken();
    final cafeID = ObjectFactory().prefs.getCafeId(); // Ensure this exists
    final url = '${UrlsDiceApp.getCafeNotification}/$cafeID';

    print("Bearer $token");
    print("URL: $url");

    return dioDiceApp.get(
      url,
      options: Options(headers: {"Authorization": token}),
    );
  }

  Future<Response> getCustomerNotificationDataById() {
    final token = ObjectFactory().prefs.getCustomerAuthToken();
    final userID = ObjectFactory().prefs.getUserId(); // Ensure this exists
    final url = '${UrlsDiceApp.getCustomerNotification}/$userID';

    print("Bearer $token");
    print("URL: $url");

    return dioDiceApp.get(
      url,
      options: Options(headers: {"Authorization": token}),
    );
  }

  Future<Response> markNotificationAsRead(NotificationReadRequest request) {
    final token =
        ObjectFactory().prefs.getUserDecisionName() == "PUBLIC_USER"
            ? ObjectFactory().prefs.getCustomerAuthToken()
            : ObjectFactory().prefs.getAuthToken();
    final url = UrlsDiceApp.markNotificationAsRead;

    print("Bearer $token");
    print("URL: $url");

    return dioDiceApp.post(
      url,
      data: request,
      options: Options(headers: {"Authorization": token}),
    );
  }

  Future<Response> notificationStatus(NotificationStatusRequest request) {
    final token =
        ObjectFactory().prefs.getUserDecisionName() == "PUBLIC_USER"
            ? ObjectFactory().prefs.getCustomerAuthToken()
            : ObjectFactory().prefs.getAuthToken();
    final url = UrlsDiceApp.updateNotificationStatus;

    print("Bearer $token");
    print("URL: $url");

    return dioDiceApp.post(
      url,
      data: request,
      options: Options(headers: {"Authorization": token}),
    );
  }

  Future<Response> getCafeEditProfileById() {
    final token = ObjectFactory().prefs.getAuthToken();
    final cafeID = ObjectFactory().prefs.getCafeId(); // Ensure this exists
    final url = '${UrlsDiceApp.getEditProfile}$cafeID';

    print("Bearer $token");
    print("URL: $url");

    return dioDiceApp.get(
      url,
      options: Options(headers: {"Authorization": token}),
    );
  }

  Future<Response> profileUpdateById(ProfileUpdateRequest request) async {
    final token = ObjectFactory().prefs.getAuthToken();
    final cafeID = ObjectFactory().prefs.getCafeId();
    final url = '${UrlsDiceApp.profileUpdate}$cafeID';

    final formData = request.toFormData();

    return dioDiceApp.post(
      url,
      data: formData,
      options: Options(
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
        contentType: 'multipart/form-data',
      ),
    );
  }

  // Future<Response> profileUpdateById(ProfileUpdateRequest request) {
  //   final token = ObjectFactory().prefs.getAuthToken();
  //   final cafeID = ObjectFactory().prefs.getCafeId(); // Ensure this exists
  //   final url = '${UrlsDiceApp.profileUpdate}$cafeID';

  //   print("Bearer $token");
  //   print("URL: $url");

  //   return dioDiceApp.post(
  //     url,
  //     data: request,
  //     options: Options(headers: {
  //       "Authorization": token,
  //     }),
  //   );
  // }
  //Delete Account
  Future<Response> cafeProfileDelete() {
    final token = ObjectFactory().prefs.getAuthToken();
    final cafeID = ObjectFactory().prefs.getCafeId(); // Ensure this exists
    final url = '${UrlsDiceApp.cafeProfileDelete}/$cafeID';

    print("Bearer $token");
    print("URL: $url");

    return dioDiceApp.post(
      url,
      options: Options(headers: {"Authorization": token}),
    );
  }

  // Part of ObjectFactory().apiClient

  Future<Response> uploadCafeGallery(FormData formData) {
    final token = ObjectFactory().prefs.getAuthToken();
    const url = '/api/upload-cafe-gallery'; // Based on the image URL
    print("uploadCafeGallery API call - URL: $url");
    print("Token exists: ${token != null && token.isNotEmpty}");

    // Calculate total size for logging
    try {
      int totalSize = 0;
      if (formData.files.isNotEmpty) {
        for (var fileEntry in formData.files) {
          final multipartFile = fileEntry.value;
          totalSize += multipartFile.length;
        }
        print(
          "Total upload size: ${(totalSize / 1024 / 1024).toStringAsFixed(2)} MB",
        );
      }
    } catch (e) {
      print("Error calculating upload size: $e");
    }

    return dioDiceApp
        .post(
          url,
          data: formData, // Data is now the FormData object
          options: Options(
            headers: {
              'Authorization': 'Bearer $token',
              'Accept': 'application/json',
            },
            contentType: 'multipart/form-data',
          ),
        )
        .then((response) {
          print("uploadCafeGallery API response received");
          print("Status: ${response.statusCode}");
          print("Data: ${response.data}");
          return response;
        })
        .catchError((error) {
          print("uploadCafeGallery API error: $error");
          throw error; // Re-throw the error so it can be caught by DioException handler
        });
  }

  Future<Response> uploadCafePhoto(FormData formData) {
    final token = ObjectFactory().prefs.getAuthToken();
    const url = '/api/upload-cafe-photo';
    print("uploadCafePhoto API call - URL: $url");
    print("Token exists: ${token != null && token.isNotEmpty}");

    return dioDiceApp
        .post(
          url,
          data: formData,
          options: Options(
            headers: {
              'Authorization': 'Bearer $token',
              'Accept': 'application/json',
            },
            contentType: 'multipart/form-data',
          ),
        )
        .then((response) {
          print("uploadCafePhoto API response received");
          print("Status: ${response.statusCode}");
          print("Data: ${response.data}");
          return response;
        })
        .catchError((error) {
          print("uploadCafePhoto API error: $error");
          throw error; // Re-throw the error so it can be caught by DioException handler
        });
  }

  Future<Response> deleteGalleryPhoto(
    DeleteGalleryImageRequest photoIdRequest,
  ) {
    final token = ObjectFactory().prefs.getAuthToken();
    final url = '/api/delete-gallery-image';

    print("Deleting gallery photo");
    print("Bearer $token");
    print("URL: $url");
    print("Photo ID: ${photoIdRequest.toQueryParams()}");

    return dioDiceApp.post(
      url,
      // data: photoId,
      queryParameters: photoIdRequest.toQueryParams(),
      options: Options(headers: {"Authorization": token}),
    );
  }

  ///Customer
  ///
  //Favourite
  Future<Response> getFavourite() {
    print("Bearer ${ObjectFactory().prefs.getCustomerAuthToken()}");
    return dioDiceApp.get(
      UrlsDiceApp.getFavourite,
      options: Options(
        headers: {
          "Authorization": ObjectFactory().prefs.getCustomerAuthToken(),
        },
      ),
    );
  }

  ///Booking
  Future<Response> booking(BookingRequest bookingRequest) {
    print(ObjectFactory().prefs.getCustomerAuthToken());
    return dioDiceApp.post(
      UrlsDiceApp.booking,
      data: bookingRequest,
      options: Options(
        headers: {
          "Authorization": ObjectFactory().prefs.getCustomerAuthToken(),
        },
      ),
    );
  }

  ///CafeList
  Future<Response> getCafeList(CafeListRequest request) {
    print("Bearer ${ObjectFactory().prefs.getCustomerAuthToken()}");
    final isGuest = ObjectFactory().prefs.isGuestUser();
    final headers =
        isGuest == true
            ? null
            : Options(
              headers: {
                "Authorization": ObjectFactory().prefs.getCustomerAuthToken(),
              },
            );
    return dioDiceApp.post(
      UrlsDiceApp.cafeList,
      data: request,
      options: headers,
    );
  }

  ///AddFavourite
  Future<Response> addFavourite(AddFavouriteRequest addFavouriteRequest) {
    print(ObjectFactory().prefs.getCustomerAuthToken());
    final isGuest = ObjectFactory().prefs.isGuestUser();
    final headers =
        isGuest == true
            ? null
            : Options(
              headers: {
                "Authorization": ObjectFactory().prefs.getCustomerAuthToken(),
              },
            );
    return dioDiceApp.post(
      UrlsDiceApp.addFavourite,
      data: addFavouriteRequest,
      options: headers,
    );
  }

  ///RemoveFavourite
  Future<Response> removeFavourite(
    RemoveFavouriteRequest removeFavouriteRequest,
  ) {
    print(ObjectFactory().prefs.getCustomerAuthToken());
    return dioDiceApp.post(
      UrlsDiceApp.removeFavourite,
      data: removeFavouriteRequest,
      options: Options(
        headers: {
          "Authorization": ObjectFactory().prefs.getCustomerAuthToken(),
        },
      ),
    );
  }

  ///History
  Future<Response> getHistory() {
    final token = ObjectFactory().prefs.getCustomerAuthToken();
    final userID = ObjectFactory().prefs.getUserId(); // Ensure this exists
    final url = '${UrlsDiceApp.history}/$userID';

    print("Bearer $token");
    print("URL: $url");

    return dioDiceApp.get(
      url,
      options: Options(headers: {"Authorization": token}),
    );
  }

  ///GetCustomerProfile
  Future<Response> getCustomerProfile() {
    final token = ObjectFactory().prefs.getCustomerAuthToken();
    final userID = ObjectFactory().prefs.getUserId();
    final url = '${UrlsDiceApp.getCustomerProfile}/$userID';

    print("Bearer $token");
    print("URL: $url");

    return dioDiceApp.get(
      url,
      options: Options(headers: {"Authorization": token}),
    );
  }

  ///UpdateCustomerProfile
  Future<Response> updateCustomerProfile(CustomerUpdateProfileRequest request) {
    final token = ObjectFactory().prefs.getCustomerAuthToken();
    final userID = ObjectFactory().prefs.getUserId();
    final url = '${UrlsDiceApp.updateCustomerProfile}/$userID';

    print("Bearer $token");
    print("URL: $url");
    return dioDiceApp.post(
      url,
      data: request,
      options: Options(headers: {"Authorization": token}),
    );
  }

  ///CafeSearch
  Future<Response> cafeSearch(CafeSearchRequest cafeSearchRequest) {
    print(ObjectFactory().prefs.getCustomerAuthToken());
    print(ObjectFactory().prefs.isGuestUser());

    final isGuest = ObjectFactory().prefs.isGuestUser();
    final headers =
        isGuest == true
            ? null
            : Options(
              headers: {
                "Authorization": ObjectFactory().prefs.getCustomerAuthToken(),
              },
            );

    return dioDiceApp.post(
      UrlsDiceApp.cafeSearch,
      data: cafeSearchRequest,
      options: headers,
    );
  }

  ///Get Filter Options
  Future<Response> getFilterOptions() {
    print("Bearer ${ObjectFactory().prefs.getCustomerAuthToken()}");

    final isGuest = ObjectFactory().prefs.isGuestUser();
    final deviceToken = ObjectFactory().prefs.getDeviceID() ?? '';

    final data = isGuest == true ? {"device_token": deviceToken} : null;

    final headers =
        isGuest == true
            ? null
            : Options(
              headers: {
                "Authorization": ObjectFactory().prefs.getCustomerAuthToken(),
              },
            );

    return dioDiceApp.get(UrlsDiceApp.getFilters, data: data, options: headers);
  }

  ///Withdraw
  Future<Response> withdrawBooking(WithdrawBookingRequest request) {
    print(ObjectFactory().prefs.getCustomerAuthToken());
    return dioDiceApp.post(
      UrlsDiceApp.withdrawBooking,
      data: request,
      options: Options(
        headers: {
          "Authorization": ObjectFactory().prefs.getCustomerAuthToken(),
        },
      ),
    );
  }

  //Delete Account
  Future<Response> customerProfileDelete() {
    final token = ObjectFactory().prefs.getCustomerAuthToken();
    final userID = ObjectFactory().prefs.getUserId();
    final url = '${UrlsDiceApp.deleteCustomerAccount}/$userID';

    print("Bearer $token");
    print("URL: $url");

    return dioDiceApp.post(
      url,
      options: Options(headers: {"Authorization": token}),
    );
  }

  ///Guest
  Future<Response> guestUserSignIn(GuestUserRequest request) {
    return dioDiceApp.post(
      UrlsDiceApp.guestUserSignIn,
      data: request,

      // options: Options(headers: {
      //   "Authorization": ObjectFactory().prefs.getCustomerAuthToken(),
      // }),
    );
  }

  Future<Response> getPaidCustomerProfileById() {
    final token = ObjectFactory().prefs.getCustomerAuthToken();
    final userID = ObjectFactory().prefs.getUserId(); // Ensure this exists
    final url = '${UrlsDiceApp.getPaidCustomerProfileById}$userID';

    print("Bearer $token");
    print("URL: $url");

    return dioDiceApp.get(
      url,
      options: Options(headers: {"Authorization": token}),
    );
  }

  Future<Response> updatePaidCustomerProfile(
    PaidProfileUpdateRequest profileRequest,
  ) async {
    final token = ObjectFactory().prefs.getCustomerAuthToken();
    final userID = ObjectFactory().prefs.getUserId();
    final url = '${UrlsDiceApp.updatePaidCustomerProfile}$userID';

    // Convert model to FormData for multipart upload
    final formData = await profileRequest.toFormData();
    print("----- FORM DATA DEBUG -----");
    formData.fields.forEach((field) {
      print("Field: ${field.key} = ${field.value}");
    });

    formData.files.forEach((file) {
      print("File field: ${file.key}");
      print(" - filename: ${file.value.filename}");
    });
    print("----- END FORM DATA -----");

    return dioDiceApp.post(
      // or .post if your API expects POST
      url,
      data: formData,
      options: Options(
        headers: {
          "Authorization": token,
          "Content-Type": "multipart/form-data",
        },
      ),
    );
  }
}
