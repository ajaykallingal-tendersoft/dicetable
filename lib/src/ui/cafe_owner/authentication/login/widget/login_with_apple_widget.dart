import 'dart:io';

import 'package:dicetable/src/constants/app_colors.dart';
import 'package:dicetable/src/constants/assets.dart';
import 'package:dicetable/src/ui/cafe_owner/authentication/login/cubit/apple_signin_cubit.dart';
import 'package:dicetable/src/utils/data/object_factory.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';


class LoginWithAppleWidget extends StatelessWidget {
  // final VoidCallback onSuccess;

  const LoginWithAppleWidget({super.key});

  @override
  Widget build(BuildContext context) {
    if (!Platform.isIOS) return const SizedBox();

    return BlocConsumer<AppleSignInCubit, AppleSignInState>(
      listener: (context, state) {
        if (state is AppleSignInLoaded) {
          final fcmToken = ObjectFactory().prefs.getFcmToken();
          if (fcmToken != null && fcmToken.isNotEmpty) {
            debugPrint("UserMail: ${state.user.email}");
            debugPrint("Username: ${state.displayName}");
            debugPrint("ID: ${state.user.uid}");
            debugPrint("IdentityToken: ${state.identityToken}");

            // onSuccess();

            // Example: Dispatch to LoginBloc if needed
            // BlocProvider.of<LoginBloc>(context).add(
            //   AppleSignInEvent(
            //     appleSignInRequest: AppleSignInRequest(
            //       email: state.user.email,
            //       displayName: state.displayName ?? state.user.displayName,
            //       mobileNo: "0",
            //       appleKey: state.user.uid,
            //       deviceToken: fcmToken,
            //       deviceType: Platform.isAndroid ? "A" : "I",
            //     ),
            //   ),
            // );

          } else {
            _showErrorSnackBar(context, "The request cannot be completed.");
          }
        } else if (state is AppleSignInDenied) {
          _showErrorSnackBar(context, "The request cannot be completed.");
        }
      },
      builder: (context, state) {
        return InkWell(
          onTap: state is AppleSignInLoading
              ? null
              : () => _signInWithApple(context),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 50.w, vertical: 10.h),
            margin: EdgeInsets.all(16),
            height: 70.h,
            decoration: BoxDecoration(
              color: AppColors.primaryWhiteColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  Assets.APPLE_LOGO,
                  fit: BoxFit.cover,
                ),
                SizedBox(width: 20.w),
                state is AppleSignInLoading
                    ? SizedBox(
                  height: 24,
                  width: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    backgroundColor: AppColors.primaryWhiteColor,
                    color: AppColors.primary,
                  ),
                )
                    : Text(
                  'Sign in with Apple',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: AppColors.textFieldTextColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        );
      },
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
      SnackBar(
        backgroundColor: AppColors.appRedColor,
        content: Text(message),
      ),
    );
  }
}
