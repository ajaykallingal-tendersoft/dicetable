import 'dart:io';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:soloseaters/src/constants/app_colors.dart';
import 'package:soloseaters/src/constants/assets.dart';
import 'package:soloseaters/src/model/cafe_owner/auth/login/apple_login_request.dart';
import 'package:soloseaters/src/ui/cafe_owner/authentication/login/bloc/login_bloc.dart';
import 'package:soloseaters/src/ui/cafe_owner/authentication/login/cubit/apple_signin_cubit.dart';
import 'package:soloseaters/src/ui/customer/authentication/login/bloc/customer_login_bloc.dart';
import 'package:soloseaters/src/utils/data/object_factory.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:soloseaters/src/utils/network_connectivity/network_connectivity_bloc.dart';

class LoginWithAppleWidget extends StatelessWidget {
  LoginWithAppleWidget({super.key});
  NetworkConnectivityState? _networkState;
  @override
  Widget build(BuildContext context) {
    if (!Platform.isIOS) return const SizedBox();
    final userCategory = ObjectFactory().prefs.getUserDecisionName();
    return BlocListener<NetworkConnectivityBloc, NetworkConnectivityState>(
      listener: (context, state) {
        _networkState = state;
      },
      child: BlocConsumer<AppleSignInCubit, AppleSignInState>(
        listener: (context, state) {
          if (state is AppleSignInLoading) {
            EasyLoading.show();
          }
          if (state is AppleSignInLoaded) {
            EasyLoading.dismiss();
            print("AppleCubitLoaded Usermail:${state.userMail}");
            if (userCategory == 'PUBLIC_USER') {
              BlocProvider.of<CustomerLoginBloc>(context).add(
                CustomerAppleLoginEvent(
                  appleLoginRequest: AppleLoginRequest(
                    identityToken: state.identityToken,
                    loginType: 5,
                    fcmToken: ObjectFactory().prefs.getFcmToken().toString(),
                  ),
                ),
              );
              ObjectFactory().prefs.setCustomerUserName(
                customerUserName: state.displayName,
              );
              ObjectFactory().prefs.setCustomerUserMail(
                customerUserMail: state.userMail,
              );
            } else {
              print("AppleCubitLoaded Usermail:${state.userMail}");
              BlocProvider.of<LoginBloc>(context).add(
                GetAppleLoginEvent(
                  appleLoginRequest: AppleLoginRequest(
                    identityToken: state.identityToken,
                    loginType: 3,
                    fcmToken: ObjectFactory().prefs.getFcmToken().toString(),
                  ),
                ),
              );
              ObjectFactory().prefs.setCafeUserName(
                cafeUserName: state.displayName,
              );
              ObjectFactory().prefs.setCafeUserMail(
                cafeUserMail: state.userMail,
              );
            }
          }
          if (state is AppleSignInDenied) {
            EasyLoading.dismiss();
            _showErrorSnackBar(context, "The request cannot be completed.");
          }
          if (state is AppleSignInError) {
            EasyLoading.dismiss();
            _showErrorSnackBar(context, "The request cannot be completed.");
          }
        },
        builder: (context, state) {
          return SignInWithAppleButton(
            onPressed:
                state is AppleSignInLoading
                    ? null
                    : () {
                      if (_networkState is NetworkFailure) {
                        Fluttertoast.showToast(
                          msg: "No internet connection",
                          backgroundColor: AppColors.primaryWhiteColor,
                          textColor: AppColors.appRedColor,
                        );
                        return;
                      }
                      _signInWithApple(context);
                    },
            style: SignInWithAppleButtonStyle.white,
          );
        },
      ),
    );
  }

  Future<void> _signInWithApple(BuildContext context) async {
    try {
      final authService = BlocProvider.of<AppleSignInCubit>(context);
      final user = await authService.signInWithApple();
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }

  void _showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(backgroundColor: AppColors.appRedColor, content: Text(message)),
    );
  }
}
