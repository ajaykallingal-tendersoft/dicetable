import 'package:dicetable/src/common/elevated_button_widget.dart';
import 'package:dicetable/src/constants/app_colors.dart';
import 'package:dicetable/src/ui/cafe_owner/authentication/forgot_password/widget/otp_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

class ForgotPasswordOtpScreen extends StatefulWidget {
  final String email;
  const ForgotPasswordOtpScreen({super.key,required this.email});

  @override
  State<ForgotPasswordOtpScreen> createState() => _ForgotPasswordOtpScreenState();
}

class _ForgotPasswordOtpScreenState extends State<ForgotPasswordOtpScreen> {
  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        leading: InkWell(
            onTap: () => context.pop(),
            child: SvgPicture.asset('assets/svg/back.svg', fit: BoxFit.scaleDown),
        ),
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
                  "We sent the OTP via email to hello@dicetable.app",
                  style: TextTheme.of(context).labelLarge!.copyWith(
                    fontSize: 16,
                    color: AppColors.primaryBlackColor,
                  ),
                  textAlign: TextAlign.center,
                ),
                Gap(30),
                OtpWidget(),
                Gap(60),
                InkWell(
                  onTap: () {
                    context.push('/reset_password',extra: widget.email);
                  },
                  child: ElevatedButtonWidget(
                    height: 70.h,
                    width: 377.w,
                    iconEnabled: false,
                    iconLabel: "VERIFY",
                    color: AppColors.primary,
                    textColor: AppColors.primaryWhiteColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
