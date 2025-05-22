import 'package:dicetable/src/constants/app_colors.dart';
import 'package:dicetable/src/ui/cafe_owner/subscription/widget/billing_history_card.dart';
import 'package:dicetable/src/ui/cafe_owner/subscription/widget/payment_methods_card.dart';
import 'package:dicetable/src/ui/cafe_owner/subscription/widget/subscription_overview_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gap/gap.dart';

import 'bloc/subscription_bloc.dart';


class SubscriptionOverviewScreen extends StatefulWidget {
  const SubscriptionOverviewScreen({super.key});

  @override
  State<SubscriptionOverviewScreen> createState() => _SubscriptionOverviewScreenState();
}

class _SubscriptionOverviewScreenState extends State<SubscriptionOverviewScreen> {
  @override
  void initState() {
    super.initState();
    context.read<SubscriptionBloc>().add(FetchSubscriptionOverview());
  }
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
      child: BlocConsumer<SubscriptionBloc, SubscriptionState>(
        listener: (context, state) {
          if(state is SubscriptionOverviewLoading) {
            EasyLoading.show(status: '');
          }
          if(state is SubscriptionOverviewLoaded) {
            EasyLoading.dismiss();
          }
          if(state is SubscriptionOverviewError) {
            EasyLoading.dismiss();
            Fluttertoast.showToast(
              msg: "Failed to load subscription data.",
              backgroundColor: AppColors.primaryWhiteColor,
              textColor: AppColors.appRedColor,
            );
          }
        },
        builder: (context, state) {
          if (state is SubscriptionOverviewLoaded) {

            return SingleChildScrollView(
              physics: BouncingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.all(26.0),
                child: Column(
                  children: [
                    Visibility(
                      visible: state.subscriptionOverviewResponse.data!.subsriptionOverview != null,
                        child: SubscriptionOverviewCard(subsriptionOverview: state.subscriptionOverviewResponse.data?.subsriptionOverview,)),
                    Gap(20),
                    BillingHistoryCard(),
                    Gap(20),
                    PaymentMethodsCard(),
                    Gap(20),
                  ],
                ),
              ),
            );
          }
          if (state is SubscriptionOverviewError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Something went wrong.",
                    style: TextStyle(color: AppColors.appRedColor),
                  ),
                  SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () {
                      context.read<SubscriptionBloc>().add(FetchSubscriptionOverview());
                    },
                    child: Text("Retry"),
                  ),
                ],
              ),
            );
          }

          // Show empty container or shimmer/loading widget if needed
          return SizedBox.shrink();
        },
      ),
    );
  }
}
