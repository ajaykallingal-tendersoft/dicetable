import 'dart:io';

import 'package:dicetable/src/model/cafe_owner/auth/forgot_password/forgot_password_request.dart';
import 'package:dicetable/src/model/cafe_owner/auth/forgot_password/password_reset_request.dart';
import 'package:dicetable/src/model/cafe_owner/auth/forgot_password/resend_otp_request.dart';
import 'package:dicetable/src/model/cafe_owner/auth/login/google_login_request.dart';
import 'package:dicetable/src/model/cafe_owner/auth/login/login_request.dart';
import 'package:dicetable/src/model/cafe_owner/auth/signUp/google_sign-up_request.dart';
import 'package:dicetable/src/model/cafe_owner/auth/signUp/sign_up_request.dart';
import 'package:dicetable/src/model/cafe_owner/home/dice_table_update_request.dart';
import 'package:dicetable/src/model/cafe_owner/profile/profile_update_request.dart';
import 'package:dicetable/src/model/cafe_owner/subscription/subscription_start_request.dart';
import 'package:dicetable/src/model/customer/booking/booking_request.dart';
import 'package:dicetable/src/model/customer/booking/withdraw_booking_request.dart';
import 'package:dicetable/src/model/customer/cafe/add_favourite_request.dart';
import 'package:dicetable/src/model/customer/cafe/cafe_list_request.dart';
import 'package:dicetable/src/model/customer/cafe/cafe_search_request.dart';
import 'package:dicetable/src/model/customer/cafe/remove_favourite_request.dart';
import 'package:dicetable/src/model/customer/guest/guest_user_request.dart';
import 'package:dicetable/src/model/customer/profile/customer_profile_update_request.dart';
import 'package:dicetable/src/model/verification/otp_verify_request.dart';
import 'package:dicetable/src/ui/cafe_owner/notification/notification_item.dart';
import 'package:dicetable/src/utils/data/object_factory.dart';
import 'package:dicetable/src/utils/urls/urls.dart';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';

import '../../model/cafe_owner/auth/login/apple_sign_in_request.dart';


class ApiClient {
  ApiClient() {
    ///Dev
    initClientDiceAppDev();
    ///Live
    // initClientDiceAppLive();
  }



  Dio dioDiceApp = Dio();

  BaseOptions _baseOptionsDiceApp = BaseOptions();
  //
  // /// The request info for the request that throws exception.
  // RequestOptions? requestOptions;
  //
  // /// Response info, it may be `null` if the request can't reach to the
  // /// HTTP server, for example, occurring a DNS error, network is not available.
  // Response? response;
  //
  // /// The type of the current [DioException].
  // DioExceptionType? type;
  //
  // /// The original error/exception object;
  // /// It's usually not null when `type` is [DioExceptionType.unknown].
  // Object? error;
  //
  // /// The stacktrace of the original error/exception object;
  // /// It's usually not null when `type` is [DioExceptionType.unknown].
  // StackTrace? stackTrace;
  //
  // /// The error message that throws a [DioException].
  // String? message;

  /// client production
  // initClientDiceAppLive() async {
  //   _baseOptionsDiceApp = BaseOptions(
  //     baseUrl: UrlsDiceApp.baseUrlDev,
  //     connectTimeout: const Duration(seconds: 5000),
  //     receiveTimeout: const Duration(seconds: 3000),
  //     followRedirects: true,
  //     headers: {
  //       HttpHeaders.contentTypeHeader: 'application/json',
  //       HttpHeaders.acceptHeader: 'application/json',
  //     },
  //     responseType: ResponseType.json,
  //     receiveDataWhenStatusError: true,
  //   );
  //
  //   dioDiceApp = Dio(_baseOptionsDiceApp);
  //   dioDiceApp.httpClientAdapter = IOHttpClientAdapter(
  //     createHttpClient: () {
  //       // Don't trust any certificate just because their root cert is trusted.
  //       final HttpClient client =
  //       HttpClient(context: SecurityContext(withTrustedRoots: false));
  //       // You can test the intermediate / root cert here. We just ignore it.
  //       client.badCertificateCallback =
  //       ((X509Certificate cert, String host, int port) => true);
  //       return client;
  //     },
  //   );
  //
  //
  //   dioDiceApp.interceptors.add(InterceptorsWrapper(
  //     onRequest: (reqOptions, handler) {
  //       return handler.next(reqOptions);
  //     },
  //     onError: (DioException dioError, handler) {
  //       return handler.next(dioError);
  //     },
  //   ));
  // }


  ///client dev
  initClientDiceAppDev() async {

    _baseOptionsDiceApp = BaseOptions(
      baseUrl: UrlsDiceApp.baseUrlDev,
      connectTimeout: const Duration(seconds: 5000),
      receiveTimeout: const Duration(seconds: 3000),
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
        final HttpClient client =
        HttpClient(context: SecurityContext(withTrustedRoots: false));
        // You can test the intermediate / root cert here. We just ignore it.
        client.badCertificateCallback =
        ((X509Certificate cert, String host, int port) => true);
        return client;
      },
    );


    dioDiceApp.interceptors.add(InterceptorsWrapper(
      onRequest: (reqOptions, handler) {
        return handler.next(reqOptions);
      },
      onError: (DioException dioError, handler) {
        return handler.next(dioError);
      },
    ));
  }

  ///Cafe Owner
  /// Auth
  //Register
  Future<Response> registerUser(SignUpRequest signupRequest) {
    return dioDiceApp.post(
      UrlsDiceApp.register,
      data: signupRequest,

    );
  }
  //Login
  Future<Response> loginUser(LoginRequest loginRequest) {
    return dioDiceApp.post(
      UrlsDiceApp.login,
      data: loginRequest,

    );
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
    return dioDiceApp.post(
      UrlsDiceApp.resendOtp,
      data: resendOtpRequest,
    );
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
    return dioDiceApp.post(
      UrlsDiceApp.googleLogin,
      data: googleLoginRequest,

    );
  }
  //Google Register
  Future<Response> googleRegisterUser(GoogleSignUpRequest googleSignUpRequest) {
    return dioDiceApp.post(
      UrlsDiceApp.googleSignUp,
      data: googleSignUpRequest,

    );
  }

  //Apple Sign-In
  Future<Response> appleLogin(AppleSignInRequest appleSignInRequest) {
    return dioDiceApp.post(
      UrlsDiceApp.appleSignIn,
      data: appleSignInRequest,

    );
  }

  //Otp Verify
  Future<Response> verifyOTP(OtpVerifyRequest otpVerifyRequest) {
    return dioDiceApp.post(
      UrlsDiceApp.otpVerify,
     data: otpVerifyRequest
    );
  }
  //Get Venue type
  Future<Response> getVenueTypes() {
    return dioDiceApp.get(
      UrlsDiceApp.venueType,
    );
  }

  ///Subscription
  Future<Response> subscriptionStart(SubscriptionStartRequest subscriptionStartRequest) {
    return dioDiceApp.post(
      UrlsDiceApp.subscriptionStart,
      data: subscriptionStartRequest,
      options: Options(headers: {
        "Authorization": ObjectFactory().prefs.getAuthToken(),
      }),

    );
  }
  //Initial subscription plan
  Future<Response> getInitialSubscription() {
    print("Bearer ${ObjectFactory().prefs.getAuthToken()}");
    return dioDiceApp.get(
      UrlsDiceApp.subscriptionInitial,
      options: Options(headers: {
        "Authorization": ObjectFactory().prefs.getAuthToken(),
      }),
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
      options: Options(headers: {
        "Authorization": token,
      }),
    );
  }


///Venue owner home
  Future<Response> getVenueOwnerHomeData( ) {
    return dioDiceApp.get(
      UrlsDiceApp.venueOwnerHome,
      options: Options(headers: {
        "Authorization": ObjectFactory().prefs.getAuthToken(),
      }),
    );
  }
 //Update DiceTable Type
  Future<Response> updateDiceTableType(DiceTableTypeUpdateRequest diceTableUpdateRequest) {
    return dioDiceApp.post(
      UrlsDiceApp.updateDiceTable,
      data: diceTableUpdateRequest,
      options: Options(headers: {
        "Authorization": ObjectFactory().prefs.getAuthToken(),
      }),

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
      options: Options(headers: {
        "Authorization": token,
      }),
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
      options: Options(headers: {
        "Authorization": token,
      }),
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
      options: Options(headers: {
        "Authorization": token,
      }),
    );
  }

  Future<Response> markNotificationAsRead(NotificationReadRequest request) {
    final token = ObjectFactory().prefs.getUserDecisionName() == "PUBLIC_USER"
        ? ObjectFactory().prefs.getCustomerAuthToken()
        : ObjectFactory().prefs.getAuthToken();
    final url = UrlsDiceApp.markNotificationAsRead;

    print("Bearer $token");
    print("URL: $url");

    return dioDiceApp.post(
      url,
      data: request,
      options: Options(headers: {
        "Authorization": token,
      }),
    );
  }

  Future<Response> notificationStatus(NotificationStatusRequest request) {
    final token = ObjectFactory().prefs.getUserDecisionName() == "PUBLIC_USER"
        ? ObjectFactory().prefs.getCustomerAuthToken()
        : ObjectFactory().prefs.getAuthToken();
    final url = UrlsDiceApp.updateNotificationStatus;

    print("Bearer $token");
    print("URL: $url");

    return dioDiceApp.post(
      url,
      data: request,
      options: Options(headers: {
        "Authorization": token,
      }),
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
      options: Options(headers: {
        "Authorization": token,
      }),
    );
  }


  Future<Response> profileUpdateById(ProfileUpdateRequest request) {
    final token = ObjectFactory().prefs.getAuthToken();
    final cafeID = ObjectFactory().prefs.getCafeId(); // Ensure this exists
    final url = '${UrlsDiceApp.profileUpdate}$cafeID';

    print("Bearer $token");
    print("URL: $url");

    return dioDiceApp.post(
      url,
      data: request,
      options: Options(headers: {
        "Authorization": token,
      }),
    );
  }
  //Delete Account
  Future<Response> cafeProfileDelete() {
    final token = ObjectFactory().prefs.getAuthToken();
    final cafeID = ObjectFactory().prefs.getCafeId(); // Ensure this exists
    final url = '${UrlsDiceApp.cafeProfileDelete}/$cafeID';

    print("Bearer $token");
    print("URL: $url");

    return dioDiceApp.post(
      url,
      options: Options(headers: {
        "Authorization": token,
      }),
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
      options: Options(headers: {
        "Authorization": ObjectFactory().prefs.getCustomerAuthToken(),
      }),

    );
  }

  ///CafeList
  Future<Response> getCafeList(CafeListRequest request) {
    print("Bearer ${ObjectFactory().prefs.getCustomerAuthToken()}");
    final isGuest = ObjectFactory().prefs.isGuestUser();
    final headers = isGuest == true
        ? null
        : Options(headers: {
      "Authorization": ObjectFactory().prefs.getCustomerAuthToken(),
    });
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
    final headers = isGuest == true
        ? null
        : Options(headers: {
      "Authorization": ObjectFactory().prefs.getCustomerAuthToken(),
    });
    return dioDiceApp.post(
      UrlsDiceApp.addFavourite,
      data: addFavouriteRequest,
      options: headers,

    );
  }

  ///RemoveFavourite
  Future<Response> removeFavourite(RemoveFavouriteRequest removeFavouriteRequest) {
    print(ObjectFactory().prefs.getCustomerAuthToken());
    return dioDiceApp.post(
      UrlsDiceApp.removeFavourite,
      data: removeFavouriteRequest,
      options: Options(headers: {
        "Authorization": ObjectFactory().prefs.getCustomerAuthToken(),
      }),

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
      options: Options(headers: {
        "Authorization": token,
      }),
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
      options: Options(headers: {
        "Authorization": token,
      }),
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
      options: Options(headers: {
        "Authorization": token,
      }),
    );
  }

  ///CafeSearch
  Future<Response> cafeSearch(CafeSearchRequest cafeSearchRequest) {
    print(ObjectFactory().prefs.getCustomerAuthToken());
    print(ObjectFactory().prefs.isGuestUser());

    final isGuest = ObjectFactory().prefs.isGuestUser();
    final headers = isGuest == true
        ? null
        : Options(headers: {
      "Authorization": ObjectFactory().prefs.getCustomerAuthToken(),
    });

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

    final data = isGuest == true
        ? {
      "device_token": deviceToken,
    }
        : null;

    final headers = isGuest == true
        ? null
        : Options(headers: {
      "Authorization": ObjectFactory().prefs.getCustomerAuthToken(),
    });

    return dioDiceApp.get(
      UrlsDiceApp.getFilters,
      data: data,
      options: headers,
    );
  }


  ///Withdraw
  Future<Response> withdrawBooking( WithdrawBookingRequest request) {
    print(ObjectFactory().prefs.getCustomerAuthToken());
    return dioDiceApp.post(
      UrlsDiceApp.withdrawBooking,
      data: request,
      options: Options(headers: {
        "Authorization": ObjectFactory().prefs.getCustomerAuthToken(),
      }),

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
      options: Options(headers: {
        "Authorization": token,
      }),
    );
  }

  ///Guest
  Future<Response> guestUserSignIn( GuestUserRequest request) {
    return dioDiceApp.post(
      UrlsDiceApp.guestUserSignIn,
      data: request,
      // options: Options(headers: {
      //   "Authorization": ObjectFactory().prefs.getCustomerAuthToken(),
      // }),

    );
  }



}

