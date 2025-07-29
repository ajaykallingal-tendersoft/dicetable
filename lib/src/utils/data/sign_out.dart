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

  Future<void> logout(BuildContext context) async {
try {
  final prefs = ObjectFactory().prefs;

  // Sign out from providers
  context.read<GoogleSignInCubit>().signOut();
  context.read<AppleSignInCubit>().signOut();

  // Clear all shared prefs (unified)
  prefs.setIsLoggedIn(false);
  prefs.setIsCustomerLoggedIn(false);

  prefs.setAuthToken(token: "");
  prefs.setCustomerAuthToken(token: "");

  prefs.setUserId(userId: "");
  prefs.setCafeId(cafeId: "");

  prefs.setCustomerUserName(customerUserName: "");
  prefs.setCustomerMail(mail: "");

  prefs.setCafeUserName(cafeUserName: "");

  prefs.setCafeUserId(cafeUserId: "");
  prefs.setCafeUserMail(cafeUserMail: "");

  // Optional: reset user decision if needed
  // prefs.setUserDecisionName('');

  // Optional: clear navigation source if used
  // prefs.setNavigationSource('');

  context.go('/category');
} catch (e) {
  if (kDebugMode) {
    print('Error during logout: $e');
  }
}

  }
}
