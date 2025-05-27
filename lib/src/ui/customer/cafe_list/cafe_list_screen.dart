import 'package:dicetable/src/constants/app_colors.dart';
import 'package:dicetable/src/ui/customer/cafe_list/bloc/cafe_list_bloc.dart';
import 'package:dicetable/src/ui/customer/cafe_list/widget/cafe_list_container_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';


class CafeListScreen extends StatefulWidget {
  const CafeListScreen({super.key});

  @override
  State<CafeListScreen> createState() => _CafeListScreenState();
}

class _CafeListScreenState extends State<CafeListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CafeListBloc>().add(GetCafeListEvent());
    });
  }
  @override
  Widget build(BuildContext context) {
    return Container(
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
                  child: BlocConsumer<CafeListBloc, CafeListState>(
                    listener: (context, state) {
                      // Handle error states or show success messages
                      if (state is CafeListError) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(state.errorMessage),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    },
                    builder: (context, state) {
                      if (state is CafeListLoading) {
                        EasyLoading.show();
                      } else if (state is CafeListLoaded) {
                        EasyLoading.dismiss();
                        return ListView.builder(
                          physics: NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: state.cafeListResponse.cafes!.length,
                          itemBuilder: (context, index) {
                            final cafe = state.cafeListResponse.cafes![index];
                            return CafeListCard(
                              cafes: cafe,
                              isLoading: false, // No specific loading for this cafe
                              onFavoriteToggle: () => context.read<CafeListBloc>().add(
                                  ToggleFavoriteEvent(index)
                              ),
                            );
                          },
                        );
                      } else if (state is FavoriteToggleLoading) {
                        return ListView.builder(
                          physics: NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: state.cafeListResponse.cafes!.length,
                          itemBuilder: (context, index) {
                            final cafe = state.cafeListResponse.cafes![index];
                            final isThisCafeLoading = state.toggledCafeIndex == index;

                            return CafeListCard(
                              cafes: cafe,
                              isLoading: isThisCafeLoading,
                              onFavoriteToggle: isThisCafeLoading
                                  ? null
                                  : () => context.read<CafeListBloc>().add(
                                  ToggleFavoriteEvent(index)
                              ),
                            );
                          },
                        );
                      } else if (state is CafeListError) {
                        EasyLoading.dismiss();
                        return Center(
                          child: Padding(
                            padding: const EdgeInsets.all(50.0),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.error_outline,
                                  size: 60,
                                  color: AppColors.primaryWhiteColor,
                                ),
                                Gap(16),
                                Text(
                                  'Failed to load cafes',
                                  style: TextStyle(
                                    color: AppColors.primaryWhiteColor,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Gap(8),
                                Text(
                                  state.errorMessage,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: AppColors.primaryWhiteColor.withOpacity(0.8),
                                    fontSize: 14,
                                  ),
                                ),
                                Gap(16),
                                ElevatedButton(
                                  onPressed: () {
                                    context.read<CafeListBloc>().add(GetCafeListEvent());
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primaryWhiteColor,
                                    foregroundColor: AppColors.primary,
                                  ),
                                  child: Text('Retry'),
                                ),
                              ],
                            ),
                          ),
                        );
                      }

                      return SizedBox.shrink();
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      );
  }
}
