import 'package:bloc/bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:meta/meta.dart';

part 'google_sign_in_state.dart';

class GoogleSignInCubit extends Cubit<GoogleSignInState> {
  GoogleSignInCubit() : super(GoogleSignInInitial());
  final GoogleSignIn googleSignIn = GoogleSignIn();
  final _auth = FirebaseAuth.instance;

  void login() async {
    emit(GoogleSignInCubitLoading());
    try {
      // Select account
      final userAccount = await googleSignIn.signIn();

      // User dismissed the dialog box
      if (userAccount == null) {
        emit(GoogleSignInDenied());
        print("User denied Google Sign-In");
        return;
      }

      final GoogleSignInAuthentication googleSignInAuthentication =
      await userAccount.authentication;


      final credential = GoogleAuthProvider.credential(
        accessToken: googleSignInAuthentication.accessToken,
        idToken: googleSignInAuthentication.idToken,
      );


      final userCredentials = await _auth.signInWithCredential(credential);


      print("Google Sign-In initiated");
      print("Account: ${userAccount.email}");
      print("Firebase User: ${userCredentials.user?.displayName}, ${userCredentials.user?.email}");

      if (userCredentials.user != null) {
        emit(GoogleSignInSuccess(user: userCredentials.user!));
      } else {
        emit(GoogleSignInError());
        print("Firebase user is null after sign-in.");
      }
    } catch (e, stack) {
      print("Google Sign-In Error: $e");
      print(stack);
      emit(GoogleSignInError());
    }
  }


  void signOut() async {
    try {
      await googleSignIn.signOut();
      await googleSignIn.disconnect();
      await FirebaseAuth.instance.signOut();
      emit(GoogleSignInLoggedOut());
    } catch (e) {
      print(e);
      emit(GoogleSignInError());
    }
  }


}
