import 'package:dicetable/src/constants/app_colors.dart';
import 'package:dicetable/src/ui/customer/home/widget/cafe_marker_map_widget.dart';
import 'package:dicetable/src/ui/customer/home/widget/cafe_search_bar.dart';
import 'package:dicetable/src/ui/customer/home/widget/filter_bottom_sheet.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

class CustomerHomePage extends StatefulWidget {
  const CustomerHomePage({super.key});

  @override
  State<CustomerHomePage> createState() => _CustomerHomePageState();
}

class _CustomerHomePageState extends State<CustomerHomePage> {

  void showFilterBottomSheet(BuildContext context) {
    showModalBottomSheet(
      constraints: BoxConstraints(minWidth: double.infinity),
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => const FilterBottomSheet(),
    );
  }
  @override
  Widget build(BuildContext context) {
    return   Container(
      height: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary,
            AppColors.primary,
            Colors.transparent,
            Colors.transparent,
          ],
          stops: [0.0, 0.5, 0.75, 1.0],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: SafeArea(
        child: CustomScrollView(
          physics: const NeverScrollableScrollPhysics(),
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
                expandedHeight: 80.h,
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

                      ],
                    ),
                  ),

                ),
              ),
            ),

            SliverToBoxAdapter(
              child: CafeSearchBar(
                onSearch: (query) {
                  // Call your API or filter list
                  print('Search for: $query');
                },
                onFilterTap: ()  => showFilterBottomSheet(context),
              ),
            ),
            SliverToBoxAdapter(
              child: Container(
                height: MediaQuery.sizeOf(context).height,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.primaryWhiteColor,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                  child: CafeMarkerMapWidget(),
                ),
              ),
            ),

          ],
        ),
      ),
    );
  }
}
