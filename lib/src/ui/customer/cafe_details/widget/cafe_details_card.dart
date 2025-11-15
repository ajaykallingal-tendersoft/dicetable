import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import 'package:soloseaters/src/constants/app_colors.dart';
import 'package:soloseaters/src/constants/assets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
import 'package:lottie/lottie.dart';
import 'package:soloseaters/src/model/customer/cafe/cafe_list_response.dart';
import 'package:soloseaters/src/ui/customer/cafe_list/components/cafe_details_arguments.dart';

class CafeDetailsCard extends StatefulWidget {
  final String name;
  final String id;
  final List<String> tableType;
  final String description;
  final String image;
  final List<WorkingHour>? openingHours;
  final bool bookingStatus;
  final List<String> gallery;
  final List<Attende>? attendes;
  final List<UpcomingEvent>? upcomingEvents;

  const CafeDetailsCard({
    super.key,
    required this.name,
    required this.tableType,
    required this.description,
    required this.image,
    this.openingHours,
    required this.id,
    required this.bookingStatus,
    required this.gallery,
    this.attendes,
    this.upcomingEvents,
  });

  @override
  State<CafeDetailsCard> createState() => _CafeDetailsCardState();
}

class _CafeDetailsCardState extends State<CafeDetailsCard> {
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
  }

  Widget _buildDot(int index) {
    return Container(
      width: 8.0,
      height: 8.0,
      margin: EdgeInsets.symmetric(horizontal: 4.0),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color:
            _currentPage == index
                ? AppColors.primary
                : AppColors.textPrimaryGrey.withOpacity(0.5),
      ),
    );
  }

  // Helper function to capitalize day abbreviation (e.g., 'mon' -> 'Mon')
  String _capitalize(String s) => s[0].toUpperCase() + s.substring(1);

  // Helper function to convert 'mon' to 'Monday'
  String _getFullDay(String dayAbbr) {
    switch (dayAbbr.toLowerCase()) {
      case 'mon':
        return 'Monday';
      case 'tue':
        return 'Tuesday';
      case 'wed':
        return 'Wednesday';
      case 'thu':
        return 'Thursday';
      case 'fri':
        return 'Friday';
      case 'sat':
        return 'Saturday';
      case 'sun':
        return 'Sunday';
      default:
        return _capitalize(dayAbbr);
    }
  }

  // Helper function to convert 24h time string ('10:00:00') to 12h time ('10:00 AM')
  String _formatTime(String time24) {
    try {
      final parts = time24.split(':');
      final hour = int.parse(parts[0]);
      final minute = int.parse(parts[1]);
      final time = TimeOfDay(hour: hour, minute: minute);
      // You might need a more robust way to get the context for format,
      // but this is a simple string conversion approach:
      final period = hour >= 12 ? 'PM' : 'AM';
      final formattedHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
      final formattedMinute = minute.toString().padLeft(2, '0');
      return '$formattedHour:$formattedMinute $period';
    } catch (e) {
      return time24; // Return original if parsing fails
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool hasDescription =
        widget.description != null &&
        widget.description.trim().isNotEmpty &&
        widget.description.trim().toLowerCase() != 'null';

    final bool hasUpcomingEvents = widget.upcomingEvents?.isNotEmpty ?? false;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16),
      margin: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.primaryWhiteColor,
        borderRadius: BorderRadius.circular(15),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            offset: Offset(0, 1), // Horizontal and vertical offsets
            blurRadius: 4.0, // Softness of the shadow
            spreadRadius: 1.0, // Extent of the shadow
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.name,
                style: TextTheme.of(context).labelMedium!.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 16.sp,
                ),
              ),
              InkWell(
                onTap: () {
                  context.push(
                    '/networking_attendees',
                    extra: CafeDetailsArguments(
                      from: "CafeList",
                      name: widget.name ?? "Unknown Cafe",
                      tableType: widget.tableType ?? [],
                      description: widget.description ?? "No description",
                      image: widget.image ?? '',
                      openingHours: widget.openingHours ?? [],
                      id: widget.id.toString(),
                      bookingStatus: widget.bookingStatus ?? false,
                      gallery: widget.gallery ?? [],
                      attendes: widget.attendes ?? [],
                      upcomingEvents: widget.upcomingEvents ?? [],
                    ),
                  );
                  // TODO: Implement navigation to the attendees screen
                  // context.push('/attendees_screen', extra: id);
                },
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color:
                        AppColors.primary, // Using primary color for the button
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'View Attendess',
                    style: Theme.of(context).textTheme.bodySmall!.copyWith(
                      color: AppColors.primaryWhiteColor,
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),

          Gap(10),

          // ---- FIXED GALLERY SECTION ----
          if (widget.gallery.isNotEmpty &&
              widget.gallery.any((img) => img.trim().isNotEmpty))
            LayoutBuilder(
              builder: (context, constraints) {
                return ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: AspectRatio(
                    aspectRatio:
                        4/3, // Auto adjust height instead of fixed 240.h
                    child: PageView.builder(
                      itemCount: widget.gallery.length,
                      onPageChanged: (index) {
                        setState(() {
                          _currentPage = index;
                        });
                      },
                      itemBuilder: (context, index) {
                        final imageUrl = widget.gallery[index];
                        final heroTag =
                            index == 0 ? widget.id : '${widget.id}_$index';

                        return Hero(
                          tag: heroTag,
                          child:
                              (imageUrl.trim().isNotEmpty)
                                  ? CachedNetworkImage(
                                    imageUrl: imageUrl,
                                    fit: BoxFit.cover,
                                    placeholder:
                                        (context, url) => Center(
                                          child: Lottie.asset(
                                            Assets.JUMBING_DOT,
                                            height: 20,
                                            width: 20,
                                          ),
                                        ),
                                    errorWidget:
                                        (context, url, error) =>
                                            SvgPicture.asset(
                                              'assets/svg/cafe-list.svg',
                                              fit: BoxFit.cover,
                                            ),
                                  )
                                  : SvgPicture.asset(
                                    'assets/svg/cafe-list.svg',
                                    fit: BoxFit.cover,
                                  ),
                        );
                      },
                    ),
                  ),
                );
              },
            ),

          // ClipRRect(
          //   borderRadius: BorderRadius.circular(15),
          //   child: SizedBox(
          //     height: 240.h, // Define a fixed height for the carousel
          //     child: PageView.builder(
          //       itemCount: widget.gallery.length,
          //       onPageChanged: (index) {
          //         setState(() {
          //           _currentPage = index;
          //         });
          //       },
          //       itemBuilder: (context, index) {
          //         final imageUrl = widget.gallery[index];
          //         // Use the Hero tag on the first image only, or use a list of unique tags
          //         final heroTag =
          //             index == 0 ? widget.id : '${widget.id}_$index';

          //         return Hero(
          //           tag: heroTag,
          //           child:
          //               (imageUrl.trim().isNotEmpty)
          //                   ? CachedNetworkImage(
          //                     imageUrl: imageUrl,
          //                     fit:
          //                         BoxFit
          //                             .cover, // Use BoxFit.cover for carousels
          //                     placeholder:
          //                         (context, url) => Center(
          //                           child: Lottie.asset(
          //                             Assets.JUMBING_DOT,
          //                             height: 20,
          //                             width: 20,
          //                           ),
          //                         ),
          //                     errorWidget:
          //                         (context, url, error) => SvgPicture.asset(
          //                           'assets/svg/cafe-list.svg',
          //                           fit: BoxFit.cover,
          //                         ),
          //                   )
          //                   : SvgPicture.asset(
          //                     'assets/svg/cafe-list.svg',
          //                     fit: BoxFit.cover,
          //                   ),
          //         );
          //       },
          //     ),
          //   ),
          // ),
          Gap(7),

          // Pagination Dots
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              widget.gallery.length,
              (index) => _buildDot(index),
            ),
          ),

          Gap(25),
          RichText(
            text: TextSpan(
              style: Theme.of(context).textTheme.bodySmall!.copyWith(
                fontSize: 10.sp,
                color: AppColors.shadowColor,
              ),
              children: [
                TextSpan(
                  text: 'Table Type:\n',
                  style: TextTheme.of(context).bodySmall!.copyWith(
                    color: AppColors.shadowColor,
                    fontWeight: FontWeight.w500,
                    fontSize: 10.sp,
                  ),
                ),
                TextSpan(
                  text: widget.tableType.join(', ') ?? '',
                  style: TextTheme.of(context).bodyMedium!.copyWith(
                    color: AppColors.shadowColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 12.sp,
                  ),
                ),
              ],
            ),
          ),

          Gap(10),
          Divider(color: AppColors.primaryBlackColor, thickness: 0.4),
          Gap(10),
          Visibility(
            visible: hasDescription,
            child: Text(
              'Description:',
              style: TextTheme.of(context).bodySmall!.copyWith(
                color: AppColors.shadowColor,
                fontWeight: FontWeight.w500,
                fontSize: 10.sp,
              ),
            ),
          ),
          Gap(hasDescription ? 3 : 0),
          Visibility(
            visible: hasDescription,
            child: Text(
              widget.description,
              style: TextTheme.of(context).bodyMedium!.copyWith(
                color: AppColors.shadowColor,
                fontWeight: FontWeight.w600,
                fontSize: 12.sp,
              ),
            ),
          ),
          Gap(10),
          if (hasDescription)
            Divider(color: AppColors.primaryBlackColor, thickness: 0.4),
          Gap(hasDescription ? 10 : 0),
          Visibility(
            visible: hasUpcomingEvents,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Upcoming Events:',
                  style: Theme.of(context).textTheme.bodySmall!.copyWith(
                    color: AppColors.shadowColor,
                    fontWeight: FontWeight.w500,
                    fontSize: 10.sp,
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Gap(3),

                    // The main logic to process and display all event details
                    // The following section is corrected:
                    ...?widget.upcomingEvents?.map((event) {
                      // Correctly cast the dynamic event to UpcomingEvent
                      final upcomingEvent = event as UpcomingEvent;

                      final dayWidgets = <Widget>[];

                      // Access availableDays directly from the UpcomingEvent object
                      final availableDays = upcomingEvent.availableDays;

                      if (availableDays != null) {
                        for (var day in availableDays) {
                          // Access properties directly from the AvailableDay object
                          // and use the helper function _getFullDay
                          final fullDay = _getFullDay(day.day as String);

                          // Access timings directly from the AvailableDay object
                          final timings = day.timings;

                          if (timings != null) {
                            for (var timing in timings) {
                              // Access open/close directly from the Timing object
                              final openTime = _formatTime(
                                timing.open as String,
                              );
                              final closeTime = _formatTime(
                                timing.close as String,
                              );

                              // 1. Event Name on Day (Business Networking on Monday)
                              dayWidgets.add(
                                Text(
                                  '${upcomingEvent.name} on $fullDay', // Use upcomingEvent.name
                                  style: Theme.of(
                                    context,
                                  ).textTheme.bodyMedium!.copyWith(
                                    color: AppColors.shadowColor,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12.sp,
                                  ),
                                ),
                              );

                              // 2. Start Time - End Time (10:00 AM - 12:00 PM)
                              dayWidgets.add(
                                Text(
                                  '$openTime - $closeTime',
                                  style: Theme.of(
                                    context,
                                  ).textTheme.bodyMedium!.copyWith(
                                    color: AppColors.shadowColor,
                                    fontWeight: FontWeight.normal,
                                    fontSize: 12.sp,
                                  ),
                                ),
                              );

                              // Add a small gap between different timings/events
                              dayWidgets.add(const Gap(8));
                            }
                          }
                        }
                      }
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: dayWidgets,
                      );
                    }).toList(), // Convert the map result to a List of Widgets
                  ],
                ),
                Gap(10),
                Divider(color: AppColors.primaryBlackColor, thickness: 0.4),
                Gap(10),
              ],
            ),
          ),

          // Gap(hasDescription ? 10 : 0),
          Text(
            'Opening Hours:',
            style: Theme.of(context).textTheme.bodySmall!.copyWith(
              color: AppColors.shadowColor,
              fontWeight: FontWeight.w500,
              fontSize: 10.sp,
            ),
          ),
          Gap(3),

          // --- START OF WORKING HOURS FIX ---
          if (widget.openingHours != null && widget.openingHours!.isNotEmpty)
            ...widget.openingHours!
                .map((entry) {
                  // Safely cast the entry to the correct WorkingHour model
                  final workingHour = entry as WorkingHour;

                  // Determine the display text, color, and font weight
                  final String timeText;
                  final Color timeColor;
                  final FontWeight timeFontWeight;

                  // Check the isOpen property, which is a bool
                  if (workingHour.isOpen == true) {
                    // Display time range (e.g., "08:00 AM - 10:00 PM")
                    timeText =
                        '${workingHour.opening} - ${workingHour.closing}'; // Accessing opening/closing properties
                    timeColor = AppColors.shadowColor;
                    timeFontWeight = FontWeight.w600;
                  } else {
                    // Display "Closed"
                    timeText = 'Closed';
                    timeColor =
                        AppColors
                            .shadowColor; // Use a distinct color for "Closed"
                    timeFontWeight = FontWeight.w600;
                  }

                  final dayName = _getFullDay(workingHour.day as String);

                  return Padding(
                    padding: const EdgeInsets.only(
                      bottom: 2.0,
                    ), // Small gap between days
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          '$dayName: ',
                          style: Theme.of(
                            context,
                          ).textTheme.bodyMedium!.copyWith(
                            color: AppColors.shadowColor,
                            fontWeight: FontWeight.w600,
                            fontSize: 12.sp,
                          ),
                        ),

                        Text(
                          timeText,
                          style: Theme.of(
                            context,
                          ).textTheme.bodyMedium!.copyWith(
                            color: timeColor, // Apply conditional color
                            fontWeight:
                                timeFontWeight, // Apply conditional font weight
                            fontSize: 12.sp,
                          ),
                        ),
                      ],
                    ),
                  );
                })
                .toList() // Convert the map result to a List of Widgets
          else
            Text(
              "Opening hours not available",
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                color: AppColors.shadowColor,
                fontWeight: FontWeight.w600,
                fontSize: 12.sp,
              ),
            ),
        ],
      ),
    );
  }
}
