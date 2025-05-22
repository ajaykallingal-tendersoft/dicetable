import 'package:dicetable/src/constants/app_colors.dart';
import 'package:dicetable/src/ui/cafe_owner/home/bloc/home_bloc.dart';
import 'package:dicetable/src/utils/data/object_factory.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import '../notification/notification_cubit.dart';
import 'widget/expandable_card.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return   Container(
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
            CupertinoSliverRefreshControl(
              onRefresh: () async {
                // context.read<CardCubit>().fetchCards();
              },
            ),

            SliverPadding(
              padding:  EdgeInsets.symmetric(horizontal: 20.h, vertical: 20.h),
              sliver: SliverAppBar(
                backgroundColor: Colors.transparent,
                expandedHeight: 120.h,
                leading: const SizedBox(),
                flexibleSpace: FlexibleSpaceBar(
                  centerTitle: false,
                  collapseMode: CollapseMode.parallax,
                  stretchModes: const [
                    StretchMode.zoomBackground,
                  ],
                  background: SizedBox.fromSize(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                             Text(
                              "Dice Table",
                             style: TextTheme.of(context).labelMedium!.copyWith(
                      color: AppColors.primaryWhiteColor,
                      fontWeight:  FontWeight.bold,
                      fontSize: 30.sp,
                    ),
                            ),
                            BlocBuilder<NotificationCubit, int>(
                              builder: (context, count) {
                                return InkWell(
                                  onTap: () {
                                    GoRouter.of(context).push('/notification');
                                    // context.push('/notification');
                                  },
                                  child: Stack(
                                    children: [
                                      const Icon(
                                        Icons.notifications_outlined,
                                        color: AppColors.primaryWhiteColor,
                                        size: 35,
                                      ),
                                      if (count > 0)
                                        Positioned(
                                          right: 0,
                                          top: 0,
                                          child: Container(
                                            padding: const EdgeInsets.all(4),
                                            decoration: const BoxDecoration(
                                              color: AppColors.appRedColor,
                                              shape: BoxShape.circle,
                                            ),
                                            constraints: const BoxConstraints(
                                              minWidth: 16,
                                              minHeight: 16,
                                            ),
                                            child: Center(
                                              child: Text(
                                                '$count',
                                                style: const TextStyle(
                                                  color: AppColors.primaryWhiteColor,
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                );
                              },
                            )
                          ],
                        ),
                        const Gap(20),
                         Text(
                          ObjectFactory().prefs.getCafeUserName() ?? "Hi",
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
            // SliverPadding(
            //   padding:
            //   const EdgeInsets.only(bottom: 20),
            //   sliver: BlocBuilder<HomeBloc, HomeState>(
            //     builder: (context, state) {
            //       if(state is HomeLoaded) {
            //         return AnimationLimiter(
            //           child: SliverList(
            //             delegate: SliverChildBuilderDelegate(
            //                   (context, index) {
            //                 final card = state.cards;
            //                 return AnimationConfiguration.staggeredList(
            //                   position: index,
            //                   duration: const Duration(milliseconds: 375),
            //                   child: SlideAnimation(
            //                     verticalOffset: 50.0,
            //                     child: FadeInAnimation(
            //                       child:
            //                       ExpandableCard(index: index, card: card),
            //                     ),
            //                   ),
            //                 );
            //               },
            //               childCount: state.cards.length,
            //             ),
            //           ),
            //         );
            //       }
            //     },
            //   ),
            // ),
          ],
        ),
      ),
    );
  }
}
