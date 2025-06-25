import 'package:badges/badges.dart' as badges;
import 'package:dicetable/src/constants/app_colors.dart';
import 'package:dicetable/src/ui/cafe_owner/home/bloc/home_bloc.dart';
import 'package:dicetable/src/ui/cafe_owner/notification/bloc/notification_bloc.dart';
import 'package:dicetable/src/ui/cafe_owner/notification/count_controller.dart';
import 'package:dicetable/src/utils/data/object_factory.dart';
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

  @override
  void initState() {
    super.initState();
    context.read<HomeBloc>().add(GetHomeDataEvent());
    // Fetch notifications
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
            // CupertinoSliverRefreshControl(
            //   onRefresh: () async {
            //     context.read<HomeBloc>().add(GetHomeDataEvent());
            //   },
            // ),
            SliverPadding(
              padding: EdgeInsets.symmetric(horizontal: 20.h, vertical: 10.h),
              sliver: SliverAppBar(
                backgroundColor: Colors.transparent,
                expandedHeight: isTabletOrLarger ? 150.h : 110.h,
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
                                Text(
                                  "DICE TABLE",
                                  style: TextTheme.of(
                                    context,
                                  ).labelMedium!.copyWith(
                                    color: AppColors.primaryWhiteColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 30.sp,
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
                                            shape: badges.BadgeShape.square,
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                            badgeColor: Colors.red,
                                            padding: EdgeInsets.symmetric(
                                              horizontal: 6,
                                              vertical: 2,
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
                                          child: const Icon(
                                            Icons.notifications_outlined,
                                            color: AppColors.primaryWhiteColor,
                                            size: 35,
                                          ),
                                        )
                                        : const Icon(
                                          Icons.notifications_outlined,
                                          color: AppColors.primaryWhiteColor,
                                          size: 35,
                                        );
                                  }),
                                ),
                              ],
                            );
                          },
                        ),
                        const Gap(30),
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
                  } else if (state is HomeLoading) {
                    EasyLoading.show();
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
                              'Error: ${state.errorMessage}',
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
                  if (state is HomeLoaded) {
                    if (state.subscriptionStatus == false) {
                      Fluttertoast.showToast(
                        backgroundColor: AppColors.primaryWhiteColor,
                        textColor: AppColors.appRedColor,
                        gravity: ToastGravity.BOTTOM,
                        msg: "Your subscription have expired!.",
                      );
                      context.go('/login');
                    }
                  }
                  if (state is HomeError) {
                    EasyLoading.dismiss();
                    if (state.errorMessage.contains("UnAuthorized") ||
                        state.errorMessage.contains("status code of 401") ||
                        state.errorMessage.contains("Unknown error")) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        context.go('/login');
                        Fluttertoast.showToast(
                          backgroundColor: AppColors.primaryWhiteColor,
                          textColor: AppColors.appGreenColor,
                          gravity: ToastGravity.BOTTOM,
                          msg:
                              "Exception caught for UnAuthorized access. Please login again!",
                        );
                      });
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
