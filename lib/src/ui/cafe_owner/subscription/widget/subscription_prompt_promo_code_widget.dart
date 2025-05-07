import 'package:dicetable/src/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SubscriptionPromptPromoCodeWidget extends StatelessWidget {
  const SubscriptionPromptPromoCodeWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView( // Added SingleChildScrollView for small screens
      child: Container(
        padding: const EdgeInsets.all(0),
        decoration: BoxDecoration(
          color: AppColors.primaryWhiteColor,
          borderRadius: BorderRadius.circular(15.r), // Using .r for responsive radius
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              offset: Offset(0, 1),
              blurRadius: 4.0,
              spreadRadius: 1.0,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min, // Important for fitting content
          children: [
            Flexible(
              flex: 2,
              child: Padding(
                padding: EdgeInsets.all(30.0.r), // Using .r for responsive padding
                child: Column(
                  mainAxisSize: MainAxisSize.min, // Ensure inner Column doesn't take infinite space
                  children: [
                    Text(
                      'Start With A Free 3-Month Trial,\nThen \$99 Per Year!',
                      textAlign: TextAlign.center,
                      style: TextTheme.of(context).labelMedium!.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 18.sp // Using .sp for responsive font size
                      ),
                    ),
                    SizedBox(height: 10.h), // Using .h for responsive height
                    Text(
                      'Enjoy all premium features for 3 months,\nabsolutely free!',
                      textAlign: TextAlign.center,
                      style: TextTheme.of(context).bodySmall!.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w500,
                          fontSize: 12.sp // Using .sp for responsive font size
                      ),
                    ),
                    SizedBox(height: 20.h), // Using .h for responsive height
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: 'Promo Code: ',
                            style: TextTheme.of(context).bodyMedium!.copyWith(
                              color: AppColors.tertiary,
                              fontWeight: FontWeight.w700,
                              fontSize: 14.sp, // Using .sp for responsive font size
                            ),
                          ),
                          TextSpan(
                            text: 'E23FTU6',
                            style: TextTheme.of(context).bodyMedium!.copyWith(
                              color: AppColors.tertiary,
                              fontWeight: FontWeight.w700,
                              fontSize: 14.sp, // Using .sp for responsive font size
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 10.h), // Using .h for responsive height
                    TextField(
                      style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                        color: AppColors.hintColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 14.sp, // Using .sp for responsive font size
                      ),
                      decoration: InputDecoration(
                        hintText: 'Enter Promo Code',
                        hintStyle: TextStyle(
                          color: AppColors.textPrimaryGrey,
                          fontWeight: FontWeight.w600,
                          fontSize: 14.sp, // Using .sp for responsive font size
                        ),
                        contentPadding: EdgeInsets.symmetric(horizontal: 16.w), // Using .w for responsive width
                        border: OutlineInputBorder(
                          borderSide: BorderSide(color: AppColors.borderColor1),
                          borderRadius: BorderRadius.circular(10.r), // Using .r for responsive radius
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: AppColors.borderColor1),
                          borderRadius: BorderRadius.circular(10.r), // Using .r for responsive radius
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: AppColors.borderColor1),
                          borderRadius: BorderRadius.circular(10.r), // Using .r for responsive radius
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
            Flexible(
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.all(20.r), // Using .r for responsive padding
                decoration: BoxDecoration(
                  color: AppColors.subscriptionPromptSubColor,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(20.r), // Using .r for responsive radius
                    bottomRight: Radius.circular(20.r), // Using .r for responsive radius
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min, // Ensure inner Column doesn't take infinite space
                  children: [
                    Text(
                      'Continue After Trial',
                      style: TextTheme.of(context).bodyMedium!.copyWith(
                        decoration: TextDecoration.underline,
                        decorationColor: AppColors.textPrimaryGrey,
                        color: AppColors.timeTextColor,
                        fontWeight: FontWeight.w500,
                        fontSize: 12.sp, // Using .sp for responsive font size
                      ),
                    ),
                    SizedBox(height: 5.h), // Using .h for responsive height
                    Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: '\$99',
                            style: TextTheme.of(context).bodyLarge!.copyWith(
                              color: AppColors.primary,
                              fontSize: 24.sp, // Making the price more prominent responsively
                            ),
                          ),
                          TextSpan(
                            text: ' / Year',
                            style: TextTheme.of(context).bodyMedium!.copyWith(
                              color: AppColors.subscriptionPriceSubColor,
                              fontWeight: FontWeight.w600,
                              fontSize: 14.sp, // Using .sp for responsive font size
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 5.h), // Using .h for responsive height
                    Text(
                      'Get all the benefits for just \$99 per year.',
                      textAlign: TextAlign.center,
                      style: TextTheme.of(context).bodyMedium!.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                        fontSize: 12.sp, // Using .sp for responsive font size
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
