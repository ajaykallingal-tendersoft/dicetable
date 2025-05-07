import 'package:dicetable/src/constants/app_colors.dart';
import 'package:dicetable/src/ui/cafe_owner/profile/bloc/profile_bloc.dart';
import 'package:flutter/material.dart';

class ProfileOpeningHoursWidget extends StatelessWidget {
  final String day;
  final ProfileOpeningHour data;
  final void Function(ProfileOpeningHour updated) onChanged;

  const ProfileOpeningHoursWidget({
    super.key,
    required this.day,
    required this.data,
    required this.onChanged,
  });

  Future<void> _pickTime(
      BuildContext context,
      TimeOfDay initialTime,
      void Function(TimeOfDay) onPicked,
      ) async {
    final picked = await showTimePicker(context: context, initialTime: initialTime);
    if (picked != null) {
      onPicked(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final fromTime = data.from;
    final toTime = data.to;
    final isEnabled = data.isEnabled;
    final displayTime = '${fromTime.format(context)} - ${toTime.format(context)}';

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.all(12),
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
      child: Column(
        children: [
          Row(
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
                      onChanged(data.copyWith(isEnabled: val));
                    },
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  day,
                  style: TextTheme.of(context).bodyMedium!.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ),
              Text(
                isEnabled ? displayTime : '',
                style: TextTheme.of(context).bodyMedium!.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.timeTextColor,
                ),
              ),
              const SizedBox(width: 10),
              const Icon(
                Icons.expand_more,
                color: AppColors.textPrimaryGrey,
              ),
            ],
          ),
          if (isEnabled)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _pickTime(context, fromTime, (picked) {
                        onChanged(data.copyWith(from: picked));
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
                          style: TextTheme.of(context).bodyMedium!.copyWith(
                            color: AppColors.pickedTimeColor,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Text(
                      'to',
                      style: TextTheme.of(context).bodySmall!.copyWith(
                        color: AppColors.timeDividerColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _pickTime(context, toTime, (picked) {
                        onChanged(data.copyWith(to: picked));
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
                          style: TextTheme.of(context).bodyMedium!.copyWith(
                            color: AppColors.pickedTimeColor,
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
    );
  }
}
