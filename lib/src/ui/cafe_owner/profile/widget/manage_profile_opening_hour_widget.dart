import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:soloseaters/src/constants/app_colors.dart';
import 'package:soloseaters/src/ui/cafe_owner/profile/bloc/profile_bloc.dart';

class OpeningHoursWidget extends StatelessWidget {
  final Map<String, ProfileOpeningHour> openingHours;

  const OpeningHoursWidget({
    super.key,
    required this.openingHours,
  });

  // Helper function to format TimeOfDay (assume this is defined elsewhere or add it)
  String _formatTimeOfDay(TimeOfDay timeOfDay) {
    final hour = timeOfDay.hourOfPeriod == 0 ? 12 : timeOfDay.hourOfPeriod;
    final minutes = timeOfDay.minute.toString().padLeft(2, '0');
    final period = timeOfDay.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minutes $period';
  }

  // Modified function to create ONLY the list of day/time strings
  String _formatOpeningHours() {
    if (openingHours.isEmpty) return 'No opening hours set';

    // Define the standard order of days (Full Name -> BLoC Key)
    const orderedDayMap = {
      'Monday': 'mon',
      'Tuesday': 'tue',
      'Wednesday': 'wed',
      'Thursday': 'thu',
      'Friday': 'fri',
      'Saturday': 'sat',
      'Sunday': 'sun',
    };

    final buffer = StringBuffer();

    // Iterate through the full day names for correct display order
    for (final entry in orderedDayMap.entries) {
      final fullDayName = entry.key; // e.g., 'Monday'
      final blocKey = entry.value;   // e.g., 'mon'

      // Look up the hours using the BLoC's key ('mon', 'tue', etc.)
      final hours = openingHours[blocKey];

      // Safety check: only process if the day data is present
      if (hours != null) {
        if (hours.isEnabled) {
          final fromTime = _formatTimeOfDay(hours.from);
          final toTime = _formatTimeOfDay(hours.to);
          // Format: Day: HH:MM AM/PM - HH:MM AM/PM
          buffer.writeln('$fullDayName: $fromTime - $toTime\n');
        } else {
          // Format: Day: Closed
          buffer.writeln('$fullDayName: Closed\n');
        }
      }
    }

    // Return the combined string, removing any leading/trailing whitespace
    return buffer.toString().trim();
  }

  @override
  Widget build(BuildContext context) {
    final formattedHours = _formatOpeningHours();

    return Container(
      width: MediaQuery.sizeOf(context).width,
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 14),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.profileTextFiledBorderColor,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Opening Hours',
            style: GoogleFonts.montserrat(
              color: AppColors.profileTextFiledSubColor,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          const Gap(10),
          formattedHours == 'No opening hours set'
              ? Center(
                  child: Text(
                    'No opening hours set',
                   style: GoogleFonts.montserrat(
                      color: AppColors.disabledColor,
                      fontSize: 12,
                    ),
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Text(
                    formattedHours,
                    style: GoogleFonts.montserrat(
                      color: AppColors.primaryWhiteColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w600
                    ),
                  ),
                ),
        ],
      ),
    );
  }
}