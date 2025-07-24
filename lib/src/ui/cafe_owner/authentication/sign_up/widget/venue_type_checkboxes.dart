import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:soloseaters/src/constants/app_colors.dart';
import 'package:soloseaters/src/constants/assets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lottie/lottie.dart';
import 'package:soloseaters/src/utils/network_connectivity/network_connectivity_bloc.dart';
import '../bloc/sign_up/sign_up_bloc.dart';
import '../model/venue_type_model.dart';

class VenueTypeCheckboxes extends StatelessWidget {
  final bool? showValidationErrors;
  final bool? hasSelectedVenue;
  final SignUpFormState state;

  const VenueTypeCheckboxes({
    super.key,
    this.showValidationErrors,
    this.hasSelectedVenue,
    required this.state,
  });

  @override
  Widget build(BuildContext context) {
    return BlocListener<NetworkConnectivityBloc, NetworkConnectivityState>(
      listenWhen:
          (previous, current) => previous.runtimeType != current.runtimeType,
      listener: (context, state) {
        if (state is NetworkFailure) {
          EasyLoading.showError(
            "No internet connection. Please try again later.",
            duration: const Duration(seconds: 3),
          );
        }
      },
      child: BlocConsumer<SignUpBloc, SignUpState>(
        builder: (context, state) {
          if (state is! SignUpFormState || state.isLoadingVenueTypes) {
            return const SizedBox();
          }

          final errorMessage = state.error;
          if (errorMessage != null && errorMessage.isNotEmpty) {
            EasyLoading.showError(
              "Unable to fetch venue types. Please check your connection and try again.",
            );
          }

          if (state.venueTypes.isNotEmpty) {
            EasyLoading.dismiss();
            return LayoutBuilder(
              builder: (context, constraints) {
                final screenWidth = constraints.maxWidth;
                final textScaleFactor = MediaQuery.of(context).textScaleFactor;

                // Adjust font and layout based on screen width and text scaling
                final isSmallScreen = screenWidth < 350;
                final fontSize =
                    (isSmallScreen ? 12.0 : 14.0) / textScaleFactor;
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
                        style: Theme.of(
                          context,
                        ).textTheme.labelMedium!.copyWith(
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
                        itemCount: state.venueTypes.length,
                        itemBuilder: (context, index) {
                          final model = state.venueTypes[index];
                          return _VenueTypeCheckbox(model: model);
                        },
                      ),
                      // const SizedBox(height: 16),
                      if (showValidationErrors == true &&
                          hasSelectedVenue == true &&
                          !state.venueTypes.any((venue) => venue.isSelected))
                        Padding(
                          padding: const EdgeInsets.only(left: 16.0, top: 4.0),
                          child: Text(
                            'Please select at least one venue type',
                            style: TextStyle(
                              color: AppColors.appRedColor,
                              fontSize: fontSize - 2,
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              },
            );
          } else {
            return const _LoadingIndicator();
          }
        },
        listener: (BuildContext context, SignUpState state) {
          if (state is SignUpFormState) {
            if (state.isLoadingVenueTypes) {
              EasyLoading.show();
            } else {
              EasyLoading.dismiss();
            }

            final errorMessage = state.error;
            if (errorMessage != null &&
                errorMessage.isNotEmpty &&
                state.venueTypes.isEmpty) {
              EasyLoading.showError(
                "Unable to fetch venue types. Please check your connection and try again.",
                duration: const Duration(seconds: 3),
              );
            }
          }
        },
      ),
    );
  }
}

class _VenueTypeCheckbox extends StatelessWidget {
  final VenueTypeModel model;

  const _VenueTypeCheckbox({required this.model});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return InkWell(
          key: ValueKey(model.id),
          onTap: () {
            context.read<SignUpBloc>().add(
              ToggleVenueType(id: model.id, isSelected: !model.isSelected),
            );
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
                      model.isSelected
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
                  model.name,
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

class _LoadingIndicator extends StatelessWidget {
  const _LoadingIndicator();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        height: 50,
        width: 50,
        child: Lottie.asset(Assets.JUMBING_DOT),
      ),
    );
  }
}
