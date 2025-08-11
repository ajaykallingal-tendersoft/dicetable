import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:soloseaters/src/constants/app_colors.dart';
import 'package:soloseaters/src/constants/assets.dart';
import 'package:soloseaters/src/model/cafe_owner/auth/login/google_login_request.dart';
import 'package:soloseaters/src/resources/api_providers/auth/auth_data_provider.dart';
import 'package:soloseaters/src/ui/cafe_owner/authentication/login/bloc/login_bloc.dart';
import 'package:soloseaters/src/ui/cafe_owner/authentication/login/cubit/google_sign_in_cubit.dart';
import 'package:soloseaters/src/ui/customer/authentication/sign_up/bloc/customer_sign_up_bloc.dart';
import 'package:soloseaters/src/utils/data/object_factory.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:soloseaters/src/utils/network_connectivity/network_connectivity_bloc.dart';

import '../../../../customer/authentication/login/bloc/customer_login_bloc.dart';

const _googleIconSizeScale = 28 / 44;

class LoginWithGoogleWidget extends StatelessWidget {
  LoginWithGoogleWidget({
    super.key,
    this.height = 44,
    this.borderRadius = const BorderRadius.all(Radius.circular(8.0)),
  });
  final double height;

  final BorderRadius borderRadius;

  NetworkConnectivityState? _networkState;

  @override
  Widget build(BuildContext context) {
    final userCategory = ObjectFactory().prefs.getUserDecisionName();

    return BlocListener<NetworkConnectivityBloc, NetworkConnectivityState>(
      listener: (context, state) {
        _networkState = state;
      },
      child: BlocConsumer<GoogleSignInCubit, GoogleSignInState>(
        listener: (context, state) {
          if (state is GoogleSignInCubitLoading) {
            EasyLoading.show();
          }
          if (state is GoogleSignInSuccess) {
            EasyLoading.dismiss();
            if (userCategory == 'PUBLIC_USER') {
              BlocProvider.of<CustomerLoginBloc>(context).add(
                CustomerGoogleLoginEvent(
                  googleLoginRequest: GoogleLoginRequest(
                    email: state.user.email!,
                    loginType: 5,
                    fcmToken: ObjectFactory().prefs.getFcmToken().toString(),
                  ),
                ),
              );
              ObjectFactory().prefs.setCustomerUserName(
                customerUserName: state.user.displayName,
              );
              ObjectFactory().prefs.setCustomerUserMail(
                customerUserMail: state.user.email,
              );
            } else {
              BlocProvider.of<LoginBloc>(context).add(
                GetGoogleLoginEvent(
                  googleLoginRequest: GoogleLoginRequest(
                    email: state.user.email!,
                    loginType: 3,
                    fcmToken: ObjectFactory().prefs.getFcmToken().toString(),
                  ),
                ),
              );
              ObjectFactory().prefs.setCafeUserName(
                cafeUserName: state.user.displayName,
              );
              ObjectFactory().prefs.setCafeUserMail(
                cafeUserMail: state.user.email,
              );
              ObjectFactory().prefs.setCafeUserImage(
                cafeUserImage: state.base64Image,
              );
            }
          }
          if (state is GoogleSignInDenied) {
             EasyLoading.dismiss();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                backgroundColor: AppColors.appRedColor,
                content: Text("Failed to Authenticate With Google."),
              ),
            );
          }
          if (state is GoogleSignInError) {
              EasyLoading.dismiss();
            context.read<GoogleSignInCubit>().signOut();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                backgroundColor: AppColors.appRedColor,
                content: Text("Failed to Authenticate With Google."),
              ),
            );
          }
        },
        builder: (context, state) {
          // Calculate font size based on height (same as Apple button)
          final fontSize = height * 0.43;
          return SizedBox(
            height: height,
            child: SizedBox.expand(
              child: InkWell(
                onTap:
                    state is GoogleSignInCubitLoading
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
                          context.read<GoogleSignInCubit>().login(
                            forceAccountSelection: true,
                          );
                        },
                borderRadius: borderRadius,
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.primaryWhiteColor,
                    borderRadius: borderRadius,
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  height: height,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: _googleIconSizeScale * height,
                        height: _googleIconSizeScale * height,
                        child: Center(
                          child: Image.asset(
                            Assets.GOOGLE_LOGO,
                            fit: BoxFit.contain,
                            width: 25,
                            height: 25,
                          ),
                        ),
                      ),
                      Flexible(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 5),
                          child: Text(
                            'Sign in with Google',
                            style: TextStyle(
                              fontFamily: '.SF Pro Text',
                              letterSpacing: -0.41,
                              fontSize: fontSize,
                              color: AppColors.primaryBlackColor,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
