import 'package:dicetable/src/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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

  // Future<void> _pickTime(
  //     BuildContext context,
  //     TimeOfDay initialTime,
  //     void Function(TimeOfDay) onPicked,
  //     ) async {
  //   final picked = await showTimePicker(context: context, initialTime: initialTime);
  //   if (picked != null) {
  //     onPicked(picked);
  //   }
  // }

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

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.all(12),
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
      child: Column(
        children: [
          !isEnabled
              ? Row(
                children: [
                  SizedBox(
                    height: 35,
                    width: 55,
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
                          // Auto-expand when enabling the switch
                          if (val && !isExpanded) {
                            setState(() {
                              isExpanded = true;
                            });
                          }
                        },
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 8,
                  ), // Small spacing between Switch and Day
                  Text(
                    widget.day,
                    style: Theme.of(context).textTheme.labelLarge!.copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: AppColors.primary,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      'Closed',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                        fontWeight: FontWeight.w600,
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
                        widget.onChanged(widget.data.copyWith(isEnabled: true));
                      }
                    },
                    child: Icon(
                      isExpanded ? Icons.expand_less : Icons.expand_more,
                      color: AppColors.textPrimaryGrey,
                    ),
                  ),
                ],
              )
              : Row(
                children: [
                  SizedBox(
                    height: 35,
                    width: 55,
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
                          // Auto-expand when enabling the switch
                          if (val && !isExpanded) {
                            setState(() {
                              isExpanded = true;
                            });
                          }
                        },
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      widget.day,
                      style: Theme.of(context).textTheme.labelLarge!.copyWith(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  Text(
                    displayTime,
                    style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.timeTextColor,
                    ),
                  ),
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        isExpanded = !isExpanded;
                      });
                    },
                    child: Icon(
                      isExpanded ? Icons.expand_less : Icons.expand_more,
                      color: AppColors.timeTextColor,
                    ),
                  ),
                ],
              ),
          if (isEnabled &&
              isExpanded) // Show time pickers only if enabled and expanded
            Padding(
              padding: const EdgeInsets.only(top: 12),
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
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: AppColors.timePickerBoxColor,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          fromTime.format(context),
                          style: Theme.of(context).textTheme.bodyMedium!
                              .copyWith(color: AppColors.pickedTimeColor),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Text(
                      'to',
                      style: Theme.of(context).textTheme.bodySmall!.copyWith(
                        color: AppColors.timeDividerColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap:
                          () => _pickTime(context, toTime, (picked) {
                            widget.onChanged(widget.data.copyWith(to: picked));
                          }),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: AppColors.timePickerBoxColor,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          toTime.format(context),
                          style: Theme.of(context).textTheme.bodyMedium!
                              .copyWith(color: AppColors.pickedTimeColor),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
