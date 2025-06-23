import 'package:dicetable/src/constants/app_colors.dart';
import 'package:dicetable/src/model/customer/cafe/cafe_search_request.dart';
import 'package:dicetable/src/ui/customer/home/widget/cafe_marker_map_widget.dart';
import 'package:dicetable/src/ui/customer/home/widget/cafe_search_bar.dart';
import 'package:dicetable/src/ui/customer/home/widget/filter_bottom_sheet.dart';
import 'package:dicetable/src/utils/data/object_factory.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:gap/gap.dart';
import 'bloc/customer_home_bloc.dart';
import 'package:responsive_framework/responsive_framework.dart';


class CustomerHomePage extends StatefulWidget {
  const CustomerHomePage({super.key});

  @override
  State<CustomerHomePage> createState() => _CustomerHomePageState();
}

class _CustomerHomePageState extends State<CustomerHomePage> {
  late final String latitude;
  late final String longitude;
  final CounterController controller = Get.find<CounterController>();

@override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CustomerHomeBloc>().add(FetchLocationEvent(context: context));
    });
    latitude = ObjectFactory().prefs.getLatitude().toString();
    longitude = ObjectFactory().prefs.getLongitude().toString();
    _performSearch();
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   context.read<CustomerHomeBloc>().add(FetchLocationEvent(context: context));
    // });

  }

  void _performSearch() {
    final isGuest = ObjectFactory().prefs.isGuestUser() == true;
    final deviceToken = isGuest
        ? ObjectFactory().prefs.getDeviceID() ?? ''
        : '';
    final double lat = latitude != null ? double.tryParse(latitude!) ?? 0.0 : 0.0;
    final double lon = longitude != null ? double.tryParse(longitude!) ?? 0.0 : 0.0;

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
              child: const FilterBottomSheet()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isTabletOrLarger = ResponsiveBreakpoints.of(context).largerThan(
        MOBILE);
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
                  stretchModes: const [
                    StretchMode.zoomBackground,
                  ],
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
                              style: TextTheme
                                  .of(context)
                                  .labelMedium!
                                  .copyWith(
                                color: AppColors.primaryWhiteColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 30.sp,
                              ),
                            ),
                            InkWell(
                              onTap: () {
                                context.push('/notification');
                                },
                              child: Obx(() {
                                return controller.notificationBadgeAmount.value > 0
                                    ? badges.Badge(
                                  position: badges.BadgePosition.topEnd(top: 0, end: 0),
                                  badgeAnimation: badges.BadgeAnimation.slide(),
                                  showBadge: true,
                                  badgeStyle: badges.BadgeStyle(
                                    shape: badges.BadgeShape.square,
                                    borderRadius: BorderRadius.circular(10),
                                    badgeColor: Colors.red,
                                    padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  ),
                                  badgeContent: Text(
                                    controller.notificationBadgeAmount.value.toString(),
                                    style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                                  ),
                                  child: const Icon(
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

              },
              builder: (context, state) {
                return SliverToBoxAdapter(
                  child: Container(
                    height: MediaQuery
                        .sizeOf(context)
                        .height,
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
