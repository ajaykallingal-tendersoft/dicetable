part of 'apple_signin_cubit.dart';

abstract class AppleSignInState {}

class AppleSignInInitial extends AppleSignInState {}

class AppleSignInLoading extends AppleSignInState {}

class AppleSignInLoaded extends AppleSignInState {
  final User user;
  final String displayName;
  final String userMail;
  final String  identityToken;

  AppleSignInLoaded({required this.user,required this.displayName,required this.userMail, required this.identityToken});
}

class AppleSignInError extends AppleSignInState {
  final String message;
  AppleSignInError({required this.message});
}

class AppleSignInCancelled extends AppleSignInState {}

class AppleSignInDenied extends AppleSignInState {}
