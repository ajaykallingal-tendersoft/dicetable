import 'package:dicetable/src/constants/app_colors.dart';
import 'package:dicetable/src/ui/cafe_owner/subscription/widget/billing_history_card.dart';
import 'package:dicetable/src/ui/cafe_owner/subscription/widget/payment_methods_card.dart';
import 'package:dicetable/src/ui/cafe_owner/subscription/widget/subscription_overview_card.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';


class SubscriptionOverviewScreen extends StatelessWidget {
  const SubscriptionOverviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
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
        physics: BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(26.0),
          child: Column(
            children: [
              SubscriptionOverviewCard(),
              Gap(20),
              BillingHistoryCard(),
              Gap(20),
              PaymentMethodsCard(),
              Gap(20),
            ],
          ),
        ),
      ),
    );
  }
}
