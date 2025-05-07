import 'package:dicetable/src/constants/app_colors.dart';
import 'package:dicetable/src/ui/customer/cafe_list/bloc/cafe_list_bloc.dart';
import 'package:dicetable/src/ui/customer/cafe_list/widget/cafe_list_container_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

class CafeListScreen extends StatelessWidget {
  const CafeListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
  create: (context) => CafeListBloc(),
  child: Container(
      height: double.infinity,
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
                expandedHeight: 140.h,
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
                            InkWell(
                              onTap: () {
                                context.push('/notification');
                              },
                              child: Stack(
                                children: [
                                  const Icon(
                                    Icons.notifications_outlined,
                                    color: AppColors.primaryWhiteColor,
                                    size: 35,
                                  ),
                                  // if (count > 0)
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
                                          '8',
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
                            ),
                          ],
                        ),
                        const Gap(20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Cafes near by you",
                              style: TextTheme.of(context).labelMedium!.copyWith(
                                color: AppColors.primaryWhiteColor,
                                fontWeight: FontWeight.w600,
                                fontSize: 14.sp,
                              ),
                            ),
                            IconButton(
                              icon: SvgPicture.asset(
                                'assets/svg/search-filter.svg',
                                fit: BoxFit.scaleDown,
                                color: AppColors.primaryWhiteColor,
                              ),
                              onPressed: () {},
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            SliverPadding(
              padding: EdgeInsets.only(bottom: 50),
              sliver: SliverToBoxAdapter(
                child: BlocBuilder<CafeListBloc, CafeState>(
                  builder: (context, state) {
                    return ListView.builder(
                      physics: NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: state.cafes.length,
                      itemBuilder: (context, index) {
                        final cafe = state.cafes[index];
                        return CafeListCard(
                          cafe: cafe,
                          onFavoriteToggle: () => context.read<CafeListBloc>().add(ToggleFavoriteEvent(index)),
                        );
                      },
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    ),
);
  }
}
