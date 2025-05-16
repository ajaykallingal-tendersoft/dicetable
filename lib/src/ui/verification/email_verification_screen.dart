import 'package:dicetable/src/common/elevated_button_widget.dart';
import 'package:dicetable/src/common/otp_widget.dart';
import 'package:dicetable/src/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';


class EmailVerificationScreen extends StatelessWidget {
  const EmailVerificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        leading: SizedBox(),
        title: Text(
          'Dice app',
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
                  "We have sent the verification code via email to hello@dicetable.app",
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
