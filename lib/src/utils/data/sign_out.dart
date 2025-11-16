import 'package:soloseaters/main.dart';
import 'package:soloseaters/src/ui/cafe_owner/authentication/login/cubit/apple_signin_cubit.dart';
import 'package:soloseaters/src/ui/cafe_owner/authentication/login/cubit/google_sign_in_cubit.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'object_factory.dart';

// class SignOut {
//   SignOut._();
//   static final SignOut _instance = SignOut._();

//   factory SignOut() => _instance;

//   Future<void> logout(BuildContext context) async {
    
// try {
//   final prefs = ObjectFactory().prefs;

//   // Sign out from providers
//   context.read<GoogleSignInCubit>().signOut();
//   context.read<AppleSignInCubit>().signOut();

//   // Clear all shared prefs (unified)
//   prefs.setIsLoggedIn(false);
//   prefs.setIsCustomerLoggedIn(false);

//   prefs.setAuthToken(token: "");
//   prefs.setCustomerAuthToken(token: "");

//   prefs.setUserId(userId: "");
//   prefs.setCafeId(cafeId: "");

//   prefs.setCustomerUserName(customerUserName: "");
//   prefs.setCustomerMail(mail: "");

//   prefs.setCafeUserName(cafeUserName: "");

//   prefs.setCafeUserId(cafeUserId: "");
//   prefs.setCafeUserMail(cafeUserMail: "");

//   // Optional: reset user decision if needed
//   // prefs.setUserDecisionName('');

//   // Optional: clear navigation source if used
//   // prefs.setNavigationSource('');

//   context.go('/category');
// } catch (e) {
//   if (kDebugMode) {
//     print('Error during logout: $e');
//   }
// }

//   }
// }


// 🎯 Import your global key file here

class SignOut {
  SignOut._();
  static final SignOut _instance = SignOut._();

  factory SignOut() => _instance;
  
  // 🎯 NEW METHOD FOR DIO INTERCEPTOR (Context-free)
  Future<void> logoutFromInterceptor() async {
    final context = navigatorKey.currentContext;
    final prefsManager = ObjectFactory().prefs; // Get the actual prefs manager object

    if (context == null) {
      if (kDebugMode) {
        print('Error: Navigator context is null during interceptor logout. Clearing prefs only.');
      }
      // If context is null, at least clear the prefs to invalidate session
      _clearAuthData(prefsManager); 
      return;
    }
    
    // Call the original logic with the retrieved context
    await logout(context);
  }


  // ORIGINAL IMPLEMENTATION (called from UI widgets) - LOGIC MOVED TO HELPER
  Future<void> logout(BuildContext context) async {
    try {
      final prefsManager = ObjectFactory().prefs; // Get the actual prefs manager object

      // Sign out from providers
      context.read<GoogleSignInCubit>().signOut();
      context.read<AppleSignInCubit>().signOut();

      // Clear all shared prefs
      _clearAuthData(prefsManager);

      // Navigate to the category screen
      context.go('/category');
    } catch (e) {
      if (kDebugMode) {
        print('Error during logout: $e');
      }
    }
  }

  // Helper method to consolidate pref clearing logic
  // 💡 FIX: Changed the parameter type from 'ObjectFactory' to 'dynamic' 
  // and renamed to 'prefsManager' for clarity.
  void _clearAuthData(dynamic prefsManager) { 
    prefsManager.setIsLoggedIn(false);
    prefsManager.setIsCustomerLoggedIn(false);

    prefsManager.setAuthToken(token: "");
    prefsManager.setCustomerAuthToken(token: "");

    prefsManager.setUserId(userId: "");
    prefsManager.setCafeId(cafeId: "");

    prefsManager.setCustomerUserName(customerUserName: "");
    prefsManager.setCustomerMail(mail: "");

    prefsManager.setCafeUserName(cafeUserName: "");

    prefsManager.setCafeUserId(cafeUserId: "");
    prefsManager.setCafeUserMail(cafeUserMail: "");
  }
}