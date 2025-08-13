import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:meta/meta.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:the_apple_sign_in/scope.dart';
import 'package:the_apple_sign_in/the_apple_sign_in.dart';

part 'apple_signin_state.dart';

class AppleSignInCubit extends Cubit<AppleSignInState> {
  AppleSignInCubit() : super(AppleSignInInitial());
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  // Keys for storing Apple user data
  static const String _appleUserDataKey = 'apple_user_data';

  // Store Apple user data locally
  Future<void> _storeAppleUserData({
    required String userId,
    required String? displayName,
    required String? email,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final userData = {
      'userId': userId,
      'displayName': displayName,
      'email': email,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    };
    await prefs.setString(_appleUserDataKey, jsonEncode(userData));
    // print(
    //   "📁 DEBUG: Stored data - displayName: '$displayName', email: '$email'",
    // );
  }

  // Retrieve stored Apple user data
  Future<Map<String, dynamic>?> _getStoredAppleUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final userDataString = prefs.getString(_appleUserDataKey);
    if (userDataString != null) {
      final data = jsonDecode(userDataString) as Map<String, dynamic>;
      // print(
      //   "📁 DEBUG: Retrieved stored data - displayName: '${data['displayName']}', email: '${data['email']}'",
      // );
      return data;
    }
    // print("📁 DEBUG: No stored data found");
    return null;
  }

  // Clear stored Apple user data (useful for sign out)
  Future<void> clearStoredAppleUserData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_appleUserDataKey);
    // print("📁 DEBUG: Cleared stored Apple user data");
  }

  // APPLE Sign-In Logic
  Future<User> signInWithApple({
    List<Scope> scopes = const [Scope.email, Scope.fullName],
  }) async {
    // print("🚀 APPLE SIGN-IN STARTED - ${DateTime.now()}");
    // print("Requested Scopes: $scopes");
    emit(AppleSignInLoading());

    try {
      // print("📱 Calling TheAppleSignIn.performRequests...");
      final result = await TheAppleSignIn.performRequests([
        AppleIdRequest(requestedScopes: scopes),
      ]);
      // print("✅ Apple Sign-In request completed with status: ${result.status}");

      switch (result.status) {
        case AuthorizationStatus.authorized:
          // print("✅ AUTHORIZATION SUCCESSFUL");
          final appleIdCredential = result.credential!;

          // Debug: Print all Apple credential data
          // print("=== APPLE SIGN-IN DEBUG START ===");
          // print("Apple Credential Status: ${result.status}");
          // print("User ID: ${appleIdCredential.user}");
          // print("Given Name (First): ${appleIdCredential.fullName?.givenName}");
          // print(
          //   "Family Name (Last): ${appleIdCredential.fullName?.familyName}",
          // );
          // print("Middle Name: ${appleIdCredential.fullName?.middleName}");
          // print("Nickname: ${appleIdCredential.fullName?.nickname}");
          // print("Email from Apple: ${appleIdCredential.email}");
          // print("Real User Status: ${appleIdCredential.realUserStatus}");
          // print("=== APPLE SIGN-IN DEBUG END ===");

          // print("🔐 Creating Firebase credential...");
          final oAuthProvider = OAuthProvider('apple.com');
          final credential = oAuthProvider.credential(
            idToken: String.fromCharCodes(appleIdCredential.identityToken!),
            accessToken: String.fromCharCodes(
              appleIdCredential.authorizationCode!,
            ),
          );

          // print("🔥 Signing in with Firebase...");
          final userCredential = await _firebaseAuth.signInWithCredential(
            credential,
          );
          final firebaseUser = userCredential.user!;
          // print("✅ Firebase sign-in successful. User UID: ${firebaseUser.uid}");

          // Debug Firebase user data
          // print("🔥 FIREBASE USER DEBUG:");
          // print("Firebase User Email: ${firebaseUser.email}");
          // print("Firebase User DisplayName: ${firebaseUser.displayName}");
          // print("Firebase User UID: ${firebaseUser.uid}");
          // print("Firebase Provider Data: ${firebaseUser.providerData}");

          String? displayName;
          String? userMail;
          String? identityToken;

          // Get identity token
          final Uint8List? identityTokenBytes = appleIdCredential.identityToken;
          if (identityTokenBytes != null) {
            identityToken = utf8.decode(identityTokenBytes.toList());
            // print("🔐 Identity Token decoded successfully");
          }

          if (appleIdCredential.fullName?.givenName != null ||
              appleIdCredential.email != null) {
            // print("🟢 BRANCH: Using fresh Apple data");
            await clearStoredAppleUserData();

            final firstName = appleIdCredential.fullName?.givenName;
            final lastName = appleIdCredential.fullName?.familyName;

            // print("Debug - First Name: '$firstName'");
            // print("Debug - Last Name: '$lastName'");

            if (firstName != null && lastName != null) {
              displayName = '$firstName $lastName';
              // print("Debug - Full Name: '$displayName'");
            } else if (firstName != null) {
              displayName = firstName;
              // print("Debug - Only First Name: '$displayName'");
            } else if (lastName != null) {
              displayName = lastName;
              // print("Debug - Only Last Name: '$displayName'");
            } else {
              displayName = null;
              // print("Debug - No name available, displayName set to null");
            }

            userMail = appleIdCredential.email;
            // print("Debug - Email from Apple: '$userMail'");
            // print("Debug - Firebase User Email: '${firebaseUser.email}'");
            // print("Debug - Final displayName before storing: '$displayName'");

            await _storeAppleUserData(
              userId: firebaseUser.uid,
              displayName: displayName,
              email: userMail,
            );

            if (displayName != null) {
              await firebaseUser.updateDisplayName(displayName);
              // print("Debug - Updated Firebase displayName to: '$displayName'");
            }
          } else {
            // print("🟡 BRANCH: Using stored/fallback data");
            final storedData = await _getStoredAppleUserData();

            if (storedData != null) {
              displayName = storedData['displayName'];
              userMail = storedData['email'];
              // print("Debug - Retrieved from storage:");
              // print("  - displayName: '$displayName'");
              // print("  - email: '$userMail'");
              // print("  - timestamp: ${storedData['timestamp']}");
            } else {
              // print("🔴 BRANCH: Using Firebase fallback data");
              displayName = firebaseUser.displayName;
              userMail = firebaseUser.providerData[0].email;
              // print("Debug - Firebase fallback:");
              // print("  - displayName: '$displayName'");
              // print("  - email: '$userMail'");
            }
          }

          // print("🏁 FINAL VALUES:");
          // print("  - Final displayName: '$displayName'");
          // print("  - Final userMail: '$userMail'");
          // print("  - Firebase User UID: ${firebaseUser.uid}");

          // print("📤 EMITTING AppleSignInLoaded STATE");
          emit(
            AppleSignInLoaded(
              user: firebaseUser,
              displayName: displayName!,
              userMail: userMail!,
              identityToken: identityToken!,
            ),
          );

          // print("✅ APPLE SIGN-IN PROCESS COMPLETED SUCCESSFULLY");
          return firebaseUser;

        case AuthorizationStatus.error:
          // print("❌ APPLE SIGN-IN ERROR: ${result.error}");
          emit(AppleSignInDenied());
          throw PlatformException(
            code: 'ERROR_AUTHORIZATION_DENIED',
            message: result.error.toString(),
          );

        case AuthorizationStatus.cancelled:
          // print("🚫 APPLE SIGN-IN CANCELLED BY USER");
          emit(AppleSignInDenied());
          emit(AppleSignInInitial());
          return Future.error('Sign in aborted by user');

        default:
          // print("⚠️ UNKNOWN AUTHORIZATION STATUS: ${result.status}");
          throw UnimplementedError();
      }
    } catch (e) {
      // print("💥 APPLE SIGN-IN EXCEPTION: $e");
      // print("Exception Type: ${e.runtimeType}");
      emit(AppleSignInError(message: "ERROR_AUTHORIZATION_DENIED"));
      rethrow;
    }
  }

  // Sign out method that also clears stored data
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
    await clearStoredAppleUserData();
    emit(AppleSignInInitial());
    // print("🚪 SIGNED OUT - Cleared Firebase auth and stored data");
  }
}
