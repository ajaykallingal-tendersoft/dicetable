import 'package:dicetable/src/constants/app_colors.dart';
import 'package:dicetable/src/constants/assets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:lottie/lottie.dart';

import '../bloc/sign_up/sign_up_bloc.dart';
import '../model/venue_type_model.dart';



class VenueTypeCheckboxes extends StatelessWidget {
  const VenueTypeCheckboxes({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SignUpBloc, SignUpState>(
      builder: (context, state) {
        // Show loading indicator if not in form state
        if (state is! SignUpFormState) {
          return const _LoadingIndicator();
        }

        // Show loading indicator if venue types are loading
        if (state.isLoadingVenueTypes) {
          return const _LoadingIndicator();
        }

        // Show error if present
        if (state.error != null && state.error!.isNotEmpty) {
          return Center(child: Text(state.error!, style: const TextStyle(color: Colors.red)));
        }

        // Show empty state if no venue types
        if (state.venueTypes.isEmpty) {
          return const Center(child: Text('No venue types available'));
        }

        // Show the actual checkboxes
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
            ],
          ),
        );
      },
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
                  width: 18,
                  height: 18,
                ),
              )
                  : const SizedBox.shrink(),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              model.name,
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
              overflow: TextOverflow.ellipsis,
            ),
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