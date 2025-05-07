import 'package:dicetable/src/common/divider_with_center_text.dart';
import 'package:dicetable/src/constants/app_colors.dart';

import 'package:dicetable/src/common/elevated_button_widget.dart';
import 'package:dicetable/src/ui/category/widget/category_description_text.dart';
import 'package:dicetable/src/ui/category/widget/remember_decision.dart';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

class CategoryScreen extends StatelessWidget {
  const CategoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                              ),
                              Gap(10.h),
                              Text(
                                "Connect.",
                                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                                  color: AppColors.primaryWhiteColor,
                                  fontSize: 32.sp,
                                ),
                              ),
                              Gap(10.h),

                              FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Container(
                                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 5.h),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20.r),
                                    border: Border.all(
                                      width: 2,
                                      color: AppColors.primaryWhiteColor,
                                    ),
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
                              ),
                            ],
                          ),

                          Gap(60.h),

                          CategoryDescriptionText(
                            description: 'Connect instead of sitting Solo.',
                            subDescription: 'Solo seaters find your table?',
                          ),
                          SizedBox(height: 20.h),
                          InkWell(
                            splashColor: AppColors.secondary,
                            splashFactory: InkRipple.splashFactory,
                            onTap: () => context.go('/customer_login'),
                            child: ElevatedButtonWidget(
                              height: 70.h,
                              width: 343.w,
                              iconEnabled: true,
                              iconLabel: 'PUBLIC USER',
                              icon: SvgPicture.asset('assets/svg/arw-blue.svg'),
                              color: AppColors.primaryWhiteColor,
                              textColor: AppColors.primary,
                            ),
                          ),

                          Gap(20.h),
                          DividerWithCenterText(centerText: 'Or'),
                          Gap(20.h),


                          CategoryDescriptionText(
                            description: 'Turn your venue into a networking spot!',
                            subDescription: 'Connect solo seaters and boost business',
                          ),
                          Gap(20.h),
                          InkWell(
                            splashColor: AppColors.secondary,
                            splashFactory: InkRipple.splashFactory,
                            onTap: () => context.go('/login'),
                            child: ElevatedButtonWidget(
                              height: 70.h,
                              width: 343.w,
                              iconEnabled: true,
                              iconLabel: 'VENUE OWNER',
                              icon: SvgPicture.asset('assets/svg/arw-white.svg'),
                              color: AppColors.primary,
                              textColor: AppColors.primaryWhiteColor,
                            ),
                          ),

                          const Spacer(),
                          RememberDecisionWidget(),
                          Gap( 50.h),
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
    );
  }

}

