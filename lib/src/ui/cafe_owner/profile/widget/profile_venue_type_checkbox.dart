import 'package:soloseaters/src/constants/app_colors.dart';
import 'package:soloseaters/src/ui/cafe_owner/profile/bloc/profile_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ProfileVenueTypeCheckboxes extends StatelessWidget {
  const ProfileVenueTypeCheckboxes({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileBloc, ProfileState>(
      builder: (context, state) {
        final venueTypes = state.venueTypes;

        return LayoutBuilder(
          builder: (context, constraints) {
            final screenWidth = constraints.maxWidth;
            final textScaleFactor = MediaQuery.of(context).textScaleFactor;

            // Adjust font and layout based on screen width and text scaling
            final isSmallScreen = screenWidth < 350;
            final fontSize = (isSmallScreen ? 12.0 : 14.0) / textScaleFactor;
            final gridAspectRatio = isSmallScreen ? 3.0 : 3.5;

            return Container(
              width: double.infinity,
              padding: const EdgeInsets.only(
                top: 16,
                left: 16,
                right: 8,
                bottom: 16,
              ),
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
                      fontSize: fontSize,
                      color: AppColors.primary,
                    ),
                  ),
                  SizedBox(height: 16.h),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: gridAspectRatio,
                      mainAxisSpacing: 8,
                      crossAxisSpacing: 8,
                    ),
                    itemCount: venueTypes.length,
                    itemBuilder: (context, index) {
                      final type = venueTypes[index];
                      final isSelected = state.selectedVenueTypeIds.contains(
                        type.id,
                      );
                      return _ProfileVenueTypeCheckbox(
                        key: ValueKey('${type.id}_${isSelected}'),
                        type: type,
                        isSelected: isSelected,
                      );
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _ProfileVenueTypeCheckbox extends StatelessWidget {
  final dynamic type; // Using dynamic to match your existing type
  final bool isSelected;
  const _ProfileVenueTypeCheckbox({
    Key? key, // <--- Accept key
    required this.type,
    required this.isSelected,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return InkWell(
          key: ValueKey(type.id),
          onTap: () {
            if (type.id != null) {
              context.read<ProfileBloc>().add(
                ToggleVenueType(venueTypeId: type.id!, isSelected: !isSelected),
              );
            }
          },
          borderRadius: BorderRadius.circular(8.r),
          child: Row(
            children: [
              Container(
                margin: EdgeInsets.all(6.r),
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6.r),
                  border: Border.all(color: AppColors.primary, width: 1.5),
                  color: AppColors.primaryWhiteColor,
                ),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child:
                      isSelected
                          ? Center(
                            child: SvgPicture.asset(
                              'assets/svg/check.svg',
                              fit: BoxFit.scaleDown,
                              width: 18.w,
                              height: 18.h,
                            ),
                          )
                          : const SizedBox.shrink(),
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  type.title ?? '',
                  textAlign: TextAlign.left,
                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                  softWrap: true,
                  maxLines: 2,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
