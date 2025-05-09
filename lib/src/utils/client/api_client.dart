import 'dart:io';

import 'package:dicetable/src/model/cafe_owner/auth/forgot_password/forgot_password_request.dart';
import 'package:dicetable/src/model/cafe_owner/auth/forgot_password/password_reset_request.dart';
import 'package:dicetable/src/model/cafe_owner/auth/login/login_request.dart';
import 'package:dicetable/src/model/cafe_owner/auth/signUp/sign_up_request.dart';
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
  //PasswordReset
  Future<Response> passwordReset(PasswordResetRequest passwordResetRequest) {
    return dioDiceApp.post(
      UrlsDiceApp.passwordReset,
      data: passwordResetRequest,

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


  //
  // ///Login
  // Future<Response> loginRequest(LoginRequest loginRequest) {
  //   return dioLetsCollect.post(
  //     options: Options(),
  //     UrlsLetsCollect.LOGIN_URL,
  //     data: loginRequest,
  //   );
  // }

  // //Forgot Password email
  // Future<Response> forgotPassword(
  //     ForgotPasswordEmailRequest forgotPasswordEmailRequest) {
  //   return dioLetsCollect.post(
  //     UrlsLetsCollect.FORGOT_PASSWORD_EMAIL,
  //     data: forgotPasswordEmailRequest,
  //   );
  // }

  // //Forgot Password Otp
  // Future<Response> forgotPasswordOtp(
  //     ForgotPasswordOtpRequest forgotPasswordOtpRequest) {
  //   return dioLetsCollect.post(
  //     UrlsLetsCollect.FORGOT_PASSWORD_OTP,
  //     data: forgotPasswordOtpRequest,
  //   );
  // }

  // //Forgot Password Reset
  // Future<Response> forgotPasswordReset(
  //     ForgotPasswordResetRequest forgotPasswordResetRequest) {
  //   return dioLetsCollect.post(
  //     UrlsLetsCollect.FORGOT_PASSWORD_RESET,
  //     data: forgotPasswordResetRequest,
  //     options: Options(headers: {
  //       "Authorization": ObjectFactory().prefs.getAuthToken(),
  //     }),
  //   );
  // }

  // ///Home Page
  // Future<Response> getHomeData() {
  //   return dioLetsCollect.get(
  //     UrlsLetsCollect.HOME_DATA,
  //     options: Options(headers: {
  //       "Authorization": ObjectFactory().prefs.getAuthToken(),
  //     }),
  //   );
  // }




}