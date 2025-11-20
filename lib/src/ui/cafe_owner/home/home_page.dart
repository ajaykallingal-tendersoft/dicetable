import 'package:auto_size_text/auto_size_text.dart';
import 'package:badges/badges.dart' as badges;
import 'package:google_fonts/google_fonts.dart';
import 'package:soloseaters/src/constants/app_colors.dart';
import 'package:soloseaters/src/ui/cafe_owner/home/bloc/home_bloc.dart';
import 'package:soloseaters/src/ui/cafe_owner/notification/bloc/notification_bloc.dart';
import 'package:soloseaters/src/ui/cafe_owner/notification/count_controller.dart';
import 'package:soloseaters/src/utils/data/auth_session_manager.dart';
import 'package:soloseaters/src/utils/data/object_factory.dart';
import 'package:soloseaters/src/utils/data/sign_out.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'widget/expandable_card.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:get/get.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final CounterController controller = Get.find<CounterController>();
  bool _initialLoadComplete = false; // ✅ Track if initial data is loaded

  @override
  void initState() {
    super.initState();
    context.read<HomeBloc>().add(GetHomeDataEvent());
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NotificationBloc>().add(FetchNotifications());
    });
  }

  @override
  Widget build(BuildContext context) {
    final isTabletOrLarger = ResponsiveBreakpoints.of(
      context,
    ).largerThan(MOBILE);

    return Container(
      decoration: const BoxDecoration(
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
      child: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverPadding(
              padding: EdgeInsets.symmetric(horizontal: 20.h, vertical: 10.h),
              sliver: SliverAppBar(
                backgroundColor: Colors.transparent,
                expandedHeight: isTabletOrLarger ? 130.h : 90.h,
                leading: const SizedBox(),
                flexibleSpace: FlexibleSpaceBar(
                  centerTitle: false,
                  collapseMode: CollapseMode.parallax,
                  stretchModes: const [StretchMode.zoomBackground],
                  background: SizedBox.fromSize(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        BlocConsumer<NotificationBloc, NotificationState>(
                          listener: (context, state) async {
                            if (state is NotificationLoaded) {
                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                controller.notificationBadgeAmount.value =
                                    state.notificationItems.data.unread.length;
                              });
                            }
                          },
                          builder: (context, state) {
                            return Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                AutoSizeText(
                                  "SOLO SEATERS",
                                  style: GoogleFonts.montserrat(
                                    color: AppColors.primaryWhiteColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: isTabletOrLarger ? 28.sp : 24.sp,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(right: 6.0),
                                  child: InkWell(
                                    onTap: () {
                                      GoRouter.of(
                                        context,
                                      ).push('/notification');
                                    },
                                    child: Obx(() {
                                      return controller
                                                  .notificationBadgeAmount
                                                  .value >
                                              0
                                          ? badges.Badge(
                                            position: badges
                                                .BadgePosition.topEnd(
                                              top: 0,
                                              end: -5,
                                            ),
                                            badgeAnimation:
                                                badges.BadgeAnimation.slide(),
                                            showBadge: true,
                                            badgeStyle: badges.BadgeStyle(
                                              shape: badges.BadgeShape.circle,

                                              badgeColor: Colors.red,
                                              padding: EdgeInsets.all(4),
                                            ),
                                            badgeContent: Text(
                                              // Logic: If greater than 99, show "99+", otherwise show number
                                              int.parse(
                                                        controller
                                                            .notificationBadgeAmount
                                                            .value
                                                            .toString(),
                                                      ) >
                                                      99
                                                  ? "99+"
                                                  : controller
                                                      .notificationBadgeAmount
                                                      .value
                                                      .toString(),
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 10.sp,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            child: Icon(
                                              Icons.notifications_outlined,
                                              color:
                                                  AppColors.primaryWhiteColor,
                                              size: 28.w,
                                            ),
                                          )
                                          : Icon(
                                            Icons.notifications_outlined,
                                            color: AppColors.primaryWhiteColor,
                                            size: 28.w,
                                          );
                                    }),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                        const Gap(25),
                        Text(
                          "Hi, ${ObjectFactory().prefs.getCafeUserName()}" ??
                              "Hi",
                          style: TextTheme.of(context).labelMedium!.copyWith(
                            color: AppColors.primaryWhiteColor,
                            fontWeight: FontWeight.w600,
                            fontSize: 18.sp,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.only(bottom: 20),
              sliver: BlocConsumer<HomeBloc, HomeState>(
                builder: (context, state) {
                  // ✅ Always show content if available (even during loading)
                  if (state is HomeLoaded) {
                    return AnimationLimiter(
                      child: SliverList(
                        delegate: SliverChildBuilderDelegate((context, index) {
                          final card = state.cards[index];
                          return AnimationConfiguration.staggeredList(
                            position: index,
                            duration: const Duration(milliseconds: 375),
                            child: SlideAnimation(
                              verticalOffset: 50.0,
                              child: FadeInAnimation(
                                child: ExpandableCard(index: index, card: card),
                              ),
                            ),
                          );
                        }, childCount: state.cards.length),
                      ),
                    );
                  }

                  if (state is HomeError) {
                    return SliverFillRemaining(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.error_outline,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            const Gap(16),
                            Text(
                              'Something went wrong!',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 16,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const Gap(16),
                            ElevatedButton(
                              onPressed: () {
                                context.read<HomeBloc>().add(
                                  GetHomeDataEvent(),
                                );
                              },
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  // ✅ Show empty space during initial load (EasyLoading will overlay)
                  return const SliverToBoxAdapter(child: SizedBox.shrink());
                },
                listener: (BuildContext context, HomeState state) {
                  // ✅ Show EasyLoading for ALL loading states
                  if (state is HomeLoading) {
                    EasyLoading.show();
                  }

                  if (state is DiceTableUpdateLoading) {
                    EasyLoading.show();
                  }

                  if (state is HomeLoaded) {
                    EasyLoading.dismiss();
                    _initialLoadComplete = true; // ✅ Mark initial load complete

                    if (state.homeResponse.status == false) {
                      if (state.homeResponse.message!.contains(
                            "Unauthorized",
                          ) &&
                          AuthSessionManager.consumeRefreshFailureFlag()) {
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          SignOut().logout(context);
                          Fluttertoast.showToast(
                            fontSize: 14.sp,
                            backgroundColor: AppColors.primaryWhiteColor,
                            textColor: AppColors.appRedColor,
                            gravity: ToastGravity.BOTTOM,
                            msg:
                                "Your session has expired. Please sign in again.",
                          );
                        });
                      }
                    }
                  }

                  if (state is HomeError) {
                    EasyLoading.dismiss();

                    if ((state.errorMessage.contains("Unauthorized") ||
                            state.errorMessage.contains("status code of 401") ||
                            state.errorMessage.contains("UnAuthorized")) &&
                        AuthSessionManager.consumeRefreshFailureFlag()) {
                      SignOut().logout(context);
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        Fluttertoast.showToast(
                          fontSize: 14.sp,
                          backgroundColor: AppColors.primaryWhiteColor,
                          textColor: AppColors.appRedColor,
                          gravity: ToastGravity.BOTTOM,
                          msg:
                              "Your session has expired. Please sign in again.",
                        );
                      });
                    } else {
                      Fluttertoast.showToast(
                        fontSize: 14.sp,
                        backgroundColor: AppColors.primaryWhiteColor,
                        textColor: AppColors.appRedColor,
                        gravity: ToastGravity.BOTTOM,
                        msg: state.errorMessage,
                      );
                    }
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}



/*class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final CounterController controller = Get.find<CounterController>();

  @override
  void initState() {
    super.initState();
    context.read<HomeBloc>().add(GetHomeDataEvent());
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NotificationBloc>().add(FetchNotifications());
    });
  }

  @override
  Widget build(BuildContext context) {
    final isTabletOrLarger = ResponsiveBreakpoints.of(
      context,
    ).largerThan(MOBILE);
    return Container(
      decoration: const BoxDecoration(
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
      child: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverPadding(
              padding: EdgeInsets.symmetric(horizontal: 20.h, vertical: 10.h),
              sliver: SliverAppBar(
                backgroundColor: Colors.transparent,
                expandedHeight: isTabletOrLarger ? 130.h : 90.h,
                leading: const SizedBox(),
                flexibleSpace: FlexibleSpaceBar(
                  centerTitle: false,
                  collapseMode: CollapseMode.parallax,
                  stretchModes: const [StretchMode.zoomBackground],
                  background: SizedBox.fromSize(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        BlocConsumer<NotificationBloc, NotificationState>(
                          listener: (context, state) async {
                            if (state is NotificationLoaded) {
                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                controller.notificationBadgeAmount.value =
                                    state.notificationItems.data.unread.length;
                              });
                            }
                          },
                          builder: (context, state) {
                            return Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                AutoSizeText(
                                  "SOLO SEATERS",
                                  style: GoogleFonts.montserrat(
                                    color: AppColors.primaryWhiteColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: isTabletOrLarger ? 28.sp : 24.sp,
                                  ),
                                ),
                                InkWell(
                                  onTap: () {
                                    GoRouter.of(context).push('/notification');
                                  },
                                  child: Obx(() {
                                    return controller
                                                .notificationBadgeAmount
                                                .value >
                                            0
                                        ? badges.Badge(
                                          position: badges.BadgePosition.topEnd(
                                            top: 0,
                                            end: 0,
                                          ),
                                          badgeAnimation:
                                              badges.BadgeAnimation.slide(),
                                          showBadge: true,
                                          badgeStyle: badges.BadgeStyle(
                                            shape: badges.BadgeShape.circle,
                                            borderRadius: BorderRadius.circular(
                                              10.r,
                                            ),
                                            badgeColor: Colors.red,
                                            padding: EdgeInsets.symmetric(
                                              horizontal: 6.w,
                                              vertical: 2.h,
                                            ),
                                          ),
                                          badgeContent: Text(
                                            controller
                                                .notificationBadgeAmount
                                                .value
                                                .toString(),
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          child:  Icon(
                                            Icons.notifications_outlined,
                                            color: AppColors.primaryWhiteColor,
                                            size: 28.w,
                                          ),
                                        )
                                        :  Icon(
                                          Icons.notifications_outlined,
                                          color: AppColors.primaryWhiteColor,
                                          size: 28.w,
                                        );
                                  }),
                                ),
                              ],
                            );
                          },
                        ),
                        const Gap(25),
                        Text(
                          "Hi, ${ObjectFactory().prefs.getCafeUserName()}" ??
                              "Hi",
                          style: TextTheme.of(context).labelMedium!.copyWith(
                            color: AppColors.primaryWhiteColor,
                            fontWeight: FontWeight.w600,
                            fontSize: 18.sp,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.only(bottom: 20),
              sliver: BlocConsumer<HomeBloc, HomeState>(
                builder: (context, state) {
                  if (state is HomeLoaded) {
                    EasyLoading.dismiss();
                    return AnimationLimiter(
                      child: SliverList(
                        delegate: SliverChildBuilderDelegate((context, index) {
                          final card = state.cards[index];
                          return AnimationConfiguration.staggeredList(
                            position: index,
                            duration: const Duration(milliseconds: 375),
                            child: SlideAnimation(
                              verticalOffset: 50.0,
                              child: FadeInAnimation(
                                child: ExpandableCard(index: index, card: card),
                              ),
                            ),
                          );
                        }, childCount: state.cards.length),
                      ),
                    );
                  }
                  if (state is HomeError) {
                    EasyLoading.dismiss();
                    return SliverFillRemaining(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.error_outline,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            const Gap(16),
                            Text(
                              'Something went wrong!.}',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 16,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const Gap(16),
                            ElevatedButton(
                              onPressed: () {
                                context.read<HomeBloc>().add(
                                  GetHomeDataEvent(),
                                );
                              },
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      ),
                    );
                  }
                  return const SliverToBoxAdapter(child: SizedBox.shrink());
                },
                listener: (BuildContext context, HomeState state) {
                  if (state is HomeLoading) {
                    EasyLoading.show();
                  }
                  if(state is DiceTableUpdateLoading) {
                    EasyLoading.show();
                  }
                  // if (state is HomeLoaded) {
                  //   EasyLoading.dismiss();
                  //   if (state.subscriptionStatus == false) {
                  //     Fluttertoast.showToast(
                  //       fontSize: 14.sp, 
                  //       backgroundColor: AppColors.primaryWhiteColor,
                  //       textColor: AppColors.appRedColor,
                  //       gravity: ToastGravity.BOTTOM,
                  //       msg: "You dont have an active subscription. Please subscribe to access all features.",
                  //     );
                  //      SignOut().logout(context);
                  //   }
                  // }
                  if (state is HomeLoaded) {
                    if(state.homeResponse.status == false) {
                      if(state.homeResponse.message!.contains("Unauthorized")) {
                        EasyLoading.dismiss();
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          SignOut().logout(context);
                          Fluttertoast.showToast(
                            fontSize: 14.sp,
                            backgroundColor: AppColors.primaryWhiteColor,
                            textColor: AppColors.appRedColor,
                            gravity: ToastGravity.BOTTOM,
                            msg:
                            "Your session has expired. Please sign in again.",
                          );
                        });
                      }
                    }
                  }
                    if (state is HomeError) {
                    if (state.errorMessage.contains("Unauthorized") ||
                        state.errorMessage.contains("status code of 401") || state.errorMessage.contains("UnAuthorized")
                    ) {
                      EasyLoading.dismiss();
                      SignOut().logout(context);
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        Fluttertoast.showToast(
                          fontSize: 14.sp,
                          backgroundColor: AppColors.primaryWhiteColor,
                          textColor: AppColors.appRedColor,
                          gravity: ToastGravity.BOTTOM,
                          msg:
                          "Your session has expired. Please sign in again.",
                        );
                      });
                    }else {
                      Fluttertoast.showToast(
                        fontSize: 14.sp,
                        backgroundColor: AppColors.primaryWhiteColor,
                        textColor: AppColors.appRedColor,
                        gravity: ToastGravity.BOTTOM,
                        msg: state.errorMessage,
                      );
                    }
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
*/