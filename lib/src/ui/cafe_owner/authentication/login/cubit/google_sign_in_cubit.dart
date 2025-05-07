import 'package:bloc/bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:meta/meta.dart';

part 'google_sign_in_state.dart';

class GoogleSignInCubit extends Cubit<GoogleSignInState> {
  GoogleSignInCubit() : super(GoogleSignInInitial());

  final GoogleSignIn googleSignIn = GoogleSignIn();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> login() async {
    if (isClosed) return;

    emit(GoogleSignInCubitLoading());

    try {
      final userAccount = await googleSignIn.signIn();

      // User dismissed the sign-in dialog
      if (userAccount == null) {
        if (!isClosed) emit(GoogleSignInDenied());
        return;
      }

      final googleAuth = await userAccount.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredentials = await _auth.signInWithCredential(credential);

      final user = userCredentials.user;

      if (user != null) {
        if (!isClosed) emit(GoogleSignInSuccess(user: user));
      } else {
        if (!isClosed) emit(GoogleSignInError());
      }
    } catch (e, stackTrace) {
      print("Google Sign-In Error: $e\n$stackTrace");
      if (!isClosed) emit(GoogleSignInError());
    }
  }

  Future<void> signOut() async {
    try {
      await googleSignIn.signOut();

      // Disconnect may throw if already disconnected; catch and ignore.
      try {
        await googleSignIn.disconnect();
      } catch (disconnectError) {
        print("Google disconnect failed: $disconnectError");
      }

      await _auth.signOut();

      if (!isClosed) emit(GoogleSignInLoggedOut());
    } catch (e) {
      print("Sign-out error: $e");
      if (!isClosed) emit(GoogleSignInError());
    }
  }
}
