import 'package:dicetable/src/common/elevated_button_widget.dart';
import 'package:dicetable/src/constants/app_colors.dart';
import 'package:dicetable/src/ui/cafe_owner/subscription/widget/subscription_prompt_promo_code_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

class SubscriptionPromptScreen extends StatelessWidget {
  const SubscriptionPromptScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.primary,
              AppColors.primary,
              AppColors.secondary,
              AppColors.tertiary,
            ],
            stops: [0.0, 0.5, 0.75, 1.0],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 26,vertical: 20),
            child: Column(
              children: [
                Gap(30),
                SvgPicture.asset(
                  'assets/svg/free-icon.svg',
                  height: 123.h,
                  width: 123.w,
                ),
                Gap(30),
                SubscriptionPromptPromoCodeWidget(),
                Gap(30),
                InkWell(
                  splashColor: AppColors.secondary,
                  splashFactory: InkRipple.splashFactory,
                  onTap: () => context.go('/home'),
                  child: ElevatedButtonWidget(
                      height: 70.h,
                      width: double.infinity,
                      iconEnabled: false,
                      iconLabel: "START FREE TRAIL",
                      color: AppColors.primary,
                      textColor: AppColors.primaryWhiteColor,
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

