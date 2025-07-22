import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:soloseaters/src/constants/app_colors.dart';
import 'package:soloseaters/src/ui/cafe_owner/profile/bloc/profile_bloc.dart';
import 'package:flutter/material.dart';

class ProfileOpeningHoursWidget extends StatefulWidget {
  final String day;
  final ProfileOpeningHour data;
  final void Function(ProfileOpeningHour updated) onChanged;

  const ProfileOpeningHoursWidget({
    super.key,
    required this.day,
    required this.data,
    required this.onChanged,
  });

  @override
  State<ProfileOpeningHoursWidget> createState() => _ProfileOpeningHoursWidgetState();
}

class _ProfileOpeningHoursWidgetState extends State<ProfileOpeningHoursWidget> {
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

  // Helper method to check if we need compact layout
  bool _needsCompactLayout(double screenWidth, double textScaleFactor) {
    return screenWidth < 400 || textScaleFactor > 1.3;
  }

  @override
  Widget build(BuildContext context) {
    final fromTime = widget.data.from;
    final toTime = widget.data.to;
    final isEnabled = widget.data.isEnabled;
    final displayTime = '${fromTime.format(context)} - ${toTime.format(context)}';

    return LayoutBuilder(
      builder: (context, constraints) {
        // Get screen width and text scale factor for responsive calculations
        final screenWidth = constraints.maxWidth;
        final textScaleFactor = MediaQuery.of(context).textScaleFactor;
        final needsCompactLayout = _needsCompactLayout(screenWidth, textScaleFactor);
        
        // Calculate responsive dimensions
        final isSmallScreen = screenWidth < 350;
        final isMediumScreen = screenWidth >= 350 && screenWidth < 600;
        
        // Adaptive spacing based on screen size
        final horizontalPadding = isSmallScreen ? 8.0 : (isMediumScreen ? 12.0 : 16.0);
        final verticalPadding = isSmallScreen ? 8.0 : (isMediumScreen ? 12.0 : 16.0);
        final switchWidth = isSmallScreen ? 45.0 : (isMediumScreen ? 55.0 : 65.0);
        final switchHeight = isSmallScreen ? 25.0 : (isMediumScreen ? 35.0 : 45.0);
        
        // More conservative font sizes that work better with text scaling
        final dayFontSize = isSmallScreen ? 12.0 : (isMediumScreen ? 14.0 : 16.0);
        final timeFontSize = isSmallScreen ? 11.0 : (isMediumScreen ? 13.0 : 15.0);
        final timePickerFontSize = isSmallScreen ? 12.0 : (isMediumScreen ? 14.0 : 16.0);
        
        // Adaptive spacing between elements
        final elementSpacing = isSmallScreen ? 4.0 : (isMediumScreen ? 8.0 : 12.0);
        final timePickerSpacing = isSmallScreen ? 6.0 : (isMediumScreen ? 8.0 : 12.0);

        // Dynamic height calculation based on content and text scaling
        final baseCollapsedHeight = isSmallScreen ? 50.0 : (isMediumScreen ? 90.0 : 100.0);
        final baseExpandedHeight = isSmallScreen ? 90.0 : (isMediumScreen ? 190.0 : 220.0);
        
        // Adjust heights for large text scaling
        final collapsedHeight = needsCompactLayout 
            ? baseCollapsedHeight * (1 + (textScaleFactor - 1) * 0.3)
            : baseCollapsedHeight;
        final expandedHeight = needsCompactLayout 
            ? baseExpandedHeight * (1 + (textScaleFactor - 1) * 0.2)
            : baseExpandedHeight;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: isExpanded ? expandedHeight : collapsedHeight,
          margin: EdgeInsets.symmetric(vertical: isSmallScreen ? 4 : 6),
          padding: EdgeInsets.all(horizontalPadding),
          decoration: BoxDecoration(
            color: AppColors.primaryWhiteColor,
            borderRadius: BorderRadius.circular(15),
            border: isEnabled
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
                  // Main row content
                  needsCompactLayout && isEnabled
                      ? _buildCompactEnabledLayout(
                          switchWidth,
                          switchHeight,
                          elementSpacing,
                          dayFontSize,
                          timeFontSize,
                          displayTime,
                          isSmallScreen,
                          isMediumScreen,
                        )
                      : _buildNormalLayout(
                          isEnabled,
                          switchWidth,
                          switchHeight,
                          elementSpacing,
                          dayFontSize,
                          timeFontSize,
                          displayTime,
                          isSmallScreen,
                          isMediumScreen,
                        ),
                  
                  // Time pickers section
                  if (isEnabled && isExpanded)
                    Padding(
                      padding: EdgeInsets.only(top: timePickerSpacing),
                      child: Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () => _pickTime(context, fromTime, (picked) {
                                widget.onChanged(widget.data.copyWith(from: picked));
                              }),
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  vertical: isSmallScreen ? 8 : (isMediumScreen ? 12 : 16),
                                  horizontal: isSmallScreen ? 8 : (isMediumScreen ? 12 : 16),
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.timePickerBoxColor,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  fromTime.format(context),
                                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                                    color: AppColors.pickedTimeColor,
                                    fontSize: timePickerFontSize,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: timePickerSpacing),
                            child: Text(
                              'to',
                              style: Theme.of(context).textTheme.bodySmall!.copyWith(
                                color: AppColors.timeDividerColor,
                                fontWeight: FontWeight.w600,
                                fontSize: isSmallScreen ? 10.0 : (isMediumScreen ? 12.0 : 14.0),
                              ),
                            ),
                          ),
                          Expanded(
                            child: GestureDetector(
                              onTap: () => _pickTime(context, toTime, (picked) {
                                widget.onChanged(widget.data.copyWith(to: picked));
                              }),
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  vertical: isSmallScreen ? 8 : (isMediumScreen ? 12 : 16),
                                  horizontal: isSmallScreen ? 8 : (isMediumScreen ? 12 : 16),
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.timePickerBoxColor,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  toTime.format(context),
                                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                                    color: AppColors.pickedTimeColor,
                                    fontSize: timePickerFontSize,
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

  Widget _buildCompactEnabledLayout(
    double switchWidth,
    double switchHeight,
    double elementSpacing,
    double dayFontSize,
    double timeFontSize,
    String displayTime,
    bool isSmallScreen,
    bool isMediumScreen,
  ) {
    return Row(
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
              value: widget.data.isEnabled,
              onChanged: (val) {
                widget.onChanged(widget.data.copyWith(isEnabled: val));
                _handleSwitchChange(val); // Call to handle expansion
              },
            ),
          ),
        ),
        SizedBox(width: elementSpacing),
        // Day name - takes only the space it needs
        Text(
          widget.day,
          style: Theme.of(context).textTheme.labelLarge!.copyWith(
            fontWeight: FontWeight.w600,
            fontSize: dayFontSize,
            color: AppColors.primary,
          ),
        ),
        // Expanded space for time display - centers the time in remaining space
        Expanded(
          child: Text(
            displayTime,
            style: Theme.of(context).textTheme.bodyMedium!.copyWith(
              fontWeight: FontWeight.w600,
              fontSize: timeFontSize,
              color: AppColors.timeTextColor,
            ),
            textAlign: TextAlign.center,
            overflow: TextOverflow.visible, // Allow text to be fully visible
            maxLines: 1,
          ),
        ),
        // Icon always stays at the right end
        GestureDetector(
          onTap: () {
            setState(() {
              isExpanded = !isExpanded;
            });
          },
          child: Icon(
            isExpanded ? Icons.expand_less : Icons.expand_more,
            color: AppColors.timeTextColor,
            size: isSmallScreen ? 20 : (isMediumScreen ? 24 : 28),
          ),
        ),
      ],
    );
  }

  Widget _buildNormalLayout(
    bool isEnabled,
    double switchWidth,
    double switchHeight,
    double elementSpacing,
    double dayFontSize,
    double timeFontSize,
    String displayTime,
    bool isSmallScreen,
    bool isMediumScreen,
  ) {
    return Row(
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
                widget.onChanged(widget.data.copyWith(isEnabled: val));
                _handleSwitchChange(val); // Call to handle expansion
              },
            ),
          ),
        ),
        SizedBox(width: elementSpacing),
        Text(
          widget.day,
          style: Theme.of(context).textTheme.labelLarge!.copyWith(
            fontWeight: FontWeight.w600,
            fontSize: dayFontSize,
            color: AppColors.primary,
          ),
        ),
        if (isEnabled) ...[
          // Time display takes all remaining space and centers the text
          Expanded(
            child: Text(
              displayTime,
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                fontWeight: FontWeight.w600,
                fontSize: timeFontSize,
                color: AppColors.timeTextColor,
              ),
              textAlign: TextAlign.center,
              overflow: TextOverflow.visible, // Allow text to be fully visible
              maxLines: 1,
            ),
          ),
        ] else
          Expanded(
            child: Text(
              'Closed',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                fontWeight: FontWeight.w600,
                fontSize: timeFontSize,
                color: AppColors.timeTextColor,
              ),
            ),
          ),
        SizedBox(width: elementSpacing),
        GestureDetector(
          onTap: () {
            setState(() {
              isExpanded = !isExpanded;
            });
            if (!isEnabled && isExpanded) {
              widget.onChanged(widget.data.copyWith(isEnabled: true));
            }
          },
          child: Icon(
            isExpanded ? Icons.expand_less : Icons.expand_more,
            color: isEnabled ? AppColors.timeTextColor : AppColors.textPrimaryGrey,
            size: isSmallScreen ? 20 : (isMediumScreen ? 24 : 28),
          ),
        ),
      ],
    );
  }

  void _handleSwitchChange(bool val) {
    setState(() {
      isExpanded = val; // Expand when enabled, collapse when disabled
    });
  }
}