import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:soloseaters/src/common/elevated_button_widget.dart';
import 'package:soloseaters/src/constants/app_colors.dart';
import 'package:soloseaters/src/model/cafe_owner/subscription/initial_subscription_plan_response.dart';
import 'package:soloseaters/src/model/cafe_owner/subscription/subscription_start_request.dart';
import 'package:soloseaters/src/purchase/bloc/bloc/purchase_bloc.dart';
import 'package:soloseaters/src/purchase/bloc/bloc/purchase_event.dart';
import 'package:soloseaters/src/purchase/bloc/bloc/purchase_state.dart';
import 'package:soloseaters/src/ui/cafe_owner/subscription/bloc/subscription_bloc.dart';
import 'package:soloseaters/src/ui/cafe_owner/subscription/widget/gradient.dart';
import 'package:soloseaters/src/utils/data/object_factory.dart';

// class SubscriptionPromptScreen extends StatefulWidget {
//   const SubscriptionPromptScreen({super.key});

//   @override
//   State<SubscriptionPromptScreen> createState() =>
//       _SubscriptionPromptScreenState();
// }

// class _SubscriptionPromptScreenState extends State<SubscriptionPromptScreen> {
//   late final int cafeId;
//   late final int subscriptionTypeId;
//   late final int paymentMethod;
//   late final double amount;
//   InitialSubscriptionPlanResponse? initialData;
//   bool _initialized = false;
//   DateTime? currentBackPressTime;

//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       // Initialize payment system
//       context.read<PaymentPlanBloc>().add(const InitializePaymentEvent());
//       // Fetch subscription data
//       context.read<SubscriptionBloc>().add(FetchInitialSubscription());
//     });
//   }

//   Future<bool> onWillPop() {
//     DateTime now = DateTime.now();
//     if (currentBackPressTime == null ||
//         now.difference(currentBackPressTime!) > const Duration(seconds: 3)) {
//       currentBackPressTime = now;
//       Fluttertoast.showToast(
//         fontSize: 14.sp,
//         backgroundColor: AppColors.secondary,
//         textColor: AppColors.primaryWhiteColor,
//         gravity: ToastGravity.BOTTOM,
//         msg: "Press again to exit",
//       );
//       return Future.value(false);
//     }
//     SystemNavigator.pop();
//     return Future.value(true);
//   }

//   Widget _buildSubscriptionContent(
//     BuildContext context,
//     InitialSubscriptionPlanResponse data,
//   ) {
//     if (!_initialized) {
//       cafeId = data.data!.cafeId!;
//       ObjectFactory().prefs.setCafeId(cafeId: data.data!.cafeId!.toString());
//       subscriptionTypeId = data.data!.subscriptionTypeId!;
//       paymentMethod = data.data!.paymentMethod!;
//       amount = double.tryParse(data.data!.amount ?? '') ?? 0.0;

//       _initialized = true;
//     }
//     // cafeId = data.data!.cafeId!;
//     // ObjectFactory().prefs.setCafeId(cafeId: data.data!.cafeId!.toString());
//     // subscriptionTypeId = data.data!.subscriptionTypeId!;
//     // paymentMethod = data.data!.paymentMethod!;
//     // amount = double.tryParse(data.data!.amount ?? '') ?? 0.0;

//     return SingleChildScrollView(
//       child: Padding(
//         padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 20),
//         child: Column(
//           children: [
//             Gap(30),
//             SvgPicture.asset(
//                   'assets/svg/free-icon.svg',
//                   height: 123,
//                   width: 123,
//                 )
//                 .animate()
//                 .scale(
//                   begin: const Offset(0.7, 0.7),
//                   end: const Offset(1, 1),
//                   duration: 500.ms,
//                   curve: Curves.easeOutBack,
//                 )
//                 .shake(
//                   hz: 4,
//                   duration: 400.ms,
//                   delay: 500.ms,
//                   curve: Curves.easeInOut,
//                 )
//                 .fadeIn(duration: 400.ms),
//             Gap(30),
//             SingleChildScrollView(
//               child: Container(
//                 padding: const EdgeInsets.all(0),
//                 decoration: BoxDecoration(
//                   color: AppColors.primaryWhiteColor,
//                   borderRadius: BorderRadius.circular(15.r),
//                   boxShadow: const [
//                     BoxShadow(
//                       color: Colors.black26,
//                       offset: Offset(0, 1),
//                       blurRadius: 4.0,
//                       spreadRadius: 1.0,
//                     ),
//                   ],
//                 ),
//                 child: Column(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     Flexible(
//                       flex: 2,
//                       child: Padding(
//                         padding: EdgeInsets.all(30.0.r),
//                         child: Column(
//                           mainAxisSize: MainAxisSize.min,
//                           children: [
//                             Text(
//                               'Start With A Free 1-Month Trial,\nThen \$ ${data.data!.amount} Per Year!',
//                               textAlign: TextAlign.center,
//                               style: TextTheme.of(
//                                 context,
//                               ).labelMedium!.copyWith(
//                                 color: AppColors.primary,
//                                 fontWeight: FontWeight.bold,
//                                 fontSize: 18.sp,
//                               ),
//                             ),
//                             SizedBox(height: 10.h),
//                             Text(
//                               'Enjoy all premium features for ${data.data!.trialDuration} ${data.data!.trialType},\nabsolutely free!',
//                               textAlign: TextAlign.center,
//                               style: TextTheme.of(context).bodySmall!.copyWith(
//                                 color: AppColors.primary,
//                                 fontWeight: FontWeight.w500,
//                                 fontSize: 12.sp,
//                               ),
//                             ),
//                             SizedBox(height: 20.h),

//                             RichText(
//                               text: TextSpan(
//                                 children: [
//                                   TextSpan(
//                                     text: 'Promo Code: ',
//                                     style: TextTheme.of(
//                                       context,
//                                     ).bodyMedium!.copyWith(
//                                       color: AppColors.tertiary,
//                                       fontWeight: FontWeight.w700,
//                                       fontSize: 14.sp,
//                                     ),
//                                   ),
//                                   TextSpan(
//                                     text: 'E23FTU6',
//                                     style: TextTheme.of(
//                                       context,
//                                     ).bodyMedium!.copyWith(
//                                       color: AppColors.tertiary,
//                                       fontWeight: FontWeight.w700,
//                                       fontSize: 14.sp,
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                             SizedBox(height: 10.h),
//                             TextField(
//                               style: Theme.of(
//                                 context,
//                               ).textTheme.bodyMedium!.copyWith(
//                                 color: AppColors.hintColor,
//                                 fontWeight: FontWeight.w600,
//                                 fontSize: 14.sp,
//                               ),
//                               decoration: InputDecoration(
//                                 hintText: 'Enter Promo Code',
//                                 hintStyle: TextStyle(
//                                   color: AppColors.textPrimaryGrey,
//                                   fontWeight: FontWeight.w600,
//                                   fontSize: 14.sp,
//                                 ),
//                                 contentPadding: EdgeInsets.symmetric(
//                                   horizontal: 16.w,
//                                 ),
//                                 border: OutlineInputBorder(
//                                   borderSide: BorderSide(
//                                     color: AppColors.borderColor1,
//                                   ),
//                                   borderRadius: BorderRadius.circular(10.r),
//                                 ),
//                                 focusedBorder: OutlineInputBorder(
//                                   borderSide: BorderSide(
//                                     color: AppColors.borderColor1,
//                                   ),
//                                   borderRadius: BorderRadius.circular(10.r),
//                                 ),
//                                 enabledBorder: OutlineInputBorder(
//                                   borderSide: BorderSide(
//                                     color: AppColors.borderColor1,
//                                   ),
//                                   borderRadius: BorderRadius.circular(10.r),
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                     Flexible(
//                       child: Container(
//                         width: double.infinity,
//                         padding: EdgeInsets.all(20.r),
//                         decoration: BoxDecoration(
//                           color: AppColors.subscriptionPromptSubColor,
//                           borderRadius: BorderRadius.only(
//                             bottomLeft: Radius.circular(20.r),
//                             bottomRight: Radius.circular(20.r),
//                           ),
//                         ),
//                         child: Column(
//                           mainAxisSize: MainAxisSize.min,
//                           children: [
//                             Text(
//                               'Continue After Trial',
//                               style: TextTheme.of(context).bodyMedium!.copyWith(
//                                 decoration: TextDecoration.underline,
//                                 decorationColor: AppColors.textPrimaryGrey,
//                                 color: AppColors.timeTextColor,
//                                 fontWeight: FontWeight.w500,
//                                 fontSize: 12.sp,
//                               ),
//                             ),
//                             SizedBox(height: 5.h),
//                             Text.rich(
//                               TextSpan(
//                                 children: [
//                                   TextSpan(
//                                     text: '\$${data.data!.amount}',
//                                     style: TextTheme.of(
//                                       context,
//                                     ).bodyLarge!.copyWith(
//                                       color: AppColors.primary,
//                                       fontSize: 24.sp,
//                                     ),
//                                   ),
//                                   TextSpan(
//                                     text: ' / ${data.data!.type}',
//                                     style: TextTheme.of(
//                                       context,
//                                     ).bodyMedium!.copyWith(
//                                       color:
//                                           AppColors.subscriptionPriceSubColor,
//                                       fontWeight: FontWeight.w600,
//                                       fontSize: 14.sp,
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                             SizedBox(height: 5.h),
//                             Text(
//                               'Get all the benefits for just \$${data.data!.amount} ${data.data!.type}.',
//                               textAlign: TextAlign.center,
//                               style: TextTheme.of(context).bodyMedium!.copyWith(
//                                 color: AppColors.primary,
//                                 fontWeight: FontWeight.w600,
//                                 fontSize: 12.sp,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//             Gap(30),
//             BlocConsumer<PaymentPlanBloc, PaymentPlanState>(
//                   listener: (context, paymentState) {
//                     if (paymentState.status ==
//                         PaymentPlanStatus.purchaseSuccess) {
//                       // After successful trial start, sync with backend
//                       context.read<SubscriptionBloc>().add(
//                         StartSubscriptionEvent(
//                           subscriptionStartRequest: SubscriptionStartRequest(
//                             cafeId: cafeId,
//                             subscriptionTypeId: subscriptionTypeId,
//                             paymentMethod: paymentMethod,
//                             amount: amount,
//                             autoRenew: true,
//                           ),
//                         ),
//                       );
//                     }
//                   },
//                   builder: (context, paymentState) {
//                     final isProcessing = paymentState.isProcessing;

//                     return InkWell(
//                       splashColor: AppColors.secondary,
//                       splashFactory: InkRipple.splashFactory,
//                       onTap:
//                           isProcessing
//                               ? null
//                               : () {
//                                 final bloc = context.read<PaymentPlanBloc>();
//                                 final products = bloc.state.products;

//                                 if (products.isNotEmpty) {
//                                   final plan = products.first;
//                                   bloc
//                                     ..add(SelectPlanEvent(plan.id))
//                                     ..add(PurchaseProductEvent(plan.id));
//                                 }
//                               },
//                       child: ElevatedButtonWidget(
//                         height: 70.h,
//                         width: MediaQuery.of(context).size.width,
//                         iconEnabled: false,
//                         iconLabel:
//                             isProcessing ? "PROCESSING..." : "START FREE TRIAL",
//                         color: AppColors.primary,
//                         textColor: AppColors.primaryWhiteColor,
//                       ),
//                     );
//                   },
//                 )
//                 .animate()
//                 .fadeIn(duration: 450.ms)
//                 .slideY(begin: 0.2, delay: 600.ms),
//           ],
//         ),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return WillPopScope(
//       onWillPop: onWillPop,
//       child: Scaffold(
//         body: Container(
//           height: double.infinity,
//           decoration: BoxDecoration(
//             gradient: LinearGradient(
//               colors: [
//                 AppColors.primary,
//                 AppColors.primary,
//                 AppColors.secondary,
//                 AppColors.tertiary,
//               ],
//               stops: [0.0, 0.5, 0.75, 1.0],
//               begin: Alignment.topCenter,
//               end: Alignment.bottomCenter,
//             ),
//           ),
//           child: BlocListener<PaymentPlanBloc, PaymentPlanState>(
//             listener: (context, paymentState) {
//               // ONLY navigate after actual purchase
//               if (paymentState.status == PaymentPlanStatus.purchaseSuccess) {
//                 EasyLoading.dismiss();
//                 Fluttertoast.showToast(
//                   fontSize: 14.sp,
//                   backgroundColor: AppColors.appGreenColor,
//                   textColor: AppColors.primaryWhiteColor,
//                   gravity: ToastGravity.BOTTOM,
//                   msg: 'Trial started successfully!',
//                 );
//                 // context.go('/home');
//                 return;
//               }

//               // Existing behavior (keep)
//               if (paymentState.status == PaymentPlanStatus.purchaseFailed) {
//                 EasyLoading.dismiss();
//                 Fluttertoast.showToast(
//                   fontSize: 14.sp,
//                   backgroundColor: AppColors.appRedColor,
//                   textColor: AppColors.primaryWhiteColor,
//                   gravity: ToastGravity.BOTTOM,
//                   msg: paymentState.errorMessage ?? 'Failed to start trial',
//                 );
//               }
//             },
//             child: BlocConsumer<SubscriptionBloc, SubscriptionState>(
//               listener: (context, state) {
//                 if (state is InitialSubscriptionLoading) {
//                   EasyLoading.show();
//                 }
//                 if (state is StartSubscriptionLoading) {
//                   EasyLoading.show();
//                 }
//                 if (state is InitialSubscriptionLoaded) {
//                   EasyLoading.dismiss();
//                 }
//                 if (state is StartSubscriptionLoaded) {
//                   EasyLoading.dismiss();

//                   final msg =
//                       state.subscriptionStartResponse.message?.toString() ??
//                       "Your subscription was successful.";

//                   Fluttertoast.showToast(
//                     fontSize: 14.sp,
//                     backgroundColor: AppColors.primaryWhiteColor,
//                     textColor: AppColors.appGreenColor,
//                     gravity: ToastGravity.BOTTOM,
//                     msg: msg,
//                   );

//                   // Only here we navigate!
//                   context.go('/home');
//                 }

//                 if (state is StartSubscriptionError) {
//                   EasyLoading.dismiss();
//                   Fluttertoast.showToast(
//                     fontSize: 14.sp,
//                     backgroundColor: AppColors.primaryWhiteColor,
//                     textColor: AppColors.appGreenColor,
//                     gravity: ToastGravity.BOTTOM,
//                     msg: state.errorMessage,
//                   );
//                 }
//               },
//               builder: (context, state) {
//                 if (state is InitialSubscriptionLoading ||
//                     state is StartSubscriptionLoading) {
//                   return GradientBackGround();
//                 }
//                 if (state is InitialSubscriptionLoaded &&
//                     state.initialSubscriptionPlanResponse.message ==
//                         "Subscription type found!" &&
//                     state.initialSubscriptionPlanResponse.data != null) {
//                   initialData = state.initialSubscriptionPlanResponse;
//                   return _buildSubscriptionContent(
//                     context,
//                     state.initialSubscriptionPlanResponse,
//                   );
//                 }
//                 if (state is StartSubscriptionError && initialData != null) {
//                   return _buildSubscriptionContent(context, initialData!);
//                 }
//                 return GradientBackGround();
//               },
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

class SubscriptionPromptScreen extends StatefulWidget {
  const SubscriptionPromptScreen({super.key});

  @override
  State<SubscriptionPromptScreen> createState() =>
      _SubscriptionPromptScreenState();
}

class _SubscriptionPromptScreenState extends State<SubscriptionPromptScreen> {
  late final int cafeId;
  late final int subscriptionTypeId;
  late final int paymentMethod;
  late final double amount;
  InitialSubscriptionPlanResponse? initialData;
  bool _initialized = false;
  DateTime? currentBackPressTime;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PaymentPlanBloc>().add(const InitializePaymentEvent());
      context.read<SubscriptionBloc>().add(FetchInitialSubscription());
    });
  }

  Future<bool> onWillPop() {
    DateTime now = DateTime.now();
    if (currentBackPressTime == null ||
        now.difference(currentBackPressTime!) > const Duration(seconds: 3)) {
      currentBackPressTime = now;
      Fluttertoast.showToast(
        fontSize: 14.sp,
        backgroundColor: AppColors.secondary,
        textColor: AppColors.primaryWhiteColor,
        gravity: ToastGravity.BOTTOM,
        msg: "Press again to exit",
      );
      return Future.value(false);
    }
    SystemNavigator.pop();
    return Future.value(true);
  }

  Widget _buildSubscriptionContent(
    BuildContext context,
    InitialSubscriptionPlanResponse data,
  ) {
    if (!_initialized) {
      cafeId = data.data!.cafeId!;
      ObjectFactory().prefs.setCafeId(cafeId: data.data!.cafeId!.toString());
      subscriptionTypeId = data.data!.subscriptionTypeId!;
      paymentMethod = data.data!.paymentMethod!;
      amount = double.tryParse(data.data!.amount ?? '') ?? 0.0;
      _initialized = true;
    }

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 20),
        child: Column(
          children: [
            Gap(30),
            SvgPicture.asset(
                  'assets/svg/free-icon.svg',
                  height: 123,
                  width: 123,
                )
                .animate()
                .scale(
                  begin: const Offset(0.7, 0.7),
                  end: const Offset(1, 1),
                  duration: 500.ms,
                  curve: Curves.easeOutBack,
                )
                .shake(
                  hz: 4,
                  duration: 400.ms,
                  delay: 500.ms,
                  curve: Curves.easeInOut,
                )
                .fadeIn(duration: 400.ms),
            Gap(30),
            SingleChildScrollView(
              child: Container(
                padding: const EdgeInsets.all(0),
                decoration: BoxDecoration(
                  color: AppColors.primaryWhiteColor,
                  borderRadius: BorderRadius.circular(15.r),
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
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      flex: 2,
                      child: Padding(
                        padding: EdgeInsets.all(30.0.r),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Start With A Free 1-Month Trial,\nThen \$ ${data.data!.amount} Per Year!',
                              textAlign: TextAlign.center,
                              style: TextTheme.of(
                                context,
                              ).labelMedium!.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold,
                                fontSize: 18.sp,
                              ),
                            ),
                            SizedBox(height: 10.h),
                            Text(
                              'Enjoy all premium features for ${data.data!.trialDuration} ${data.data!.trialType},\nabsolutely free!',
                              textAlign: TextAlign.center,
                              style: TextTheme.of(context).bodySmall!.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w500,
                                fontSize: 12.sp,
                              ),
                            ),
                            SizedBox(height: 20.h),
                            // RichText(
                            //   text: TextSpan(
                            //     children: [
                            //       TextSpan(
                            //         text: 'Promo Code: ',
                            //         style: TextTheme.of(context)
                            //             .bodyMedium!
                            //             .copyWith(
                            //               color: AppColors.tertiary,
                            //               fontWeight: FontWeight.w700,
                            //               fontSize: 14.sp,
                            //             ),
                            //       ),
                            //       TextSpan(
                            //         text: 'E23FTU6',
                            //         style: TextTheme.of(context)
                            //             .bodyMedium!
                            //             .copyWith(
                            //               color: AppColors.tertiary,
                            //               fontWeight: FontWeight.w700,
                            //               fontSize: 14.sp,
                            //             ),
                            //       ),
                            //     ],
                            //   ),
                            // ),
                            // SizedBox(height: 10.h),
                            // TextField(
                            //   style: Theme.of(context)
                            //       .textTheme
                            //       .bodyMedium!
                            //       .copyWith(
                            //         color: AppColors.hintColor,
                            //         fontWeight: FontWeight.w600,
                            //         fontSize: 14.sp,
                            //       ),
                            //   decoration: InputDecoration(
                            //     hintText: 'Enter Promo Code',
                            //     hintStyle: TextStyle(
                            //       color: AppColors.textPrimaryGrey,
                            //       fontWeight: FontWeight.w600,
                            //       fontSize: 14.sp,
                            //     ),
                            //     contentPadding: EdgeInsets.symmetric(
                            //       horizontal: 16.w,
                            //     ),
                            //     border: OutlineInputBorder(
                            //       borderSide: BorderSide(
                            //         color: AppColors.borderColor1,
                            //       ),
                            //       borderRadius: BorderRadius.circular(10.r),
                            //     ),
                            //     focusedBorder: OutlineInputBorder(
                            //       borderSide: BorderSide(
                            //         color: AppColors.borderColor1,
                            //       ),
                            //       borderRadius: BorderRadius.circular(10.r),
                            //     ),
                            //     enabledBorder: OutlineInputBorder(
                            //       borderSide: BorderSide(
                            //         color: AppColors.borderColor1,
                            //       ),
                            //       borderRadius: BorderRadius.circular(10.r),
                            //     ),
                            //   ),
                            // ),
                          ],
                        ),
                      ),
                    ),
                    Flexible(
                      child: Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(20.r),
                        decoration: BoxDecoration(
                          color: AppColors.subscriptionPromptSubColor,
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(20.r),
                            bottomRight: Radius.circular(20.r),
                          ),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Continue After Trial',
                              style: TextTheme.of(context).bodyMedium!.copyWith(
                                decoration: TextDecoration.underline,
                                decorationColor: AppColors.textPrimaryGrey,
                                color: AppColors.timeTextColor,
                                fontWeight: FontWeight.w500,
                                fontSize: 12.sp,
                              ),
                            ),
                            SizedBox(height: 5.h),
                            Text.rich(
                              TextSpan(
                                children: [
                                  TextSpan(
                                    text: '\$${data.data!.amount}',
                                    style: TextTheme.of(
                                      context,
                                    ).bodyLarge!.copyWith(
                                      color: AppColors.primary,
                                      fontSize: 24.sp,
                                    ),
                                  ),
                                  TextSpan(
                                    text: ' / ${data.data!.type}',
                                    style: TextTheme.of(
                                      context,
                                    ).bodyMedium!.copyWith(
                                      color:
                                          AppColors.subscriptionPriceSubColor,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14.sp,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 5.h),
                            Text(
                              'Get all the benefits for just \$${data.data!.amount} ${data.data!.type}.',
                              textAlign: TextAlign.center,
                              style: TextTheme.of(context).bodyMedium!.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600,
                                fontSize: 12.sp,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Gap(30),
            BlocConsumer<PaymentPlanBloc, PaymentPlanState>(
              listener: (context, paymentState) {
                // ✅ Handle verification failure with support info
                if (paymentState.status ==
                    PaymentPlanStatus.verificationFailed) {
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder:
                        (context) => AlertDialog(
                          title: const Text('Verification Issue'),
                          content: Text(
                            paymentState.errorMessage ??
                                'Unable to verify your purchase. Please contact support.',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                                // User can try again or contact support
                              },
                              child: const Text('Contact Support'),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                                // Trigger restore to re-check
                                context.read<PaymentPlanBloc>().add(
                                  const RestorePurchasesEvent(),
                                );
                              },
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                  );
                }

                // ✅ Handle "already owned" scenario
                if (paymentState.status == PaymentPlanStatus.needsRestore) {
                  EasyLoading.show(status: 'Restoring subscription...');
                }

                if (paymentState.status == PaymentPlanStatus.purchaseSuccess) {
                  context.read<SubscriptionBloc>().add(
                    StartSubscriptionEvent(
                      subscriptionStartRequest: SubscriptionStartRequest(
                        cafeId: cafeId,
                        subscriptionTypeId: subscriptionTypeId,
                        paymentMethod: paymentMethod,
                        amount: amount,
                        autoRenew: true,
                      ),
                    ),
                  );
                }
              },
              builder: (context, paymentState) {
                final isProcessing = paymentState.isProcessing;
                final isRetrying =
                    paymentState.status ==
                        PaymentPlanStatus.verificationFailed &&
                    (paymentState.verificationAttempts ?? 0) > 0;

                return InkWell(
                  splashColor: AppColors.secondary,
                  splashFactory: InkRipple.splashFactory,
                  onTap:
                      isProcessing
                          ? null
                          : () {
                            final bloc = context.read<PaymentPlanBloc>();
                            final products = bloc.state.products;

                            if (products.isNotEmpty) {
                              final plan = products.first;
                              bloc
                                ..add(SelectPlanEvent(plan.id))
                                ..add(PurchaseProductEvent(plan.id));
                            }
                          },
                  child: ElevatedButtonWidget(
                    height: 70.h,
                    width: MediaQuery.of(context).size.width,
                    iconEnabled: false,
                    iconLabel:
                        isRetrying
                            ? "VERIFYING... (${paymentState.verificationAttempts}/3)"
                            : (isProcessing
                                ? "PROCESSING..."
                                : "START FREE TRIAL"),
                    color: AppColors.primary,
                    textColor: AppColors.primaryWhiteColor,
                  ),
                );
              },
            ).animate().fadeIn(duration: 450.ms).slideY(begin: 0.2, delay: 600.ms),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: onWillPop,
      child: Scaffold(
        body: Container(
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
          child: BlocListener<PaymentPlanBloc, PaymentPlanState>(
            listener: (context, paymentState) {
              // ✅ Debug logging to track state changes
              print('💳 Payment State: ${paymentState.status}');
              print('💳 Premium Override: ${paymentState.premiumOverride}');
              print('💳 Is Premium: ${paymentState.isPremium}');

              if (paymentState.status == PaymentPlanStatus.purchaseSuccess) {
                EasyLoading.dismiss();
                Fluttertoast.showToast(
                  fontSize: 14.sp,
                  backgroundColor: AppColors.appGreenColor,
                  textColor: AppColors.primaryWhiteColor,
                  gravity: ToastGravity.BOTTOM,
                  msg: 'Trial started successfully!',
                );
                return;
              }

              if (paymentState.status == PaymentPlanStatus.purchaseFailed) {
                EasyLoading.dismiss();
                Fluttertoast.showToast(
                  fontSize: 14.sp,
                  backgroundColor: AppColors.appRedColor,
                  textColor: AppColors.primaryWhiteColor,
                  gravity: ToastGravity.BOTTOM,
                  msg: paymentState.errorMessage ?? 'Failed to start trial',
                );
              }

              // ✅ Show restore success
              if (paymentState.status == PaymentPlanStatus.purchaseRestored) {
                EasyLoading.dismiss();
                Fluttertoast.showToast(
                  fontSize: 14.sp,
                  backgroundColor: AppColors.appGreenColor,
                  textColor: AppColors.primaryWhiteColor,
                  gravity: ToastGravity.BOTTOM,
                  msg: 'Subscription restored successfully!',
                );
              }
            },
            child: BlocConsumer<SubscriptionBloc, SubscriptionState>(
              listener: (context, state) {
                if (state is InitialSubscriptionLoading) {
                  EasyLoading.show();
                }
                if (state is StartSubscriptionLoading) {
                  EasyLoading.show();
                }
                if (state is InitialSubscriptionLoaded) {
                  EasyLoading.dismiss();
                }
                if (state is StartSubscriptionLoaded) {
                  EasyLoading.dismiss();

                  final msg =
                      state.subscriptionStartResponse.message?.toString() ??
                      "Your subscription was successful.";

                  Fluttertoast.showToast(
                    fontSize: 14.sp,
                    backgroundColor: AppColors.primaryWhiteColor,
                    textColor: AppColors.appGreenColor,
                    gravity: ToastGravity.BOTTOM,
                    msg: msg,
                  );

                  // ✅ CRITICAL: Refresh subscription status from backend to update cache
                  // This ensures premiumOverride and all subscription data is properly synced
                  print('🔄 Refreshing subscription status from backend...');
                  context.read<PaymentPlanBloc>().add(
                    const CheckSubscriptionStatusEvent(),
                  );

                  // ✅ Navigate after a short delay to ensure state is synced
                  Future.delayed(const Duration(milliseconds: 500), () {
                    if (mounted) {
                      print('✅ Navigating to home with synced state');
                      context.go('/home');
                    }
                  });
                }

                if (state is StartSubscriptionError) {
                  EasyLoading.dismiss();
                  Fluttertoast.showToast(
                    fontSize: 14.sp,
                    backgroundColor: AppColors.primaryWhiteColor,
                    textColor: AppColors.appGreenColor,
                    gravity: ToastGravity.BOTTOM,
                    msg: state.errorMessage,
                  );
                }
              },
              builder: (context, state) {
                if (state is InitialSubscriptionLoading ||
                    state is StartSubscriptionLoading) {
                  return GradientBackGround();
                }
                if (state is InitialSubscriptionLoaded &&
                    state.initialSubscriptionPlanResponse.message ==
                        "Subscription type found!" &&
                    state.initialSubscriptionPlanResponse.data != null) {
                  initialData = state.initialSubscriptionPlanResponse;
                  return _buildSubscriptionContent(
                    context,
                    state.initialSubscriptionPlanResponse,
                  );
                }
                if (state is StartSubscriptionError && initialData != null) {
                  return _buildSubscriptionContent(context, initialData!);
                }
                return GradientBackGround();
              },
            ),
          ),
        ),
      ),
    );
  }
}
