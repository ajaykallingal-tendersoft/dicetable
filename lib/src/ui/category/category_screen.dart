import 'dart:io';

import 'package:dicetable/src/common/divider_with_center_text.dart';
import 'package:dicetable/src/constants/app_colors.dart';
import 'package:dicetable/src/common/elevated_button_widget.dart';
import 'package:dicetable/src/ui/category/widget/category_description_text.dart';
import 'package:dicetable/src/ui/category/widget/remember_decision.dart';
import 'package:dicetable/src/utils/data/object_factory.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

class CategoryScreen extends StatefulWidget {

   const CategoryScreen({super.key});

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  bool rememberDecision = false;
  DateTime? currentBackPressTime;

  Future<bool> onWillPop() {
    DateTime now = DateTime.now();
    if (currentBackPressTime == null ||
        now.difference(currentBackPressTime!) > const Duration(seconds: 3)) {
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

  void _onCategoryTap(String userType) {
    if (rememberDecision) {
      ObjectFactory().prefs.setUserDecisionName(userDecision: userType);
      ObjectFactory().prefs.setRememberDecision(true);
    } else {
      ObjectFactory().prefs.setRememberDecision(false);
      ObjectFactory().prefs.setUserDecisionName(userDecision: "");
    }

    // Set navigation source to track where we're coming from
    ObjectFactory().prefs.setNavigationSource('category_screen');

    if (userType == 'PUBLIC_USER') {
      context.go('/customer_login');
    } else {
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: onWillPop,
      child: Scaffold(
        body: SizedBox.expand(
          child: DecoratedBox(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/png/landing-bg.png'),
                fit: BoxFit.cover,
              ),
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 0.1.sw),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(minHeight: constraints.maxHeight),
                      child: IntrinsicHeight(
                        child: Column(
                          children: [
                            Gap(90.h),
                            Column(
                              children: [
                                Text(
                                  "Meet.",
                                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                                    color: AppColors.primaryWhiteColor,
                                    fontSize: 32.sp,
                                  ),
                                ).animate().fadeIn(duration: 600.ms).slideY(begin: -0.3, curve: Curves.easeOut),

                                Gap(10.h),

                                Text(
                                  "Connect.",
                                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                                    color: AppColors.primaryWhiteColor,
                                    fontSize: 32.sp,
                                  ),
                                ).animate().fadeIn(duration: 600.ms).slideY(begin: -0.2, delay: 400.ms, curve: Curves.easeOut),

                                Gap(10.h),

                                FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Container(
                                    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 5.h),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(20.r),
                                      border: Border.all(width: 2, color: AppColors.primaryWhiteColor),
                                      color: Colors.transparent,
                                    ),
                                    child: Text(
                                      "Network.",
                                      style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                                        color: AppColors.primaryWhiteColor,
                                        fontSize: 32.sp,
                                      ),
                                    ),
                                  ),
                                ).animate().fadeIn(duration: 600.ms).slideY(begin: -0.1, delay: 500.ms),
                              ],
                            ),
                            Gap(60.h),
                            CategoryDescriptionText(
                              description: 'Connect instead of sitting Solo.',
                              subDescription: 'Solo seaters find your table?',
                            ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.2),
                            SizedBox(height: 20.h),
                            InkWell(
                              splashColor: AppColors.secondary,
                              splashFactory: InkRipple.splashFactory,
                              onTap: () => _onCategoryTap('PUBLIC_USER'),
                              child: ElevatedButtonWidget(
                                height: 70.h,
                                width: 343.w,
                                iconEnabled: true,
                                iconLabel: 'PUBLIC USER',
                                icon: SvgPicture.asset('assets/svg/arw-blue.svg'),
                                color: AppColors.primaryWhiteColor,
                                textColor: AppColors.primary,
                              ),
                            ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.3, delay: 100.ms),

                            Gap(20.h),
                            DividerWithCenterText(centerText: 'Or')
                                .animate().fadeIn(duration: 400.ms).scale(delay: 200.ms),
                            Gap(20.h),
                            CategoryDescriptionText(
                              description: 'Turn your venue into a networking spot!',
                              subDescription: 'Connect solo seaters and boost business',
                            ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.2),
                            Gap(20.h),
                            InkWell(
                              splashColor: AppColors.secondary,
                              splashFactory: InkRipple.splashFactory,
                              onTap: () => _onCategoryTap('VENUE_OWNER'),
                              child: ElevatedButtonWidget(
                                height: 70.h,
                                width: 343.w,
                                iconEnabled: true,
                                iconLabel: 'VENUE OWNER',
                                icon: SvgPicture.asset('assets/svg/arw-white.svg'),
                                color: AppColors.primary,
                                textColor: AppColors.primaryWhiteColor,
                              ),
                            ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.3, delay: 150.ms),
                            const Spacer(),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Checkbox(
                                  value: rememberDecision,
                                  onChanged: (value) {
                                    setState(() {
                                      rememberDecision = value ?? false;
                                    });
                                  },
                                ),
                                const Text(
                                  "Remember this decision",
                                  style: TextStyle(color: Colors.white),
                                ),
                              ],
                            ),
                            Gap(50.h),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

