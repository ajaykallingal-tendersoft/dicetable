import 'package:dicetable/src/constants/app_colors.dart';
import 'package:dicetable/src/ui/cafe_owner/subscription/widget/billing_history_card.dart';
import 'package:dicetable/src/ui/cafe_owner/subscription/widget/payment_methods_card.dart';
import 'package:dicetable/src/ui/cafe_owner/subscription/widget/subscription_overview_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gap/gap.dart';

import 'bloc/subscription_bloc.dart';

class SubscriptionOverviewScreen extends StatefulWidget {
  const SubscriptionOverviewScreen({super.key});

  @override
  State<SubscriptionOverviewScreen> createState() =>
      _SubscriptionOverviewScreenState();
}

class _SubscriptionOverviewScreenState
    extends State<SubscriptionOverviewScreen> {
  @override
  void initState() {
    super.initState();
    context.read<SubscriptionBloc>().add(FetchSubscriptionOverview());
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SubscriptionBloc, SubscriptionState>(
      listener: (context, state) {
        if (state is SubscriptionOverviewLoading) {
          EasyLoading.show();
        }
        if (state is SubscriptionOverviewLoaded) {
          EasyLoading.dismiss();
        }
        if (state is SubscriptionOverviewError) {
          EasyLoading.dismiss();
          Fluttertoast.showToast(
            msg: "Failed to load subscription data.",
            backgroundColor: AppColors.primaryWhiteColor,
            textColor: AppColors.appRedColor,
          );
        }
      },
      builder: (context, state) {
        Widget child;
        if (state is SubscriptionOverviewLoaded) {
          if (state.subscriptionOverviewResponse.data!.subsriptionOverview ==
              null) {
            Center(
              child: Text(
                "No Subscription found for this account!.",
                style: Theme.of(context).textTheme.bodySmall!.copyWith(
                  color: AppColors.primaryWhiteColor,
                  fontWeight: FontWeight.w500,
                  fontSize: 18.sp,
                ),
              ),
            );
          }
        }
        if (state is SubscriptionOverviewLoaded) {
          child = SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.only(
                left: 26.0,
                right: 26.0,
                bottom: 70,
                top: 40,
              ),
              child: Column(
                children: [
                  Visibility(
                    visible:
                        state
                            .subscriptionOverviewResponse
                            .data!
                            .subsriptionOverview !=
                        null,
                    child: SubscriptionOverviewCard(
                      subsriptionOverview:
                          state
                              .subscriptionOverviewResponse
                              .data
                              ?.subsriptionOverview,
                    ),
                  ),
                  const Gap(20),
                  // const BillingHistoryCard(),
                  const Gap(20),
                  // const PaymentMethodsCard(),
                  const Gap(20),
                ],
              ),
            ),
          );
        } else if (state is SubscriptionOverviewError) {
          child = Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Something went wrong.",
                  style: TextStyle(color: AppColors.appRedColor),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () {
                    context.read<SubscriptionBloc>().add(
                      FetchSubscriptionOverview(),
                    );
                  },
                  child: const Text("Retry"),
                ),
              ],
            ),
          );
        } else {
          child = const Center(child: SizedBox.shrink());
        }

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
              stops: const [0.0, 0.5, 0.75, 1.0],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: child,
        );
      },
    );
  }
}
