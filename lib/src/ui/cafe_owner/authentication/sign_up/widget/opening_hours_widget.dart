import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:soloseaters/src/constants/app_colors.dart';
import 'package:flutter/material.dart';
import '../bloc/sign_up/sign_up_bloc.dart';

class OpeningHoursWidget extends StatefulWidget {
  final String day;
  final OpeningHour data;
  final void Function(OpeningHour updated) onChanged;

  const OpeningHoursWidget({
    super.key,
    required this.day,
    required this.data,
    required this.onChanged,
  });

  @override
  State<OpeningHoursWidget> createState() => _OpeningHoursWidgetState();
}

class _OpeningHoursWidgetState extends State<OpeningHoursWidget> {
  bool isExpanded = false; // Track expanded/collapsed state

  Future<void> _pickTime(
    BuildContext context,
    TimeOfDay initialTime,
    void Function(TimeOfDay) onPicked,
  ) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: initialTime,
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child!,
        );
      },
    );
    if (picked != null) {
      onPicked(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final fromTime = widget.data.from;
    final toTime = widget.data.to;
    final isEnabled = widget.data.isEnabled;
    final displayTime =
        '${fromTime.format(context)} - ${toTime.format(context)}';

    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;
        final textScaleFactor = MediaQuery.of(context).textScaleFactor;

        // Calculate responsive dimensions
        final isSmallScreen = screenWidth < 350;
        final isMediumScreen = screenWidth >= 350 && screenWidth < 600;
        final isLargeScreen = screenWidth >= 600;

        // Adaptive spacing based on screen size and text scale
        final horizontalPadding =
            isSmallScreen ? 8.0 : (isMediumScreen ? 12.0 : 16.0);
        final verticalPadding =
            isSmallScreen ? 8.0 : (isMediumScreen ? 12.0 : 16.0);
        final switchWidth =
            isSmallScreen ? 45.0 : (isMediumScreen ? 55.0 : 65.0);
        final switchHeight =
            isSmallScreen ? 25.0 : (isMediumScreen ? 35.0 : 45.0);

        // Adaptive font sizes considering text scale factor
        final dayFontSize =
            (isSmallScreen ? 12.0 : (isMediumScreen ? 14.0 : 16.0)) /
            textScaleFactor;
        final timeFontSize =
            (isSmallScreen ? 11.0 : (isMediumScreen ? 13.0 : 15.0)) /
            textScaleFactor;
        final timePickerFontSize =
            (isSmallScreen ? 12.0 : (isMediumScreen ? 14.0 : 16.0)) /
            textScaleFactor;

        // Adaptive spacing between elements
        final elementSpacing =
            isSmallScreen ? 4.0 : (isMediumScreen ? 8.0 : 12.0);
        final timePickerSpacing =
            isSmallScreen ? 6.0 : (isMediumScreen ? 8.0 : 12.0);

        final collapsedHeight =
            isSmallScreen ? 50.0 : (isMediumScreen ? 90.0 : 100.0);
        final expandedHeight =
            isSmallScreen ? 90.0 : (isMediumScreen ? 190.0 : 220.0);

        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: isExpanded ? expandedHeight : collapsedHeight,
          margin: EdgeInsets.symmetric(vertical: isSmallScreen ? 4 : 6),
          padding: EdgeInsets.all(horizontalPadding),
          decoration: BoxDecoration(
            color: AppColors.primaryWhiteColor,
            borderRadius: BorderRadius.circular(15),
            border:
                isEnabled
                    ? Border.all(color: AppColors.activeBorderColor)
                    : Border.all(color: Colors.transparent),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: SingleChildScrollView(
            physics: const NeverScrollableScrollPhysics(),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: 0,
                maxHeight: expandedHeight,
              ),
              child: Column(
                children: [
                  !isEnabled
                      ? Row(
                        children: [
                          SizedBox(
                            height: switchHeight,
                            width: switchWidth,
                            child: FittedBox(
                              fit: BoxFit.fill,
                              child: Switch(
                                activeColor: AppColors.primaryWhiteColor,
                                activeTrackColor: AppColors.tertiary,
                                inactiveThumbColor: AppColors.disabledColor,
                                inactiveTrackColor: AppColors.primaryWhiteColor,
                                value: isEnabled,
                                onChanged: (val) {
                                  widget.onChanged(
                                    widget.data.copyWith(isEnabled: val),
                                  );

                                  if (val && !isExpanded) {
                                    WidgetsBinding.instance
                                        .addPostFrameCallback((_) {
                                          if (mounted) {
                                            setState(() {
                                              isExpanded = true;
                                            });
                                          }
                                        });
                                  } else if (!val && isExpanded) {
                                    WidgetsBinding.instance
                                        .addPostFrameCallback((_) {
                                          if (mounted) {
                                            setState(() {
                                              isExpanded = false;
                                            });
                                          }
                                        });
                                  }
                                },

                                // onChanged: (val) {
                                //   widget.onChanged(
                                //     widget.data.copyWith(isEnabled: val),
                                //   );
                                //   // Auto-expand when enabling the switch
                                //   if (val && !isExpanded) {
                                //     setState(() {
                                //       isExpanded = true;
                                //     });
                                //   }
                                // },
                              ),
                            ),
                          ),
                          SizedBox(width: elementSpacing),
                          Text(
                            widget.day,
                            style: Theme.of(
                              context,
                            ).textTheme.labelLarge!.copyWith(
                              fontWeight: FontWeight.w600,
                              fontSize: dayFontSize.sp,
                              color: AppColors.primary,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              'Closed',
                              textAlign: TextAlign.center,
                              style: Theme.of(
                                context,
                              ).textTheme.bodyMedium!.copyWith(
                                fontWeight: FontWeight.w600,
                                fontSize: timeFontSize.sp,
                                color: AppColors.timeTextColor,
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                isExpanded = !isExpanded;
                              });
                              // Enable the day if not enabled when expanding
                              if (!isEnabled && isExpanded) {
                                widget.onChanged(
                                  widget.data.copyWith(isEnabled: true),
                                );
                              }
                            },
                            child: Icon(
                              isExpanded
                                  ? Icons.expand_less
                                  : Icons.expand_more,
                              color: AppColors.textPrimaryGrey,
                              size:
                                  isSmallScreen
                                      ? 20
                                      : (isMediumScreen ? 24 : 28),
                            ),
                          ),
                        ],
                      )
                      : Row(
                        children: [
                          SizedBox(
                            height: switchHeight,
                            width: switchWidth,
                            child: FittedBox(
                              fit: BoxFit.fill,
                              child: Switch(
                                activeColor: AppColors.primaryWhiteColor,
                                activeTrackColor: AppColors.tertiary,
                                inactiveThumbColor: AppColors.disabledColor,
                                inactiveTrackColor: AppColors.primaryWhiteColor,
                                value: isEnabled,
                                onChanged: (val) {
                                  widget.onChanged(
                                    widget.data.copyWith(isEnabled: val),
                                  );

                                  if (val && !isExpanded) {
                                    WidgetsBinding.instance
                                        .addPostFrameCallback((_) {
                                          if (mounted) {
                                            setState(() {
                                              isExpanded = true;
                                            });
                                          }
                                        });
                                  } else if (!val && isExpanded) {
                                    // Optionally collapse when switch is turned OFF
                                    WidgetsBinding.instance
                                        .addPostFrameCallback((_) {
                                          if (mounted) {
                                            setState(() {
                                              isExpanded = false;
                                            });
                                          }
                                        });
                                  }
                                },

                                // onChanged: (val) {
                                //   widget.onChanged(
                                //     widget.data.copyWith(isEnabled: val),
                                //   );
                                //   // Auto-expand when enabling the switch
                                //   if (val && !isExpanded) {
                                //     setState(() {
                                //       isExpanded = true;
                                //     });
                                //   }
                                // },
                              ),
                            ),
                          ),
                          SizedBox(width: elementSpacing),
                          Expanded(
                            child: Text(
                              widget.day,
                              style: Theme.of(
                                context,
                              ).textTheme.labelLarge!.copyWith(
                                fontWeight: FontWeight.w600,
                                fontSize: dayFontSize.sp,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                          Flexible(
                            child: Text(
                              displayTime,
                              style: Theme.of(
                                context,
                              ).textTheme.bodyMedium!.copyWith(
                                fontWeight: FontWeight.w600,
                                fontSize: timeFontSize.sp,
                                color: AppColors.timeTextColor,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          SizedBox(width: elementSpacing),
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                isExpanded = !isExpanded;
                              });
                            },
                            child: Icon(
                              isExpanded
                                  ? Icons.expand_less
                                  : Icons.expand_more,
                              color: AppColors.timeTextColor,
                              size:
                                  isSmallScreen
                                      ? 20
                                      : (isMediumScreen ? 24 : 28),
                            ),
                          ),
                        ],
                      ),
                  if (isEnabled &&
                      isExpanded) // Show time pickers only if enabled and expanded
                    Padding(
                      padding: EdgeInsets.only(top: timePickerSpacing),
                      child: Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap:
                                  () => _pickTime(context, fromTime, (picked) {
                                    widget.onChanged(
                                      widget.data.copyWith(from: picked),
                                    );
                                  }),
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  vertical:
                                      isSmallScreen
                                          ? 8
                                          : (isMediumScreen ? 12 : 16),
                                  horizontal:
                                      isSmallScreen
                                          ? 8
                                          : (isMediumScreen ? 12 : 16),
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.timePickerBoxColor,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  fromTime.format(context),
                                  style: Theme.of(
                                    context,
                                  ).textTheme.bodyMedium!.copyWith(
                                    color: AppColors.pickedTimeColor,
                                    fontSize: timePickerFontSize.sp,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: timePickerSpacing,
                            ),
                            child: Text(
                              'to',
                              style: Theme.of(
                                context,
                              ).textTheme.bodySmall!.copyWith(
                                color: AppColors.timeDividerColor,
                                fontWeight: FontWeight.w600,
                                fontSize:
                                    (isSmallScreen
                                            ? 10.0
                                            : (isMediumScreen ? 12.0 : 14.0))
                                        .sp,
                              ),
                            ),
                          ),
                          Expanded(
                            child: GestureDetector(
                              onTap:
                                  () => _pickTime(context, toTime, (picked) {
                                    widget.onChanged(
                                      widget.data.copyWith(to: picked),
                                    );
                                  }),
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  vertical:
                                      isSmallScreen
                                          ? 8
                                          : (isMediumScreen ? 12 : 16),
                                  horizontal:
                                      isSmallScreen
                                          ? 8
                                          : (isMediumScreen ? 12 : 16),
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.timePickerBoxColor,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  toTime.format(context),
                                  style: Theme.of(
                                    context,
                                  ).textTheme.bodyMedium!.copyWith(
                                    color: AppColors.pickedTimeColor,
                                    fontSize: timePickerFontSize.sp,
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
            ),
          ),
        );
      },
    );
  }
}
