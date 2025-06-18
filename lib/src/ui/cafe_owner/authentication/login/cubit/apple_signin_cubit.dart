import 'package:bloc/bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:meta/meta.dart';
import 'package:the_apple_sign_in/scope.dart';
import 'package:the_apple_sign_in/the_apple_sign_in.dart';

part 'apple_signin_state.dart';

class AppleSignInCubit extends Cubit<AppleSignInState> {
  AppleSignInCubit() : super(AppleSignInInitial());
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  // APPLE Sign-In Logic
  Future<User> signInWithApple(
      {List<Scope> scopes = const [
        Scope.email,
        Scope.fullName,
      ]}) async {
    emit(AppleSignInLoading());

    final result = await TheAppleSignIn.performRequests(
      [AppleIdRequest(requestedScopes: scopes)],
    );

    switch (result.status) {
      case AuthorizationStatus.authorized:
        final appleIdCredential = result.credential!;
        final oAuthProvider = OAuthProvider('apple.com');
        final credential = oAuthProvider.credential(
          idToken: String.fromCharCodes(appleIdCredential.identityToken!),
          accessToken:
          String.fromCharCodes(appleIdCredential.authorizationCode!),
        );

        final userCredential =
        await _firebaseAuth.signInWithCredential(credential);
        final firebaseUser = userCredential.user!;
        if (scopes.contains(Scope.fullName)) {
          final fullName = appleIdCredential.fullName;
          print('AppleFullName: ${appleIdCredential.fullName!.givenName.toString()}');
          print('AuthorizationToken: ${appleIdCredential.identityToken}');
          String? displayName;
          String? userMail;
          String? identityToken;
          userMail = '${appleIdCredential.email}';
          displayName = '${fullName!.givenName}';
          identityToken = '${appleIdCredential.identityToken}';
          print('NAMEFROMAPPLE: $displayName');
          print('MailFROMAPPLE: $userMail');


          emit(AppleSignInLoaded(user: firebaseUser, displayName: displayName, userMail: userMail,identityToken: identityToken));
          await firebaseUser.updateDisplayName(displayName);
        }

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
  }
}

