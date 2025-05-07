import 'package:dicetable/src/constants/app_colors.dart';
import 'package:dicetable/src/ui/cafe_owner/authentication/login/cubit/google_sign_in_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';

class LoginWithGoogleWidget extends StatelessWidget {
  const LoginWithGoogleWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<GoogleSignInCubit>(
          create: (context) => GoogleSignInCubit(),
        ),
        // BlocProvider<LoginBloc>(
        //   create: (context) => LoginBloc(),
        // ),
      ],
      child: BlocConsumer<GoogleSignInCubit, GoogleSignInState>(
        listener: (context, state) {
          if (state is GoogleSignInSuccess) {
            print("Email: ${state.user.email}");
            print("DisplayName: ${state.user.displayName}");

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                backgroundColor: AppColors.secondary,
                content: Text("Successfully Authenticated With Google."),
              ),
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
