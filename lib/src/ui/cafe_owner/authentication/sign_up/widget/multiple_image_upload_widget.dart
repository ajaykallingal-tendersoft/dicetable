import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';
import 'package:lottie/lottie.dart';
import 'package:soloseaters/src/constants/app_colors.dart';
import 'package:soloseaters/src/constants/assets.dart';
import 'package:soloseaters/src/ui/cafe_owner/authentication/sign_up/bloc/sign_up/sign_up_bloc.dart';

class MultipleImageUploadWidget extends StatefulWidget {
  final bool showValidationErrors;
  final SignUpFormState state;

  const MultipleImageUploadWidget({
    super.key,
    required this.showValidationErrors,
    required this.state,
  });

  @override
  State<MultipleImageUploadWidget> createState() =>
      _MultipleImageUploadWidgetState();
}

class _MultipleImageUploadWidgetState extends State<MultipleImageUploadWidget> {
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SignUpBloc, SignUpState>(
      listener: (context, state) {
        if (state is SignUpImageErrorState) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage),
              backgroundColor: AppColors.appRedColor,
            ),
          );
        }
      },
      builder: (context, state) {
        final images =
            (state is SignUpFormState) ? state.multipleImages ?? [] : [];

        return Container(
          width: double.infinity,
          padding:  const EdgeInsets.only(left: 16,right: 16,top: 16,bottom: 0),
          decoration: BoxDecoration(
            color: AppColors.signUpContainerColor,
            borderRadius: BorderRadius.circular(16),
          ),
          child:
              state is SignUpImageLoadingState
                  ? Center(
                    child: Lottie.asset(
                      Assets.JUMBING_DOT,
                      fit: BoxFit.scaleDown,
                      width: 40.w,
                      height: 40.h,
                    ),
                  )
                  : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Upload Cafe/Eatery Photos',
                        style: Theme.of(context).textTheme.labelMedium!
                            .copyWith(fontSize: 16, color: AppColors.primary),
                      ),
                      const Gap(15),
                      if (images.isNotEmpty)
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3,
                                crossAxisSpacing: 8,
                                mainAxisSpacing: 8,
                              ),
                          itemCount: images.length,
                          itemBuilder: (context, index) {
                            return Stack(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.file(
                                    File(images[index].path),
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                    height: double.infinity,
                                  ),
                                ),
                                Positioned(
                                  top: 4,
                                  right: 4,
                                  child: GestureDetector(
                                    onTap: () {
                                      context.read<SignUpBloc>().add(
                                        RemoveSingleImageEvent(index),
                                      );
                                    },
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Colors.black54,
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: const Icon(
                                        Icons.close,
                                        color: Colors.white,
                                        size: 18,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      const Gap(15),
                      InkWell(
                        onTap: () {
                          context.read<SignUpBloc>().add(
                            PickMultipleImagesFromGalleryEvent(),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.primaryWhiteColor,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            children: [
                              Container(
                                height: 54.18,
                                width: 54.18,
                                padding: const EdgeInsets.all(15),
                                decoration: BoxDecoration(
                                  color: AppColors.primary,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: SvgPicture.asset(
                                  'assets/svg/upload-photo.svg',
                                ),
                              ),
                              const Gap(10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Upload from Gallery',
                                      style: Theme.of(
                                        context,
                                      ).textTheme.bodyMedium!.copyWith(
                                        color: AppColors.primary,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    Text(
                                      'Select multiple JPEG or PNG images (max 5MB each)',
                                      style: Theme.of(
                                        context,
                                      ).textTheme.bodySmall!.copyWith(
                                        color: AppColors.timeTextColor,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const Gap(10),
                      Align(
                        alignment: Alignment.center,
                        child: Text(
                          'Or',
                          style: Theme.of(context).textTheme.bodyMedium!
                              .copyWith(color: AppColors.textPrimaryGrey),
                        ),
                      ),
                      const Gap(10),
                      InkWell(
                        onTap: () {
                          context.read<SignUpBloc>().add(
                            TakeMultiplePicturesEvent(),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.primaryWhiteColor,
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SvgPicture.asset(
                                'assets/svg/take-pic.svg',
                                color: AppColors.primary,
                              ),
                              const Gap(10),
                              Text(
                                'Take Picture',
                                style: Theme.of(
                                  context,
                                ).textTheme.bodyMedium!.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const Gap(10),
                      if (images.isNotEmpty)
                        Center(
                          child: TextButton.icon(
                            onPressed: () {
                              context.read<SignUpBloc>().add(
                                ClearAllImagesEvent(),
                              );
                            },
                            icon: const Icon(
                              Icons.delete_outline,
                              color: Colors.red,
                            ),
                            label: Text(
                              "Clear All",
                              style: TextStyle(
                                color: Colors.red,
                                fontSize: 14.sp,
                              ),
                            ),
                          ),
                        ),
                      const Gap(10),
                      if (widget.showValidationErrors &&
                          state is SignUpFormState &&
                          (state.multipleImages.isEmpty))
                        Padding(
                          padding: const EdgeInsets.only(left: 16.0, top: 4.0),
                          child: Align(
                            alignment: Alignment.center,
                            child: Text(
                              'Please upload at least one image to continue.',
                              style: TextStyle(
                                color: AppColors.appRedColor,
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
        );
      },
    );
  }
}
