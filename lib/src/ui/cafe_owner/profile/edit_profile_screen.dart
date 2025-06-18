import 'dart:convert';
import 'dart:io';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:dicetable/src/common/custom_text_field.dart';
import 'package:dicetable/src/common/elevated_button_widget.dart';
import 'package:dicetable/src/constants/app_colors.dart';
import 'package:dicetable/src/model/cafe_owner/profile/profile_update_request.dart';
import 'package:dicetable/src/ui/cafe_owner/profile/bloc/profile_bloc.dart';
import 'package:dicetable/src/ui/cafe_owner/profile/widget/profile_opening_hour_widget.dart';
import 'package:dicetable/src/ui/cafe_owner/profile/widget/profile_venue_type_checkbox.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:permission_handler/permission_handler.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key, required this.profileState});

  final ProfileState? profileState;

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController _venueNameController;
  late TextEditingController _venueDescriptionController;
  late TextEditingController _emailController;

  // late TextEditingController _passwordController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;
  late TextEditingController _cityController;
  late TextEditingController _postalCodeController;
  late TextEditingController _countryController;
  late TextEditingController _regionController;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    context.read<ProfileBloc>().add(GetProfileEditViewEvent());
  }

  void _initializeControllers() {
    final profileState = widget.profileState;
    _venueNameController = TextEditingController(
      text: profileState?.venueName ?? '',
    );
    _venueDescriptionController = TextEditingController(
      text: profileState?.venueDescription ?? '',
    );
    _emailController = TextEditingController(text: profileState?.email ?? '');
    // _passwordController =
    //     TextEditingController(text: profileState?.password ?? '');
    _phoneController = TextEditingController(text: profileState?.phone ?? '');
    _addressController = TextEditingController(
      text: profileState?.address ?? '',
    );
    _cityController = TextEditingController(text: profileState?.city ?? '');
    _postalCodeController = TextEditingController(
      text: profileState?.postalCode ?? '',
    );
  }

  @override
  void dispose() {
    _venueNameController.dispose();
    _venueDescriptionController.dispose();
    _emailController.dispose();
    // _passwordController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _postalCodeController.dispose();
    super.dispose();
  }

  void _showPermissionDialog(bool isPermanentlyDenied, String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(
            'Permission Required',
            style: Theme.of(context).textTheme.bodyLarge!.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
              fontSize: 16.sp,
            ),
          ),
          content: Text(
            message,
            style: Theme.of(context).textTheme.bodySmall!.copyWith(
              color: AppColors.textPrimaryGrey,
              fontWeight: FontWeight.w500,
              fontSize: 15.sp,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
              child: Text(
                'Cancel',
                style: Theme.of(context).textTheme.bodySmall!.copyWith(
                  color: AppColors.shadowColor,
                  fontWeight: FontWeight.w500,
                  fontSize: 14.sp,
                ),
              ),
            ),
            if (isPermanentlyDenied)
              ElevatedButton(
                onPressed: () async {
                  Navigator.of(dialogContext).pop();
                  await openAppSettings();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  'Open Settings',
                  style: Theme.of(context).textTheme.bodySmall!.copyWith(
                    color: AppColors.primaryWhiteColor,

                    fontWeight: FontWeight.w500,
                    fontSize: 14.sp,
                  ),
                ),
              )
            else
              ElevatedButton(
                onPressed: () {
                  Navigator.of(dialogContext).pop();
                  context.read<ProfileBloc>().add(PickImageFromGalleryEvent());
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  'Try again',
                  style: Theme.of(context).textTheme.bodySmall!.copyWith(
                    color: AppColors.primaryWhiteColor,
                    fontWeight: FontWeight.w500,
                    fontSize: 14.sp,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  Future<bool> _onWillPop() async {
    context.read<ProfileBloc>().add(GetProfileViewEvent());
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProfileBloc, ProfileState>(
      listener: (context, state) async {
        if (state is ProfileEditViewLoading) {
          await EasyLoading.show();
        } else if (state is ProfileUpdateLoading) {
          await EasyLoading.show();
        } else {
          await EasyLoading.dismiss();
          if (state is ProfileUpdateSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Profile updated successfully'),
                backgroundColor: AppColors.appGreenColor,
              ),
            );
          } else if (state is ProfileUpdateError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage),
                backgroundColor: AppColors.appRedColor,
              ),
            );
          } else if (state is ProfileEditViewLoaded) {
            _cityController.text =
                state.profileEditViewResponse.data?.city ?? '';
          } else if (state is ProfileImagePermissionDeniedState) {
            _showPermissionDialog(
              state.isPermanentlyDenied,
              state.errorMessage.toString(),
            );
          } else if (state is ProfileImageErrorState) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage!),
                backgroundColor: AppColors.appRedColor,
              ),
            );
          }
        }
      },
      builder: (context, state) {
        return WillPopScope(
          onWillPop: _onWillPop,
          child: Scaffold(
            backgroundColor: Colors.transparent,
            body: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primary,
                    AppColors.primary,
                    AppColors.primary,
                    AppColors.tertiary,
                  ],
                  stops: [0.0, 0.1, 0.75, 1.0],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: SafeArea(
                child:
                    state is ProfileEditViewLoading
                        ? const Center(
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                              AppColors.primaryWhiteColor,
                            ),
                          ),
                        )
                        : state is ProfileEditViewError
                        ? Center(child: Text(state.errorMessage))
                        : CustomScrollView(
                          slivers: [
                            _buildSliverAppBar(),
                            _buildSectionHeader(context),
                            SliverToBoxAdapter(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16.0,
                                ),
                                child: Column(
                                  children: [
                                    CustomTextField(
                                      controller: _venueNameController,
                                      hintText: 'Venue Name',
                                      textFieldAnnotationText: 'Venue Name',
                                      onChanged: (value) {
                                        context.read<ProfileBloc>().add(
                                          UpdateTextField(
                                            (state) => state.copyWith(
                                              venueName: value,
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                    CustomTextField(
                                      height: 112,
                                      hintText: 'Your Venue description here',
                                      maxLines: 5,
                                      controller: _venueDescriptionController,
                                      textFieldAnnotationText:
                                          'Your Venue description here',
                                      onChanged: (value) {
                                        context.read<ProfileBloc>().add(
                                          UpdateTextField(
                                            (state) => state.copyWith(
                                              venueDescription: value,
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                    CustomTextField(
                                      controller: _emailController,
                                      hintText: 'Email',
                                      textFieldAnnotationText: 'Email',
                                      onChanged: (value) {
                                        context.read<ProfileBloc>().add(
                                          UpdateTextField(
                                            (state) =>
                                                state.copyWith(email: value),
                                          ),
                                        );
                                      },
                                    ),
                                    // CustomTextField(
                                    //   controller: _passwordController,
                                    //   hintText: 'Password',
                                    //   textFieldAnnotationText: 'Password',
                                    //   isPassword: true,
                                    //   onChanged: (value) {
                                    //     context.read<ProfileBloc>().add(
                                    //       UpdateTextField(
                                    //             (state) =>
                                    //             state.copyWith(password: value),
                                    //       ),
                                    //     );
                                    //   },
                                    // ),
                                    CustomTextField(
                                      controller: _phoneController,
                                      hintText: 'Phone',
                                      textFieldAnnotationText: 'Phone',
                                      onChanged: (value) {
                                        context.read<ProfileBloc>().add(
                                          UpdateTextField(
                                            (state) =>
                                                state.copyWith(phone: value),
                                          ),
                                        );
                                      },
                                    ),
                                    CustomTextField(
                                      controller: _addressController,
                                      hintText: 'Street Address',
                                      textFieldAnnotationText: 'Street Address',
                                      onChanged: (value) {
                                        context.read<ProfileBloc>().add(
                                          UpdateTextField(
                                            (state) =>
                                                state.copyWith(address: value),
                                          ),
                                        );
                                      },
                                    ),

                                    CustomTextField(
                                      controller: _postalCodeController,
                                      hintText: 'Postal Code',
                                      textFieldAnnotationText: 'Postal Code',
                                      onChanged: (value) {
                                        context.read<ProfileBloc>().add(
                                          UpdateTextField(
                                            (state) => state.copyWith(
                                              postalCode: value,
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                    Gap(10.h),
                                    ProfileVenueTypeCheckboxes(),
                                    Gap(17.h),
                                    Container(
                                      padding: const EdgeInsets.all(15),
                                      decoration: BoxDecoration(
                                        color: AppColors.signUpContainerColor,
                                        borderRadius: BorderRadius.circular(15),
                                        boxShadow: [
                                          BoxShadow(
                                            color: AppColors.shadowColor,
                                            blurRadius: 4,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.only(
                                              left: 5.0,
                                            ),
                                            child: Text(
                                              'Opening Hours',
                                              style: Theme.of(
                                                context,
                                              ).textTheme.labelMedium?.copyWith(
                                                fontSize: 14,
                                                color: AppColors.primary,
                                              ),
                                            ),
                                          ),
                                          Gap(10.h),
                                          BlocBuilder<
                                            ProfileBloc,
                                            ProfileState
                                          >(
                                            buildWhen: (previous, current) {
                                              return previous.openingHours !=
                                                  current.openingHours;
                                            },
                                            builder: (context, currentState) {
                                              return Column(
                                                children: [
                                                  for (final day in [
                                                    'mon',
                                                    'tue',
                                                    'wed',
                                                    'thu',
                                                    'fri',
                                                    'sat',
                                                    'sun',
                                                  ])
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                            bottom: 8.0,
                                                          ),
                                                      child: Builder(
                                                        builder: (
                                                          innerContext,
                                                        ) {
                                                          final openingHourData =
                                                              currentState
                                                                  .openingHours[day] ??
                                                              ProfileOpeningHour(
                                                                isEnabled:
                                                                    false,
                                                                from: TimeOfDay(
                                                                  hour: 10,
                                                                  minute: 0,
                                                                ),
                                                                to: TimeOfDay(
                                                                  hour: 22,
                                                                  minute: 0,
                                                                ),
                                                                id: null,
                                                              );
                                                          debugPrint(
                                                            'Passing to ProfileOpeningHoursWidget for $day: $openingHourData',
                                                          );
                                                          return ProfileOpeningHoursWidget(
                                                            key: ValueKey(
                                                              '${day}_${openingHourData.isEnabled}_${openingHourData.from}_${openingHourData.to}_${openingHourData.id}',
                                                            ),
                                                            day: day,
                                                            data:
                                                                openingHourData,
                                                            onChanged: (
                                                              updatedHour,
                                                            ) {
                                                              innerContext
                                                                  .read<
                                                                    ProfileBloc
                                                                  >()
                                                                  .add(
                                                                    UpdateOpeningHour(
                                                                      day,
                                                                      updatedHour,
                                                                    ),
                                                                  );
                                                            },
                                                          );
                                                        },
                                                      ),
                                                    ),
                                                ],
                                              );
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                    Gap(30.h),
                                    InkWell(
                                      onTap: () {
                                        _submitProfile(context, state);
                                      },
                                      child: ElevatedButtonWidget(
                                        height: 70.h,
                                        width: double.infinity,
                                        iconEnabled: false,
                                        iconLabel: 'SAVE CHANGES',
                                        color: AppColors.primary,
                                        textColor: AppColors.primaryWhiteColor,
                                      ),
                                    ),
                                    Gap(20.h),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _submitProfile(BuildContext context, ProfileState state) {
    final profileUpdateRequest = ProfileUpdateRequest(
      name: state.venueName.isNotEmpty ? state.venueName : '',
      venueDescription:
          state.venueDescription.isNotEmpty ? state.venueDescription : '',
      email: state.email.isNotEmpty ? state.email : '',
      phone: state.phone.isNotEmpty ? state.phone : '',
      address: state.address.isNotEmpty ? state.address : '',
      // city: state.city.isNotEmpty ? state.city : '',
      postcode: state.postalCode.isNotEmpty ? state.postalCode : '',
      accommodations:
          state.selectedVenueTypeIds.map((id) => id.toString()).toList(),
      workingDays:
          state.openingHours.entries.map((entry) {
            final day = entry.key;
            final hour = entry.value;
            return WorkingDay(
              id: hour.id,
              day: day,
              isOpen: hour.isEnabled,
              open: _formatTimeOfDay(hour.from),
              close: _formatTimeOfDay(hour.to),
            );
          }).toList(),
      blob: state.blob ?? state.profileEditViewResponse?.data?.photo,
      originalName: state.image != null ? state.originalName : null,
    );

    context.read<ProfileBloc>().add(
      SubmitProfile(profileUpdateRequest: profileUpdateRequest),
    );
    context.read<ProfileBloc>().add(GetProfileViewEvent());
    context.pop();
  }

  String _formatTimeOfDay(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute:00';
  }

  Widget _buildBase64Image(String? base64Image) {
    if (base64Image != null && base64Image.isNotEmpty) {
      try {
        final cleanBase64 =
            base64Image.startsWith('data:image')
                ? base64Image.split(',').last
                : base64Image;
        final decodedBytes = base64Decode(cleanBase64);
        return Image.memory(
          decodedBytes,
          fit: BoxFit.cover,
          width: 170.r,
          height: 170.r,
          errorBuilder:
              (context, error, stackTrace) => Image.asset(
                'assets/png/profile-img.png',
                fit: BoxFit.cover,
                width: 170.r,
                height: 170.r,
              ),
        );
      } catch (e) {
        debugPrint('Invalid base64 image: $e');
        return Image.asset(
          'assets/png/profile-img.png',
          fit: BoxFit.cover,
          width: 170.r,
          height: 170.r,
        );
      }
    }
    return Image.asset(
      'assets/png/profile-img.png',
      fit: BoxFit.cover,
      width: 170.r,
      height: 170.r,
    );
  }

  Widget _buildSliverAppBar() {
    final state = context.read<ProfileBloc>().state;
    return SliverAppBar(
      expandedHeight: 380.h,
      pinned: true,
      floating: false,
      backgroundColor: AppColors.primary,
      automaticallyImplyLeading: false,
      flexibleSpace: FlexibleSpaceBar(
        stretchModes: [StretchMode.zoomBackground],
        background: Stack(
          children: [
            Container(color: AppColors.primary),
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: 380.h / 1.8.h,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(30.r),
                    bottomRight: Radius.circular(30.r),
                  ),
                  image: DecorationImage(
                    image: const AssetImage('assets/png/p-bg.png'),
                    fit: BoxFit.cover,
                    colorFilter: ColorFilter.mode(
                      AppColors.secondary.withOpacity(0.1),
                      BlendMode.overlay,
                    ),
                  ),
                  gradient: const LinearGradient(
                    colors: [
                      AppColors.primary,
                      AppColors.primary,
                      AppColors.secondary,
                      AppColors.tertiary,
                    ],
                    stops: [0.0, 0.5, 0.75, 1.0],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: Column(
                  children: [
                    Gap(70.h),
                    Text(
                      state.venueName,
                      style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                        color: AppColors.primaryWhiteColor,
                        fontSize: 22.sp,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      state.venueDescription,
                      style: Theme.of(context).textTheme.bodySmall!.copyWith(
                        color: AppColors.primaryWhiteColor,
                        fontSize: 12.sp,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            BlocBuilder<ProfileBloc, ProfileState>(
              builder: (context, state) {
                final image = state.image;
                return Positioned(
                  top: (350.h / 1.9.h) - 60.h,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Stack(
                      children: [
                        CircleAvatar(
                          radius: 95.r,
                          backgroundColor: AppColors.primary,
                          child: CircleAvatar(
                            backgroundColor: Colors.transparent,
                            radius: 85.r,
                            child: ClipOval(
                              child:
                                  image != null
                                      ? Image.file(
                                        File(image.path),
                                        fit: BoxFit.cover,
                                        width: 170.r,
                                        height: 170.r,
                                        errorBuilder:
                                            (context, error, stackTrace) =>
                                                Image.asset(
                                                  'assets/png/profile-img.png',
                                                  fit: BoxFit.cover,
                                                  width: 170.r,
                                                  height: 170.r,
                                                ),
                                      )
                                      : _buildBase64Image(
                                        state
                                            .profileEditViewResponse
                                            ?.data
                                            ?.photo,
                                      ),
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 30.h,
                          right: 0,
                          child: Container(
                            height: 44.h,
                            width: 44.w,
                            padding: const EdgeInsets.all(10),
                            decoration: const BoxDecoration(
                              color: AppColors.primaryWhiteColor,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black26,
                                  blurRadius: 2,
                                  spreadRadius: 1,
                                ),
                              ],
                            ),
                            child: InkWell(
                              onTap: () {
                                context.read<ProfileBloc>().add(
                                  PickImageFromGalleryEvent(),
                                );
                              },
                              child: SvgPicture.asset(
                                'assets/svg/camera-icon.svg',
                                fit: BoxFit.scaleDown,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
      actionsPadding: EdgeInsets.only(right: 15.w),
      title: Text(
        'Edit Profile',
        style: Theme.of(context).textTheme.labelLarge!.copyWith(
          color: AppColors.primaryWhiteColor,
          fontWeight: FontWeight.w600,
        ),
      ),
      leading: InkWell(
        onTap: () {
          context.read<ProfileBloc>().add(GetProfileViewEvent());
          context.pop();
        },
        child: SvgPicture.asset('assets/svg/back.svg', fit: BoxFit.scaleDown),
      ),
      actions: [
        InkWell(
          onTap: () {
            context.push('/notification');
          },
          child: SvgPicture.asset('assets/svg/notify.svg'),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Venue Information",
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontSize: 14,
                color: AppColors.primaryWhiteColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            ElevatedButton.icon(
              onPressed: () {
                _submitProfile(context, context.read<ProfileBloc>().state);
              },
              icon: SvgPicture.asset('assets/svg/save-form.svg'),
              label: Text(
                "SAVE",
                style: GoogleFonts.roboto(
                  color: AppColors.primary,
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 10.h, vertical: 2.h),
                foregroundColor: AppColors.primaryWhiteColor,
                side: const BorderSide(color: AppColors.primaryWhiteColor),
                fixedSize: Size(75.w, 26.h),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
