import 'package:auto_size_text/auto_size_text.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:soloseaters/src/constants/app_colors.dart';
import 'package:soloseaters/src/model/cafe_owner/subscription/subscription_overview_response.dart';
import 'package:soloseaters/src/ui/cafe_owner/authentication/sign_up/widget/custom_switch.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';

class SubscriptionOverviewCard extends StatefulWidget {
  final SubsriptionOverview? subsriptionOverview;

  const SubscriptionOverviewCard({
    super.key,
    required this.subsriptionOverview,
  });

  @override
  State<SubscriptionOverviewCard> createState() =>
      _SubscriptionOverviewCardState();
}

class _SubscriptionOverviewCardState extends State<SubscriptionOverviewCard> {
  bool _isExpanded = false;
  bool isAutoRenewOn = true;
  final TextEditingController _discountController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Calculate responsive dimensions based on available width
        final double cardPadding = constraints.maxWidth * 0.04; // 4% of width
        final double headerHeight =
            constraints.maxHeight * 0.1; // 10% of height
        final double buttonWidth = constraints.maxWidth * 0.4; // 30% of width
        final double buttonHeight =
            constraints.maxHeight * 0.05; // 5% of height
        final double containerWidth =
            constraints.maxWidth * 0.6; // 60% of width
        final double containerHeight =
            constraints.maxHeight * 0.06; // 6% of height
        final double fontScale =
            constraints.maxWidth / 360; // Base width for scaling

        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          decoration: BoxDecoration(
            color: AppColors.primaryWhiteColor,
            borderRadius: BorderRadius.circular(15),
          ),
          width: double.infinity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(
                onTap: () => setState(() => _isExpanded = !_isExpanded),
                child: Container(
                  height: headerHeight.clamp(60, 80.h),
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(
                    horizontal: cardPadding,
                    vertical: cardPadding * 0.5,
                  ),
                  decoration: BoxDecoration(
                    color:
                        _isExpanded
                            ? AppColors.subscriptionExpandHeaderColor
                            : AppColors.primaryWhiteColor,
                    borderRadius:
                        _isExpanded
                            ? BorderRadius.only(
                              topLeft: Radius.circular(15),
                              topRight: Radius.circular(15),
                            )
                            : BorderRadius.circular(15),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      AutoSizeText(
                        'Subscription Overview',
                        style: GoogleFonts.montserrat(
                        fontSize: 18.sp,
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700
                        )
                      
                      ),
                      _isExpanded
                          ? SvgPicture.asset('assets/svg/tab-arw-1.svg')
                          : SvgPicture.asset('assets/svg/tab-arw-2.svg'),
                    ],
                  ),
                ),
              ),
              if (_isExpanded) Gap(cardPadding * 0.5),
              if (_isExpanded)
                SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: cardPadding,
                      vertical: 0,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Gap(cardPadding * 1.5),
                        Text(
                          'Status: ${widget.subsriptionOverview?.status}',
                          style: Theme.of(
                            context,
                          ).textTheme.bodySmall!.copyWith(
                            color: AppColors.appGreenColor,
                            fontSize: (14 * fontScale).sp,
                          ),
                        ),
                        Gap(cardPadding * 0.75),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: cardPadding,
                            vertical: cardPadding * 0.3,
                          ),
                          height: containerHeight.clamp(36, 42.h),
                          width: containerWidth.clamp(200, 237.w),
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
                              Gap(cardPadding * 0.5),
                              Text(
                                widget.subsriptionOverview!.planName!,
                                style: Theme.of(
                                  context,
                                ).textTheme.bodyMedium!.copyWith(
                                  color: AppColors.premiumPlanTextColor,
                                  fontSize: (16 * fontScale).sp,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Gap(cardPadding * 0.75),
                        Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(
                                text: '\$${widget.subsriptionOverview?.amount}',
                                style: Theme.of(
                                  context,
                                ).textTheme.bodyLarge!.copyWith(
                                  color: AppColors.primary,
                                  fontSize: (24 * fontScale).sp,
                                ),
                              ),
                              TextSpan(
                                text:
                                    ' / ${widget.subsriptionOverview?.duration}',
                                style: Theme.of(
                                  context,
                                ).textTheme.bodyMedium!.copyWith(
                                  color: AppColors.subscriptionPriceSubColor,
                                  fontWeight: FontWeight.w600,
                                  fontSize: (14 * fontScale).sp,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Gap(cardPadding * 0.5),
                        Text(
                          'Expires On ${widget.subsriptionOverview?.expiryDate}',
                          style: Theme.of(
                            context,
                          ).textTheme.bodyMedium!.copyWith(
                            color: AppColors.timeTextColor,
                            fontWeight: FontWeight.w500,
                            fontSize: (12 * fontScale).sp,
                          ),
                        ),
                        Gap(cardPadding * 0.5),
                        Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: cardPadding * 3.5,
                          ),
                          child: DottedBorder(
                            borderType: BorderType.RRect,
                            radius: const Radius.circular(8),
                            padding: EdgeInsets.symmetric(
                              horizontal: cardPadding * 0.9,
                              vertical: cardPadding * 0.4,
                            ),
                            dashPattern: const [6, 4],
                            child: Row(
                              children: [
                                AutoSizeText(
                                  'Discount Code: ',
                                  style: Theme.of(
                                    context,
                                  ).textTheme.bodyMedium?.copyWith(
                                    color: AppColors.discountTextColor,
                                    fontWeight: FontWeight.w700,
                                    fontSize: (14 * fontScale).sp,
                                  ),
                                ),
                                SizedBox(width: cardPadding * 0.1),
                                Expanded(
                                  child: TextFormField(
                                    controller: _discountController,
                                    decoration: const InputDecoration(
                                      isDense: true,
                                      contentPadding: EdgeInsets.zero,
                                      border: InputBorder.none,
                                      hintText: 'Enter code',
                                      hintStyle: TextStyle(color: Colors.grey),
                                    ),
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodyMedium?.copyWith(
                                      fontWeight: FontWeight.normal,
                                      fontSize: (14 * fontScale).sp,
                                      color: AppColors.textPrimaryGrey,
                                    ),
                                    keyboardType: TextInputType.text,
                                    textInputAction: TextInputAction.done,
                                    onFieldSubmitted: (value) {
                                      // Handle submission if needed
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Gap(cardPadding),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            ElevatedButton(
                              onPressed: () {},
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                fixedSize: Size(
                                  buttonWidth,
                                  buttonHeight.clamp(30, 37.h),
                                ),
                              ),
                              child: Text(
                                'RENEW NOW',
                                textAlign: TextAlign.left,
                                style: Theme.of(
                                  context,
                                ).textTheme.bodyMedium!.copyWith(
                                  color: AppColors.primaryWhiteColor,
                                  fontWeight: FontWeight.w600,
                                  fontSize: (12 * fontScale).sp,
                                ),
                              ),
                            ),
                            OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                fixedSize: Size(
                                  buttonWidth,
                                  buttonHeight.clamp(30, 37.h),
                                ),
                              ),
                              onPressed: () {},
                              child: Text(
                                'CANCEL',
                                style: Theme.of(
                                  context,
                                ).textTheme.bodyMedium!.copyWith(
                                  color: AppColors.discountTextColor,
                                  fontWeight: FontWeight.w600,
                                  fontSize: (12 * fontScale).sp,
                                ),
                              ),
                            ),
                          ],
                        ),
                        Gap(cardPadding),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
