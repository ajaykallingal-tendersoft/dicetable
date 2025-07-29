import 'dart:io';
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
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:responsive_framework/responsive_framework.dart';

class LoginWithAppleWidget extends StatelessWidget {
  const LoginWithAppleWidget({super.key});

  @override
  Widget build(BuildContext context) {
    if (!Platform.isIOS) return const SizedBox();
    final userCategory = ObjectFactory().prefs.getUserDecisionName();
    return BlocConsumer<AppleSignInCubit, AppleSignInState>(
      listener: (context, state) {
        if (state is AppleSignInLoaded) {
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
            ObjectFactory().prefs.setCafeUserMail(cafeUserMail: state.userMail);
          }
        } else if (state is AppleSignInDenied) {
          _showErrorSnackBar(context, "The request cannot be completed.");
        }
      },
      builder: (context, state) {
        final isTabletOrLarger = ResponsiveBreakpoints.of(
          context,
        ).largerThan(MOBILE);
        return InkWell(
          onTap:
              state is AppleSignInLoading
                  ? null
                  : () => _signInWithApple(context),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
            margin: EdgeInsets.all(16),
            height: 70.h,
            decoration: BoxDecoration(
              color: AppColors.primaryWhiteColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Padding(
              padding:
                  isTabletOrLarger
                      ? EdgeInsets.zero
                      : EdgeInsets.only(right: 27.0),

              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  isTabletOrLarger ? Gap(10) : Gap(0),
                  Image.asset(
                    Assets.APPLE_LOGO,
                    fit: isTabletOrLarger ? BoxFit.contain : BoxFit.cover,
                    width: 60.w,
                    height: 60.h,
                  ),
                  state is AppleSignInLoading
                      ? Padding(
                        padding: EdgeInsets.only(left: 24.w),
                        child: SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            backgroundColor: AppColors.primaryWhiteColor,
                            color: AppColors.primary,
                          ),
                        ),
                      )
                      : Text(
                        'Sign in with Apple',
                        style: Theme.of(
                          context,
                        ).textTheme.labelMedium?.copyWith(
                          color: AppColors.textFieldTextColor,
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                ],
              ),
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
      SnackBar(backgroundColor: AppColors.appRedColor, content: Text(message)),
    );
  }
}
