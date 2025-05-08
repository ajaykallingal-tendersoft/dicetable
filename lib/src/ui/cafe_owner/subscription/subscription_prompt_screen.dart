import 'dart:io';

import 'package:dicetable/src/common/elevated_button_widget.dart';
import 'package:dicetable/src/constants/app_colors.dart';
import 'package:dicetable/src/ui/cafe_owner/subscription/widget/subscription_prompt_promo_code_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

class SubscriptionPromptScreen extends StatelessWidget {

  const SubscriptionPromptScreen({super.key});

  Future<bool> onWillPop() {
    DateTime? currentBackPressTime;
    DateTime now = DateTime.now();
    if (currentBackPressTime == null ||
        now.difference(currentBackPressTime) > const Duration(seconds: 3)) {
      currentBackPressTime = now;
      Fluttertoast.showToast(
        backgroundColor: AppColors.secondary,
        textColor: AppColors.primaryWhiteColor,
        gravity: ToastGravity.BOTTOM,
        msg: "Press again to exit",
      );
      return Future.value(false);
    }
    SystemNavigator.pop();
    return Future.value(true);

  }

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
                  height: 123,
                  width: 123,
                )
                    .animate()
                    .scale(
                  begin: const Offset(0.7, 0.7),
                  end: const Offset(1, 1),
                  duration: 500.ms,
                  curve: Curves.easeOutBack,
                )

                    .shake(
                  hz: 4,
                  duration: 400.ms,
                  delay: 500.ms,
                  curve: Curves.easeInOut,
                )
                    .fadeIn(duration: 400.ms),

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
                ).animate()
                    .fadeIn(duration: 450.ms)
                    .slideY(begin: 0.2, delay: 600.ms),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

