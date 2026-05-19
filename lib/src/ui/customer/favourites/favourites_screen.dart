import 'package:badges/badges.dart' as badges;
import 'package:soloseaters/src/constants/app_colors.dart';
import 'package:soloseaters/src/model/customer/cafe/favourite_list_response.dart';
import 'package:soloseaters/src/ui/cafe_owner/notification/count_controller.dart';
import 'package:soloseaters/src/ui/customer/cafe_list/bloc/cafe_list_bloc.dart';
import 'package:soloseaters/src/ui/customer/favourites/widget/fav_list_container.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:responsive_framework/responsive_framework.dart';

class FavouritesScreen extends StatefulWidget {
  const FavouritesScreen({super.key});

  @override
  State<FavouritesScreen> createState() => _FavouritesScreenState();
}

class _FavouritesScreenState extends State<FavouritesScreen> {
  final CounterController controller = Get.find<CounterController>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CafeListBloc>().add(GetFavListEvent());
    });
  }

  FavCafe _convertCafeToFavCafe(dynamic cafe) {
    if (cafe is FavCafe) {
      return cafe;
    }
    return FavCafe(
      id: cafe.id,
      name: cafe.name,
      photo: cafe.photo,
      venueDescription: cafe.venueDescription,
      tableTypes: cafe.tableTypes,
      workingHours:
          (cafe.workingHours as List<dynamic>?)
              ?.map(
                (wh) => FavWorkingHour(
                  day: wh.day,
                  opening: wh.opening,
                  closing: wh.closing,
                ),
              )
              .toList(),
      favourites: cafe.favourites,
      bookingStatus: cafe.bookingStatus,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
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
        child: BlocConsumer<CafeListBloc, CafeListState>(
          listener: (context, state) {
            if (state is FavListLoading) {
              EasyLoading.show();
            }
            if (state is FavListLoaded) {
              EasyLoading.dismiss();
              print(
                'FavListLoaded: ${state.favListResponse.cafes?.length ?? 0} cafes',
              );
            }
            if (state is FavListError) {
              EasyLoading.dismiss();
              print('FavListError: ${state.errorMessage}');
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.errorMessage),
                  backgroundColor: AppColors.appRedColor,
                ),
              );
            }

            if (state is FavoriteToggleLoading) {}
          },
          builder: (context, state) {
            final isTabletOrLarger = ResponsiveBreakpoints.of(
              context,
            ).largerThan(MOBILE);
            return CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverAppBar(
                  leading: SizedBox.shrink(),
                  backgroundColor: AppColors.primary,
                  expandedHeight: isTabletOrLarger ? 70.h : 0.h,
                  floating: false,
                  pinned: true,
                  flexibleSpace: FlexibleSpaceBar(
                    centerTitle: false,
                    collapseMode: CollapseMode.parallax,
                    stretchModes: const [StretchMode.zoomBackground],
                    background: Container(
                      padding: EdgeInsets.only(
                        top: MediaQuery.of(context).padding.top,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Padding(
                              padding: EdgeInsets.only(left: 20),
                              child: Text(
                                "Favourites",
                                style: TextTheme.of(
                                  context,
                                ).labelMedium!.copyWith(
                                  color: AppColors.primaryWhiteColor,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 18.sp,
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: 15,
                              vertical: 10,
                            ),
                            child: InkWell(
                              onTap: () {
                                context.push('/notification');
                              },
                              child: Obx(() {
                                return controller
                                            .notificationBadgeAmount
                                            .value >
                                        0
                                    ? badges.Badge(
                                      position: badges.BadgePosition.topEnd(
                                        top: 0,
                                       end: int.parse(
                                          controller
                                              .notificationBadgeAmount
                                              .value
                                              .toString(),
                                        ) >
                                        99 ? -12 :-2,
                                      ),
                                      badgeAnimation:
                                          badges.BadgeAnimation.slide(),
                                      showBadge: true,
                                      badgeStyle: badges.BadgeStyle(
                                        shape: badges.BadgeShape.circle,
                                        // borderRadius: BorderRadius.circular(
                                        //   10.r,
                                        // ),
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
                                        color: AppColors.primaryWhiteColor,
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
                      ),
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: BlocBuilder<CafeListBloc, CafeListState>(
                    builder: (context, state) {
                      // Handle loaded favorite list
                      if (state is FavListLoaded) {
                        if (state.favListResponse.cafes == null ||
                            state.favListResponse.cafes!.isEmpty) {
                          return SizedBox(
                            height: MediaQuery.of(context).size.height * 0.6,
                            child: Center(
                              child: Text(
                                "No favourites yet",
                                style: TextStyle(
                                  color: AppColors.primaryWhiteColor,
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          );
                        } else {
                          final favoriteCafes = state.favListResponse.cafes!;

                          return ListView.builder(
                            physics: const NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            itemCount: favoriteCafes.length,
                            itemBuilder: (context, index) {
                              final cafe = favoriteCafes[index];
                              return FavListCard(
                                cafes: cafe,
                                index: index,
                                isLoading: false, // No loading for normal state
                              );
                            },
                          );
                        }
                      }
                      // Handle favorite toggle loading state
                      else if (state is FavoriteToggleLoading) {
                        // Get the cafe list from the loading state
                        final cafeList = state.cafeListResponse.cafes ?? [];

                        if (cafeList.isEmpty) {
                          return SizedBox(
                            height: MediaQuery.of(context).size.height * 0.6,
                            child: Center(
                              child: Text(
                                "No favourites yet",
                                style: TextStyle(
                                  color: AppColors.primaryWhiteColor,
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          );
                        }

                        return ListView.builder(
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: cafeList.length,
                          itemBuilder: (context, index) {
                            final cafe = cafeList[index];
                            final favCafe = _convertCafeToFavCafe(cafe);
                            final isThisCafeLoading =
                                state.toggledCafeIndex == index;

                            return FavListCard(
                              cafes: favCafe,
                              index: index,
                              isLoading: isThisCafeLoading,
                            );
                          },
                        );
                      }
                      // Handle error state
                      else if (state is FavListError) {
                        return Center(
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 20.h),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.error_outline,
                                  size: 64,
                                  color: AppColors.primaryWhiteColor,
                                ),
                                SizedBox(height: 16.h),
                                Text(
                                  state.errorMessage,
                                  style: TextStyle(
                                    color: AppColors.primaryWhiteColor,
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                SizedBox(height: 16.h),
                                ElevatedButton(
                                  onPressed: () {
                                    context.read<CafeListBloc>().add(
                                      GetFavListEvent(),
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primaryWhiteColor,
                                    foregroundColor: AppColors.primary,
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 20.w,
                                      vertical: 10.h,
                                    ),
                                    textStyle: TextStyle(
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  child: const Text('Retry'),
                                ),
                              ],
                            ),
                          ),
                        );
                      } else if (state is FavListLoading) {
                        // When in FavListLoading state, show a loading indicator below the AppBar
                        EasyLoading.show();
                        return SizedBox.shrink();
                      }

                      return const SizedBox(); // Fallback for unhandled states
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
