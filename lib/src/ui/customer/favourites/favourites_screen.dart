import 'package:dicetable/src/constants/app_colors.dart';
import 'package:dicetable/src/ui/customer/cafe_list/bloc/cafe_list_bloc.dart';
import 'package:dicetable/src/ui/customer/favourites/widget/fav_list_container.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class FavouritesScreen extends StatefulWidget {
  const FavouritesScreen({super.key});

  @override
  State<FavouritesScreen> createState() => _FavouritesScreenState();
}

class _FavouritesScreenState extends State<FavouritesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CafeListBloc>().add(GetFavListEvent());
    });
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
              print('FavListLoaded: ${state.favListResponse.cafes?.length ?? 0} cafes');
            }
            if (state is FavListError) {
              EasyLoading.dismiss();
              print('FavListError: ${state.errorMessage}');
            }
          },
          builder: (context, state) {
            if (state is FavListLoading) {
              // Return an empty widget to preserve the gradient background
              // EasyLoading overlay will handle the loading UI
              return const SizedBox.expand();
            }
            return CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                CupertinoSliverRefreshControl(
                  onRefresh: () async {
                    context.read<CafeListBloc>().add(GetFavListEvent());
                  },
                ),
                SliverAppBar(
                  backgroundColor: Colors.transparent,
                  expandedHeight: 100.h,
                  centerTitle: false,
                  titleSpacing: 20,
                  leadingWidth: 0,
                  title: Text(
                    "Favorites",
                    style: TextTheme.of(context).labelMedium!.copyWith(
                      color: AppColors.primaryWhiteColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 18.sp,
                    ),
                  ),
                  actionsPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                  actions: [
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
                                  '8', // Replace with dynamic count if available
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
                  leading: const SizedBox(),
                  flexibleSpace: FlexibleSpaceBar(
                    centerTitle: false,
                    collapseMode: CollapseMode.parallax,
                    stretchModes: const [
                      StretchMode.zoomBackground,
                    ],
                  ),
                ),
                SliverToBoxAdapter(
                  child: BlocBuilder<CafeListBloc, CafeListState>(
                    builder: (context, state) {
                      if (state is FavListLoaded) {
                        if (state.favListResponse.cafes == null || state.favListResponse.cafes!.isEmpty) {
                          return Container(
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
                              );
                            },
                          );
                        }
                      }
                      if (state is FavListError) {
                        return Center(
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 20.h),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Failed to load favorites: ${state.errorMessage}',
                                  style: TextStyle(
                                    color: AppColors.primaryWhiteColor,
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                SizedBox(height: 20.h),
                                ElevatedButton(
                                  onPressed: () {
                                    context.read<CafeListBloc>().add(GetFavListEvent());
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primary,
                                    foregroundColor: AppColors.primaryWhiteColor,
                                    padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
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