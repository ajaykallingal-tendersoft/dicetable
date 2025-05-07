import 'package:dicetable/src/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';

class BillingHistoryCard extends StatefulWidget {
  const BillingHistoryCard({super.key});

  @override
  State<BillingHistoryCard> createState() => _BillingHistoryCardState();
}

class _BillingHistoryCardState extends State<BillingHistoryCard> {
  bool _isExpanded = false;
  final List<Map<String, String>> _billingData = [
    {
      'date': '02/04/2025',
      'period': 'Apr 02 - Mar 01',
      'status': 'Paid',
      'amount': '\$99',
    },
    {
      'date': '01/04/2024',
      'period': 'Jan 02 - Nov 30',
      'status': 'Paid',
      'amount': '\$99',
    },
    {
      'date': '28/03/2023',
      'period': 'Mar 01 - Feb 28',
      'status': 'Paid',
      'amount': '\$99',
    },
    {
      'date': '28/03/2022',
      'period': 'Mar 01 - Feb 28',
      'status': 'Paid',
      'amount': '\$99',
    },
    {
      'date': '28/03/2021',
      'period': 'Mar 01 - Feb 28',
      'status': 'Paid',
      'amount': '\$99',
    },
  ];

  @override
  Widget build(BuildContext context) {
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
              height: 80.h,
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: _isExpanded
                    ? AppColors.subscriptionExpandHeaderColor
                    : AppColors.primaryWhiteColor,
                borderRadius: _isExpanded
                    ? const BorderRadius.only(
                  topLeft: Radius.circular(15),
                  topRight: Radius.circular(15),
                )
                    : BorderRadius.circular(15),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Billing History',
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
            AnimatedCrossFade(
              firstChild: const SizedBox.shrink(),
              secondChild: Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                decoration: const BoxDecoration(
                  color: AppColors.primaryWhiteColor,
                  borderRadius: BorderRadius.vertical(
                    bottom: Radius.circular(15),
                  ),
                ),
                child: Column(
                  children: [
                    // Table Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Expanded(
                          child: Text(
                            'DATE',
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 12,
                              color: AppColors.textPrimaryGrey,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            'PERIOD',
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 12,
                              color: AppColors.textPrimaryGrey,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            'STATUS',
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 12,
                              color: AppColors.textPrimaryGrey,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            'AMOUNT',
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 12,
                              color: AppColors.textPrimaryGrey,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Divider(color: AppColors.shadowColor,),

                    // Table Rows
                    ListView.builder(
                      itemCount: _billingData.length,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemBuilder: (context, index) {
                        final data = _billingData[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(

                                child: Text(
                                  data['date']!,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.shadowColor,
                                  ),
                                ),
                              ),
                              Expanded(

                                child: Text(
                                  data['period']!,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.shadowColor,
                                  ),
                                ),
                              ),
                              Gap(8),
                              Expanded(

                                child: Text(
                                  data['status']!,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.appGreenColor,
                                  ),
                                ),
                              ),
                              Expanded(

                                child: Text(
                                  data['amount']!,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.shadowColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              crossFadeState: _isExpanded
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
              duration: const Duration(milliseconds: 300),
            ),
        ],
      ),
    );
  }

}
