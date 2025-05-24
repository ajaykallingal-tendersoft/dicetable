import 'dart:io';

import 'package:dicetable/src/model/cafe_owner/auth/forgot_password/forgot_password_request.dart';
import 'package:dicetable/src/model/cafe_owner/auth/forgot_password/password_reset_request.dart';
import 'package:dicetable/src/model/cafe_owner/auth/login/google_login_request.dart';
import 'package:dicetable/src/model/cafe_owner/auth/login/login_request.dart';
import 'package:dicetable/src/model/cafe_owner/auth/signUp/google_sign-up_request.dart';
import 'package:dicetable/src/model/cafe_owner/auth/signUp/google_sign-up_response.dart';
import 'package:dicetable/src/model/cafe_owner/auth/signUp/sign_up_request.dart';
import 'package:dicetable/src/model/cafe_owner/home/dice_table_update_request.dart';
import 'package:dicetable/src/model/cafe_owner/subscription/subscription_start_request.dart';
import 'package:dicetable/src/model/verification/otp_verify_request.dart';
import 'package:dicetable/src/utils/data/object_factory.dart';
import 'package:dicetable/src/utils/urls/urls.dart';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';

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
      // onRequest: (options, handler) {
      //   final token = ObjectFactory().prefs.getAuthToken();
      //   if (token != null && token.isNotEmpty) {
      //     options.headers["Authorization"] = token;
      //   }
      //   return handler.next(options);
      // },
      // onError: (DioException error, handler) async {
      //   // If 401 error and retry not attempted yet
      //   if (error.response?.statusCode == 401 && !error.requestOptions.headers.containsKey('x-retry')) {
      //     final newToken = await refreshToken();
      //     if (newToken != null) {
      //       final opts = error.requestOptions;
      //       opts.headers["Authorization"] = newToken;
      //       opts.headers["x-retry"] = "true"; // Prevent infinite loop
      //       final cloneReq = await dioDiceApp.fetch(opts);
      //       return handler.resolve(cloneReq);
      //     }
      //   }
      //
      //   return handler.next(error); // Pass error to UI
      // },
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
  //GetVenueOwnerHomeData
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



  ///Customer
///
Future<Response> getFavourite() {
    print("Bearer ${ObjectFactory().prefs.getCustomerAuthToken()}");
  return dioDiceApp.get(
    UrlsDiceApp.getFavourite,
    options: Options(headers: {
      "Authorization": ObjectFactory().prefs.getCustomerAuthToken(),
    }),
  );
}

}