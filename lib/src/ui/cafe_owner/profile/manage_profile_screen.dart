import 'dart:io';
import 'dart:convert';
import 'package:dicetable/src/common/custom_text_field.dart';
import 'package:dicetable/src/common/elevated_button_widget.dart';
import 'package:dicetable/src/constants/app_colors.dart';
import 'package:dicetable/src/utils/data/object_factory.dart';
import 'package:dicetable/src/ui/cafe_owner/authentication/login/cubit/google_sign_in_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'bloc/profile_bloc.dart';
import 'package:responsive_framework/responsive_framework.dart';

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

  // late TextEditingController _passwordController = TextEditingController();
  late TextEditingController _phoneController = TextEditingController();
  late TextEditingController _addressController = TextEditingController();
  late TextEditingController _postalCodeController = TextEditingController();
  File? _imageFile;

  // Add visibility state variables
  bool _isEmailVisible = false;
  bool _isPhoneVisible = false;
  bool _isMounted = false;

  @override
  void initState() {
    super.initState();
    _isMounted = true;
    context.read<ProfileBloc>().add(GetProfileViewEvent());
    _initializeControllers();
  }

  void _initializeControllers() {
    final state = context.read<ProfileBloc>().state;
    _venueNameController = TextEditingController(text: state.venueName);
    _venueDescriptionController = TextEditingController(
      text: state.venueDescription,
    );
    _emailController = TextEditingController(text: state.email);
    // _passwordController = TextEditingController(text: state.password);
    _phoneController = TextEditingController(text: state.phone);
    _addressController = TextEditingController(text: state.address);
    _postalCodeController = TextEditingController(text: state.postalCode);
  }

  @override
  void dispose() {
    _venueNameController.dispose();
    _venueDescriptionController.dispose();
    _emailController.dispose();
    // _passwordController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _postalCodeController.dispose();
    super.dispose();
  }

  String _getMaskedEmail(String email) {
    if (email.isEmpty) return email;
    final atIndex = email.indexOf('@');
    if (atIndex <= 1) return email;

    final username = email.substring(0, atIndex);
    final domain = email.substring(atIndex);

    if (username.length <= 2) return email;

    final maskedUsername =
        username[0] +
        '*' * (username.length - 2) +
        username[username.length - 1];

    return maskedUsername + domain;
  }

  String _getMaskedPhone(String phone) {
    if (phone.isEmpty || phone.length < 4) return phone;

    final visibleDigits = 2;
    final maskedPart = '*' * (phone.length - visibleDigits * 2);

    return phone.substring(0, visibleDigits) +
        maskedPart +
        phone.substring(phone.length - visibleDigits);
  }

  void _showToast(String message, Color textColor) {
    if (!_isMounted) return;

    Fluttertoast.showToast(
      backgroundColor: AppColors.primaryWhiteColor,
      textColor: textColor,
      gravity: ToastGravity.BOTTOM,
      msg: message,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProfileBloc, ProfileState>(
      listener: (context, state) async {
        if (state is ProfileViewLoaded) {
          _initializeControllers(); // Reinitialize controllers
        }
        _venueNameController.text = state.venueName;
        _venueDescriptionController.text = state.venueDescription;
        _emailController.text = state.email;
        // _passwordController.text = state.password;
        _phoneController.text = state.phone;
        _addressController.text = state.address;
        _postalCodeController.text = state.postalCode;
        if (state.image != null) {
          _imageFile = File(state.image!.path);
        }

        if (state is ProfileUpdateLoading) {
          EasyLoading.show();
        }
        if (state is ProfileUpdateSuccess) {
          _venueNameController.text = state.venueName;
          _venueDescriptionController.text = state.venueDescription;
          _emailController.text = state.email;
          _phoneController.text = state.phone;
          _addressController.text = state.address;
          _postalCodeController.text = state.postalCode;
          EasyLoading.dismiss();
          Fluttertoast.showToast(
            msg: 'Profile updated successfully',
            backgroundColor: AppColors.primaryWhiteColor,
            textColor: AppColors.appGreenColor,
          );
        } else if (state is ProfileUpdateError) {
          Fluttertoast.showToast(
            msg: state.errorMessage,
            backgroundColor: AppColors.primaryWhiteColor,
            textColor: AppColors.appRedColor,
          );
        }

        if (state is ProfileViewLoading) {
          await EasyLoading.show();
        } else {
          await EasyLoading.dismiss();
          if (state is ProfileImageErrorState) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text("Something went wrong!.")));
          }
        }

        if (state is ProfileDeleteLoading) {
          EasyLoading.show();
        }
        if (state is ProfileDeleteSuccess) {
          if (state.cafeDeleteProfileResponse.status == true) {
            EasyLoading.dismiss();
            _showToast(
              state.cafeDeleteProfileResponse.message ??
                  "Account Deleted successful",
              AppColors.appGreenColor,
            );
            context.go('/category');
          } else if (state.cafeDeleteProfileResponse.status == false) {
            EasyLoading.dismiss();
            _showToast(
              state.cafeDeleteProfileResponse.message ??
                  "Failed to delete account",
              AppColors.appRedColor,
            );
          }
        } else if (state is ProfileDeleteError) {
          EasyLoading.dismiss();
          _showToast(state.errorMessage, AppColors.appRedColor);
        }
      },
      builder: (context, state) {
        if (state is ProfileViewError) {
          return Center(child: Text(state.errorMessage));
        }
        if (state is ProfileViewLoading) {
          EasyLoading.show();
        }
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
                          onChanged: (value) {},
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
                          onChanged: (value) {},
                        ),
                        Align(
                          alignment: Alignment.centerRight,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              SizedBox(
                                height: 35,
                                width: 55,
                                child: FittedBox(
                                  fit: BoxFit.fill,
                                  child: Switch(
                                    activeColor: AppColors.primaryWhiteColor,
                                    activeTrackColor: AppColors.tertiary,
                                    inactiveThumbColor: AppColors.disabledColor,
                                    inactiveTrackColor:
                                        AppColors.primaryWhiteColor,
                                    value: _isEmailVisible,
                                    onChanged: (val) {
                                      setState(() {
                                        _isEmailVisible = val;
                                      });
                                    },
                                  ),
                                ),
                              ),
                              Gap(1),
                              Text(
                                "Show to user",
                                style: TextTheme.of(
                                  context,
                                ).bodySmall!.copyWith(
                                  color: AppColors.primaryWhiteColor,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        CustomTextField(
                          isProfile: true,
                          readOnly: true,
                          controller: TextEditingController(
                            text:
                                _isEmailVisible
                                    ? state.email
                                    : _getMaskedEmail(state.email),
                          ),
                          hintText: 'Email',
                          textFieldAnnotationText: 'Email',
                          onChanged: (value) {},
                        ),
                        Align(
                          alignment: Alignment.centerRight,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              SizedBox(
                                height: 35,
                                width: 55,
                                child: FittedBox(
                                  fit: BoxFit.fill,
                                  child: Switch(
                                    activeColor: AppColors.primaryWhiteColor,
                                    activeTrackColor: AppColors.tertiary,
                                    inactiveThumbColor: AppColors.disabledColor,
                                    inactiveTrackColor:
                                        AppColors.primaryWhiteColor,
                                    value: _isPhoneVisible,
                                    onChanged: (val) {
                                      setState(() {
                                        _isPhoneVisible = val;
                                      });
                                    },
                                  ),
                                ),
                              ),
                              Gap(1),
                              Text(
                                "Show to user",
                                style: TextTheme.of(
                                  context,
                                ).bodySmall!.copyWith(
                                  color: AppColors.primaryWhiteColor,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        CustomTextField(
                          isProfile: true,
                          readOnly: true,
                          controller: TextEditingController(
                            text:
                                _isPhoneVisible
                                    ? state.phone
                                    : _getMaskedPhone(state.phone),
                          ),
                          hintText: 'Phone',
                          textFieldAnnotationText: 'Phone',
                          onChanged: (value) {},
                        ),
                        CustomTextField(
                          isProfile: true,
                          readOnly: true,
                          controller: _addressController,
                          hintText: 'Street Address And City',
                          textFieldAnnotationText: 'Street Address And City',
                          onChanged: (value) {},
                        ),
                        CustomTextField(
                          isProfile: true,
                          readOnly: true,
                          controller: _postalCodeController,
                          hintText: 'Postal Code',
                          textFieldAnnotationText: 'Postal Code',
                          onChanged: (value) {},
                        ),
                        const Gap(10),
                        CustomTextField(
                          textAlign: TextAlign.left,
                          height: 90.h,
                          maxLines: 3,
                          isProfile: true,
                          readOnly: true,
                          controller: TextEditingController(
                            text: state.venueType ?? 'No venue type selected',
                          ),
                          hintText: 'Venue Type',
                          textFieldAnnotationText: 'Venue Type',
                          onChanged: (value) {},
                        ),

                        // LayoutBuilder(
                        //   builder: (context, constraints) {
                        //     final venueTypeText = state.venueType ?? 'No venue type selected';
                        //     final textStyle = TextStyle(
                        //       fontSize: 14.sp, // Adjust based on your text style
                        //       fontWeight: FontWeight.w600, // Match your design
                        //     );
                        //     final textSpan = TextSpan(text: venueTypeText, style: textStyle);
                        //     final textPainter = TextPainter(
                        //       text: textSpan,
                        //       maxLines: 1,
                        //       textDirection: TextDirection.ltr,
                        //       textScaleFactor: MediaQuery.of(context).textScaleFactor,
                        //     )..layout(maxWidth: constraints.maxWidth - 32); // Subtract padding
                        //
                        //     final lineCount = textPainter.computeLineMetrics().length;
                        //     final dynamicHeight = lineCount == 1 ? 70.h : 90.h; // Single line or multi-line height
                        //     final dynamicMaxLines = lineCount == 1 ? 1 : 3;
                        //
                        //     return CustomTextField(
                        //       textAlign: TextAlign.left,
                        //       height: dynamicHeight,
                        //       maxLines: dynamicMaxLines,
                        //       isProfile: true,
                        //       readOnly: true,
                        //       controller: TextEditingController(text: venueTypeText),
                        //       hintText: 'Venue Type',
                        //       textFieldAnnotationText: 'Venue Type',
                        //       onChanged: (value) {},
                        //     );
                        //   },
                        // ),

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
                              cafeUserName: "",
                            );
                            ObjectFactory().prefs.setCafeId(cafeId: '');
                            ObjectFactory().prefs.setCafeUserId(cafeUserId: '');
                            ObjectFactory().prefs.getNavigationSource();
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
                        const Gap(10),
                        InkWell(
                          onTap: () {
                            _showDeleteAccountDialog(context);
                          },
                          child: ElevatedButtonWidget(
                            height: 70.h,
                            width: double.infinity,
                            iconEnabled: false,
                            iconLabel: 'DELETE ACCOUNT',
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

  void _showDeleteAccountDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              title: Text(
                'Are you sure?',
                style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                  fontSize: 16.sp,
                ),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Are you sure you want to delete your account? This action is permanent and cannot be undone. All your data will be erased.",
                    style: Theme.of(context).textTheme.bodySmall!.copyWith(
                      color: AppColors.textPrimaryGrey,
                      fontWeight: FontWeight.w500,
                      fontSize: 15.sp,
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => dialogContext.pop(),
                  child: Text(
                    'Cancel',
                    style: Theme.of(context).textTheme.bodySmall!.copyWith(
                      color: AppColors.shadowColor,
                      fontWeight: FontWeight.w500,
                      fontSize: 14.sp,
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    context.read<ProfileBloc>().add(ProfileDeleteEvent());
                    // dialogContext.pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'Continue',
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
      },
    );
  }

  // For venue types, convert selected types to a readable string
  String _formatVenueTypes(Map<String, bool> venueTypes) {
    final selectedTypes =
        venueTypes.entries
            .where((entry) => entry.value)
            .map((entry) => entry.key)
            .toList();
    return selectedTypes.isEmpty
        ? 'No venue types selected'
        : selectedTypes.join(', ');
  }

  // For opening hours, create a formatted string with each day and its hours
  String _formatOpeningHours(Map<String, ProfileOpeningHour> openingHours) {
    if (openingHours.isEmpty) return 'No opening hours set';
    final buffer = StringBuffer();
    openingHours.forEach((day, hours) {
      if (hours.isEnabled) {
        final fromTime = _formatTimeOfDay(hours.from);
        final toTime = _formatTimeOfDay(hours.to);
        buffer.writeln('$day: $fromTime - $toTime');
      } else {
        buffer.writeln('$day: Closed');
      }
    });
    return buffer.toString();
  }

  String _formatTimeOfDay(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }

  Widget _buildSliverAppBar() {
    final isTabletOrLarger = ResponsiveBreakpoints.of(
      context,
    ).largerThan(MOBILE);
    final state = context.read<ProfileBloc>().state;
    final subTitle = state.profileViewResponse?.data?.cafeSince?.toString() ?? "";
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
              height: isTabletOrLarger ? 460.h / 1.8.h : 380.h / 1.8.h,
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
                      state.venueName,
                      style: TextTheme.of(context).bodyLarge!.copyWith(
                        color: AppColors.primaryWhiteColor,
                        fontSize: 22,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      subTitle,
                      style: TextTheme.of(context).bodySmall!.copyWith(
                        color: AppColors.primaryWhiteColor,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              top:
                  isTabletOrLarger
                      ? (350.h / 1.9.h) - 20.h
                      : (350.h / 1.9.h) - 60.h,
              left: 0,
              right: 0,
              child: Center(
                child: CircleAvatar(
                  radius: 95.r,
                  backgroundColor: AppColors.primary,
                  child: CircleAvatar(
                    backgroundColor: Colors.transparent,
                    radius: 85.r,
                    child: ClipOval(
                      child: BlocBuilder<ProfileBloc, ProfileState>(
                        builder: (context, state) {
                          final base64Image =
                              state.profileViewResponse?.data?.photo;
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
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        InkWell(
          onTap: () {
            context.push('/notification');
          },
          child: SvgPicture.asset('assets/svg/notify.svg'),
        ),
      ],
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
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontSize: 14,
                color: AppColors.primaryWhiteColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            ElevatedButton.icon(
              onPressed: () async {
                final profileState = context.read<ProfileBloc>().state;
                final dynamic result = await context.push(
                  '/edit_profile',
                  extra: profileState,
                );
                if (result is String && result.isNotEmpty) {
                  setState(() {
                    _imageFile = File(result);
                  });
                }
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
