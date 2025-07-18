import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:soloseaters/src/constants/app_colors.dart';
import 'package:soloseaters/src/constants/assets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
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
        listenWhen: (previous, current) => previous.runtimeType != current.runtimeType,
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
            EasyLoading.showError("Unable to fetch venue types. Please check your connection and try again.");
    
          }
      
          if (state.venueTypes.isNotEmpty) {
            EasyLoading.dismiss();
            return Container(
              width: double.infinity,
              padding: EdgeInsets.only(top: 16, left: 16, right: 8, bottom: 16),
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
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 3.5,
                      mainAxisSpacing: 8,
                      crossAxisSpacing: 8,
                    ),
                    itemCount: state.venueTypes.length,
                    itemBuilder: (context, index) {
                      final model = state.venueTypes[index];
                      return _VenueTypeCheckbox(model: model);
                    },
                  ),
                  const SizedBox(height: 16),
                  if (showValidationErrors == true &&
                      hasSelectedVenue == true &&
                      !state.venueTypes.any((venue) => venue.isSelected))
                    Padding(
                      padding: const EdgeInsets.only(left: 16.0, top: 4.0),
                      child: Text(
                        'Please select at least one venue type',
                        style: TextStyle(
                          color: AppColors.appRedColor,
                          fontSize: 12.sp,
                        ),
                      ),
                    ),
                ],
              ),
            );
          } else {
            return _LoadingIndicator();
          }
        }, 
       listener: (BuildContext context, SignUpState state) {
  if (state is SignUpFormState) {
    if (state.isLoadingVenueTypes ) {
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
}


      ),
    );
  }
}

class _VenueTypeCheckbox extends StatelessWidget {
  final VenueTypeModel model;

  const _VenueTypeCheckbox({required this.model});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      key: ValueKey(model.id),
      onTap: () {
        context.read<SignUpBloc>().add(
          ToggleVenueType(id: model.id, isSelected: !model.isSelected),
        );
      },
      borderRadius: BorderRadius.circular(8),
      child: Row(
        children: [
          Container(
            margin: const EdgeInsets.all(6),
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: AppColors.primary, width: 1.5),
              color: AppColors.primaryWhiteColor,
            ),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: model.isSelected
                  ? Center(
                      child: SvgPicture.asset(
                        'assets/svg/check.svg',
                        fit: BoxFit.scaleDown,
                        width: 18,
                        height: 18,
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
          ),
          Expanded(
            child: Text(
              textAlign: TextAlign.left,
              model.name,
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                fontSize: 14,
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
  }
}

class _ErrorWidget extends StatelessWidget {
  final String errorMessage;
  final VoidCallback onRetry;

  const _ErrorWidget({
    required this.errorMessage,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.signUpContainerColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.error_outline,
            color: AppColors.appRedColor,
            size: 48,
          ),
          const SizedBox(height: 16),
          Text(
            'Failed to load venue types',
            style: Theme.of(context).textTheme.titleMedium!.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            errorMessage,
            style: Theme.of(context).textTheme.bodySmall!.copyWith(
              color: AppColors.appRedColor,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: onRetry,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.primaryWhiteColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}

class _EmptyStateWidget extends StatelessWidget {
  final VoidCallback onRetry;

  const _EmptyStateWidget({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.signUpContainerColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Unable to load venue types at this time',
            style: Theme.of(context).textTheme.bodySmall!.copyWith(
              color: AppColors.primary.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: onRetry,
            style: TextButton.styleFrom(
              foregroundColor: AppColors.primary,
            ),
            child: const Text('Try Again'),
          ),
        ],
      ),
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