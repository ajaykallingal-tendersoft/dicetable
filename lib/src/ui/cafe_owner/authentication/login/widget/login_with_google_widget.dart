import 'package:dicetable/src/constants/app_colors.dart';
import 'package:dicetable/src/resources/api_providers/auth/auth_data_provider.dart';
import 'package:dicetable/src/ui/cafe_owner/authentication/login/bloc/login_bloc.dart';
import 'package:dicetable/src/ui/cafe_owner/authentication/login/cubit/google_sign_in_cubit.dart';
import 'package:dicetable/src/utils/data/object_factory.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

class LoginWithGoogleWidget extends StatelessWidget {
  const LoginWithGoogleWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final userCategory = ObjectFactory().prefs.getUserDecisionName();
    return MultiBlocProvider(
      providers: [
        BlocProvider<GoogleSignInCubit>(
          create: (context) => GoogleSignInCubit(),
        ),
        BlocProvider<LoginBloc>(
          create: (context) => LoginBloc(authDataProvider: AuthDataProvider()),
        ),
      ],
      child: BlocConsumer<GoogleSignInCubit, GoogleSignInState>(
        listener: (context, state) {
          if (state is GoogleSignInSuccess) {
            print("Email: ${state.user.email}");
            print("DisplayName: ${state.user.displayName}");
            if(userCategory == 'PUBLIC_USER') {
              ObjectFactory().prefs.setIsCustomerLoggedIn(true);
              ObjectFactory().prefs.setCustomerUserName(customerUserName: state.user.displayName);
              context.go('/customer_home');
            }else {
              ObjectFactory().prefs.setIsLoggedIn(true);
              ObjectFactory().prefs.setCafeUserName(cafeUserName: state.user.displayName);
              context.go('/home');
            }
            Fluttertoast.showToast(
              backgroundColor: AppColors.primaryWhiteColor,
              textColor: AppColors.appRedColor,
              gravity: ToastGravity.BOTTOM,
              msg: "Successfully Authenticated With Google.",
            );
          }
          if (state is GoogleSignInDenied) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                backgroundColor: AppColors.appRedColor,
                content: Text("Failed to Authenticate With Google."),
              ),
            );
          }
        },
        builder: (context, state) {
          return InkWell(
            onTap: state is GoogleSignInCubitLoading
                ? null
                : () {
              context.read<GoogleSignInCubit>().login();
            },

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
                  SvgPicture.asset('assets/svg/google.svg'),
                  Gap(20),
                  state is GoogleSignInCubitLoading
                      ? CircularProgressIndicator(
                        backgroundColor: AppColors.primaryWhiteColor,
                        color: AppColors.primary,
                      )
                      : Text(
                        'GOOGLE',
                        style: Theme.of(context).textTheme.labelMedium!
                            .copyWith(color: AppColors.primary),
                      ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
