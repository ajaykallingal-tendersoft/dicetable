import 'dart:io';

import 'package:dicetable/src/common/custom_text_field.dart';
import 'package:dicetable/src/common/elevated_button_widget.dart';
import 'package:dicetable/src/constants/app_colors.dart';
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

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key, required this.profileState});

  final ProfileState? profileState;

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController _venueNameController = TextEditingController();
  late TextEditingController _venueDescriptionController =
      TextEditingController();
  late TextEditingController _emailController = TextEditingController();
  late TextEditingController _passwordController = TextEditingController();
  late TextEditingController _phoneController = TextEditingController();
  late TextEditingController _addressController = TextEditingController();
  late TextEditingController _postalCodeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initializeControllers();
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
    _passwordController = TextEditingController(
      text: profileState?.password ?? '',
    );
    _phoneController = TextEditingController(text: profileState?.phone ?? '');
    _addressController = TextEditingController(
      text: profileState?.address ?? '',
    );
    _postalCodeController = TextEditingController(
      text: profileState?.postalCode ?? '',
    );
  }

  @override
  void dispose() {
    _venueNameController.dispose();
    _venueDescriptionController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _postalCodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileBloc, ProfileState>(
      builder: (context, state) {
        final image = state.image;
        return Builder(
          builder: (context) {
            return Scaffold(
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
                  child: CustomScrollView(
                    slivers: [
                      _buildSliverAppBar(),
                      _buildSectionHeader(context),
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Column(
                            children: [
                              CustomTextField(
                                controller: _venueNameController,
                                hintText: 'Venue Name',
                                // initialValue: state.venueName,
                                onChanged: (value) {
                                  context.read<ProfileBloc>().add(
                                    UpdateTextField(
                                      (state) =>
                                          state.copyWith(venueName: value),
                                    ),
                                  );
                                },
                                textFieldAnnotationText: 'Venue Name',
                              ),
                              CustomTextField(
                                height: 112,
                                hintText: 'Your Venue description here',
                                maxLines: 5,
                                controller: _venueDescriptionController,
                                // initialValue: state.venueDescription,
                                onChanged: (value) {
                                  context.read<ProfileBloc>().add(
                                    UpdateTextField(
                                      (state) => state.copyWith(
                                        venueDescription: value,
                                      ),
                                    ),
                                  );
                                },
                                textFieldAnnotationText:
                                    'Your Venue description here',
                              ),
                              CustomTextField(
                                controller: _emailController,
                                hintText: 'Email',
                                textFieldAnnotationText: 'Email',
                                // initialValue: state.email,
                                onChanged: (value) {
                                  context.read<ProfileBloc>().add(
                                    UpdateTextField(
                                      (state) => state.copyWith(email: value),
                                    ),
                                  );
                                },
                              ),
                              CustomTextField(
                                controller: _passwordController,
                                hintText: 'Password',
                                textFieldAnnotationText: 'Password',
                                isPassword: true,
                                // initialValue: state.password,
                                onChanged: (value) {
                                  context.read<ProfileBloc>().add(
                                    UpdateTextField(
                                      (state) =>
                                          state.copyWith(password: value),
                                    ),
                                  );
                                },
                              ),

                              CustomTextField(
                                controller: _phoneController,
                                hintText: 'Phone',
                                textFieldAnnotationText: 'Phone',
                                // initialValue: state.phone,
                                onChanged: (value) {
                                  context.read<ProfileBloc>().add(
                                    UpdateTextField(
                                      (state) => state.copyWith(phone: value),
                                    ),
                                  );
                                },
                              ),
                              CustomTextField(
                                controller: _addressController,
                                hintText: 'Street Address And City',
                                textFieldAnnotationText:
                                    'Street Address And City',
                                // initialValue: state.address,
                                onChanged: (value) {
                                  context.read<ProfileBloc>().add(
                                    UpdateTextField(
                                      (state) => state.copyWith(address: value),
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
                                      (state) =>
                                          state.copyWith(postalCode: value),
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
                                child: BlocBuilder<ProfileBloc, ProfileState>(
                                  builder: (context, state) {
                                    return Column(
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
                                        for (final day in [
                                          'Monday',
                                          'Tuesday',
                                          'Wednesday',
                                          'Thursday',
                                          'Friday',
                                          'Saturday',
                                          'Sunday',
                                        ])
                                          ProfileOpeningHoursWidget(
                                            day: day,
                                            data:
                                                state.openingHours[day] ??
                                                ProfileOpeningHour(
                                                  isEnabled: false,
                                                  from: TimeOfDay(
                                                    hour: 10,
                                                    minute: 0,
                                                  ),
                                                  to: TimeOfDay(
                                                    hour: 12,
                                                    minute: 0,
                                                  ),
                                                ),
                                            onChanged: (updatedHour) {
                                              context.read<ProfileBloc>().add(
                                                UpdateOpeningHour(
                                                  day,
                                                  updatedHour,
                                                ),
                                              );
                                            },
                                          ),
                                      ],
                                    );
                                  },
                                ),
                              ),

                               Gap(30.h),
                              InkWell(
                                onTap: () {
                                  context.pop(image?.path);
                                  context.read<ProfileBloc>().add(
                                    SubmitProfile(),
                                  );
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
            );
          },
        );
      },
    );
  }

  Widget _buildSliverAppBar() {
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
                  borderRadius:  BorderRadius.only(
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
                      "Sun Cafe",
                      style: TextTheme.of(context).bodyLarge!.copyWith(
                        color: AppColors.primaryWhiteColor,
                        fontSize: 22.sp,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      "Member Since June, 2024",
                      style: TextTheme.of(context).bodySmall!.copyWith(
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
                            radius: 85.r,
                            backgroundImage:
                                image != null
                                    ? FileImage(File(image.path))
                                    : AssetImage('assets/png/profile-img.png'),
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
        style: TextTheme.of(context).labelLarge!.copyWith(
          color: AppColors.primaryWhiteColor,
          fontWeight: FontWeight.w600,
        ),
      ),
      leading: InkWell(
        onTap: () {
          context.pop();
        },
        child: SvgPicture.asset('assets/svg/back.svg', fit: BoxFit.scaleDown),
      ),
      actions: [SvgPicture.asset('assets/svg/notify.svg')],
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
              onPressed: () {},
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
                padding:  EdgeInsets.symmetric(
                  horizontal: 10.h,
                  vertical: 2.h,
                ),
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
