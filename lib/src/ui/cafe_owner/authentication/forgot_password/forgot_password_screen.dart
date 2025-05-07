import 'package:dicetable/src/common/custom_text_field.dart';
import 'package:dicetable/src/common/elevated_button_widget.dart';
import 'package:dicetable/src/constants/app_colors.dart';
import 'package:dicetable/src/model/cafe_owner/auth/forgot_password/forgot_password_request.dart';
import 'package:dicetable/src/resources/api_providers/auth/auth_data_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

import 'bloc/forgotPassword/forgot_password_bloc.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController _controller = TextEditingController();
  FocusNode focusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
  create: (context) => ForgotPasswordBloc(authDataProvider: AuthDataProvider()),
  child: Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        leading: InkWell(
          onTap: () => context.pop(),
            child: SvgPicture.asset('assets/svg/back.svg', fit: BoxFit.scaleDown)),
        title: Text(
          'Forgot Password',
          style: TextTheme.of(context).labelLarge,
          textAlign: TextAlign.left,
        ),
      ),
      body: SizedBox.expand(
        child: DecoratedBox(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/png/fp-bg.png'),
              fit: BoxFit.cover,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 10),
            child: Column(
              children: [
                Gap(100),
                Text(
                  "Enter your Email ID To send the OTP code",
                  style: TextTheme.of(context).labelLarge!.copyWith(
                    fontSize: 16,
                    color: AppColors.primaryBlackColor,
                  ),
                  textAlign: TextAlign.center,
                ),
                Gap(30),
                CustomTextField(
                  hintText: 'Email Address',
                  controller: _controller,
                ),
                Gap(60),
                BlocConsumer<ForgotPasswordBloc, ForgotPasswordState>(
  listener: (context, state) {
    if(state is ForgotPasswordError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(state.errorMessage),
          backgroundColor: AppColors.appRedColor,
        ),
      );
    }
    if(state is ForgotPasswordLoaded) {
      if(state.forgotPasswordRequestResponse.message == "We have emailed your password reset link!") {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(state.forgotPasswordRequestResponse.message!),
            backgroundColor: AppColors.appGreenColor,
          ),
        );
        context.go('/forgot_password_otp',extra: _controller.text);
      }
    }
  },
  builder: (context, state) {
    final bool isLoading = state is ForgotPasswordLoading;
    return InkWell(
                  onTap: () {
                    context.read<ForgotPasswordBloc>().add(GetForgotPasswordEvent(forgotPasswordRequest: ForgotPasswordRequest(email: _controller.text),),);
                  },
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      ElevatedButtonWidget(
                        height: 70.h,
                        width: 377.w,
                        iconEnabled: false,
                        iconLabel: isLoading ? "" : "SEND",
                        color: AppColors.primary,
                        textColor: AppColors.primaryWhiteColor,
                      ),
                      if (isLoading)
                        CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<
                              Color>(
                            AppColors.primaryWhiteColor,
                          ),
                        ),
                    ],
                  ),

                );
  },
),
              ],
            ),
          ),
        ),
      ),
    ),
);
  }
}
