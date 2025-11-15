import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
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
        if (state is SignUpImageLoadingState) {
          EasyLoading.show(
            status: 'Processing images...',
            maskType: EasyLoadingMaskType.black,
          );
        } else {
          // Dismiss EasyLoading when not loading
          EasyLoading.dismiss();
        }
        if (state is SignUpImageErrorState) {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage),
              backgroundColor: AppColors.appRedColor,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      },
      builder: (context, state) {
        final images = (state is SignUpFormState) ? state.multipleImages : [];
        final imageCount = images.length;
        final hasImages = imageCount > 0;
        final canAddMore = imageCount < 4;

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,
            bottom: 16,
          ),
          decoration: BoxDecoration(
            color: AppColors.signUpContainerColor,
            borderRadius: BorderRadius.circular(16),

            // Add border if validation error
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with count
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Upload Cafe/Eatery Photos',
                    style: Theme.of(context).textTheme.labelMedium!.copyWith(
                      fontSize: 16,
                      color: AppColors.primary,
                    ),
                  ),
                  // if (hasImages)
                    // Container(
                    //   padding: const EdgeInsets.symmetric(
                    //     horizontal: 8,
                    //     vertical: 4,
                    //   ),
                    //   decoration: BoxDecoration(
                    //     color:
                    //         canAddMore
                    //             ? AppColors.primary.withOpacity(0.1)
                    //             : AppColors.appRedColor.withOpacity(0.1),
                    //     borderRadius: BorderRadius.circular(12),
                    //   ),
                    //   child: Text(
                    //     '$imageCount/4',
                    //     style: TextStyle(
                    //       color:
                    //           canAddMore
                    //               ? AppColors.primary
                    //               : AppColors.appRedColor,
                    //       fontWeight: FontWeight.bold,
                    //       fontSize: 12.sp,
                    //     ),
                    //   ),
                    // ),
                ],
              ),
              const Gap(15),

              // Image Grid
              if (hasImages)
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1,
                  ),
                  itemCount: imageCount,
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
                        // Remove button
                        Positioned(
                          top: 4,
                          right: 4,
                          child: GestureDetector(
                            onTap: () {
                              context.read<SignUpBloc>().add(
                                RemoveMultipleImageEvent(index),
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.7),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Icon(
                                Icons.close,
                                color: AppColors.primaryWhiteColor,
                                size: 18,
                              ),
                            ),
                          ),
                        ),

                        // Image number badge
                      ],
                    );
                  },
                ),

              if (hasImages) const Gap(15),

              // Upload from Gallery button (disabled if limit reached)
              Opacity(
                opacity: canAddMore ? 1.0 : 0.5,
                child: InkWell(
                  onTap:
                      canAddMore
                          ? () {
                            context.read<SignUpBloc>().add(
                              PickMultipleImagesFromGalleryEvent(),
                            );
                          }
                          : null,
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
                            color: canAddMore ? AppColors.primary : Colors.grey,
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
                                canAddMore
                                    ? 'Upload from Gallery'
                                    : 'Maximum limit reached',
                                style: Theme.of(
                                  context,
                                ).textTheme.bodyMedium!.copyWith(
                                  color:
                                      canAddMore
                                          ? AppColors.primary
                                          : Colors.grey,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              Text(
                                canAddMore
                                    ? 'Supported formats JPEG and PNG\n[size 5MB]'
                                    : 'You have uploaded 4/4 images',
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
              ),
              const Gap(10),
              Align(
                alignment: Alignment.center,
                child: Text(
                  'Or',
                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                    color: AppColors.textPrimaryGrey,
                  ),
                ),
              ),
              const Gap(10),

              // Take Picture button (disabled if limit reached)
              Opacity(
                opacity: canAddMore ? 1.0 : 0.5,
                child: InkWell(
                  onTap:
                      canAddMore
                          ? () {
                            context.read<SignUpBloc>().add(
                              TakeMultiplePicturesEvent(),
                            );
                          }
                          : null,
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
                          color: canAddMore ? AppColors.primary : Colors.grey,
                        ),
                        const Gap(10),
                        Text(
                          canAddMore ? 'Take Picture' : 'Limit Reached',
                          style: Theme.of(
                            context,
                          ).textTheme.bodyMedium!.copyWith(
                            color: canAddMore ? AppColors.primary : Colors.grey,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Clear All button (only show if images exist)
              // if (hasImages) ...[
              //   const Gap(10),
              //   Center(
              //     child: TextButton.icon(
              //       onPressed: () {
              //         context.read<SignUpBloc>().add(
              //           ClearAllImagesEvent(),
              //         );
              //       },
              //       icon: const Icon(
              //         Icons.delete_outline,
              //         color: Colors.red,
              //       ),
              //       label: Text(
              //         "Clear All ($imageCount)",
              //         style: TextStyle(
              //           color: Colors.red,
              //           fontSize: 14.sp,
              //           fontWeight: FontWeight.w600,
              //         ),
              //       ),
              //     ),
              //   ),
              // ],

              // Validation error message
              if (widget.showValidationErrors &&
                  state is SignUpFormState &&
                  (state.multipleImages == null ||
                      state.multipleImages!.isEmpty)) ...[
                const Gap(10),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.appRedColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.appRedColor, width: 1),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.error_outline,
                        color: AppColors.appRedColor,
                        size: 20,
                      ),
                      const Gap(8),
                      Expanded(
                        child: Text(
                          'Please upload at least one image to continue.',
                          style: TextStyle(
                            color: AppColors.appRedColor,
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
