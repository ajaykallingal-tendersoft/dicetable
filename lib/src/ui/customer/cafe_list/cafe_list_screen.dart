import 'package:badges/badges.dart' as badges;
import 'package:google_fonts/google_fonts.dart';
import 'package:soloseaters/src/constants/app_colors.dart';
import 'package:soloseaters/src/model/customer/cafe/cafe_list_request.dart';
import 'package:soloseaters/src/ui/cafe_owner/notification/count_controller.dart';
import 'package:soloseaters/src/ui/customer/cafe_list/bloc/cafe_list_bloc.dart';
import 'package:soloseaters/src/ui/customer/cafe_list/widget/cafe_list_container_widget.dart';
import 'package:soloseaters/src/ui/customer/cafe_list/widget/cafe_list_filter.dart';
import 'package:soloseaters/src/utils/data/sign_out.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:soloseaters/src/utils/data/auth_session_manager.dart';
import 'package:soloseaters/src/utils/data/object_factory.dart';
import 'package:responsive_framework/responsive_framework.dart';

class CafeListScreen extends StatefulWidget {
  const CafeListScreen({super.key});

  @override
  State<CafeListScreen> createState() => _CafeListScreenState();
}

class _CafeListScreenState extends State<CafeListScreen> {
  late final String latitude;
  late final String longitude;
  final CounterController controller = Get.find<CounterController>();
  final isGuest = ObjectFactory().prefs.isGuestUser() == true;
  bool _isInitialLoad = true;

  @override
  void initState() {
    super.initState();
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
    final deviceToken =
        isGuest ? ObjectFactory().prefs.getDeviceID() ?? '' : '';

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
            latitude: 0.0,
            // Fallback value
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
      ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Location data unavailable. Using default location.", style: TextStyle(color: AppColors.primaryWhiteColor)),
        backgroundColor: AppColors.appRedColor,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
    }
  }

  void showFilterBottomSheet(BuildContext context) async {
    // Make it async
    await showModalBottomSheet(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * 0.9,
        minWidth: double.infinity,
      ),
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => FractionallySizedBox(child: const CafeListFilter()),
    );
    // _fetchCafeListWithLocation();
  }

  @override
  Widget build(BuildContext context) {
    final isTabletOrLarger = ResponsiveBreakpoints.of(
      context,
    ).largerThan(MOBILE);
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
            // CupertinoSliverRefreshControl(
            //   onRefresh: () async {
            //     // context.read<CardCubit>().fetchCards();
            //   },
            // ),
            SliverAppBar(
              pinned: false,
              backgroundColor: Colors.transparent,
              expandedHeight: isTabletOrLarger ? 70.h : 10.h,
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
                            "SOLO SEATERS",
                            style: GoogleFonts.montserrat(
                              color: AppColors.primaryWhiteColor,
                              fontWeight: FontWeight.bold,
                              fontSize: isTabletOrLarger ? 28.sp : 24.sp,
                            ),
                          ),
                          isGuest
                              ? SizedBox.shrink()
                              : InkWell(
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
              padding: EdgeInsets.only(bottom: 10, top: 0),
              sliver: SliverToBoxAdapter(
                child: BlocConsumer<CafeListBloc, CafeListState>(                  
                  buildWhen: (previous, current) {
                    return current is CafeListLoaded || current is FavoriteToggleLoading || current is CafeListLoading || current is CafeListError || current is CafeListInitial;
                  },
                  listener: (context, state) {
                    if (state is CafeListLoaded) {
                      if (state.cafeListResponse.status == false) {
                        if (state.cafeListResponse.message!.contains(
                          "Unauthorized access",
                        )) {
                          EasyLoading.dismiss();
                          if (AuthSessionManager.consumeRefreshFailureFlag()) {
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              SignOut().logout(context);
                              ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Your session has expired. Please sign in again.", style: TextStyle(color: AppColors.appRedColor)),
        backgroundColor: AppColors.primaryWhiteColor,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
                            });
                          }
                        }
                      }
                    }
                    if (state is CafeListError) {
                      if (state.errorMessage.contains("UnAuthorized") ||
                          state.errorMessage.contains("status code of 401")) {
                        EasyLoading.dismiss();
                        if (AuthSessionManager.consumeRefreshFailureFlag()) {
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            SignOut().logout(context);
                            ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Your session has expired. Please sign in again.", style: TextStyle(color: AppColors.appRedColor)),
        backgroundColor: AppColors.primaryWhiteColor,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
                          });
                        }
                      }
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(state.errorMessage),
                          backgroundColor: AppColors.appRedColor,
                        ),
                      );
                    }
                  },
                  builder: (context, state) {
                    final double? lat =
                        latitude != null ? double.tryParse(latitude) : null;
                    final double? lon =
                        longitude != null ? double.tryParse(longitude) : null;
                    if (state is CafeListLoading) {
                      EasyLoading.show();
                    } else if (state is CafeListLoaded) {
                      EasyLoading.dismiss();
                      if (state.cafeListResponse.cafes != null &&
                          state.cafeListResponse.cafes!.isNotEmpty) {
                        return ListView.builder(
                          physics: NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: state.cafeListResponse.cafes!.length,
                          itemBuilder: (context, index) {
                            final cafe = state.cafeListResponse.cafes![index];
                            return CafeListCard(
                              cafes: cafe,
                              isLoading: false,
                              onFavoriteToggle:
                                  () => context.read<CafeListBloc>().add(
                                    ToggleFavoriteEvent(index, context),
                                  ),
                            );
                          },
                        );
                      } else {
                        return Center(
                          child: Text(
                            'No cafes found.',
                            style: TextStyle(
                              color: AppColors.primaryWhiteColor,
                            ),
                          ),
                        );
                      }
                    } else if (state is FavoriteToggleLoading) {
                      return ListView.builder(
                        padding: EdgeInsets.zero,
                        physics: NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: state.cafeListResponse.cafes!.length,
                        itemBuilder: (context, index) {
                          final cafe = state.cafeListResponse.cafes![index];
                          final isThisCafeLoading =
                              state.toggledCafeIndex == index;

                          return CafeListCard(
                            cafes: cafe,
                            isLoading: isThisCafeLoading,
                            onFavoriteToggle:
                                isThisCafeLoading
                                    ? null
                                    : () => context.read<CafeListBloc>().add(
                                      ToggleFavoriteEvent(index, context),
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
