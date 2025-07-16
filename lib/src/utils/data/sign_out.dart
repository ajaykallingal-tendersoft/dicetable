import 'package:soloseaters/src/ui/cafe_owner/authentication/login/cubit/apple_signin_cubit.dart';
import 'package:soloseaters/src/ui/cafe_owner/authentication/login/cubit/google_sign_in_cubit.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'object_factory.dart';

class SignOut {
  SignOut._();
  static final SignOut _instance = SignOut._();

  factory SignOut() => _instance;
  /// Handles both PUBLIC_USER and VENUE_OWNER logout scenarios
  Future<void> logout(BuildContext context) async {
    try {
      final userDecision = ObjectFactory().prefs.getUserDecisionName();

      context.read<GoogleSignInCubit>().signOut();
      context.read<AppleSignInCubit>().signOut();

      if (userDecision == "PUBLIC_USER") {
        // Clear PUBLIC_USER (Customer) specific preferences
        ObjectFactory().prefs.setIsCustomerLoggedIn(false);
        ObjectFactory().prefs.setCustomerAuthToken(token: "");
        ObjectFactory().prefs.setUserId(userId: "");
        ObjectFactory().prefs.setCustomerUserName(customerUserName: "");
        ObjectFactory().prefs.setCustomerMail(mail: '');
      } else if (userDecision == "VENUE_OWNER") {
        ObjectFactory().prefs.setIsLoggedIn(false);
        ObjectFactory().prefs.setAuthToken(token: "");
        ObjectFactory().prefs.setCafeUserName(cafeUserName: "");
        ObjectFactory().prefs.setCafeId(cafeId: '');
        ObjectFactory().prefs.setCafeUserId(cafeUserId: '');
        ObjectFactory().prefs.setCafeUserMail(cafeUserMail: '');
      } else {
        ObjectFactory().prefs.setIsCustomerLoggedIn(false);
        ObjectFactory().prefs.setIsLoggedIn(false);
        ObjectFactory().prefs.setAuthToken(token: "");
        ObjectFactory().prefs.setUserId(userId: "");
        ObjectFactory().prefs.setCustomerUserName(customerUserName: "");
        ObjectFactory().prefs.setCafeUserName(cafeUserName: "");
        ObjectFactory().prefs.setCafeId(cafeId: '');
        ObjectFactory().prefs.setCafeUserId(cafeUserId: '');
        ObjectFactory().prefs.setCustomerMail(mail: '');
      }

      ObjectFactory().prefs.getNavigationSource();

      context.go('/category');

    } catch (e) {
      if (kDebugMode) {
        print('Error during logout: $e');
      }
    }
  }
}