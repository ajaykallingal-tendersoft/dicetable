import 'package:dicetable/src/constants/app_colors.dart';
import 'package:dicetable/src/constants/assets.dart';
import 'package:dicetable/src/model/customer/cafe/cafe_list_request.dart';
import 'package:dicetable/src/model/customer/cafe/get_filter_options_response.dart';
import 'package:dicetable/src/ui/customer/cafe_list/bloc/cafe_list_bloc.dart';
import 'package:dicetable/src/ui/customer/home/widget/styled_checkbox.dart';
import 'package:dicetable/src/utils/data/object_factory.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import 'package:fluttertoast/fluttertoast.dart';


class CafeListFilter extends StatefulWidget {
  const CafeListFilter({super.key});

  @override
  State<CafeListFilter> createState() => _CafeListFilterState();
}

class _CafeListFilterState extends State<CafeListFilter> {
  late Set<String> selectedTableTypes;
  late Set<String> selectedVenueTypes;
  late TimeOfDay openTime;
  late TimeOfDay closeTime;

  late Set<String> originalTableTypes;
  late Set<String> originalVenueTypes;
  late TimeOfDay originalOpenTime;
  late TimeOfDay originalCloseTime;

  @override
  void initState() {
    super.initState();
    final bloc = context.read<CafeListBloc>();
    selectedTableTypes = Set.from(bloc.selectedTableTypes);
    selectedVenueTypes = Set.from(bloc.selectedVenueTypes);
    openTime = bloc.openTime;
    closeTime = bloc.closeTime;

    originalTableTypes = Set.from(bloc.selectedTableTypes);
    originalVenueTypes = Set.from(bloc.selectedVenueTypes);
    originalOpenTime = bloc.openTime;
    originalCloseTime = bloc.closeTime;

    bloc.add(FilterOptionsEvent());
  }

  Widget _buildActionButtons(GetFilterOptionsResponse filterResponse) {
    return Column(
      children: [
        InkWell(
          onTap: _clearAllFilters,
          child: Container(
            height: 40.h,
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Center(
              child: Text(
                'Clear All Filters',
                style: TextTheme
                    .of(context)
                    .labelMedium!
                    .copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w500,
                  fontSize: 14.sp,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ),
        ),
        SizedBox(height: 16.h),
        Row(
          children: [
            // Cancel Button
            Expanded(
              child: InkWell(
                onTap: () => _reApplyPreviousFilters(),
                child: Container(
                  height: 50.h,
                  decoration: BoxDecoration(
                    color: AppColors.primaryWhiteColor,
                    border: Border.all(color: AppColors.primary, width: 1.5),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Center(
                    child: Text(
                      'Cancel',
                      style: TextTheme
                          .of(context)
                          .labelMedium!
                          .copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                        fontSize: 16.sp,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(width: 16.w),
            // Apply Button
            Expanded(
              child: InkWell(
                onTap: () => _applyFilters(filterResponse),
                child: Container(
                  height: 50.h,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Center(
                    child: Text(
                      'Apply',
                      style: TextTheme
                          .of(context)
                          .labelMedium!
                          .copyWith(
                        color: AppColors.primaryWhiteColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 16.sp,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _clearAllFilters() {
    setState(() {
      openTime = const TimeOfDay(hour: 10, minute: 0);
      closeTime = const TimeOfDay(hour: 14, minute: 0);
      selectedTableTypes.clear();
      selectedVenueTypes.clear();
    });

    // Clear filters in BLoC
    final bloc = context.read<CafeListBloc>();
    bloc.add(const FiltersClearEvent());

    final String latitude = ObjectFactory().prefs.getLatitude().toString();
    final String longitude = ObjectFactory().prefs.getLongitude().toString();
    final double? lat = latitude != null ? double.tryParse(latitude) : 0.0;
    final double? lon = longitude != null ? double.tryParse(longitude) : 0.0;
    final isGuest = ObjectFactory().prefs.isGuestUser() == true;
    final deviceToken = isGuest ? ObjectFactory().prefs.getDeviceID() ?? '' : '';

    final cafeListRequest = CafeListRequest(
      latitude: lat!,
      longitude: lon!,
      search: "",
      openTime: "", // Default open time
      closeTime: "", // Default close time
      diceTableFilter: [], // Empty filters
      accommodationsFilter: [], // Empty filters
      deviceToken: deviceToken,
    );

    bloc.add(GetCafeListEvent(cafeListRequest: cafeListRequest));
    context.pop();
  }

  void _applyFilters(GetFilterOptionsResponse filterResponse) {

    final bool hasTimeFilter = openTime != const TimeOfDay(hour: 00, minute: 0) ||
        closeTime != const TimeOfDay(hour: 00, minute: 0);
    final bool hasTableTypeFilter = selectedTableTypes.isNotEmpty;
    final bool hasVenueTypeFilter = selectedVenueTypes.isNotEmpty;

    if (!hasTimeFilter && !hasTableTypeFilter && !hasVenueTypeFilter) {
      Fluttertoast.showToast(
        msg: "Please select at least one filter",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: AppColors.primaryWhiteColor,
        textColor: AppColors.appRedColor,
      );
      return;
    }

    context.read<CafeListBloc>().add(FiltersUpdateEvent(
      selectedTableTypes: selectedTableTypes,
      selectedVenueTypes: selectedVenueTypes,
      openTime: openTime,
      closeTime: closeTime,
    ));

    // Prepare the filter parameters
    final List<String> diceTableTitles = selectedTableTypes.toList();
    final List<String> venueTypeTitles = selectedVenueTypes.toList();

    final String openTimeString =
        '${openTime.hour.toString().padLeft(2, '0')}:${openTime.minute.toString().padLeft(2, '0')}';
    final String closeTimeString =
        '${closeTime.hour.toString().padLeft(2, '0')}:${closeTime.minute.toString().padLeft(2, '0')}';

    final String latitude = ObjectFactory().prefs.getLatitude().toString();
    final String longitude = ObjectFactory().prefs.getLongitude().toString();
    final double? lat = latitude != null ? double.tryParse(latitude) : 0.0;
    final double? lon = longitude != null ? double.tryParse(longitude) : 0.0;
    final isGuest = ObjectFactory().prefs.isGuestUser() == true;
    final deviceToken = isGuest ? ObjectFactory().prefs.getDeviceID() ?? '' : '';

    final cafeListRequest = CafeListRequest(
      latitude: lat!,
      longitude: lon!,
      search: "",
      openTime: openTimeString,
      closeTime: closeTimeString,
      diceTableFilter: diceTableTitles,
      accommodationsFilter: venueTypeTitles,
      deviceToken: deviceToken,
    );

    context.read<CafeListBloc>().add(GetCafeListEvent(cafeListRequest: cafeListRequest));
    context.pop();
  }

  void _reApplyPreviousFilters() {
    final bloc = context.read<CafeListBloc>();

    bloc.add(FiltersUpdateEvent(
      selectedTableTypes: originalTableTypes,
      selectedVenueTypes: originalVenueTypes,
      openTime: originalOpenTime,
      closeTime: originalCloseTime,
    ));

    final List<String> diceTableTitles = originalTableTypes.toList();
    final List<String> venueTypeTitles = originalVenueTypes.toList();

    final String openTimeString =
        '${originalOpenTime.hour.toString().padLeft(2, '0')}:${originalOpenTime.minute.toString().padLeft(2, '0')}';
    final String closeTimeString =
        '${originalCloseTime.hour.toString().padLeft(2, '0')}:${originalCloseTime.minute.toString().padLeft(2, '0')}';

    final String latitude = ObjectFactory().prefs.getLatitude().toString();
    final String longitude = ObjectFactory().prefs.getLongitude().toString();
    final double? lat = double.tryParse(latitude);
    final double? lon = double.tryParse(longitude);
    final isGuest = ObjectFactory().prefs.isGuestUser() == true;
    final deviceToken = isGuest ? ObjectFactory().prefs.getDeviceID() ?? '' : '';

    final cafeListRequest = CafeListRequest(
      latitude: lat!,
      longitude: lon!,
      search: "",
      openTime: openTimeString,
      closeTime: closeTimeString,
      diceTableFilter: diceTableTitles,
      accommodationsFilter: venueTypeTitles,
      deviceToken: deviceToken,
    );

    bloc.add(GetCafeListEvent(cafeListRequest: cafeListRequest));
    context.pop();
  }

  Future<void> pickTime(bool isOpen) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: isOpen ? openTime : closeTime,
    );
    if (picked != null) {
      setState(() {
        if (isOpen) {
          openTime = picked;
        } else {
          closeTime = picked;
        }
      });
    }
  }

  void _updateSelectedTableType(String type, bool isSelected) {
    setState(() {
      if (isSelected) {
        selectedTableTypes.add(type);
      } else {
        selectedTableTypes.remove(type);
      }
    });
  }

  void _updateSelectedVenueType(String type, bool isSelected) {
    setState(() {
      if (isSelected) {
        selectedVenueTypes.add(type);
      } else {
        selectedVenueTypes.remove(type);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.primaryWhiteColor,
                AppColors.primaryWhiteColor,
                AppColors.filterGradient1,
                AppColors.filterGradient2,
              ],
              stops: [0.0, 0.0, 0.40, 1.0],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
          ),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(26),
            child: BlocConsumer<CafeListBloc, CafeListState>(
              listener: (context, state) {
                if (state is FilterLoading) {
                  EasyLoading.show();
                } else if (state is FilterLoaded ||
                    state is FilterError) {
                  EasyLoading.dismiss();
                }
                if (state is UpdateFilter) {
                  setState(() {
                    selectedTableTypes = Set.from(state.selectedTableTypes);
                    selectedVenueTypes = Set.from(state.selectedVenueTypes);
                    openTime = state.openTime;
                    closeTime = state.closeTime;
                  });
                } else if (state is FilterClear) {
                  setState(() {
                    selectedTableTypes.clear();
                    selectedVenueTypes.clear();
                    openTime = const TimeOfDay(hour: 10, minute: 0);
                    closeTime = const TimeOfDay(hour: 14, minute: 0);
                  });
                }
              },
              builder: (context, state) {
                if (state is FilterLoaded &&
                    state.getFilterOptionsResponse.diceTables!.isNotEmpty &&
                    state.getFilterOptionsResponse.venueTypes!.isNotEmpty) {
                  final List<String> tableTypes = state.getFilterOptionsResponse
                      .diceTables!
                      .map((diceTable) => diceTable.title ?? '')
                      .where((title) => title.isNotEmpty)
                      .toList();

                  final List<String> venueTypes = state.getFilterOptionsResponse
                      .venueTypes!
                      .map((venueType) => venueType.title ?? '')
                      .where((title) => title.isNotEmpty)
                      .toList();

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "FILTERS",
                            style: TextTheme
                                .of(context)
                                .bodyMedium!
                                .copyWith(
                              color: AppColors.textPrimaryGrey,
                              fontWeight: FontWeight.w600,
                              fontSize: 14.sp,
                            ),
                          ),
                          IconButton(
                            icon: SvgPicture.asset(
                                'assets/svg/filter-close.svg'),
                            onPressed: () => _reApplyPreviousFilters(),
                          ),
                        ],
                      ),
                      Gap(30.h),
                      _buildSectionTitle("HOURS"),
                      _buildHoursPicker(),
                      Gap(20.h),
                      _buildSectionTitle("TYPE OF TABLE"),
                      _buildCustomCheckboxList(tableTypes, selectedTableTypes,
                          _updateSelectedTableType),
                      Gap(20.h),
                      _buildSectionTitle("VENUE TYPE"),
                      _buildCustomCheckboxGrid(venueTypes, selectedVenueTypes,
                          _updateSelectedVenueType),
                      Gap(30.h),
                      _buildActionButtons(state.getFilterOptionsResponse),
                    ],
                  );
                } else if (state is FilterError) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Error loading filters: ${state.message}',
                          style: TextTheme
                              .of(context)
                              .bodyMedium!
                              .copyWith(
                            color: AppColors.primary,
                            fontSize: 14.sp,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 16.h),
                        ElevatedButton(
                          onPressed: () =>
                              context.read<CafeListBloc>().add(
                                  FilterOptionsEvent()),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            padding: EdgeInsets.symmetric(
                                horizontal: 20.w, vertical: 10.h),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                          ),
                          child: Text(
                            'Retry',
                            style: TextTheme
                                .of(context)
                                .labelMedium!
                                .copyWith(
                              color: AppColors.primaryWhiteColor,
                              fontWeight: FontWeight.w600,
                              fontSize: 16.sp,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }
                return  Center(child: Lottie.asset(
                    Assets.JUMBING_DOT, width: 40, height: 40));
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title,
        style: TextTheme
            .of(context)
            .labelMedium!
            .copyWith(
          color: AppColors.primary,
          fontWeight: FontWeight.bold,
          fontSize: 16.sp,
        ),
      ),
    );
  }

  Widget _buildHoursPicker() {
    return Container(
      height: 98.h,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.primaryWhiteColor,
        borderRadius: BorderRadius.circular(15.r),
        border: Border.all(color: AppColors.filterContentBorder, width: 0.9),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildTimeField("Open", openTime, () => pickTime(true)),
          ),
          Align(
            alignment: Alignment.center,
            child: Padding(
              padding: const EdgeInsets.only(left: 10, top: 10, right: 28),
              child: Text(
                "To",
                style: TextTheme
                    .of(context)
                    .bodySmall!
                    .copyWith(
                  color: AppColors.timeTextColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 12.sp,
                ),
              ),
            ),
          ),
          Expanded(
            child: _buildTimeField("Close", closeTime, () => pickTime(false)),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeField(String label, TimeOfDay time, VoidCallback onTap) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextTheme
              .of(context)
              .bodySmall!
              .copyWith(
            color: AppColors.shadowColor,
            fontWeight: FontWeight.w600,
            fontSize: 14.sp,
          ),
        ),
        SizedBox(height: 4.h),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            height: 40.h,
            width: 137.w,
            padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 6),
            decoration: BoxDecoration(
              color: AppColors.timePickerBoxColor,
              border: Border.all(
                color: AppColors.filterContentBorder,
                width: 0.8,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                SvgPicture.asset(
                  'assets/svg/f-clock.svg',
                  fit: BoxFit.scaleDown,
                ),
                Text(
                  time.format(context),
                  style: TextTheme
                      .of(context)
                      .bodySmall!
                      .copyWith(
                    color: AppColors.timeTextColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 12.sp,
                  ),
                ),
                Icon(
                  Icons.arrow_drop_down,
                  color: AppColors.timeTextColor,
                  size: 15,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCustomCheckboxList(List<String> items, Set<String> selectedSet,
      Function(String, bool) onChanged) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.primaryWhiteColor,
        border: Border.all(color: AppColors.filterContentBorder),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: items.map((item) {
          final isSelected = selectedSet.contains(item);
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              children: [
                StyledCheckbox(
                  value: isSelected,
                  onChanged: (newValue) {
                    onChanged(item, newValue!);
                  },
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    item,
                    style: TextTheme
                        .of(context)
                        .labelMedium!
                        .copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                      fontSize: 14.sp,
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildCustomCheckboxGrid(List<String> items, Set<String> selectedSet,
      Function(String, bool) onChanged) {

    return Container(
      decoration: BoxDecoration(
        color: AppColors.primaryWhiteColor,
        border: Border.all(color: AppColors.filterContentBorder),
        borderRadius: BorderRadius.circular(15),
      ),
      padding: const EdgeInsets.all(8.0),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const ClampingScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 3,
          crossAxisSpacing: 2.w,
          mainAxisSpacing: 2.h,
        ),
        itemCount: items.length,
        padding: EdgeInsets.zero,
        itemBuilder: (context, index) {
          final item = items[index];
          final isSelected = selectedSet.contains(item);
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              StyledCheckbox(
                value: isSelected,
                onChanged: (newValue) {
                  onChanged(item, newValue!);
                },
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  item,
                  textAlign: TextAlign.left,
                  style: TextTheme
                      .of(context)
                      .labelMedium!
                      .copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                    fontSize: 14.sp,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
