import 'package:dicetable/src/constants/app_colors.dart';
import 'package:dicetable/src/model/customer/cafe/cafe_list_request.dart';
import 'package:dicetable/src/ui/customer/cafe_list/bloc/cafe_list_bloc.dart';
import 'package:dicetable/src/ui/customer/cafe_list/widget/cafe_list_container_widget.dart';
import 'package:dicetable/src/ui/customer/cafe_list/widget/cafe_list_filter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:dicetable/src/utils/data/object_factory.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:responsive_framework/responsive_framework.dart';




class CafeListScreen extends StatefulWidget {
  const CafeListScreen({super.key});

  @override
  State<CafeListScreen> createState() => _CafeListScreenState();
}

class _CafeListScreenState extends State<CafeListScreen> {
  late final String latitude;
  late final String longitude;
  @override
  void initState() {
    super.initState();
    print("Latitude::${ObjectFactory().prefs.getLatitude().toString()}");
    print("Latitude::${ObjectFactory().prefs.getLongitude().toString()}");

    latitude = ObjectFactory().prefs.getLatitude().toString();
    longitude = ObjectFactory().prefs.getLongitude().toString();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchCafeListWithLocation();
    });
  }
  void _fetchCafeListWithLocation() {
    final double? lat = latitude != null ? double.tryParse(latitude) : 0.0;
    final double? lon = longitude != null ? double.tryParse(longitude) : 0.0;
    final isGuest = ObjectFactory().prefs.isGuestUser() == true;
    final deviceToken = isGuest ? ObjectFactory().prefs.getDeviceID() ?? '' : '';

    if (lat != null && lon != null) {
      context.read<CafeListBloc>().add(
        GetCafeListEvent(
          cafeListRequest: CafeListRequest(
            latitude: lat,
            longitude: lon,
            diceTableFilter: [],
            accommodationsFilter: [],
            openTime: "",
            closeTime: "",
            search: "",
            deviceToken: deviceToken,
          ),
        ),
      );
    } else {
      context.read<CafeListBloc>().add(
        GetCafeListEvent(
          cafeListRequest: CafeListRequest(
            latitude: 0.0, // Fallback value
            longitude: 0.0,
            diceTableFilter: [],
            accommodationsFilter: [],
            openTime: "",
            closeTime: "",
            search: "",
            deviceToken: deviceToken,
          ),
        ),
      );

      Fluttertoast.showToast(
        msg: "Location data unavailable. Using default location.",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: AppColors.appRedColor,
        textColor: AppColors.primaryWhiteColor,
      );
    }
  }

  void showFilterBottomSheet(BuildContext context) async { // Make it async
    await showModalBottomSheet(
      constraints: BoxConstraints(
        maxHeight: MediaQuery
            .sizeOf(context)
            .height * 0.9,
        minWidth: double.infinity,
      ),
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) =>
          FractionallySizedBox(
              child: const CafeListFilter()),
    );
    // _fetchCafeListWithLocation();
  }

  @override
  Widget build(BuildContext context) {
    final isTabletOrLarger = ResponsiveBreakpoints.of(context).largerThan(MOBILE);
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
              SliverAppBar(
                pinned: false,
                backgroundColor: Colors.transparent,
                expandedHeight: isTabletOrLarger ? 110.h : 10.h,
                leading: SizedBox.shrink(),
                elevation: 0,
                flexibleSpace: FlexibleSpaceBar(
                  collapseMode: CollapseMode.parallax,
                  background: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20.h),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Dice Table",
                              style: TextTheme.of(context).labelMedium!.copyWith(
                                color: AppColors.primaryWhiteColor,
                                fontWeight: FontWeight.bold,
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
                                      child: const Center(
                                        child: Text(
                                          '8',
                                          style: TextStyle(
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
                        SizedBox(height: 10.h),
                      ],
                    ),
                  ),
                ),
              ),
              SliverAppBar(
                pinned: true,
                backgroundColor: AppColors.primary,
                automaticallyImplyLeading: false,
                elevation: 0,
                toolbarHeight: 50.h,
                flexibleSpace: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.h),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Row(
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
                          onPressed: () => showFilterBottomSheet(context),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SliverPadding(
                padding: EdgeInsets.only(bottom: 10,top: 0),
                sliver: SliverToBoxAdapter(
                  child: BlocConsumer<CafeListBloc, CafeListState>(
                    listener: (context, state) {
                      if(state is CafeListLoaded) {
                        if(state.cafeListResponse.status == false || state.cafeListResponse.message!.contains("signup")||state.cafeListResponse.message == "Please signup to proceed.") {
                          Fluttertoast.showToast(
                            msg: "Please signup to proceed.",
                            backgroundColor: AppColors.appRedColor,
                            textColor: AppColors.primaryWhiteColor,
                            gravity: ToastGravity.BOTTOM,
                          );
                          Future.delayed(Duration.zero, () {
                            context.push('/login');
                          });
                        }
                      }
                      if (state is CafeListError) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(state.errorMessage),
                            backgroundColor: AppColors.appRedColor,
                          ),
                        );
                      }
                    },
                    builder: (context, state) {

                      final double? lat = latitude != null ? double.tryParse(latitude) : null;
                      final double? lon = longitude != null ? double.tryParse(longitude) : null;
                      if (state is CafeListLoading) {
                        EasyLoading.show();
                      } else if (state is CafeListLoaded) {
                        EasyLoading.dismiss();
                        if (state.cafeListResponse.cafes != null && state.cafeListResponse.cafes!.isNotEmpty) {
                          return ListView.builder(
                            physics: NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            itemCount: state.cafeListResponse.cafes!.length,
                            itemBuilder: (context, index) {
                              final cafe = state.cafeListResponse.cafes![index];
                              return CafeListCard(
                                cafes: cafe,
                                isLoading: false,
                                onFavoriteToggle: () => context.read<CafeListBloc>().add(
                                  ToggleFavoriteEvent(index, context),
                                )
                              );
                            },
                          );
                        } else {
                          return Center(
                            child: Text(
                              'No cafes found.',
                              style: TextStyle(color: AppColors.primaryWhiteColor),
                            ),
                          );
                        }
                      }
                      else if (state is FavoriteToggleLoading) {
                        return ListView.builder(
                          padding: EdgeInsets.zero,
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
                                  ToggleFavoriteEvent(index,context)
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
                                    context.read<CafeListBloc>().add(
                                      GetCafeListEvent(
                                        cafeListRequest: CafeListRequest(
                                          latitude: lat!,
                                          longitude: lon!,
                                          diceTableFilter: [],
                                          accommodationsFilter: [],
                                          openTime: "",
                                          closeTime: "",
                                          search: "",
                                        ),
                                      ),
                                    );
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
