import 'package:dicetable/src/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';

class PaymentMethodsCard extends StatefulWidget {
  const PaymentMethodsCard({super.key});

  @override
  State<PaymentMethodsCard> createState() => _PaymentMethodsCardState();
}

class _PaymentMethodsCardState extends State<PaymentMethodsCard> {
  bool _isExpanded = false;

  final List<Map<String, dynamic>> _paymentCards = [
    {
      'id': 1,
      'last4': '9090',
      'expDate': '06/2027',
      'isDefault': true,
    },
    {
      'id': 2,
      'last4': '3785',
      'expDate': '03/2026',
      'isDefault': false,
    },
  ];

  void _setAsDefault(int cardId) {
    setState(() {
      for (var card in _paymentCards) {
        card['isDefault'] = card['id'] == cardId;
      }
    });
  }

  void _removeCard(int cardId) {
    setState(() {
      _paymentCards.removeWhere((card) => card['id'] == cardId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          decoration: BoxDecoration(
            color: AppColors.primaryWhiteColor,
            borderRadius: BorderRadius.circular(15),
          ),
          width: double.infinity,
          child: Column(
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
                        'Payment Methods',
                        style: Theme.of(context).textTheme.labelMedium!.copyWith(
                          fontSize: 18,
                          color: AppColors.primary,
                        ),
                      ),
                      SvgPicture.asset(
                        _isExpanded
                            ? 'assets/svg/tab-arw-1.svg'
                            : 'assets/svg/tab-arw-2.svg',
                      ),
                    ],
                  ),
                ),
              ),

              AnimatedCrossFade(
                firstChild: const SizedBox.shrink(),
                secondChild: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  decoration: const BoxDecoration(
                    color: AppColors.primaryWhiteColor,
                    borderRadius: BorderRadius.vertical(
                      bottom: Radius.circular(15),
                    ),
                  ),
                  child: Column(
                    children: [
                      ConstrainedBox(
                        constraints: BoxConstraints(
                          maxHeight: constraints.maxHeight * 0.5,
                        ),
                        child: ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _paymentCards.length,
                          separatorBuilder: (_, __) => const Gap(12),
                          itemBuilder: (context, index) {
                            final card = _paymentCards[index];
                            return Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppColors.primaryWhiteColor,
                                borderRadius: BorderRadius.circular(8),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.1),
                                    spreadRadius: 1,
                                    blurRadius: 2,
                                    offset: const Offset(0, 1),
                                  ),
                                ],
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SvgPicture.asset('assets/svg/visa.svg'),
                                  const Gap(8),
                                  Expanded(
                                    flex: 2,
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Visa ending in ${card['last4']}',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall!
                                              .copyWith(
                                            fontSize: 12,
                                            color: AppColors.shadowColor,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        Text(
                                          'Exp date ${card['expDate']}',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall!
                                              .copyWith(
                                            fontSize: 12,
                                            color: AppColors.shadowColor,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        const Gap(6),
                                        Row(
                                          children: [
                                            GestureDetector(
                                              onTap: () {
                                                // Handle update card
                                              },
                                              child: Text(
                                                'Update',
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodySmall!
                                                    .copyWith(
                                                  fontSize: 12,
                                                  color: AppColors
                                                      .paymentMethodSubText,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ),
                                            const Gap(8),
                                            const Text(
                                              '|',
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: AppColors.textPrimaryGrey,
                                              ),
                                            ),
                                            const Gap(8),
                                            GestureDetector(
                                              onTap: () =>
                                                  _removeCard(card['id']),
                                              child: Text(
                                                'Remove',
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodySmall!
                                                    .copyWith(
                                                  fontSize: 12,
                                                  color: AppColors
                                                      .paymentMethodSubText,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),

                                  ),
                                  Flexible(
                                    flex: 1,
                                      child: Column(
                                          children: [
                                            const Gap(8),
                                            card['isDefault']
                                                ? Container(
                                              padding: const EdgeInsets.symmetric(
                                                  horizontal: 12, vertical: 6),
                                              decoration: BoxDecoration(
                                                color: AppColors.primaryBlackColor,
                                                borderRadius: BorderRadius.circular(7),
                                              ),
                                              child: Text(
                                                'Default',
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodySmall!
                                                    .copyWith(
                                                  fontSize: 10,
                                                  color:
                                                  AppColors.primaryWhiteColor,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            )
                                                : Container(
                                              padding: const EdgeInsets.symmetric(
                                                  horizontal: 5, vertical: 3),
                                              decoration: BoxDecoration(
                                                color: AppColors.primaryWhiteColor,
                                                borderRadius: BorderRadius.circular(7),
                                                border: Border.all(
                                                  color:
                                                  AppColors.paymentMethodSubText,
                                                ),
                                              ),
                                              child: Text(
                                                'Set as Default',
                                                textAlign: TextAlign.center,
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodySmall!
                                                    .copyWith(
                                                  fontSize: 10,
                                                  color:
                                                  AppColors.paymentMethodSubText,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ),
                                          ]
                                      )
                                  ),

                                ],
                              ),
                            );
                          },
                        ),
                      ),
                      const Gap(10),

                      Center(
                        child: ElevatedButton(
                          onPressed: () {
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: AppColors.primaryWhiteColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 25,
                              vertical: 18,
                            ),
                          ),
                          child: Text(
                            'ADD NEW CARD',
                            style: Theme.of(context).textTheme.bodySmall!.copyWith(
                              fontSize: 12,
                              color: AppColors.primaryWhiteColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
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
      },
    );
  }
}
