import 'dart:io';
import 'package:dicetable/src/common/custom_text_field.dart';
import 'package:dicetable/src/common/elevated_button_widget.dart';
import 'package:dicetable/src/constants/app_colors.dart';
import 'package:dicetable/src/utils/data/object_factory.dart';
import 'package:dicetable/src/ui/cafe_owner/authentication/login/cubit/google_sign_in_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'bloc/profile_bloc.dart';

class ManageProfileScreen extends StatefulWidget {
  const ManageProfileScreen({super.key});

  @override
  State<ManageProfileScreen> createState() => _ManageProfileScreenState();
}

class _ManageProfileScreenState extends State<ManageProfileScreen> {
  late TextEditingController _venueNameController = TextEditingController();
  late TextEditingController _venueDescriptionController =
  TextEditingController();
  late TextEditingController _emailController = TextEditingController();
  late TextEditingController _passwordController = TextEditingController();
  late TextEditingController _phoneController = TextEditingController();
  late TextEditingController _addressController = TextEditingController();
  late TextEditingController _postalCodeController = TextEditingController();
  File? _imageFile;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    final state = context
        .read<ProfileBloc>()
        .state;
    _venueNameController = TextEditingController(text: state.venueName);
    _venueDescriptionController = TextEditingController(
      text: state.venueDescription,
    );
    _emailController = TextEditingController(text: state.email);
    _passwordController = TextEditingController(text: state.password);
    _phoneController = TextEditingController(text: state.phone);
    _addressController = TextEditingController(text: state.address);
    _postalCodeController = TextEditingController(text: state.postalCode);
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
    return BlocConsumer<ProfileBloc, ProfileState>(
      listener: (context, state) {
        // Update controllers when state changes
        _venueNameController.text = state.venueName ?? '';
        _venueDescriptionController.text = state.venueDescription ?? '';
        _emailController.text = state.email ?? '';
        _passwordController.text = state.password ?? '';
        _phoneController.text = state.phone ?? '';
        _addressController.text = state.address ?? '';
        _postalCodeController.text = state.postalCode ?? '';
      },
      builder: (context, state) {
        return Container(
          decoration: const BoxDecoration(color: AppColors.primary),
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
                          isProfile: true,
                          readOnly: true,
                          controller: _venueNameController,
                          hintText: 'Venue Name',
                          textFieldAnnotationText: 'Venue Name',
                          // initialValue: state.venueName,
                          onChanged: (value) {
                            context.read<ProfileBloc>().add(
                              UpdateTextField(
                                    (state) => state.copyWith(venueName: value),
                              ),
                            );
                          },
                        ),
                        CustomTextField(
                          height: 112,
                          isProfile: true,
                          readOnly: true,
                          hintText: 'Your Venue description here',
                          textFieldAnnotationText:
                          'Your Venue description here',
                          maxLines: 5,
                          controller: _venueDescriptionController,
                          // initialValue: state.venueDescription,
                          onChanged: (value) {
                            context.read<ProfileBloc>().add(
                              UpdateTextField(
                                    (state) =>
                                    state.copyWith(venueDescription: value),
                              ),
                            );
                          },
                        ),
                        CustomTextField(
                          isProfile: true,
                          readOnly: true,
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
                          isProfile: true,
                          readOnly: true,
                          controller: _passwordController,
                          hintText: 'Password',
                          textFieldAnnotationText: 'Password',
                          isPassword: true,
                          // initialValue: state.password,
                          onChanged: (value) {
                            context.read<ProfileBloc>().add(
                              UpdateTextField(
                                    (state) => state.copyWith(password: value),
                              ),
                            );
                          },
                        ),

                        CustomTextField(
                          isProfile: true,
                          readOnly: true,
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
                          isProfile: true,
                          readOnly: true,
                          controller: _addressController,
                          hintText: 'Street Address And City',
                          textFieldAnnotationText: 'Street Address And City',
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
                          isProfile: true,
                          readOnly: true,
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

                        const Gap(10),
                        CustomTextField(
                          isProfile: true,
                          readOnly: true,
                          controller: TextEditingController(
                            text: _formatVenueTypes(state.venueTypes),
                          ),
                          hintText: 'Venue Type',
                          textFieldAnnotationText: 'Venue Type',
                          onChanged: (value) {},
                        ),
                        const Gap(17),
                        CustomTextField(
                          height: 213,
                          isProfile: true,
                          readOnly: true,
                          maxLines: 10,
                          controller: TextEditingController(
                            text: _formatOpeningHours(state.openingHours),
                          ),
                          hintText: 'Opening Hours',
                          textFieldAnnotationText: 'Opening Hours',
                          onChanged: (value) {},
                        ),

                        const Gap(30),
                        InkWell(
                          onTap: () {
                            context.read<GoogleSignInCubit>().signOut();
                            ObjectFactory().prefs.setIsLoggedIn(false);
                            ObjectFactory().prefs.setAuthToken(token: "");
                            ObjectFactory().prefs.setCafeUserName(
                                cafeUserName: "");
                            context.go('/category');
                          },
                          child: ElevatedButtonWidget(
                            height: 70.h,
                            width: double.infinity,
                            iconEnabled: false,
                            iconLabel: 'LOG OUT',
                            color: AppColors.primaryWhiteColor,
                            textColor: AppColors.primary,
                          ),
                        ),
                        const Gap(30),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // For venue types, convert selected types to a readable string
  String _formatVenueTypes(Map<String, bool> venueTypes) {
    final selectedTypes =
    venueTypes.entries
        .where((entry) => entry.value) // Only get true values
        .map((entry) => entry.key) // Get the venue type name
        .toList();

    if (selectedTypes.isEmpty) {
      return 'No venue types selected';
    }

    return selectedTypes.join(', ');
  }

  // For opening hours, create a formatted string with each day and its hours
  String _formatOpeningHours(Map<String, ProfileOpeningHour> openingHours) {
    if (openingHours.isEmpty) {
      return 'No opening hours set';
    }

    final buffer = StringBuffer();
    openingHours.forEach((day, hours) {
      if (hours.isEnabled) {
        // Format time in 12-hour format
        final fromTime = _formatTimeOfDay(hours.from);
        final toTime = _formatTimeOfDay(hours.to);
        buffer.writeln('$day: $fromTime - $toTime');
      } else {
        buffer.writeln('$day: Closed');
      }
    });

    return buffer.toString();
  }

  // Helper method to format TimeOfDay nicely
  String _formatTimeOfDay(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 380.h,
      pinned: false,
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
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
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
                    Gap(60),
                    Text(
                      "Sun Cafe",
                      style: TextTheme
                          .of(context)
                          .bodyLarge!
                          .copyWith(
                        color: AppColors.primaryWhiteColor,
                        fontSize: 22,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      "Member Since June, 2024",
                      style: TextTheme
                          .of(context)
                          .bodySmall!
                          .copyWith(
                        color: AppColors.primaryWhiteColor,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
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
                        _imageFile != null
                            ? FileImage(_imageFile!)
                            : const AssetImage(
                          'assets/png/profile-img.png',
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 30.h,
                      right: 0.w,
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
                        child: SvgPicture.asset(
                          'assets/svg/camera-icon.svg',
                          fit: BoxFit.scaleDown,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [SvgPicture.asset('assets/svg/notify.svg')],
      actionsPadding: EdgeInsets.only(right: 15),
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
              style: Theme
                  .of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(
                fontSize: 14,
                color: AppColors.primaryWhiteColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            ElevatedButton.icon(
              onPressed: () async {
                final profileState = context
                    .read<ProfileBloc>()
                    .state;
                final dynamic result = await context.push(
                  // Capture the result
                  '/edit_profile',
                  extra: profileState,
                );
                setState(() {
                  if (result is String) {
                    _imageFile = File(result);
                  }
                });
                _initializeControllers();
              },
              icon: SvgPicture.asset('assets/svg/edit-btn.svg'),
              label: Text(
                "EDIT",
                style: GoogleFonts.roboto(
                  color: AppColors.primary,
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
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
