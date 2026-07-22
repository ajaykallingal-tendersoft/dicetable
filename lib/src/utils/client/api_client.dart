import 'dart:async';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
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
import 'package:soloseaters/src/model/payment/subscription_status_request.dart';
import 'package:soloseaters/src/model/payment/verify_purchase_request.dart';
import 'package:soloseaters/src/model/verification/otp_verify_request.dart';
import 'package:soloseaters/src/ui/cafe_owner/notification/notification_item.dart';
import 'package:soloseaters/src/utils/data/auth_session_manager.dart';
import 'package:soloseaters/src/utils/data/object_factory.dart';
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

  // Flag to prevent concurrent token refresh attempts
  bool _isRefreshing = false;
  Completer<String>? _refreshCompleter;
  final List<_PendingRequest> _pendingRequests = [];

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
          try {
            await _ensureConnected(options);
            return handler.next(options);
          } on DioException catch (dioError) {
            EasyLoading.dismiss();
            return handler.reject(dioError);
          } catch (e) {
            EasyLoading.dismiss();
            return handler.reject(
              DioException(
                requestOptions: options,
                error: e,
                type: DioExceptionType.connectionError,
                message: e.toString(),
              ),
            );
          }
        },
        onError: (dioError, handler) async {
          print("❌ API ERROR: ${dioError.message}");
          if (dioError.type == DioExceptionType.connectionError) {
            EasyLoading.dismiss();
          }
          if (dioError.response?.statusCode == 401) {
            final RequestOptions options = dioError.response!.requestOptions;

            // Prevent infinite loop if the tokenRefresh API call also fails with 401
            if (options.path != UrlsDiceApp.tokenRefresh) {
              // If already refreshing, wait for it to complete
              if (_isRefreshing && _refreshCompleter != null) {
                print(
                  "Token refresh already in progress. Waiting for completion...",
                );
                try {
                  final newToken = await _refreshCompleter!.future;
                  // Update the Authorization header and retry
                  options.headers["Authorization"] = newToken;
                  print("🔄 Retrying request with refreshed token...");
                  final retryResponse = await dioDiceApp.fetch(options);
                  return handler.resolve(retryResponse);
                } catch (e) {
                  print("⚠️ Failed to get refreshed token: $e");
                  return handler.next(dioError);
                }
              }

              _isRefreshing = true;
              _refreshCompleter = Completer<String>();
              print("Attempting to refresh token...");

              try {
                // Determine the current user type (Cafe Owner or Customer)
                final userCategory =
                    ObjectFactory().prefs.getUserDecisionName();
                final isPublicUser = userCategory == "PUBLIC_USER";

                // Check if user is logged in before attempting refresh
                final isLoggedIn =
                    isPublicUser
                        ? ObjectFactory().prefs.isCustomerLoggedIn() == true
                        : ObjectFactory().prefs.isLoggedIn() == true;

                if (!isLoggedIn) {
                  print("User is not logged in. Skipping token refresh.");
                  if (_refreshCompleter != null &&
                      !_refreshCompleter!.isCompleted) {
                    _refreshCompleter!.completeError(
                      Exception("User not logged in"),
                    );
                  }
                  _isRefreshing = false;
                  _refreshCompleter = null;
                  _rejectPendingRequests(dioError);
                  return handler.next(dioError);
                }

                // Call the token refresh API
                final Response refreshResponse = await tokenRefresh();

                // Check if refresh was successful
                if (refreshResponse.statusCode == 200 &&
                    refreshResponse.data != null) {
                  final responseData = refreshResponse.data;

                  // Extract token from response - the token is directly in 'token' field
                  final newAuthToken = responseData['token'] as String?;

                  if (newAuthToken != null && newAuthToken.isNotEmpty) {
                    // Save the new token based on user type
                    // Note: setAuthToken and setCustomerAuthToken automatically add "Bearer " prefix
                    if (isPublicUser) {
                      ObjectFactory().prefs.setCustomerAuthToken(
                        token: newAuthToken,
                      );
                      print(
                        "✅ Customer Token refreshed and updated successfully.",
                      );
                    } else {
                      ObjectFactory().prefs.setAuthToken(token: newAuthToken);
                      print(
                        "✅ Cafe Owner Token refreshed and updated successfully.",
                      );
                    }

                    // Get the updated token (with Bearer prefix)
                    final updatedToken =
                        isPublicUser
                            ? ObjectFactory().prefs.getCustomerAuthToken()!
                            : ObjectFactory().prefs.getAuthToken()!;

                    // Update the Authorization header for the failed request
                    options.headers["Authorization"] = updatedToken;

                    // Complete the refresh completer so waiting requests can proceed
                    _refreshCompleter!.complete(updatedToken);

                    // Retry the original request with the new token
                    print("🔄 Retrying original request with new token...");
                    try {
                      final retryResponse = await dioDiceApp.fetch(options);
                      _isRefreshing = false;
                      _refreshCompleter = null;
                      _resolvePendingRequests(updatedToken);
                      return handler.resolve(retryResponse);
                    } catch (retryError) {
                      // If retry fails, it's not a token issue, so don't logout
                      print("⚠️ Retry failed after token refresh: $retryError");
                      _isRefreshing = false;
                      _refreshCompleter = null;
                      _rejectPendingRequests(retryError);
                      return handler.next(
                        retryError is DioException ? retryError : dioError,
                      );
                    }
                  } else {
                    throw Exception(
                      "Token refresh response missing or invalid token",
                    );
                  }
                } else {
                  throw Exception(
                    "Token refresh failed with status: ${refreshResponse.statusCode}",
                  );
                }
              } catch (e) {
                // Token refresh failed - complete the completer with error
                if (_refreshCompleter != null &&
                    !_refreshCompleter!.isCompleted) {
                  _refreshCompleter!.completeError(e);
                }

                // Token refresh failed - only logout if it's a real auth failure
                print("❌ Token refresh failed: $e");
                _isRefreshing = false;
                _refreshCompleter = null;
                _rejectPendingRequests(dioError);

                // Mark that refresh failed so UI can handle logout gracefully
                AuthSessionManager.markRefreshFailure();
                if (e is! DioException) {
                  print("Token refresh error (non-auth): $e");
                }

                return handler.next(dioError);
              }
            }
          }
          return handler.next(dioError);
        },

        onResponse: (res, handler) async {
          // Check if response has status: false with Unauthorized message
          // Some APIs return 200 with error in body instead of 401
          if (res.statusCode == 200 && res.data != null) {
            final responseData = res.data;
            if (responseData is Map) {
              final status = responseData['status'];
              final message =
                  responseData['message']?.toString().toLowerCase() ?? '';

              // Check if this is an unauthorized response
              if (status == false &&
                  (message.contains('unauthorized') ||
                      message.contains('unauthenticated') ||
                      message.contains('token') &&
                          message.contains('expired'))) {
                final RequestOptions options = res.requestOptions;

                // Prevent infinite loop if the tokenRefresh API call also returns unauthorized
                if (options.path != UrlsDiceApp.tokenRefresh) {
                  print(
                    "⚠️ Detected unauthorized response in 200 status. Attempting token refresh...",
                  );

                  // If already refreshing, wait for it to complete
                  if (_isRefreshing && _refreshCompleter != null) {
                    print(
                      "Token refresh already in progress. Waiting for completion...",
                    );
                    try {
                      final newToken = await _refreshCompleter!.future;
                      // Update the Authorization header and retry
                      options.headers["Authorization"] = newToken;
                      print("🔄 Retrying request with refreshed token...");
                      final retryResponse = await dioDiceApp.fetch(options);
                      return handler.resolve(retryResponse);
                    } catch (e) {
                      print("⚠️ Failed to get refreshed token: $e");
                      // Return the original response so UI can handle it
                      return handler.next(res);
                    }
                  }

                  _isRefreshing = true;
                  _refreshCompleter = Completer<String>();

                  try {
                    // Determine the current user type
                    final userCategory =
                        ObjectFactory().prefs.getUserDecisionName();
                    final isPublicUser = userCategory == "PUBLIC_USER";

                    // Check if user is logged in before attempting refresh
                    final isLoggedIn =
                        isPublicUser
                            ? ObjectFactory().prefs.isCustomerLoggedIn() == true
                            : ObjectFactory().prefs.isLoggedIn() == true;

                    if (!isLoggedIn) {
                      print("User is not logged in. Skipping token refresh.");
                      if (_refreshCompleter != null &&
                          !_refreshCompleter!.isCompleted) {
                        _refreshCompleter!.completeError(
                          Exception("User not logged in"),
                        );
                      }
                      _isRefreshing = false;
                      _refreshCompleter = null;
                      return handler.next(res);
                    }

                    // Call the token refresh API
                    final Response refreshResponse = await tokenRefresh();

                    // Check if refresh was successful
                    if (refreshResponse.statusCode == 200 &&
                        refreshResponse.data != null) {
                      final refreshData = refreshResponse.data;

                      // Extract token from response
                      final newAuthToken = refreshData['token'] as String?;

                      if (newAuthToken != null && newAuthToken.isNotEmpty) {
                        // Save the new token based on user type
                        if (isPublicUser) {
                          ObjectFactory().prefs.setCustomerAuthToken(
                            token: newAuthToken,
                          );
                          print(
                            "✅ Customer Token refreshed and updated successfully.",
                          );
                        } else {
                          ObjectFactory().prefs.setAuthToken(
                            token: newAuthToken,
                          );
                          print(
                            "✅ Cafe Owner Token refreshed and updated successfully.",
                          );
                        }

                        // Get the updated token (with Bearer prefix)
                        final updatedToken =
                            isPublicUser
                                ? ObjectFactory().prefs.getCustomerAuthToken()!
                                : ObjectFactory().prefs.getAuthToken()!;

                        // Complete the refresh completer so waiting requests can proceed
                        _refreshCompleter!.complete(updatedToken);

                        // Update the Authorization header and retry
                        options.headers["Authorization"] = updatedToken;
                        print("🔄 Retrying original request with new token...");

                        try {
                          final retryResponse = await dioDiceApp.fetch(options);
                          _isRefreshing = false;
                          _refreshCompleter = null;
                          return handler.resolve(retryResponse);
                        } catch (retryError) {
                          print(
                            "⚠️ Retry failed after token refresh: $retryError",
                          );
                          _isRefreshing = false;
                          _refreshCompleter = null;
                          // Return original response if retry fails
                          return handler.next(res);
                        }
                      } else {
                        throw Exception(
                          "Token refresh response missing or invalid token",
                        );
                      }
                    } else {
                      throw Exception(
                        "Token refresh failed with status: ${refreshResponse.statusCode}",
                      );
                    }
                  } catch (e) {
                    // Token refresh failed
                    AuthSessionManager.markRefreshFailure();
                    if (_refreshCompleter != null &&
                        !_refreshCompleter!.isCompleted) {
                      _refreshCompleter!.completeError(e);
                    }

                    print("❌ Token refresh failed: $e");
                    _isRefreshing = false;
                    _refreshCompleter = null;

                    // Return the original response so UI can handle logout
                    return handler.next(res);
                  }
                }
              }
            }
          }

          return handler.next(res);
        },
      ),
    );
  }

  Future<Response> tokenRefresh() {
    final userCategory = ObjectFactory().prefs.getUserDecisionName();
    final isPublicUser = userCategory == "PUBLIC_USER";
    final venueToken = ObjectFactory().prefs.getAuthToken();
    final publicToken = ObjectFactory().prefs.getCustomerAuthToken();

    // Get the current token (already includes "Bearer " prefix from prefs)
    final currentToken = isPublicUser ? publicToken : venueToken;

    if (currentToken == null || currentToken.isEmpty) {
      throw Exception("No token available for refresh");
    }

    return dioDiceApp.post(
      UrlsDiceApp.tokenRefresh,
      data: currentToken, // Send the full "Bearer <token>" string
      options: Options(headers: {"Authorization": currentToken}),
    );
  }

  // Resolve all pending requests with the new token
  void _resolvePendingRequests(String newToken) {
    for (var pendingRequest in _pendingRequests) {
      pendingRequest.options.headers["Authorization"] = newToken;
      dioDiceApp
          .fetch(pendingRequest.options)
          .then(
            (response) {
              pendingRequest.handler.resolve(response);
              pendingRequest.completer.complete();
            },
            onError: (error) {
              pendingRequest.handler.next(
                error is DioException
                    ? error
                    : DioException(
                      requestOptions: pendingRequest.options,
                      error: error,
                    ),
              );
              pendingRequest.completer.completeError(error);
            },
          );
    }
    _pendingRequests.clear();
  }

  // Reject all pending requests
  void _rejectPendingRequests(dynamic error) {
    for (var pendingRequest in _pendingRequests) {
      pendingRequest.handler.next(
        error is DioException
            ? error
            : DioException(
              requestOptions: pendingRequest.options,
              error: error,
            ),
      );
      pendingRequest.completer.completeError(error);
    }
    _pendingRequests.clear();
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
    print("${ObjectFactory().prefs.getAuthToken()}");
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

    print("$token");
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

    print("$token");
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

    print("$token");
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

    print("$token");
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

    print("$token");
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

    print("$token");
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

    print("$token");
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
        headers: {'Authorization': token, 'Accept': 'application/json'},
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

    print("$token");
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
            headers: {'Authorization': token, 'Accept': 'application/json'},
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
            headers: {'Authorization': token, 'Accept': 'application/json'},
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
    print("$token");
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
    print("${ObjectFactory().prefs.getCustomerAuthToken()}");
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
    print("${ObjectFactory().prefs.getCustomerAuthToken()}");
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

    print("$token");
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

    print("$token");
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

    print("$token");
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
    print("${ObjectFactory().prefs.getCustomerAuthToken()}");

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

    print("$token");
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

    print("$token");
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

  /// Verify purchase with backend
  Future<Response> verifyPurchase(VerifyPurchaseRequest request) {
    print('🔐 API: Verifying purchase - ${request.productId}');

    final userCategory = ObjectFactory().prefs.getUserDecisionName();
    final isPublicUser = userCategory == "PUBLIC_USER";
    final token =
        isPublicUser
            ? ObjectFactory().prefs.getCustomerAuthToken()
            : ObjectFactory().prefs.getAuthToken();

    return dioDiceApp.post(
      UrlsDiceApp.verifyPurchase,
      data: request.toJson(),
      options: Options(headers: {"Authorization": token}),
    );
  }

  /// Fetch subscription status from backend
  Future<Response> getSubscriptionStatus(SubscriptionStatusRequest request) {
    print('🔄 API: Fetching subscription status');

    final userCategory = ObjectFactory().prefs.getUserDecisionName();
    final isPublicUser = userCategory == "PUBLIC_USER";
    final token =
        isPublicUser
            ? ObjectFactory().prefs.getCustomerAuthToken()
            : ObjectFactory().prefs.getAuthToken();

    return dioDiceApp.post(
      UrlsDiceApp.subscriptionStatus,
      data: request.toJson(),
      options: Options(headers: {"Authorization": token}),
    );
  }

  /// Fetch active subscription details from database (no body parameters required)
  Future<Response> getActiveSubscription() {
    print('🔄 API: Fetching active subscription details from backend');

    final userCategory = ObjectFactory().prefs.getUserDecisionName();
    final isPublicUser = userCategory == "PUBLIC_USER";
    final token =
        isPublicUser
            ? ObjectFactory().prefs.getCustomerAuthToken()
            : ObjectFactory().prefs.getAuthToken();

    return dioDiceApp.get(
      UrlsDiceApp.activeSubscription,
      options: Options(headers: {"Authorization": token}),
    );
  }

  Future<bool> _hasRobustConnection() async {
    final connectivity = Connectivity();
    var results = await connectivity.checkConnectivity();
    if (results.isEmpty || results.every((r) => r == ConnectivityResult.none)) {
      await Future.delayed(const Duration(seconds: 1));
      results = await connectivity.checkConnectivity();
    }
    return !(results.isEmpty ||
        results.every((r) => r == ConnectivityResult.none));
  }

  Future<void> _ensureConnected([RequestOptions? options]) async {
    final connected = await _hasRobustConnection();
    if (!connected) {
      throw DioException(
        requestOptions: options ?? RequestOptions(path: ''),
        type: DioExceptionType.connectionError,
        message: "No internet connection",
      );
    }
  }
}

// Helper class for pending requests during token refresh
class _PendingRequest {
  final RequestOptions options;
  final ErrorInterceptorHandler handler;
  final Completer<void> completer;

  _PendingRequest({
    required this.options,
    required this.handler,
    required this.completer,
  });
}
