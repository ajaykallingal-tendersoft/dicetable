import 'package:dicetable/src/common/elevated_button_widget.dart';
import 'package:dicetable/src/constants/app_colors.dart';
import 'package:dicetable/src/model/cafe_owner/subscription/subscription_start_request.dart';
import 'package:dicetable/src/ui/cafe_owner/subscription/bloc/subscription_bloc.dart';
import 'package:dicetable/src/ui/cafe_owner/subscription/widget/subscription_prompt_promo_code_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

import '../../../model/cafe_owner/subscription/initial_subscription_plan_response.dart';

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

  Future<bool> onWillPop() {
    DateTime? currentBackPressTime;
    DateTime now = DateTime.now();
    if (currentBackPressTime == null ||
        now.difference(currentBackPressTime) > const Duration(seconds: 3)) {
      currentBackPressTime = now;
      Fluttertoast.showToast(
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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SubscriptionBloc>().add(FetchInitialSubscription());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
        child: BlocConsumer<SubscriptionBloc, SubscriptionState>(
          listener: (context, state) {
            if (state is InitialSubscriptionLoading) {
              EasyLoading.show(status: "Loading");
            }
            if (state is StartSubscriptionLoading) {
              EasyLoading.show(status: "Loading");
            }
            if (state is StartSubscriptionLoaded) {
              EasyLoading.dismiss();
              Fluttertoast.showToast(
                backgroundColor: AppColors.primaryWhiteColor,
                textColor: AppColors.appGreenColor,
                gravity: ToastGravity.BOTTOM,
                msg: state.subscriptionStartResponse.message!,
              );
              context.go('/home');
            }
            if(state is StartSubscriptionError) {
              EasyLoading.dismiss();
              Fluttertoast.showToast(
                backgroundColor: AppColors.primaryWhiteColor,
                textColor: AppColors.appGreenColor,
                gravity: ToastGravity.BOTTOM,
                msg: state.errorMessage,
              );
            }
          },
          builder: (context, state) {
            if (state is InitialSubscriptionLoaded) {
              if (state.initialSubscriptionPlanResponse.message ==
                      "Subscription type found!" &&
                  state.initialSubscriptionPlanResponse.data != null) {
                initialData = state.initialSubscriptionPlanResponse;
                cafeId = state.initialSubscriptionPlanResponse.data!.cafeId!;
                subscriptionTypeId =
                    state
                        .initialSubscriptionPlanResponse
                        .data!
                        .subscriptionTypeId!;
                paymentMethod =
                    state.initialSubscriptionPlanResponse.data!.paymentMethod!;
                amount =
                    double.tryParse(
                      state.initialSubscriptionPlanResponse.data!.amount ?? '',
                    ) ??
                    0.0;
                EasyLoading.dismiss();
                return SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 26,
                      vertical: 20,
                    ),
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
                          // Added SingleChildScrollView for small screens
                          child: Container(
                            padding: const EdgeInsets.all(0),
                            decoration: BoxDecoration(
                              color: AppColors.primaryWhiteColor,
                              borderRadius: BorderRadius.circular(15.r),
                              // Using .r for responsive radius
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
                              // Important for fitting content
                              children: [
                                Flexible(
                                  flex: 2,
                                  child: Padding(
                                    padding: EdgeInsets.all(30.0.r),
                                    // Using .r for responsive padding
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      // Ensure inner Column doesn't take infinite space
                                      children: [
                                        Text(
                                          'Start With A Free 3-Month Trial,\nThen \$ ${state.initialSubscriptionPlanResponse.data!.amount} Per Year!',
                                          textAlign: TextAlign.center,
                                          style: TextTheme.of(
                                            context,
                                          ).labelMedium!.copyWith(
                                            color: AppColors.primary,
                                            fontWeight: FontWeight.bold,
                                            fontSize:
                                                18.sp, // Using .sp for responsive font size
                                          ),
                                        ),
                                        SizedBox(height: 10.h),
                                        // Using .h for responsive height
                                        Text(
                                          'Enjoy all premium features for ${state.initialSubscriptionPlanResponse.data!.trialDuration} ${state.initialSubscriptionPlanResponse.data!.trialType},\nabsolutely free!',
                                          textAlign: TextAlign.center,
                                          style: TextTheme.of(
                                            context,
                                          ).bodySmall!.copyWith(
                                            color: AppColors.primary,
                                            fontWeight: FontWeight.w500,
                                            fontSize:
                                                12.sp, // Using .sp for responsive font size
                                          ),
                                        ),
                                        SizedBox(height: 20.h),
                                        // Using .h for responsive height
                                        // RichText(
                                        //   text: TextSpan(
                                        //     children: [
                                        //       TextSpan(
                                        //         text: 'Promo Code: ',
                                        //         style: TextTheme.of(context).bodyMedium!.copyWith(
                                        //           color: AppColors.tertiary,
                                        //           fontWeight: FontWeight.w700,
                                        //           fontSize: 14.sp, // Using .sp for responsive font size
                                        //         ),
                                        //       ),
                                        //       TextSpan(
                                        //         text: 'E23FTU6',
                                        //         style: TextTheme.of(context).bodyMedium!.copyWith(
                                        //           color: AppColors.tertiary,
                                        //           fontWeight: FontWeight.w700,
                                        //           fontSize: 14.sp, // Using .sp for responsive font size
                                        //         ),
                                        //       ),
                                        //     ],
                                        //   ),
                                        // ),
                                        // SizedBox(height: 10.h), // Using .h for responsive height
                                        // TextField(
                                        //   style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                                        //     color: AppColors.hintColor,
                                        //     fontWeight: FontWeight.w600,
                                        //     fontSize: 14.sp, // Using .sp for responsive font size
                                        //   ),
                                        //   decoration: InputDecoration(
                                        //     hintText: 'Enter Promo Code',
                                        //     hintStyle: TextStyle(
                                        //       color: AppColors.textPrimaryGrey,
                                        //       fontWeight: FontWeight.w600,
                                        //       fontSize: 14.sp, // Using .sp for responsive font size
                                        //     ),
                                        //     contentPadding: EdgeInsets.symmetric(horizontal: 16.w), // Using .w for responsive width
                                        //     border: OutlineInputBorder(
                                        //       borderSide: BorderSide(color: AppColors.borderColor1),
                                        //       borderRadius: BorderRadius.circular(10.r), // Using .r for responsive radius
                                        //     ),
                                        //     focusedBorder: OutlineInputBorder(
                                        //       borderSide: BorderSide(color: AppColors.borderColor1),
                                        //       borderRadius: BorderRadius.circular(10.r), // Using .r for responsive radius
                                        //     ),
                                        //     enabledBorder: OutlineInputBorder(
                                        //       borderSide: BorderSide(color: AppColors.borderColor1),
                                        //       borderRadius: BorderRadius.circular(10.r), // Using .r for responsive radius
                                        //     ),
                                        //   ),
                                        // )
                                      ],
                                    ),
                                  ),
                                ),
                                Flexible(
                                  child: Container(
                                    width: double.infinity,
                                    padding: EdgeInsets.all(20.r),
                                    // Using .r for responsive padding
                                    decoration: BoxDecoration(
                                      color:
                                          AppColors.subscriptionPromptSubColor,
                                      borderRadius: BorderRadius.only(
                                        bottomLeft: Radius.circular(20.r),
                                        // Using .r for responsive radius
                                        bottomRight: Radius.circular(
                                          20.r,
                                        ), // Using .r for responsive radius
                                      ),
                                    ),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      // Ensure inner Column doesn't take infinite space
                                      children: [
                                        Text(
                                          'Continue After Trial',
                                          style: TextTheme.of(
                                            context,
                                          ).bodyMedium!.copyWith(
                                            decoration:
                                                TextDecoration.underline,
                                            decorationColor:
                                                AppColors.textPrimaryGrey,
                                            color: AppColors.timeTextColor,
                                            fontWeight: FontWeight.w500,
                                            fontSize:
                                                12.sp, // Using .sp for responsive font size
                                          ),
                                        ),
                                        SizedBox(height: 5.h),
                                        // Using .h for responsive height
                                        Text.rich(
                                          TextSpan(
                                            children: [
                                              TextSpan(
                                                text:
                                                    '\$${state.initialSubscriptionPlanResponse.data!.amount}',
                                                style: TextTheme.of(
                                                  context,
                                                ).bodyLarge!.copyWith(
                                                  color: AppColors.primary,
                                                  fontSize:
                                                      24.sp, // Making the price more prominent responsively
                                                ),
                                              ),
                                              TextSpan(
                                                text:
                                                    ' / ${state.initialSubscriptionPlanResponse.data!.type}',
                                                style: TextTheme.of(
                                                  context,
                                                ).bodyMedium!.copyWith(
                                                  color:
                                                      AppColors
                                                          .subscriptionPriceSubColor,
                                                  fontWeight: FontWeight.w600,
                                                  fontSize:
                                                      14.sp, // Using .sp for responsive font size
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        SizedBox(height: 5.h),
                                        // Using .h for responsive height
                                        Text(
                                          'Get all the benefits for just \$${state.initialSubscriptionPlanResponse.data!.amount} ${state.initialSubscriptionPlanResponse.data!.type}.',
                                          textAlign: TextAlign.center,
                                          style: TextTheme.of(
                                            context,
                                          ).bodyMedium!.copyWith(
                                            color: AppColors.primary,
                                            fontWeight: FontWeight.w600,
                                            fontSize:
                                                12.sp, // Using .sp for responsive font size
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
                        BlocBuilder<SubscriptionBloc, SubscriptionState>(
                              builder: (context, state) {
                                return InkWell(
                                  splashColor: AppColors.secondary,
                                  splashFactory: InkRipple.splashFactory,
                                  onTap: () {
                                    context.read<SubscriptionBloc>().add(
                                      StartSubscriptionEvent(
                                        subscriptionStartRequest:
                                            SubscriptionStartRequest(
                                              cafeId: cafeId,
                                              subscriptionTypeId:
                                                  subscriptionTypeId,
                                              paymentMethod: paymentMethod,
                                              amount: amount,
                                              autoRenew: true,
                                            ),
                                      ),
                                    );
                                  },
                                  child: ElevatedButtonWidget(
                                    height: 70.h,
                                    width: double.infinity,
                                    iconEnabled: false,
                                    iconLabel: "START FREE TRAIL",
                                    color: AppColors.primary,
                                    textColor: AppColors.primaryWhiteColor,
                                  ),
                                );
                              },
                            )
                            .animate()
                            .fadeIn(duration: 450.ms)
                            .slideY(begin: 0.2, delay: 600.ms),
                      ],
                    ),
                  ),
                );
              }
            }
            if (state is StartSubscriptionError && initialData != null) {
              return   SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 26,
                    vertical: 20,
                  ),
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
                        // Added SingleChildScrollView for small screens
                        child: Container(
                          padding: const EdgeInsets.all(0),
                          decoration: BoxDecoration(
                            color: AppColors.primaryWhiteColor,
                            borderRadius: BorderRadius.circular(15.r),
                            // Using .r for responsive radius
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
                            // Important for fitting content
                            children: [
                              Flexible(
                                flex: 2,
                                child: Padding(
                                  padding: EdgeInsets.all(30.0.r),
                                  // Using .r for responsive padding
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    // Ensure inner Column doesn't take infinite space
                                    children: [
                                      Text(
                                        'Start With A Free 3-Month Trial,\nThen \$ ${initialData!.data!.amount} Per Year!',
                                        textAlign: TextAlign.center,
                                        style: TextTheme.of(
                                          context,
                                        ).labelMedium!.copyWith(
                                          color: AppColors.primary,
                                          fontWeight: FontWeight.bold,
                                          fontSize:
                                          18.sp, // Using .sp for responsive font size
                                        ),
                                      ),
                                      SizedBox(height: 10.h),
                                      // Using .h for responsive height
                                      Text(
                                        'Enjoy all premium features for ${initialData!.data!.trialDuration} ${initialData!.data!.trialType},\nabsolutely free!',
                                        textAlign: TextAlign.center,
                                        style: TextTheme.of(
                                          context,
                                        ).bodySmall!.copyWith(
                                          color: AppColors.primary,
                                          fontWeight: FontWeight.w500,
                                          fontSize:
                                          12.sp, // Using .sp for responsive font size
                                        ),
                                      ),
                                      SizedBox(height: 20.h),
                                      // Using .h for responsive height
                                      // RichText(
                                      //   text: TextSpan(
                                      //     children: [
                                      //       TextSpan(
                                      //         text: 'Promo Code: ',
                                      //         style: TextTheme.of(context).bodyMedium!.copyWith(
                                      //           color: AppColors.tertiary,
                                      //           fontWeight: FontWeight.w700,
                                      //           fontSize: 14.sp, // Using .sp for responsive font size
                                      //         ),
                                      //       ),
                                      //       TextSpan(
                                      //         text: 'E23FTU6',
                                      //         style: TextTheme.of(context).bodyMedium!.copyWith(
                                      //           color: AppColors.tertiary,
                                      //           fontWeight: FontWeight.w700,
                                      //           fontSize: 14.sp, // Using .sp for responsive font size
                                      //         ),
                                      //       ),
                                      //     ],
                                      //   ),
                                      // ),
                                      // SizedBox(height: 10.h), // Using .h for responsive height
                                      // TextField(
                                      //   style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                                      //     color: AppColors.hintColor,
                                      //     fontWeight: FontWeight.w600,
                                      //     fontSize: 14.sp, // Using .sp for responsive font size
                                      //   ),
                                      //   decoration: InputDecoration(
                                      //     hintText: 'Enter Promo Code',
                                      //     hintStyle: TextStyle(
                                      //       color: AppColors.textPrimaryGrey,
                                      //       fontWeight: FontWeight.w600,
                                      //       fontSize: 14.sp, // Using .sp for responsive font size
                                      //     ),
                                      //     contentPadding: EdgeInsets.symmetric(horizontal: 16.w), // Using .w for responsive width
                                      //     border: OutlineInputBorder(
                                      //       borderSide: BorderSide(color: AppColors.borderColor1),
                                      //       borderRadius: BorderRadius.circular(10.r), // Using .r for responsive radius
                                      //     ),
                                      //     focusedBorder: OutlineInputBorder(
                                      //       borderSide: BorderSide(color: AppColors.borderColor1),
                                      //       borderRadius: BorderRadius.circular(10.r), // Using .r for responsive radius
                                      //     ),
                                      //     enabledBorder: OutlineInputBorder(
                                      //       borderSide: BorderSide(color: AppColors.borderColor1),
                                      //       borderRadius: BorderRadius.circular(10.r), // Using .r for responsive radius
                                      //     ),
                                      //   ),
                                      // )
                                    ],
                                  ),
                                ),
                              ),
                              Flexible(
                                child: Container(
                                  width: double.infinity,
                                  padding: EdgeInsets.all(20.r),
                                  // Using .r for responsive padding
                                  decoration: BoxDecoration(
                                    color:
                                    AppColors.subscriptionPromptSubColor,
                                    borderRadius: BorderRadius.only(
                                      bottomLeft: Radius.circular(20.r),
                                      // Using .r for responsive radius
                                      bottomRight: Radius.circular(
                                        20.r,
                                      ), // Using .r for responsive radius
                                    ),
                                  ),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    // Ensure inner Column doesn't take infinite space
                                    children: [
                                      Text(
                                        'Continue After Trial',
                                        style: TextTheme.of(
                                          context,
                                        ).bodyMedium!.copyWith(
                                          decoration:
                                          TextDecoration.underline,
                                          decorationColor:
                                          AppColors.textPrimaryGrey,
                                          color: AppColors.timeTextColor,
                                          fontWeight: FontWeight.w500,
                                          fontSize:
                                          12.sp, // Using .sp for responsive font size
                                        ),
                                      ),
                                      SizedBox(height: 5.h),
                                      // Using .h for responsive height
                                      Text.rich(
                                        TextSpan(
                                          children: [
                                            TextSpan(
                                              text:
                                              '\$${initialData!.data!.amount}',
                                              style: TextTheme.of(
                                                context,
                                              ).bodyLarge!.copyWith(
                                                color: AppColors.primary,
                                                fontSize:
                                                24.sp, // Making the price more prominent responsively
                                              ),
                                            ),
                                            TextSpan(
                                              text:
                                              ' / ${initialData!.data!.type}',
                                              style: TextTheme.of(
                                                context,
                                              ).bodyMedium!.copyWith(
                                                color:
                                                AppColors
                                                    .subscriptionPriceSubColor,
                                                fontWeight: FontWeight.w600,
                                                fontSize:
                                                14.sp, // Using .sp for responsive font size
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(height: 5.h),
                                      // Using .h for responsive height
                                      Text(
                                        'Get all the benefits for just \$${initialData!.data!.amount} ${initialData!.data!.type}.',
                                        textAlign: TextAlign.center,
                                        style: TextTheme.of(
                                          context,
                                        ).bodyMedium!.copyWith(
                                          color: AppColors.primary,
                                          fontWeight: FontWeight.w600,
                                          fontSize:
                                          12.sp, // Using .sp for responsive font size
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
                      BlocBuilder<SubscriptionBloc, SubscriptionState>(
                        builder: (context, state) {
                          return InkWell(
                            splashColor: AppColors.secondary,
                            splashFactory: InkRipple.splashFactory,
                            onTap: () {
                              context.read<SubscriptionBloc>().add(
                                StartSubscriptionEvent(
                                  subscriptionStartRequest:
                                  SubscriptionStartRequest(
                                    cafeId: cafeId,
                                    subscriptionTypeId:
                                    subscriptionTypeId,
                                    paymentMethod: paymentMethod,
                                    amount: amount,
                                    autoRenew: true,
                                  ),
                                ),
                              );
                            },
                            child: ElevatedButtonWidget(
                              height: 70.h,
                              width: double.infinity,
                              iconEnabled: false,
                              iconLabel: "START FREE TRAIL",
                              color: AppColors.primary,
                              textColor: AppColors.primaryWhiteColor,
                            ),
                          );
                        },
                      )
                          .animate()
                          .fadeIn(duration: 450.ms)
                          .slideY(begin: 0.2, delay: 600.ms),
                    ],
                  ),
                ),
              );
            }
            return SizedBox();
          },
        ),
      ),
    );
  }
}
