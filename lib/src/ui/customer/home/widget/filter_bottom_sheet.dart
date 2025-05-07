import 'package:dicetable/src/constants/app_colors.dart';
import 'package:dicetable/src/ui/customer/home/widget/styled_checkbox.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';

class FilterBottomSheet extends StatefulWidget {
  const FilterBottomSheet({super.key});

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  TimeOfDay? openTime = const TimeOfDay(hour: 10, minute: 0);
  TimeOfDay? closeTime = const TimeOfDay(hour: 14, minute: 0);
  final List<String> tableTypes = [
    'Business Networking',
    'Social Solos',
    'Solo Singles',
    'Prime Time - Over 60’s',
  ];
  final List<String> venueTypes = [
    'Resturant',
    'Cafe',
    'Bakeries',
    'Dessert Venue',
    'Pub&Bars',
    'Clubs',
    'Activity Venue',
    'Hotel Restaurant/Cafe',
  ];
  final Set<String> selectedTableTypes = {
    'Business Networking',
    'Social Solos',
  };
  final Set<String> selectedVenueTypes = {'Resturant', 'Cafe', 'Bakeries'};

  Future<void> pickTime(bool isOpen) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: isOpen ? openTime! : closeTime!,
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
        return DraggableScrollableSheet(
          initialChildSize: 0.9,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          expand: false,
          builder:
              (context, controller) => Container(
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
                  controller: controller,
                  padding: const EdgeInsets.all(26),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "FILTERS",
                            style: TextTheme.of(context).bodyMedium!.copyWith(
                              color: AppColors.textPrimaryGrey,
                              fontWeight: FontWeight.w600,
                              fontSize: 14.sp,
                            ),
                          ),
                          IconButton(
                            icon: SvgPicture.asset('assets/svg/filter-close.svg',),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ],
                      ),
                     Gap(30.h),
                      _buildSectionTitle("HOURS"),
                      _buildHoursPicker(),
                      Gap(20.h),
                      _buildSectionTitle("TYPE OF TABLE"),
                      _buildCustomCheckboxList(tableTypes, selectedTableTypes, _updateSelectedTableType),
                      Gap(20.h),
                      _buildSectionTitle("VENUE TYPE"),
                      _buildCustomCheckboxGrid(venueTypes, selectedVenueTypes, _updateSelectedVenueType),
                    ],
                  ),
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
        style: TextTheme.of(context).labelMedium!.copyWith(
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
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.primaryWhiteColor,
        borderRadius: BorderRadius.circular(15.r),
        border: Border.all(color: AppColors.filterContentBorder, width: 0.9),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildTimeField("Open", openTime!, () => pickTime(true)),
          ),
          Align(
            alignment: Alignment.center,
            child: Padding(
              padding: const EdgeInsets.only(left: 10, top: 10, right: 28),
              child: Text("To",  style: TextTheme.of(context).bodySmall!.copyWith(
                color: AppColors.timeTextColor,
                fontWeight: FontWeight.w600,
                fontSize: 12.sp,
              ),),
            ),
          ),
          Expanded(
            child: _buildTimeField("Close", closeTime!, () => pickTime(false)),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeField(String label, TimeOfDay time, VoidCallback onTap) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
          style: TextTheme.of(context).bodySmall!.copyWith(
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
                SvgPicture.asset('assets/svg/f-clock.svg',fit: BoxFit.scaleDown,),
                Text(
                  time.format(context),
                  style: TextTheme.of(context).bodySmall!.copyWith(
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
                // const Icon(Icons.keyboard_arrow_down),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCustomCheckboxList(List<String> items, Set<String> selectedSet, Function(String, bool) onChanged) {
    return Container(
      padding: EdgeInsets.all(10),
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
                  child: Text(item,  style: TextTheme.of(context).labelMedium!.copyWith(
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
  Widget _buildCustomCheckboxGrid(List<String> items, Set<String> selectedSet, Function(String, bool) onChanged) {
    return Container(
      // height: 175.h,
      decoration: BoxDecoration(
        color: AppColors.primaryWhiteColor,
        border: Border.all(color: AppColors.filterContentBorder),
        borderRadius: BorderRadius.circular(15),
      ),
      padding: const EdgeInsets.all(8.0),
      child: GridView.builder(
        shrinkWrap: true, // Important to use within a SingleChildScrollView
        physics: ClampingScrollPhysics(), // Disable GridView's scrolling
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, // Define the number of columns in your grid
          childAspectRatio: 3, // Adjust as needed for the aspect ratio of each item
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
                  style: TextTheme.of(context).labelMedium!.copyWith(
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
