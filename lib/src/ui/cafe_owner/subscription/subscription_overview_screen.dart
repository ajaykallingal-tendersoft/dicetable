import 'package:soloseaters/src/constants/app_colors.dart';
import 'package:soloseaters/src/ui/cafe_owner/subscription/widget/subscription_overview_card.dart';
import 'package:soloseaters/src/utils/data/auth_session_manager.dart';
import 'package:soloseaters/src/utils/data/sign_out.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gap/gap.dart';
import 'package:soloseaters/src/purchase/bloc/bloc/purchase_bloc.dart';
import 'package:soloseaters/src/purchase/bloc/bloc/purchase_state.dart';

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
    // ✅ Listen to PaymentPlanBloc for restore purchases completion
    return BlocListener<PaymentPlanBloc, PaymentPlanState>(
      listener: (context, paymentState) {
        // Dismiss loading when restore completes (any terminal state)
        if (paymentState.status == PaymentPlanStatus.purchaseRestored) {
          EasyLoading.dismiss();
          print('✅ Restore purchases completed successfully');
        } else if (paymentState.status == PaymentPlanStatus.initial &&
            !paymentState.isProcessing) {
          // Restore timeout - no purchases found (this is normal)
          EasyLoading.dismiss();
          print('ℹ️ No purchases found to restore');
        } else if (paymentState.status == PaymentPlanStatus.purchaseFailed) {
          EasyLoading.dismiss();
          print('❌ Restore purchases failed');
        } else if (paymentState.status == PaymentPlanStatus.cancelled) {
          EasyLoading.dismiss();
          print('ℹ️ Restore purchases cancelled');
        }
      },
      child: BlocConsumer<SubscriptionBloc, SubscriptionState>(
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
              fontSize: 14.sp,
              msg: "Failed to load subscription data.",
              backgroundColor: AppColors.primaryWhiteColor,
              textColor: AppColors.appRedColor,
            );
            if ((state.errorMessage.contains("UnAuthorized") ||
                    state.errorMessage.contains("status code of 401")) &&
                AuthSessionManager.consumeRefreshFailureFlag()) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                SignOut().logout(context);
                Fluttertoast.showToast(
                  fontSize: 14.sp,
                  backgroundColor: AppColors.primaryWhiteColor,
                  textColor: AppColors.appRedColor,
                  gravity: ToastGravity.BOTTOM,
                  msg: "Your session has expired. Please sign in again.",
                );
              });
            }
          }
        },
        builder: (context, state) {
          Widget child;

          // ✅ Show subscription overview card for both free and premium users
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
                    SubscriptionOverviewCard(
                      subsriptionOverview:
                          state
                              .subscriptionOverviewResponse
                              .data
                              ?.subsriptionOverview,
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
      ), // Close BlocConsumer
    ); // Close BlocListener
  } // Close build method
} // Close class
