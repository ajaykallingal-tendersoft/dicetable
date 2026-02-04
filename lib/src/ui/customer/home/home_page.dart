import 'package:google_fonts/google_fonts.dart';
import 'package:soloseaters/src/constants/app_colors.dart';
import 'package:soloseaters/src/model/customer/cafe/cafe_search_request.dart';
import 'package:soloseaters/src/purchase/bloc/bloc/purchase_event.dart';
import 'package:soloseaters/src/ui/cafe_owner/notification/count_controller.dart';
import 'package:soloseaters/src/ui/customer/home/widget/cafe_marker_map_widget.dart';
import 'package:soloseaters/src/ui/customer/home/widget/cafe_search_bar.dart';
import 'package:soloseaters/src/ui/customer/home/widget/filter_bottom_sheet.dart';
import 'package:soloseaters/src/utils/data/object_factory.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:go_router/go_router.dart';
import 'package:gap/gap.dart';
import 'package:soloseaters/src/purchase/bloc/bloc/purchase_bloc.dart';
import 'bloc/customer_home_bloc.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:badges/badges.dart' as badges;
import 'package:auto_size_text/auto_size_text.dart';

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
  bool _hasUserSearched = false; // Track if user has performed a manual search
  @override
  void initState() {
    super.initState();

    // Reset the BLoC's search tracking when returning to home screen
    context.read<CustomerHomeBloc>().add(ResetSearchEvent());

    latitude = ObjectFactory().prefs.getLatitude().toString();
    longitude = ObjectFactory().prefs.getLongitude().toString();
    _performSearch(isUserInitiated: false);

    // Trigger subscription check on home page load.
    // This ensures the payment state is correct after a hot restart.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PaymentPlanBloc>().add(const CheckSubscriptionStatusEvent());
    });
  }

  void _performSearch({bool isUserInitiated = false}) {
    // If user has manually searched, don't override with automatic searches
    if (_hasUserSearched && !isUserInitiated) {
      return;
    }

    if (isUserInitiated) {
      _hasUserSearched = true;
    }
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

    context.read<CustomerHomeBloc>().add(
      SearchCafesEvent(searchRequest, isUserInitiated: isUserInitiated),
    );
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
                expandedHeight: isTabletOrLarger ? 90.h : 0,
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
                            AutoSizeText(
                              "SOLO SEATERS",
                              style: GoogleFonts.montserrat(
                                color: AppColors.primaryWhiteColor,
                                fontWeight: FontWeight.bold,
                                fontSize: isTabletOrLarger ? 28.sp : 24.sp,
                              ),
                            ),
                            isGuest
                                ? SizedBox.shrink()
                                : Padding(
                                  padding: const EdgeInsets.only(right: 10.0),
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
                                            position: badges
                                                .BadgePosition.topEnd(
                                              top: 0,
                                              end:
                                                  int.parse(
                                                            controller
                                                                .notificationBadgeAmount
                                                                .value
                                                                .toString(),
                                                          ) >
                                                          99
                                                      ? -12
                                                      : -2,
                                            ),
                                            badgeAnimation:
                                                badges.BadgeAnimation.slide(),
                                            showBadge:
                                                true, // You might want to check if value > 0 here
                                            badgeStyle: badges.BadgeStyle(
                                              shape:
                                                  badges
                                                      .BadgeShape
                                                      .circle, // STRICTLY CIRCLE
                                              badgeColor: Colors.red,
                                              padding: EdgeInsets.all(
                                                4.sp,
                                              ), // Use .all for circles to keep aspect ratio
                                              elevation: 0,
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
                                              color:
                                                  AppColors.primaryWhiteColor,
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
                  // Only perform automatic search if user hasn't manually searched
                  _performSearch(isUserInitiated: false);
                }
                if (state is CafeSearchLoading) {
                  EasyLoading.show();
                } else {
                  EasyLoading.dismiss();
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
