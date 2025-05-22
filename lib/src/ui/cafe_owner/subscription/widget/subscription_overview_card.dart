import 'package:dicetable/src/constants/app_colors.dart';
import 'package:dicetable/src/model/cafe_owner/subscription/subscription_overview_response.dart';
import 'package:dicetable/src/ui/cafe_owner/authentication/sign_up/widget/custom_switch.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';

class SubscriptionOverviewCard extends StatefulWidget {
  final SubsriptionOverview? subsriptionOverview;
  const SubscriptionOverviewCard({super.key,required this.subsriptionOverview});

  @override
  State<SubscriptionOverviewCard> createState() =>
      _SubscriptionOverviewCardState();
}

class _SubscriptionOverviewCardState extends State<SubscriptionOverviewCard> {
  bool _isExpanded = false;
  bool isAutoRenewOn = true;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,

      decoration: BoxDecoration(
        color:  AppColors.primaryWhiteColor,
        borderRadius: BorderRadius.circular(15),
      ),
      width: double.infinity,
      // Remove maxHeight here if not needed
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min, // Avoid overflow
        children: [
          GestureDetector(
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            child: Container(
              height: 80.h,
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 16,vertical: 10),
              decoration: BoxDecoration(
                color: _isExpanded ? AppColors.subscriptionExpandHeaderColor : AppColors.primaryWhiteColor,
                borderRadius:  _isExpanded 
                    ? BorderRadius.only(topLeft: Radius.circular(15),topRight: Radius.circular(15)) :
                BorderRadius.circular(15),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Subscription Overview',
                    style: TextTheme.of(context).labelMedium!.copyWith(
                      fontSize: 18,
                      color: AppColors.primary,
                    ),
                  ),
                  _isExpanded
                      ?  SvgPicture.asset('assets/svg/tab-arw-1.svg')
                      : SvgPicture.asset('assets/svg/tab-arw-2.svg')
                ],
              ),
            ),
          ),
          if (_isExpanded) const Gap(10),
          if (_isExpanded)
            SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16,vertical: 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Gap(30),
                    Text(
                      'Status: ${widget.subsriptionOverview?.status}',
                      style: TextTheme.of(
                        context,
                      ).bodySmall!.copyWith(color: AppColors.appGreenColor),
                    ),
                    Gap(15),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 6,
                      ),
                      height: 42.h,
                      width: 237.w,
                      decoration: BoxDecoration(
                        color: AppColors.premiumPlanColor,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            'assets/png/premium-plan.png',
                            fit: BoxFit.scaleDown,
                          ),
                          Gap(10),
                          Text(
                            widget.subsriptionOverview!.planName!,
                            style: TextTheme.of(context).bodyMedium!.copyWith(
                              color: AppColors.premiumPlanTextColor,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Gap(15),
                    Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: '\$${widget.subsriptionOverview?.amount}',
                            style: TextTheme.of(context).bodyLarge!.copyWith(
                              color: AppColors.primary,
                              fontSize:
                                  24.sp, // Making the price more prominent responsively
                            ),
                          ),
                          TextSpan(
                            text: ' / ${widget.subsriptionOverview?.duration}',
                            style: TextTheme.of(context).bodyMedium!.copyWith(
                              color: AppColors.subscriptionPriceSubColor,
                              fontWeight: FontWeight.w600,
                              fontSize:
                                  14.sp, // Using .sp for responsive font size
                            ),
                          ),
                        ],
                      ),
                    ),
                    Gap(10),
                    Text(
                      'Expires On ${widget.subsriptionOverview?.expiryDate}',
                      style: TextTheme.of(context).bodyMedium!.copyWith(
                        color: AppColors.timeTextColor,
                        fontWeight: FontWeight.w500,
                        fontSize: 12.sp, // Using .sp for responsive font size
                      ),
                    ),
                    Gap(10),
                    DottedBorder(
                      borderType: BorderType.RRect,
                      radius: const Radius.circular(8),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      dashPattern: [6, 4],
                      child: RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: 'Discount Code: ',
                              style: TextTheme.of(context).bodyMedium!.copyWith(
                                color: AppColors.discountTextColor,
                                fontWeight: FontWeight.w700,
                                fontSize: 14.sp,
                              ),
                            ),
                            TextSpan(
                              text: widget.subsriptionOverview?.discountCode,
                              style: TextTheme.of(context).bodyMedium!.copyWith(
                                color: AppColors.disabledColor,
                                fontWeight: FontWeight.w700,
                                fontSize: 14.sp,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Gap(20),
                    // Row(
                    //   mainAxisAlignment: MainAxisAlignment.center,
                    //   children: [
                    //     CustomSwitch(
                    //       value: isAutoRenewOn,
                    //       onChanged: (val) {
                    //         setState(() {
                    //           isAutoRenewOn = val;
                    //         });
                    //       },
                    //     ),
                    //     Gap(10),
                    //     Text(
                    //       isAutoRenewOn
                    //           ? "Turn off Auto Renewal"
                    //           : "Turn on Auto Renewal",
                    //       style: const TextStyle(
                    //         fontWeight: FontWeight.w600,
                    //         fontSize: 16,
                    //         color: Color(
                    //           0xFF003B63,
                    //         ), // Deep blue from your screenshot
                    //       ),
                    //     ),
                    //   ],
                    // ),
                    Gap(20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            fixedSize: Size(125.w, 37.h),
                          ),
                          child: Text(
                            'RENEW NOW',
                            textAlign: TextAlign.left,
                            style: TextTheme.of(context).bodyMedium!.copyWith(
                              color: AppColors.primaryWhiteColor,
                              fontWeight: FontWeight.w600,
                              fontSize: 11.sp,
                            ),
                          ),
                        ),
                        // Gap(10),
                        OutlinedButton(
                          style: OutlinedButton.styleFrom(

                            fixedSize: Size(125.w, 37.h),
                          ),
                          onPressed: () {},
                          child: Text(
                            'CANCEL',
                            style: TextTheme.of(context).bodyMedium!.copyWith(
                              color: AppColors.discountTextColor,
                              fontWeight: FontWeight.w600,
                              fontSize: 11.sp,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Gap(20),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
