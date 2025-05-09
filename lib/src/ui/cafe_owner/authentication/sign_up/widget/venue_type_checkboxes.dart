import 'package:dicetable/src/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';

import '../bloc/sign_up/sign_up_bloc.dart';



class VenueTypeCheckboxes extends StatelessWidget {
  const VenueTypeCheckboxes({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SignUpBloc, SignUpState>(
      builder: (context, state) {
        if (state is! SignUpFormState) {
          return const SizedBox.shrink(); // return empty if not form state
        }

        final venueTypes = state.venueTypes;

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
                style: Theme.of(context).textTheme.labelMedium!.copyWith(
                  fontSize: 14,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: venueTypes.entries.map((entry) {
                  final model = entry.value;

                  return SizedBox(
                    width: 150,
                    child: InkWell(
                      onTap: () {
                        context.read<SignUpBloc>().add(
                          ToggleVenueType(
                            venueType: model.name,
                            isSelected: !model.isSelected,
                          ),
                        );
                      },
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            margin: const EdgeInsets.all(6),
                            width: 24.w,
                            height: 24.h,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: AppColors.primary,
                                width: 1.5,
                              ),
                              color: AppColors.primaryWhiteColor,
                            ),
                            child: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 200),
                              child: model.isSelected
                                  ? Center(
                                child: SvgPicture.asset(
                                  'assets/svg/check.svg',
                                  fit: BoxFit.scaleDown,
                                ),
                              )
                                  : const SizedBox.shrink(),
                            ),
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              model.name,
                              textAlign: TextAlign.left,
                              style: TextTheme.of(context).bodyMedium!.copyWith(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
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
