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
  }

  // Retrieve stored Apple user data
  Future<Map<String, dynamic>?> _getStoredAppleUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final userDataString = prefs.getString(_appleUserDataKey);
    if (userDataString != null) {
      return jsonDecode(userDataString) as Map<String, dynamic>;
    }
    return null;
  }

  // Clear stored Apple user data (useful for sign out)
  Future<void> clearStoredAppleUserData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_appleUserDataKey);
  }

  // APPLE Sign-In Logic
  Future<User> signInWithApple({
    List<Scope> scopes = const [Scope.email, Scope.fullName],
  }) async {
    emit(AppleSignInLoading());

    try {
      final result = await TheAppleSignIn.performRequests([
        AppleIdRequest(requestedScopes: scopes),
      ]);

      switch (result.status) {
        case AuthorizationStatus.authorized:
          final appleIdCredential = result.credential!;
          final oAuthProvider = OAuthProvider('apple.com');
          final credential = oAuthProvider.credential(
            idToken: String.fromCharCodes(appleIdCredential.identityToken!),
            accessToken: String.fromCharCodes(
              appleIdCredential.authorizationCode!,
            ),
          );

          final userCredential = await _firebaseAuth.signInWithCredential(
            credential,
          );
          final firebaseUser = userCredential.user!;

          String? displayName;
          String? userMail;
          String? identityToken;

          // Get identity token
          final Uint8List? identityTokenBytes = appleIdCredential.identityToken;
          if (identityTokenBytes != null) {
            identityToken = utf8.decode(identityTokenBytes.toList());
          }

          // Check if Apple provided user data (first time sign in)
          if (appleIdCredential.fullName?.givenName != null ||
              appleIdCredential.email != null) {
            // First time sign in - Apple provides the data
            displayName = appleIdCredential.fullName?.givenName;
            userMail = appleIdCredential.email;

            print('First time sign in - storing user data');
            print('NAMEFROMAPPLE: $displayName');
            print('MailFROMAPPLE: $userMail');

            // Store the data locally for future use
            await _storeAppleUserData(
              userId: firebaseUser.uid,
              displayName: displayName,
              email: userMail,
            );

            // Update Firebase user display name if provided
            if (displayName != null) {
              await firebaseUser.updateDisplayName(displayName);
            }
          } else {
            // Subsequent sign in - Apple doesn't provide data, use stored data
            print('Subsequent sign in - retrieving stored data');
            final storedData = await _getStoredAppleUserData();

            if (storedData != null) {
              displayName = storedData['displayName'];
              userMail = storedData['email'];
              print('Retrieved stored NAMEFROMAPPLE: $displayName');
              print('Retrieved stored MailFROMAPPLE: $userMail');
            } else {
              // Fallback to Firebase user data if available
              displayName = firebaseUser.displayName;
              userMail = firebaseUser.email;
              print(
                'Using Firebase user data - Name: $displayName, Email: $userMail',
              );
            }
          }

          emit(
            AppleSignInLoaded(
              user: firebaseUser,
              displayName: displayName!,
              userMail: userMail!,
              identityToken: identityToken!,
            ),
          );

          return firebaseUser;

        case AuthorizationStatus.error:
          emit(AppleSignInDenied());
          throw PlatformException(
            code: 'ERROR_AUTHORIZATION_DENIED',
            message: result.error.toString(),
          );

        case AuthorizationStatus.cancelled:
          emit(AppleSignInError(message: "Sign in aborted by user"));
          throw PlatformException(
            code: 'ERROR_ABORTED_BY_USER',
            message: 'Sign in aborted by user',
          );

        default:
          throw UnimplementedError();
      }
    } catch (e) {
      emit(AppleSignInError(message: e.toString()));
      rethrow;
    }
  }

  // Sign out method that also clears stored data
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
    await clearStoredAppleUserData();
    emit(AppleSignInInitial());
  }
}
