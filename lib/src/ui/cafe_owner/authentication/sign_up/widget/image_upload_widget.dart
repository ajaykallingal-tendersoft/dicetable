import 'dart:io';

import 'package:dicetable/src/constants/app_colors.dart';
import 'package:dicetable/src/ui/cafe_owner/authentication/sign_up/bloc/sign_up/sign_up_bloc.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';

class ImageUploadWidget extends StatefulWidget {
  const ImageUploadWidget({super.key});

  @override
  State<ImageUploadWidget> createState() => _ImageUploadWidgetState();
}

class _ImageUploadWidgetState extends State<ImageUploadWidget> {
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
          final image = (state is SignUpFormState) ? state.image : null;

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
                  'Upload Cafe/Eatery Photos',
                  style: Theme.of(context).textTheme.labelMedium!.copyWith(
                    fontSize: 16,
                    color: AppColors.primary,
                  ),
                ),
                const Gap(15),

                if (image != null) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        height: 54.18,
                        width: 54.18,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: Image.file(File(image.path), fit: BoxFit.cover),
                      ),
                      IconButton(
                        onPressed: () {
                          context.read<SignUpBloc>().add(ClearImageEvent());
                        },
                        icon: Icon(Icons.close, size: 15, color: AppColors.textPrimaryGrey),
                      ),
                    ],
                  ),
                ] else ...[
                  InkWell(
                    onTap: () {
                      context.read<SignUpBloc>().add(PickImageFromGalleryEvent());
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
                            child: SvgPicture.asset('assets/svg/upload-photo.svg'),
                          ),
                          const Gap(10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Upload from Gallery',
                                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                Text(
                                  'Supported formats JPEG and PNG (Size 5MB)',
                                  style: Theme.of(context).textTheme.bodySmall!.copyWith(
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
                      style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                        color: AppColors.textPrimaryGrey,
                      ),
                    ),
                  ),
                  const Gap(10),
                  InkWell(
                    onTap: () {
                      context.read<SignUpBloc>().add(CaptureImageWithCameraEvent());
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
                          SvgPicture.asset('assets/svg/take-pic.svg', color: AppColors.primary),
                          const Gap(10),
                          Text(
                            'Take Picture',
                            style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ]
              ],
            ),
          );
        }
    );
  }
}
