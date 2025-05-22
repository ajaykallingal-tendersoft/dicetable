import 'package:dicetable/src/constants/app_colors.dart';
import 'package:dicetable/src/ui/cafe_owner/profile/bloc/profile_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';

class ProfileVenueTypeCheckboxes extends StatelessWidget {
  const ProfileVenueTypeCheckboxes({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileBloc, ProfileState>(
      builder: (context, state) {
        // final venueTypes = state.venu\eTypes;
        late Map<String, bool> venueTypes;

        if (state is EditProfileLoaded) {
          venueTypes = state.venueTypes;
        } else {
          venueTypes = state.venueTypes;
        }
        // print(venueTypes.runtimeType);
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.signUpContainerColor,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Venue Type',
                style: TextTheme.of(
                  context,
                ).labelMedium!.copyWith(fontSize: 14, color: AppColors.primary),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children:
                    venueTypes.entries.map((entry) {
                      return SizedBox(
                        width: 150,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Checkbox(
                              value: entry.value,
                              onChanged: (bool? newValue) {
                                if (newValue != null) {
                                  context.read<ProfileBloc>().add(
                                    ToggleVenueType(
                                      venueType: entry.key,
                                      isSelected: newValue,
                                    ),
                                  );
                                }
                              },
                              activeColor: const Color(0xFF003366),
                            ),
                            const Gap(0),
                            Expanded(
                              child: Text(
                                entry.key,
                                textAlign: TextAlign.left,
                                style: const TextStyle(
                                  color: Color(0xFF003366),
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
              ),
            ],
          ),
        );
      },
    );
  }
}
