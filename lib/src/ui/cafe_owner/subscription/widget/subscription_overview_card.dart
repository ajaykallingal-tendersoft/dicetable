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
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:soloseaters/src/purchase/bloc/bloc/purchase_bloc.dart';
import 'package:soloseaters/src/purchase/bloc/bloc/purchase_state.dart';
import 'package:intl/intl.dart';

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
    return BlocBuilder<PaymentPlanBloc, PaymentPlanState>(
      builder: (context, paymentState) {
        // Extract subscription data from PaymentPlanState
        final isActive = paymentState.canAccessPremiumFeatures;
        final status = isActive ? 'Active' : 'Expired';
        final statusColor = isActive ? AppColors.appGreenColor : Colors.red;

        // Get plan name from user type
        String planName = 'Free Plan';
        if (paymentState.userType == UserType.venuePaid) {
          planName = 'Venue Premium Plan';
        } else if (paymentState.userType == UserType.publicPaid) {
          planName = 'Public Premium Plan';
        } else if (paymentState.userType == UserType.venueTrial) {
          planName = 'Venue Trial';
        }

        // Format expiry date
        String expiryDate = 'N/A';
        if (paymentState.subscriptionExpiryDate != null) {
          expiryDate = DateFormat(
            'MMM dd, yyyy',
          ).format(paymentState.subscriptionExpiryDate!);
        } else if (paymentState.trialEndDate != null) {
          expiryDate = DateFormat(
            'MMM dd, yyyy',
          ).format(paymentState.trialEndDate!);
        }

        // Get amount from selected product (fallback to widget data)
        String amount = widget.subsriptionOverview?.amount ?? '100';
        String duration = widget.subsriptionOverview?.duration ?? 'year';

        // If we have a selected product, extract price from it
        if (paymentState.expandedProducts != null &&
            paymentState.expandedProducts!.isNotEmpty) {
          final selectedProduct = paymentState.expandedProducts!.first;
          final formattedPrice = selectedProduct['formattedPrice'] as String?;
          if (formattedPrice != null) {
            amount = formattedPrice.replaceAll(RegExp(r'[^\d.]'), '');
          }
        }

        return LayoutBuilder(
          builder: (context, constraints) {
            // Get actual available space and device pixel ratio
            final availableWidth = constraints.maxWidth;
            final mediaQuery = MediaQuery.of(context);
            final screenWidth = mediaQuery.size.width;
            final screenHeight = mediaQuery.size.height;
            final textScaleFactor = mediaQuery.textScaler.scale(1.0);

            // Truly responsive calculations based on available space
            final basePadding = availableWidth * 0.04;
            final headerHeight = (screenHeight * 0.08).clamp(60.0, 100.0);
            final buttonHeight = (screenHeight * 0.05).clamp(35.0, 60.0);
            final containerWidth = (availableWidth * 0.65).clamp(180.0, 300.0);
            final containerHeight = (screenHeight * 0.06).clamp(40.0, 70.0);

            // Font sizes that scale with both screen size and text scale factor
            final baseFontScale = (screenWidth / 375.0).clamp(0.8, 1.5);

            double getScaledFontSize(double baseSize) {
              return (baseSize * baseFontScale * textScaleFactor).clamp(
                baseSize * 0.7,
                baseSize * 2.0,
              );
            }

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
                      height: headerHeight,
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(
                        horizontal: basePadding,
                        vertical: basePadding * 0.5,
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
                          Expanded(
                            child: AutoSizeText(
                              'Subscription Overview',
                              style: GoogleFonts.montserrat(
                                fontSize: getScaledFontSize(18),
                                color: AppColors.primary,
                                fontWeight: FontWeight.w700,
                              ),
                              maxLines: 2,
                              minFontSize: 12,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          SizedBox(width: basePadding * 0.5),
                          Icon(
                            _isExpanded
                                ? Icons.keyboard_arrow_up
                                : Icons.keyboard_arrow_down,
                            color: AppColors.primary,
                            size: getScaledFontSize(24),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (_isExpanded) SizedBox(height: basePadding * 0.5),
                  if (_isExpanded)
                    SingleChildScrollView(
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: basePadding,
                          vertical: 0,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            SizedBox(height: basePadding * 1.5),
                            AutoSizeText(
                              'Status: $status',
                              style: Theme.of(
                                context,
                              ).textTheme.bodySmall!.copyWith(
                                color: statusColor,
                                fontSize: getScaledFontSize(14),
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 1,
                              minFontSize: 10,
                            ),
                            SizedBox(height: basePadding * 0.75),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: basePadding * 0.8,
                                vertical: basePadding * 0.5,
                              ),
                              height: containerHeight,
                              width: containerWidth,
                              decoration: BoxDecoration(
                                color: AppColors.premiumPlanColor,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Flexible(
                                    flex: 1,
                                    child: Image.asset(
                                      'assets/png/premium-plan.png',
                                      fit: BoxFit.contain,
                                      height: containerHeight * 0.6,
                                    ),
                                  ),
                                  SizedBox(width: basePadding * 0.3),
                                  Flexible(
                                    flex: 3,
                                    child: AutoSizeText(
                                      planName,
                                      style: Theme.of(
                                        context,
                                      ).textTheme.bodyMedium!.copyWith(
                                        color: AppColors.premiumPlanTextColor,
                                        fontSize: getScaledFontSize(16),
                                        fontWeight: FontWeight.w600,
                                      ),
                                      maxLines: 2,
                                      minFontSize: 10,
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: basePadding * 0.75),
                            AutoSizeText.rich(
                              TextSpan(
                                children: [
                                  TextSpan(
                                    text: '\$$amount',
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodyLarge!.copyWith(
                                      color: AppColors.primary,
                                      fontSize: getScaledFontSize(24),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  TextSpan(
                                    text: ' / $duration',
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodyMedium!.copyWith(
                                      color:
                                          AppColors.subscriptionPriceSubColor,
                                      fontWeight: FontWeight.w600,
                                      fontSize: getScaledFontSize(14),
                                    ),
                                  ),
                                ],
                              ),
                              maxLines: 1,
                              minFontSize: 12,
                            ),
                            SizedBox(height: basePadding * 0.5),
                            AutoSizeText(
                              'Expires On $expiryDate',
                              style: Theme.of(
                                context,
                              ).textTheme.bodyMedium!.copyWith(
                                color: AppColors.timeTextColor,
                                fontWeight: FontWeight.w500,
                                fontSize: getScaledFontSize(12),
                              ),
                              maxLines: 1,
                              minFontSize: 8,
                            ),
                            SizedBox(height: basePadding * 0.5),
                            Container(
                              width: double.infinity,
                              padding: EdgeInsets.symmetric(
                                horizontal: basePadding * 2,
                              ),
                              child: DottedBorder(
                                child: Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: basePadding * 0.6,
                                    vertical: basePadding * 0.4,
                                  ),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Text(
                                        'Discount Code: ',
                                        style: Theme.of(
                                          context,
                                        ).textTheme.bodyMedium?.copyWith(
                                          color: AppColors.discountTextColor,
                                          fontWeight: FontWeight.w700,
                                          fontSize: getScaledFontSize(14),
                                        ),
                                      ),
                                      SizedBox(width: basePadding * 0.2),
                                      Expanded(
                                        child: TextFormField(
                                          controller: _discountController,
                                          decoration: InputDecoration(
                                            isDense: true,
                                            contentPadding:
                                                EdgeInsets.symmetric(
                                                  vertical: basePadding * 0.2,
                                                  horizontal: basePadding * 0.1,
                                                ),
                                            border: InputBorder.none,
                                            hintText: 'Enter code',
                                            hintStyle: TextStyle(
                                              color: Colors.grey,
                                              fontSize: getScaledFontSize(14),
                                            ),
                                          ),
                                          style: Theme.of(
                                            context,
                                          ).textTheme.bodyMedium?.copyWith(
                                            fontWeight: FontWeight.normal,
                                            fontSize: getScaledFontSize(14),
                                            color: AppColors.textPrimaryGrey,
                                          ),
                                          keyboardType: TextInputType.text,
                                          textInputAction: TextInputAction.done,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: basePadding * 1.2),
                            LayoutBuilder(
                              builder: (context, buttonConstraints) {
                                final availableButtonWidth =
                                    (buttonConstraints.maxWidth - basePadding) /
                                    2;
                                final finalButtonWidth = availableButtonWidth
                                    .clamp(80.0, 150.0);

                                return Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    SizedBox(
                                      width: finalButtonWidth,
                                      height: buttonHeight,
                                      child: ElevatedButton(
                                        onPressed: () {
                                          showDialog(
                                            context: context,
                                            builder: (BuildContext context) {
                                              return AlertDialog(
                                                title: Text(
                                                  'Feature Unavailable',
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .titleMedium!
                                                      .copyWith(
                                                        color:
                                                            AppColors.primary,
                                                        fontSize: 16.sp,
                                                      ),
                                                ),
                                                content: Text(
                                                  'This feature is coming in a future update.',
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .bodyMedium!
                                                      .copyWith(
                                                        color:
                                                            AppColors
                                                                .textPrimaryGrey,
                                                        fontSize: 14.sp,
                                                      ),
                                                ),
                                                actions: [
                                                  TextButton(
                                                    onPressed: () {
                                                      Navigator.of(
                                                        context,
                                                      ).pop();
                                                    },
                                                    child: Text(
                                                      'OK',
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .bodyMedium!
                                                          .copyWith(
                                                            color:
                                                                AppColors
                                                                    .primary,
                                                            fontSize: 14.sp,
                                                          ),
                                                    ),
                                                  ),
                                                ],
                                              );
                                            },
                                          );
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: AppColors.primary,
                                          padding: EdgeInsets.symmetric(
                                            vertical: basePadding * 0.3,
                                            horizontal: basePadding * 0.2,
                                          ),
                                        ),
                                        child: FittedBox(
                                          fit: BoxFit.scaleDown,
                                          child: Text(
                                            'RENEW NOW',
                                            textAlign: TextAlign.center,
                                            style: Theme.of(
                                              context,
                                            ).textTheme.bodyMedium!.copyWith(
                                              color:
                                                  AppColors.primaryWhiteColor,
                                              fontWeight: FontWeight.w600,
                                              fontSize: getScaledFontSize(12),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: basePadding * 0.5),
                                    SizedBox(
                                      width: finalButtonWidth,
                                      height: buttonHeight,
                                      child: OutlinedButton(
                                        onPressed: () {},
                                        style: OutlinedButton.styleFrom(
                                          padding: EdgeInsets.symmetric(
                                            vertical: basePadding * 0.3,
                                            horizontal: basePadding * 0.2,
                                          ),
                                        ),
                                        child: FittedBox(
                                          fit: BoxFit.scaleDown,
                                          child: Text(
                                            'CANCEL',
                                            style: Theme.of(
                                              context,
                                            ).textTheme.bodyMedium!.copyWith(
                                              color:
                                                  AppColors.discountTextColor,
                                              fontWeight: FontWeight.w600,
                                              fontSize: getScaledFontSize(12),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                            SizedBox(height: basePadding),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
