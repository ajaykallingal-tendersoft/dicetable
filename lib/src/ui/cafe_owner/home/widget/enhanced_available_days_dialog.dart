import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:soloseaters/src/constants/app_colors.dart';
import 'package:soloseaters/src/constants/assets.dart';
import 'package:soloseaters/src/model/cafe_owner/home/available_days.dart';
import 'package:google_fonts/google_fonts.dart';

class EnhancedAvailableDaysDialog extends StatefulWidget {
  final List<AvailableDay> availableDays;
  final List<AvailableDay>? initialSelectedDays;
  final String tableTypeName;

  const EnhancedAvailableDaysDialog({
    required this.availableDays,
    this.initialSelectedDays,
    this.tableTypeName = "Business Networking",
    super.key,
  });

  @override
  State<EnhancedAvailableDaysDialog> createState() =>
      _EnhancedAvailableDaysDialogState();
}

class _EnhancedAvailableDaysDialogState
    extends State<EnhancedAvailableDaysDialog> {
  Map<String, DaySelection> daySelections = {};
  bool alwaysAvailable = false;

  @override
  void initState() {
    super.initState();
    _initializeDaySelections();
  }

  void _initializeDaySelections() {
    for (var day in widget.availableDays) {
      final initialDay = widget.initialSelectedDays?.firstWhere(
        (d) => d.day?.toLowerCase() == day.day?.toLowerCase(),
        orElse: () => AvailableDay(),
      );

      daySelections[day.day!.toLowerCase()] = DaySelection(
        isSelected: initialDay?.day != null,
        isExpanded: false,
        cafeOpenTime: day.openTime ?? "10:00",
        cafeCloseTime: day.closeTime ?? "22:00",
        timeSlots:
            initialDay?.day != null
                ? [
                  TimeSlot(
                    from: initialDay!.openTime ?? day.openTime ?? "10:00",
                    to: initialDay.closeTime ?? day.closeTime ?? "22:00",
                    isDefault: true,
                  ),
                ]
                : [
                  TimeSlot(
                    from: day.openTime ?? "10:00",
                    to: day.closeTime ?? "22:00",
                    isDefault: true,
                  ),
                ],
      );
    }
  }

  String _capitalizeFirstLetter(String text) {
    if (text.isEmpty) return text;
    return "${text[0].toUpperCase()}${text.substring(1).toLowerCase()}";
  }

  void _toggleAlwaysAvailable(bool value) {
    print('_toggleAlwaysAvailable called with value: $value');

    setState(() {
      alwaysAvailable = value;
      print('alwaysAvailable set to: $alwaysAvailable');

      // Create a completely new map based on toggle state
      Map<String, DaySelection> newSelections = {};

      for (var entry in daySelections.entries) {
        newSelections[entry.key] = DaySelection(
          isSelected:
              value, // Set based on toggle - true to check all, false to uncheck all
          isExpanded: false,
          cafeOpenTime: entry.value.cafeOpenTime,
          cafeCloseTime: entry.value.cafeCloseTime,
          timeSlots: [
            TimeSlot(
              from: entry.value.cafeOpenTime,
              to: entry.value.cafeCloseTime,
              isDefault: true,
            ),
          ],
        );
      }

      daySelections = newSelections;

      // Debug: Print state after update
      if (value) {
        print('Always Available toggled ON - All days selected');
      } else {
        print('Always Available toggled OFF - All days unselected');
      }
      daySelections.forEach((day, selection) {
        print(
          '$day: isSelected=${selection.isSelected}, from=${selection.timeSlots.first.from}, to=${selection.timeSlots.first.to}',
        );
      });
    });
  }

  void _toggleDay(String day) {
    setState(() {
      daySelections[day]!.isSelected = !daySelections[day]!.isSelected;
      if (daySelections[day]!.isSelected) {
        daySelections[day]!.isExpanded = true;
      } else {
        daySelections[day]!.isExpanded = false;
        // Reset to default slot when unchecked
        daySelections[day]!.timeSlots = [
          TimeSlot(
            from: daySelections[day]!.cafeOpenTime,
            to: daySelections[day]!.cafeCloseTime,
            isDefault: true,
          ),
        ];
      }

      // If a day is manually unchecked, turn off "Always Available"
      if (!daySelections[day]!.isSelected && alwaysAvailable) {
        alwaysAvailable = false;
      }
    });
  }

  void _toggleExpand(String day) {
    if (daySelections[day]!.isSelected) {
      setState(() {
        daySelections[day]!.isExpanded = !daySelections[day]!.isExpanded;
      });
    }
  }

  void _addTimeSlot(String day) {
    setState(() {
      daySelections[day]!.timeSlots.add(
        TimeSlot(
          from: daySelections[day]!.cafeOpenTime,
          to: daySelections[day]!.cafeCloseTime,
          isDefault: false,
        ),
      );
    });
  }

  void _removeTimeSlot(String day, int index) {
    setState(() {
      daySelections[day]!.timeSlots.removeAt(index);
    });
  }

  Future<String?> _selectTime(
    BuildContext context,
    String initialTime,
    String minTime,
    String maxTime,
  ) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _parseTime(initialTime),
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false),
          child: child!,
        );
      },
    );

    if (picked != null) {
      final selectedMinutes = picked.hour * 60 + picked.minute;
      final minMinutes = _timeToMinutes(minTime);
      final maxMinutes = _timeToMinutes(maxTime);

      if (selectedMinutes < minMinutes || selectedMinutes > maxMinutes) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Time must be between $minTime and $maxTime'),
            backgroundColor: AppColors.appRedColor,
          ),
        );
        return null;
      }

      return picked.format(context);
    }
    return null;
  }

  TimeOfDay _parseTime(String time) {
    final parts = time.split(':');
    int hour = int.parse(parts[0]);
    int minute = int.parse(parts[1].substring(0, 2));
    return TimeOfDay(hour: hour, minute: minute);
  }

  int _timeToMinutes(String time) {
    final parts = time.split(':');
    return int.parse(parts[0]) * 60 + int.parse(parts[1].substring(0, 2));
  }

  List<AvailableDay> _getSelectedDays() {
    List<AvailableDay> selected = [];
    daySelections.forEach((day, selection) {
      if (selection.isSelected && selection.timeSlots.isNotEmpty) {
        // For now, we'll use the first time slot
        // You can modify this to handle multiple slots if your API supports it
        final firstSlot = selection.timeSlots.first;
        selected.add(
          AvailableDay(
            day: day,
            openTime: firstSlot.from,
            closeTime: firstSlot.to,
            isOpen: true,
          ),
        );
      }
    });
    return selected;
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isSmallScreen = screenWidth < 360;

    return Dialog(
      backgroundColor: Colors.white,
      insetPadding: EdgeInsets.symmetric(
        horizontal: screenWidth * 0.05,
        vertical: screenHeight * 0.05,
      ),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: screenHeight * 0.9,
          maxWidth: 600,
        ),
        decoration: BoxDecoration(
          color: AppColors.primaryWhiteColor,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
              decoration: BoxDecoration(
                color: AppColors.primaryWhiteColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      'Select Available Days',
                      style: GoogleFonts.montserrat(
                        fontSize: isSmallScreen ? 18 : 22,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(
                      Icons.close,
                      color: AppColors.secondaryGreyTextColor,
                      size: 24,
                    ),
                  ),
                ],
              ),
            ),

            // Content
            Flexible(
              child: SingleChildScrollView(
                physics: BouncingScrollPhysics(),
                child: Padding(
                  padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Table Type Info
                      Container(
                        height: 60.h,
                        width: double.infinity,
                        padding: EdgeInsets.all(isSmallScreen ? 10 : 12),
                        decoration: BoxDecoration(
                          color: AppColors.subscriptionPromptSubColor,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Table Type',
                              style: GoogleFonts.montserrat(
                                fontSize: isSmallScreen ? 11 : 12,
                                color: AppColors.primary,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                widget.tableTypeName,
                                style: GoogleFonts.montserrat(
                                  fontSize: isSmallScreen ? 12 : 16,
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w700,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Always Available Toggle
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 50.0,
                              height: 36.0,
                              child: FittedBox(
                                fit: BoxFit.fill,
                                child: Switch(
                                  value: alwaysAvailable,
                                  onChanged: _toggleAlwaysAvailable,

                                  activeColor: AppColors.primaryWhiteColor,
                                  activeTrackColor: AppColors.secondary,

                                  inactiveThumbColor: Colors.white,
                                  inactiveTrackColor: Colors.grey.shade400,
                                  trackOutlineColor: MaterialStateProperty.all(
                                    Colors.transparent,
                                  ),
                                  trackOutlineWidth: MaterialStateProperty.all(
                                    0.0,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Always Available',
                                style: GoogleFonts.montserrat(
                                  fontSize: isSmallScreen ? 13 : 14,
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      ...widget.availableDays.map((day) {
                        return _buildDayTile(
                          day.day!.toLowerCase(),
                          isSmallScreen,
                        );
                      }).toList(),
                    ],
                  ),
                ),
              ),
            ),

            // Footer Button
            Padding(
              padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
              child: SizedBox(
                width: MediaQuery.of(context).size.width / 2.7,
                height: isSmallScreen ? 44 : 48,
                child: ElevatedButton(
                  onPressed: () {
                    context.pop(_getSelectedDays());
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: Text(
                    'DONE',
                    style: GoogleFonts.montserrat(
                      fontSize: isSmallScreen ? 14 : 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDayTile(String day, bool isSmallScreen) {
    final selection = daySelections[day];
    if (selection == null) return SizedBox.shrink();

    final isSelected = selection.isSelected;
    final isExpanded = selection.isExpanded;

    print(
      'Building tile for $day: isSelected=$isSelected, isExpanded=$isExpanded',
    );

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.subscriptionPromptSubColor,
        // border: Border.all(
        //   color: isSelected
        //       ? const Color(0xFF004B87)
        //       : const Color(0xFFE0E0E0),
        //   width: isSelected ? 2 : 1,
        // ),
        boxShadow: [
          BoxShadow(
            color: AppColors.subscriptionPromptSubColor.withOpacity(0.1),
            // Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 2,
            offset: Offset(0, 3),
          ),
        ],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          // Day Header
          InkWell(
            onTap: () => _toggleExpand(day),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  // Checkbox
                  GestureDetector(
                    onTap: () => _toggleDay(day),
                    child: Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: AppColors.primaryWhiteColor,
                        border: Border.all(color: AppColors.primary, width: 2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child:
                          isSelected
                              ? SvgPicture.asset(
                                Assets.CHECK,
                                fit: BoxFit.scaleDown,
                                height: 10,
                              )
                              // const Icon(
                              //     Icons.check,
                              //     size: 16,
                              //     color: AppColors.primary,
                              //   )
                              : null,
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Day Name
                  Expanded(
                    child: Text(
                      _capitalizeFirstLetter(day),
                      style: GoogleFonts.montserrat(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF1A1A1A),
                      ),
                    ),
                  ),

                  // Expand Icon
                  if (isSelected)
                    SvgPicture.asset(
                      height: 10,
                      fit: BoxFit.scaleDown,
                      isExpanded ? Assets.TAB_ARROW_UP : Assets.TAB_ARROW_DOWN,
                    ),
                  // Icon(
                  //   isExpanded
                  //       ? Icons.keyboard_arrow_up
                  //       : Icons.keyboard_arrow_down,
                  //   color: AppColors.primary,
                  //   size: 24,
                  // ),
                ],
              ),
            ),
          ),

          // Expanded Content
          if (isSelected && isExpanded) ...[
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Time Slots
                  ...List.generate(selection.timeSlots.length, (index) {
                    final slot = selection.timeSlots[index];
                    return _buildTimeSlot(day, index, slot);
                  }),

                  // Add New Button
                  if (selection.timeSlots.length < 5)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        SizedBox(
                          // width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () => _addTimeSlot(day),
                            style: ElevatedButton.styleFrom(
                              fixedSize: Size(90.w, 20.h),
                              backgroundColor: AppColors.primary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              padding: EdgeInsets.zero,
                            ),
                            icon: const Icon(
                              Icons.add,
                              color: AppColors.primaryWhiteColor,
                              size: 13,
                            ),
                            label: Text(
                              'ADD NEW',
                              style: GoogleFonts.montserrat(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primaryWhiteColor,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTimeSlot(String day, int index, TimeSlot slot) {
    final selection = daySelections[day]!;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          // From Label and Time
          Expanded(
            flex: 1,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'From',
                  style: GoogleFonts.montserrat(
                    fontSize: 12,
                    color: AppColors.textPrimaryGrey,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 4),
                GestureDetector(
                  onTap:
                      slot.isDefault
                          ? null
                          : () async {
                            final newTime = await _selectTime(
                              context,
                              slot.from,
                              selection.cafeOpenTime,
                              selection.cafeCloseTime,
                            );
                            if (newTime != null) {
                              setState(() {
                                selection.timeSlots[index].from = newTime;
                              });
                            }
                          },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primaryWhiteColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.access_time,
                          size: 14,
                          color: AppColors.secondaryGreyTextColor,
                        ),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            slot.from,
                            style: GoogleFonts.montserrat(
                              fontSize: 13,
                              color: AppColors.secondaryGreyTextColor,
                              fontWeight: FontWeight.w500,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (!slot.isDefault)
                          const Icon(
                            Icons.unfold_more,
                            size: 18,
                            color: Color(0xFF5B6369),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          // To Label and Time
          Expanded(
            flex: 1,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'To',
                  style: GoogleFonts.roboto(
                    fontSize: 12,
                    color: AppColors.textPrimaryGrey,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 4),
                GestureDetector(
                  onTap:
                      slot.isDefault
                          ? null
                          : () async {
                            final newTime = await _selectTime(
                              context,
                              slot.to,
                              selection.cafeOpenTime,
                              selection.cafeCloseTime,
                            );
                            if (newTime != null) {
                              setState(() {
                                selection.timeSlots[index].to = newTime;
                              });
                            }
                          },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primaryWhiteColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SvgPicture.asset(
                          Assets.CLOCK,
                          fit: BoxFit.scaleDown,
                          height: 10,
                        ),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            slot.to,
                            style: GoogleFonts.montserrat(
                              fontSize: 13,
                              color: AppColors.secondaryGreyTextColor,
                              fontWeight: FontWeight.w500,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (!slot.isDefault)
                          const Icon(
                            Icons.unfold_more,
                            size: 18,
                            color: AppColors.secondaryGreyTextColor,
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Delete Button
          if (!slot.isDefault)
            InkWell(
              onTap: () => _removeTimeSlot(day, index),
              child: SizedBox(
                width: 32,
                child: ImageIcon(
                  AssetImage(Assets.DELETE),
                  color: Color(0xFFE53935),
                  size: 20,
                ),
              ),
            )
          else
            const SizedBox(width: 8),
        ],
      ),
    );
  }
}

class DaySelection {
  bool isSelected;
  bool isExpanded;
  String cafeOpenTime;
  String cafeCloseTime;
  List<TimeSlot> timeSlots;

  DaySelection({
    required this.isSelected,
    required this.isExpanded,
    required this.cafeOpenTime,
    required this.cafeCloseTime,
    required this.timeSlots,
  });
}

class TimeSlot {
  String from;
  String to;
  bool isDefault;

  TimeSlot({required this.from, required this.to, required this.isDefault});
}
