import 'package:dicetable/src/constants/app_colors.dart';
import 'package:dicetable/src/model/customer/cafe/cafe_search_request.dart';
import 'package:dicetable/src/ui/cafe_owner/notification/count_controller.dart';
import 'package:dicetable/src/ui/customer/home/widget/cafe_marker_map_widget.dart';
import 'package:dicetable/src/ui/customer/home/widget/cafe_search_bar.dart';
import 'package:dicetable/src/ui/customer/home/widget/filter_bottom_sheet.dart';
import 'package:dicetable/src/utils/data/object_factory.dart';
import 'package:dicetable/src/utils/data/sign_out.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:go_router/go_router.dart';
import 'package:gap/gap.dart';
import 'bloc/customer_home_bloc.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:badges/badges.dart' as badges;

class CustomerHomePage extends StatefulWidget {
  const CustomerHomePage({super.key});

  @override
  State<CustomerHomePage> createState() => _CustomerHomePageState();
}

class _CustomerHomePageState extends State<CustomerHomePage> {
  String? latitude;
  String? longitude;
  final CounterController controller = Get.find<CounterController>();
  final isGuest = ObjectFactory().prefs.isGuestUser() == true;
  @override
  void initState() {
    super.initState();

    latitude = ObjectFactory().prefs.getLatitude().toString();
    longitude = ObjectFactory().prefs.getLongitude().toString();
    _performSearch();

  }

  void _performSearch() {
    final isGuest = ObjectFactory().prefs.isGuestUser() == true;
    final deviceToken =
        isGuest ? ObjectFactory().prefs.getDeviceID() ?? '' : '';
    final double lat =
        latitude != null ? double.tryParse(latitude!) ?? 0.0 : 0.0;
    final double lon =
        longitude != null ? double.tryParse(longitude!) ?? 0.0 : 0.0;

    final searchRequest = CafeSearchRequest(
      search: "",
      openTime: '',
      closeTime: '',
      diceTableFilter: [],
      accommodationsFilter: [],
      deviceToken: deviceToken,
      latitude: lat,
      longitude: lon,
    );

    context.read<CustomerHomeBloc>().add(SearchCafesEvent(searchRequest));
  }

  void showFilterBottomSheet(BuildContext context) {
    showModalBottomSheet(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * 0.9,
        minWidth: double.infinity,
      ),
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder:
          (context) => FractionallySizedBox(child: const FilterBottomSheet()),
    );
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
            SliverPadding(
              padding: EdgeInsets.symmetric(horizontal: 20.h, vertical: 0.h),
              sliver: SliverAppBar(
                backgroundColor: Colors.transparent,
                expandedHeight: isTabletOrLarger ? 110.h : 0,
                leading: const SizedBox(),
                flexibleSpace: FlexibleSpaceBar(
                  centerTitle: false,
                  collapseMode: CollapseMode.parallax,
                  stretchModes: const [StretchMode.zoomBackground],
                  background: SizedBox.fromSize(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Gap(10),
                        Row(
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
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            SliverPadding(
              padding: EdgeInsets.zero,
              sliver: SliverToBoxAdapter(
                child: CafeSearchBar(
                  onSearch: (query) {
                    // Call your API or filter list
                    print('Search for: $query');
                  },
                  onFilterTap: () => showFilterBottomSheet(context),
                ),
              ),
            ),

            BlocConsumer<CustomerHomeBloc, CustomerHomeState>(
              listener: (context, state) {
                if (state is LocationLoaded) {
                  setState(() {
                    latitude = state.latitude.toString();
                    longitude = state.longitude.toString();
                  });
                  _performSearch();
                }
                if (state is CafeSearchLoading) {
                  EasyLoading.show();
                } else {
                  EasyLoading.dismiss();
                }
                if (state is CafeSearchError) {
                   EasyLoading.dismiss();
                  if (state.message.contains("Unauthorized") ||
                      state.message.contains("status code of 401") ||
                      state.message.contains("Unknown error")) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      SignOut().logout(context);
                      Fluttertoast.showToast(
                        backgroundColor: AppColors.primaryWhiteColor,
                        textColor: AppColors.appRedColor,
                        gravity: ToastGravity.BOTTOM,
                        msg:
                        "Your session has expired. Please sign in again.",
                      );
                    });
                  }
                }
              },
              builder: (context, state) {
                return SliverToBoxAdapter(
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
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
