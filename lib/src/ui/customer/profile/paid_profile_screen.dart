import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gap/gap.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shimmer/shimmer.dart';
import 'package:soloseaters/src/common/elevated_button_widget.dart';
import 'package:soloseaters/src/common/profile_info_text_field.dart';
import 'package:soloseaters/src/constants/app_colors.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:soloseaters/src/constants/assets.dart';
import 'package:soloseaters/src/model/customer/profile/customer_paid_profile_request.dart';
import 'package:soloseaters/src/model/customer/profile/customer_paid_profile_response.dart';
import 'package:soloseaters/src/ui/customer/profile/paid_profile_bloc/bloc/paid_profile_bloc.dart';
import 'package:soloseaters/src/ui/customer/profile/paid_profile_bloc/bloc/paid_profile_event.dart';
import 'package:soloseaters/src/ui/customer/profile/paid_profile_bloc/bloc/paid_profile_state.dart';
import 'package:url_launcher/url_launcher.dart';

class PadiProfileScreen extends StatefulWidget {
  final Map<String, dynamic> profileData;
  const PadiProfileScreen({super.key, required this.profileData});

  @override
  State<PadiProfileScreen> createState() => _PadiProfileScreenState();
}

class _PadiProfileScreenState extends State<PadiProfileScreen> {
  late TextEditingController aboutMeController;
  late TextEditingController businessDetailsController;
  late TextEditingController interestController;
  bool _controllersInitialized = false;
  bool _wasLoadingInitial = false;
  bool _wasUpdating = false;

  @override
  void initState() {
    super.initState();

    aboutMeController = TextEditingController();
    businessDetailsController = TextEditingController();
    interestController = TextEditingController();

    void markDirty() =>
        context.read<PaidProfileBloc>().add(const UpdateTextFieldEvent());
    aboutMeController.addListener(markDirty);
    businessDetailsController.addListener(markDirty);
    interestController.addListener(markDirty);
  }

  @override
  void dispose() {
    aboutMeController.dispose();
    businessDetailsController.dispose();
    interestController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PaidProfileBloc, PaidProfileState>(
      listener: (context, state) {
        // Handle initial loading
        if (state.isLoading && !_wasLoadingInitial) {
          EasyLoading.show(status: 'Loading Profile...');
        }
        if (!state.isLoading && _wasLoadingInitial) {
          EasyLoading.dismiss();
        }
        _wasLoadingInitial = state.isLoading;

        // Handle updating
        if (state.isUpdating && !_wasUpdating) {
          EasyLoading.show(status: 'Updating Profile...');
        }
        if (!state.isUpdating && _wasUpdating) {
          EasyLoading.dismiss();
        }
        _wasUpdating = state.isUpdating;
        // Show success message
        if (state.updateSuccess && state.successMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.white),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      state.successMessage!,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              backgroundColor: AppColors.appGreenColor,
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 3),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              // action: SnackBarAction(
              //   label: 'Refresh',
              //   textColor: Colors.white,
              //   onPressed: () {
              //     context.read<PaidProfileBloc>().add(
              //       const GetPaidProfileEvent(),
              //     );
              //   },
              // ),
            ),
          );
          Future.delayed(const Duration(seconds: 3), () {
            if (mounted) {
              context.read<PaidProfileBloc>().add(
                const ResetUpdateStatusEvent(),
              );
            }
          });
        }

        // Show error message
        if (state.errorMessage != null &&
            state.errorMessage!.isNotEmpty &&
            !state.isLoading &&
            !state.isUpdating) {
          // ✅ Added this condition

          // Don't show subscription errors repeatedly if user is just interacting
          final isSubscriptionError = state.errorMessage!.contains(
            'subscription',
          );
          final hasLocalChanges =
              state.selectedBusinessImages.isNotEmpty ||
              state.selectedHobbyImages.isNotEmpty ||
              state.selectedProfileImage != null;

          // Only show subscription error once (not on every interaction)
          if (isSubscriptionError && hasLocalChanges) {
            // Skip showing the error again if user is just making local changes
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    const Icon(Icons.error_outline, color: Colors.white),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        state.errorMessage!,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                backgroundColor: AppColors.appRedColor,
                behavior: SnackBarBehavior.floating,
                duration: const Duration(seconds: 4),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            );
          }
        }

        // Initialize controllers once when profile loads
        if (!_controllersInitialized &&
            !state.isLoading &&
            state.profile.data != null) {
          final profile = state.profile.data!;
          aboutMeController.text = profile.aboutMe ?? '';
          businessDetailsController.text = profile.businessDetails ?? '';
          interestController.text = profile.interestsHobbies ?? '';
          _controllersInitialized = true;
        }
      },
      builder: (context, state) {
        return _buildProfileUI(context, state);
      },
    );
  }

  Widget _buildProfileUI(BuildContext context, PaidProfileState state) {
    final profile = state.profile.data;

    return Scaffold(
      backgroundColor: AppColors.primary,
      body: SafeArea(
        child: Stack(
          children: [
            CustomScrollView(
              slivers: [
                _buildSliverAppBar(context, profile, state),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 10,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // About Me Section
                        _buildSectionTitle(context, "About Me"),
                        ProfileInfoTextField(
                          controller: aboutMeController,
                          maxLines: 5,
                          height: 110,
                          hintText: "Add about yourself...",
                          onChanged: (_) {
                            context.read<PaidProfileBloc>().add(
                              const UpdateTextFieldEvent(),
                            );
                          },
                        ),
                        Divider(color: AppColors.profileTextFiledBorderColor),
                        const Gap(15),

                        // Business Details Section
                        _buildSectionTitle(context, "My Business Details"),
                        ProfileInfoTextField(
                          controller: businessDetailsController,
                          maxLines: 5,
                          height: 110,
                          hintText: "Add about your business...",
                          onChanged: (_) {
                            context.read<PaidProfileBloc>().add(
                              const UpdateTextFieldEvent(),
                            );
                          },
                        ),
                        const Gap(10),
                        _buildBusinessImagesSection(state),
                        const Gap(15),
                        Divider(color: AppColors.profileTextFiledBorderColor),
                        const Gap(15),

                        // Interests & Hobbies Section
                        _buildSectionTitle(context, "Interests & Hobbies"),
                        ProfileInfoTextField(
                          controller: interestController,
                          maxLines: 5,
                          height: 110,
                          hintText: "Add about your interests...",
                          onChanged: (_) {
                            context.read<PaidProfileBloc>().add(
                              const UpdateTextFieldEvent(),
                            );
                          },
                        ),
                        const Gap(10),
                        _buildHobbyImagesSection(state),
                        const Gap(15),
                        Divider(color: AppColors.profileTextFiledBorderColor),

                        // Preferences Section
                        _buildSectionTitle(context, "My Preferences"),
                        const Gap(5),
                        _buildPreferenceToggles(state),
                        const Gap(5),
                        Divider(color: AppColors.profileTextFiledBorderColor),
                        const Gap(20),

                        // Favorite Venues Section
                        if (profile?.favoriteVenues != null &&
                            profile!.favoriteVenues!.isNotEmpty) ...[
                          _buildSectionTitle(context, "Favorite Venues"),
                          const Gap(5),
                          _buildVenueList(state, profile.favoriteVenues ?? []),
                          const Gap(25),
                        ],

                        // Save Button
                        _buildSaveButton(state),

                        const Gap(12),

                        // Manage Subscription Button (Required by Play Store & App Store)
                        _buildManageSubscriptionButton(),

                        const Gap(30),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBusinessImagesSection(PaidProfileState state) {
    final apiImages = state.profile.data?.businessDetailsImages ?? [];
    final localImages = state.selectedBusinessImages;

    // Show info about replacement behavior
    final hasApiImages = apiImages.isNotEmpty;
    final hasLocalImages = localImages.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (hasApiImages || hasLocalImages) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (hasLocalImages && hasApiImages)
                      Text(
                        'New images will replace existing ones',
                        style: GoogleFonts.roboto(
                          color: Colors.orange.shade300,
                          fontSize: 10.sp,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          const Gap(8),
          _buildImageGrid(
            apiImages: hasLocalImages ? [] : apiImages,
            localImages: localImages,
            isBusiness: true,
          ),
          const Gap(20),
        ],
        _buildUploadButton(
          context,
          isBusiness: true,
          state: state,
          isDisabled: localImages.length >= 2,
        ),
      ],
    );
  }

  Widget _buildHobbyImagesSection(PaidProfileState state) {
    final apiImages = state.profile.data?.interestsHobbiesImages ?? [];
    final localImages = state.selectedHobbyImages;

    final hasApiImages = apiImages.isNotEmpty;
    final hasLocalImages = localImages.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (hasApiImages || hasLocalImages) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (hasLocalImages && hasApiImages)
                      Text(
                        'New images will replace existing ones',
                        style: GoogleFonts.roboto(
                          color: Colors.orange.shade300,
                          fontSize: 10.sp,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          const Gap(8),
          _buildImageGrid(
            apiImages: hasLocalImages ? [] : apiImages,
            localImages: localImages,
            isBusiness: false,
          ),
          const Gap(20),
        ],
        _buildUploadButton(
          context,
          isBusiness: false,
          state: state,
          isDisabled: localImages.length >= 2,
        ),
      ],
    );
  }

  Widget _buildImageGrid({
    required List<dynamic> apiImages,
    required List<XFile> localImages,
    required bool isBusiness,
  }) {
    final allImages = <dynamic>[...apiImages, ...localImages];

    if (allImages.isEmpty) return const SizedBox.shrink();

    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 0.7,
      ),
      itemCount: allImages.length,
      itemBuilder: (context, index) {
        final image = allImages[index];
        final isLocal = image is XFile;

        return Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(15.r),
              child:
                  isLocal
                      ? Image.file(
                        File(image.path),
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: AppColors.disabledColor.withOpacity(0.3),
                            child: const Center(
                              child: Icon(
                                Icons.broken_image_outlined,
                                color: Colors.white70,
                                size: 48,
                              ),
                            ),
                          );
                        },
                      )
                      : CachedNetworkImage(
                        imageUrl: image.toString(),
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                        placeholder:
                            (context, url) => Shimmer.fromColors(
                              baseColor: Color(0xFF003E69),
                              highlightColor: Color(0xFF0067AF),
                              child: Container(
                                width: 170.r,
                                height: 170.r,
                                color: Colors.white,
                              ),
                            ),
                        errorWidget: (context, url, error) {
                          print('Image load error: $error for URL: $url');
                          return Container(
                            color: AppColors.disabledColor.withOpacity(0.3),
                            child: const Center(
                              child: Icon(
                                Icons.broken_image_outlined,
                                color: Colors.white70,
                                size: 48,
                              ),
                            ),
                          );
                        },
                      ),
            ),
            // Badge for image type
            isLocal
                ? Positioned(
                  top: 6,
                  left: 6,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: isLocal ? Colors.blue.shade700 : Colors.black54,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'New',
                      style: GoogleFonts.roboto(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                )
                : SizedBox.shrink(),
            // Remove button (only for newly added local images)
            if (isLocal)
              Positioned(
                top: 6,
                right: 6,
                child: InkWell(
                  onTap: () {
                    final localIndex = index - apiImages.length;
                    if (isBusiness) {
                      context.read<PaidProfileBloc>().add(
                        RemoveBusinessImageEvent(localIndex),
                      );
                    } else {
                      context.read<PaidProfileBloc>().add(
                        RemoveHobbyImageEvent(localIndex),
                      );
                    }
                  },
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    padding: const EdgeInsets.all(6),
                    child: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  /// Helper method to pick single image with permission handling
  Future<void> _pickSingleImage(BuildContext context) async {
    try {
      final ImagePicker picker = ImagePicker();
      final picked = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );

      if (picked != null) {
        if (!context.mounted) return;
        context.read<PaidProfileBloc>().add(
          UpdateProfileImageEvent(XFile(picked.path)),
        );
      }
    } catch (e) {
      if (!context.mounted) return;

      // Show error snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Failed to pick image. Please check permissions in settings.',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          backgroundColor: AppColors.appRedColor,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }

  /// Helper method to pick multiple images with permission handling
  Future<void> _pickMultipleImages(
    BuildContext context, {
    required bool isBusiness,
  }) async {
    try {
      final ImagePicker picker = ImagePicker();
      final picked = await picker.pickMultiImage(imageQuality: 80);

      if (picked.isNotEmpty) {
        if (!context.mounted) return;

        if (isBusiness) {
          context.read<PaidProfileBloc>().add(AddBusinessImagesEvent(picked));
        } else {
          context.read<PaidProfileBloc>().add(AddHobbyImagesEvent(picked));
        }
      }
    } catch (e) {
      if (!context.mounted) return;

      // Show error snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Failed to pick images. Please check permissions in settings.',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          backgroundColor: AppColors.appRedColor,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }

  Widget _buildUploadButton(
    BuildContext context, {
    required bool isBusiness,
    required PaidProfileState state,
    required bool isDisabled,
  }) {
    return Center(
      child: InkWell(
        onTap:
            isDisabled
                ? null
                : () => _pickMultipleImages(
                  context,
                  isBusiness: isBusiness,
                ), // Updated
        borderRadius: BorderRadius.circular(50.r),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(50.r),
            border: Border.all(
              color: isDisabled ? Colors.grey : AppColors.primaryWhiteColor,
              width: 1.5,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                Assets.UPLOAD,
                width: 18.w,
                height: 18.h,
                color: isDisabled ? Colors.grey : AppColors.primaryWhiteColor,
                errorBuilder:
                    (context, error, stackTrace) => Icon(
                      Icons.upload,
                      color:
                          isDisabled
                              ? Colors.grey
                              : AppColors.primaryWhiteColor,
                      size: 18,
                    ),
              ),
              const SizedBox(width: 8),
              Text(
                isDisabled ? "LIMIT REACHED" : "UPLOAD IMAGE",
                style: GoogleFonts.montserrat(
                  color: isDisabled ? Colors.grey : AppColors.primaryWhiteColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 12.sp,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPreferenceToggles(PaidProfileState state) {
    final preferences = state.profile.data?.myPreferences ?? [];

    if (preferences.isEmpty) {
      return Text(
        "No preferences available",
        style: GoogleFonts.montserrat(
          color: AppColors.primaryWhiteColor.withOpacity(0.7),
          fontSize: 13.sp,
        ),
      );
    }

    return Column(
      children:
          preferences.map((preference) {
            if (preference.id == null) return const SizedBox.shrink();

            final isEnabled = state.localPreferences[preference.id] ?? false;

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 5.0),
              child: Row(
                children: [
                  SizedBox(
                    width: 50.0,
                    height: 36.0,
                    child: FittedBox(
                      fit: BoxFit.fill,
                      child: Switch(
                        activeColor: AppColors.primaryWhiteColor,
                        activeTrackColor: AppColors.tertiary,
                        inactiveThumbColor: Colors.white,
                        inactiveTrackColor: Colors.grey.shade400,
                        value: isEnabled,
                        onChanged: (newValue) {
                          context.read<PaidProfileBloc>().add(
                            TogglePreferenceEvent(
                              preferenceId: preference.id!,
                              isEnabled: newValue,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      preference.name ?? 'Unknown',
                      style: GoogleFonts.montserrat(
                        color: AppColors.primaryWhiteColor,
                        fontSize: 13.sp,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
    );
  }

  Widget _buildVenueList(PaidProfileState state, List<FavoriteVenue> venues) {
    if (venues.isEmpty) {
      return Text(
        "No favorite venues added yet.",
        style: GoogleFonts.montserrat(
          color: AppColors.primaryWhiteColor.withOpacity(0.7),
          fontSize: 13.sp,
        ),
      );
    }

    return Column(
      children:
          venues.map((venue) {
            if (venue.id == null) return const SizedBox.shrink();

            final isNotificationOn =
                state.localVenueNotifications[venue.id] ?? false;

            return Padding(
              padding: const EdgeInsets.only(bottom: 10.0),
              child: _buildVenueTile(context, venue, isNotificationOn),
            );
          }).toList(),
    );
  }

  Widget _buildVenueTile(
    BuildContext context,
    FavoriteVenue venue,
    bool isNotificationOn,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Color(0xFF094671),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: AppColors.primaryWhiteColor.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(
                width: 50.0,
                height: 36.0,
                child: FittedBox(
                  fit: BoxFit.fill,
                  child: Switch(
                    value: isNotificationOn,
                    activeColor: AppColors.primaryWhiteColor,
                    activeTrackColor: AppColors.secondary,
                    inactiveThumbColor: Colors.white,
                    inactiveTrackColor: Colors.grey.shade400,
                    onChanged: (value) {
                      if (venue.id != null) {
                        context.read<PaidProfileBloc>().add(
                          ToggleVenueNotification(
                            venueId: venue.id!,
                            isEnabled: value,
                          ),
                        );
                      }
                    },
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                venue.name ?? 'Unknown Venue',
                style: GoogleFonts.montserrat(
                  color: AppColors.primaryWhiteColor,
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          ImageIcon(
            AssetImage(isNotificationOn ? Assets.NOTIFY : Assets.UNNOTIFY),
            size: 20,
            color: AppColors.primaryWhiteColor,
          ),
        ],
      ),
    );
  }

  Widget _buildSaveButton(PaidProfileState state) {
    final hasChanges =
        state.hasUnsavedChanges ||
        state.selectedBusinessImages.isNotEmpty ||
        state.selectedHobbyImages.isNotEmpty ||
        state.selectedProfileImage != null;

    final isEnabled = hasChanges && !state.updateSuccess;

    return Center(
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.all(12),
          minimumSize: Size(223.w, 37.h),
          backgroundColor:
              isEnabled
                  ? AppColors.primaryWhiteColor
                  : AppColors.disabledColor.withOpacity(0.3),
          foregroundColor: isEnabled ? AppColors.primary : Colors.white38,
          elevation: isEnabled ? 2 : 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
        onPressed: isEnabled ? () => _onSaveProfile(context, state) : null,
        child: Text(
          "APPLY PROFILE CHANGES",
          style: GoogleFonts.montserrat(
            fontSize: 12.sp,
            fontWeight: FontWeight.w600,
            color: isEnabled ? AppColors.primary : Colors.white38,
          ),
        ),
      ),
    );
  }

  // ✅ Open Play Store / App Store subscription management
  Future<void> _openSubscriptionManagement() async {
    try {
      Uri? uri;

      if (Platform.isAndroid) {
        // Open Google Play Store subscriptions page
        uri = Uri.parse(
          'https://play.google.com/store/account/subscriptions?package=com.mydicetable.app',
        );
      } else if (Platform.isIOS) {
        // Open App Store subscriptions page
        uri = Uri.parse('https://apps.apple.com/account/subscriptions');
      }

      if (uri != null && await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        print('⚠️ Could not launch subscription management URL');
      }
    } catch (e) {
      print('❌ Error opening subscription management: $e');
    }
  }

  Widget _buildManageSubscriptionButton() {
    return Center(
      child: TextButton(
        onPressed: _openSubscriptionManagement,
        style: TextButton.styleFrom(
          padding: EdgeInsets.symmetric(vertical: 8.h),
        ),
        child: Text(
          'Manage Subscription',
          style: GoogleFonts.montserrat(
            fontSize: 13.sp,
            color: AppColors.primaryWhiteColor,
            fontWeight: FontWeight.w500,
            decoration: TextDecoration.underline,
          ),
        ),
      ),
    );
  }

  void _onSaveProfile(BuildContext context, PaidProfileState state) {
    final request = PaidProfileUpdateRequest(
      aboutMe: aboutMeController.text.trim(),
      businessDetails: businessDetailsController.text.trim(),
      interestsHobbies: interestController.text.trim(),
      myPreferences: null, // Will be built in BLoC from localPreferences
      venueNotifications:
          null, // Will be built in BLoC from localVenueNotifications
      businessImages:
          state.selectedBusinessImages.isNotEmpty
              ? state.selectedBusinessImages
              : null,
      hobbyImages:
          state.selectedHobbyImages.isNotEmpty
              ? state.selectedHobbyImages
              : null,
      image: state.selectedProfileImage,
    );

    context.read<PaidProfileBloc>().add(
      UpdatePaidProfileEvent(request: request),
    );
  }

  Widget _buildSliverAppBar(
    BuildContext context,
    Data? profile,
    PaidProfileState state,
  ) {
    final isTabletOrLarger = ResponsiveBreakpoints.of(
      context,
    ).largerThan(MOBILE);

    String? displayImageUrl;
    bool isLocalImage = false;

    if (state.selectedProfileImage != null) {
      isLocalImage = true;
    } else if (profile?.photo != null && profile!.photo.toString().isNotEmpty) {
      displayImageUrl = profile.photo.toString();
      if (displayImageUrl != null && /* ... */
          (state.imageWasJustUploaded ?? false)) {
        final separator = displayImageUrl.contains('?') ? '&' : '?';
        displayImageUrl =
            '$displayImageUrl$separator'
            'cb=${DateTime.now().millisecondsSinceEpoch}';
        print('🔄 Cache busting profile URL: $displayImageUrl'); // Debug log
      }
    }

    return SliverAppBar(
      expandedHeight: 380.h,
      pinned: true,
      floating: false,
      backgroundColor: AppColors.primary,
      automaticallyImplyLeading: false,
      flexibleSpace: FlexibleSpaceBar(
        stretchModes: const [StretchMode.zoomBackground],
        background: Stack(
          children: [
            Container(color: AppColors.primary),
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: isTabletOrLarger ? 560.h / 1.8.h : 380.h / 1.8.h,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(30.r),
                    bottomRight: Radius.circular(30.r),
                  ),
                  image: DecorationImage(
                    image: AssetImage('assets/png/p-bg.png'),
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
                    Gap(60.h),
                    Text(
                      "Serious Networker",
                      style: GoogleFonts.montserrat(
                        color: AppColors.primaryWhiteColor,
                        fontSize: 22.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      widget.profileData["name"] ?? "",
                      style: GoogleFonts.montserrat(
                        color: AppColors.primaryWhiteColor,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              top:
                  isTabletOrLarger
                      ? (350.h / 1.5.h) - 20.h
                      : (350.h / 1.7.h) - 60.h,
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
                              isLocalImage
                                  ? Image.file(
                                    File(state.selectedProfileImage!.path),
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                    height: double.infinity,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        color: AppColors.secondary,
                                        child: const Icon(
                                          Icons.person,
                                          size: 60,
                                          color: Colors.white,
                                        ),
                                      );
                                    },
                                  )
                                  : displayImageUrl != null
                                  ? CachedNetworkImage(
                                    imageUrl: displayImageUrl,
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                    height: double.infinity,
                                    placeholder:
                                        (context, url) => Shimmer.fromColors(
                                          baseColor: Color(0xFF003E69),
                                          highlightColor: Color(0xFF0067AF),
                                          child: Container(
                                            width: 170.r,
                                            height: 170.r,
                                            color: Colors.white,
                                          ),
                                        ),
                                    errorWidget: (context, url, error) {
                                      print('Profile image error: $error');
                                      return Container(
                                        color: AppColors.secondary,
                                        child: const Icon(
                                          Icons.person,
                                          size: 60,
                                          color: Colors.white,
                                        ),
                                      );
                                    },
                                  )
                                  : Container(
                                    color: AppColors.secondary,
                                    child: const Icon(
                                      Icons.person,
                                      size: 60,
                                      color: Colors.white,
                                    ),
                                  ),
                        ),
                      ),
                    ),
                    // Camera button for profile image update
                    Positioned(
                      bottom: 30.h,
                      right: 0,
                      child: Container(
                        height: 44.h,
                        width: 44.w,
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.primaryWhiteColor,
                          shape: BoxShape.circle,
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 4,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                        child: InkWell(
                          onTap: () => _pickSingleImage(context), //Updated
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
            ),
          ],
        ),
      ),
      actionsPadding: EdgeInsets.only(right: 15.w),
      title: Text(
        'Manage Profile',
        style: Theme.of(context).textTheme.labelLarge!.copyWith(
          color: AppColors.primaryWhiteColor,
          fontWeight: FontWeight.w600,
        ),
      ),
      leading: InkWell(
        onTap: () => Navigator.pop(context),
        child: SvgPicture.asset('assets/svg/back.svg', fit: BoxFit.scaleDown),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Text(
        title,
        style: GoogleFonts.montserrat(
          color: AppColors.primaryWhiteColor,
          fontWeight: FontWeight.w600,
          fontSize: 14.sp,
        ),
      ),
    );
  }
}
