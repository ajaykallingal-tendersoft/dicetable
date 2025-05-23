part of 'google_sign_in_cubit.dart';

@immutable
sealed class GoogleSignInState {}

final class GoogleSignInInitial extends GoogleSignInState {}

class GoogleSignInCubitLoading extends GoogleSignInState {}

class GoogleSignInLoggedOut extends GoogleSignInState {}

class GoogleSignInSuccess extends GoogleSignInState {
  final User user;
  final String base64Image;

  GoogleSignInSuccess({required this.user,required this.base64Image});
}
class GoogleSignInError extends GoogleSignInState {}
class GoogleSignInDenied extends GoogleSignInState {}
