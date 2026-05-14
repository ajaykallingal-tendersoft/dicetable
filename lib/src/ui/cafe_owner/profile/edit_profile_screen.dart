import 'dart:convert';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:shimmer/shimmer.dart';
import 'package:soloseaters/src/common/custom_text_field.dart';
import 'package:soloseaters/src/common/elevated_button_widget.dart';
import 'package:soloseaters/src/constants/app_colors.dart';
import 'package:soloseaters/src/model/cafe_owner/profile/delete_image_request.dart';
import 'package:soloseaters/src/model/cafe_owner/profile/profile_update_request.dart';
import 'package:soloseaters/src/model/country_response.dart';
import 'package:soloseaters/src/ui/cafe_owner/home/bloc/home_bloc.dart';
import 'package:soloseaters/src/ui/cafe_owner/profile/bloc/profile_bloc.dart';
import 'package:soloseaters/src/ui/cafe_owner/profile/widget/cafe_gallery_edit_widget.dart';
import 'package:soloseaters/src/ui/cafe_owner/profile/widget/profile_opening_hour_widget.dart';
import 'package:soloseaters/src/ui/cafe_owner/profile/widget/profile_venue_type_checkbox.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:responsive_framework/responsive_framework.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key, required this.profileState});

  final ProfileState? profileState;

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final TextEditingController _venueNameController = TextEditingController();
  final TextEditingController _venueDescriptionController =
      TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _postalCodeController = TextEditingController();
  final TextEditingController _countryController = TextEditingController();

  String _initialVenueName = '';
  String _initialVenueDescription = '';
  String _initialEmail = '';
  String _initialPhone = '';
  String _initialAddress = '';
  String _initialCity = '';
  String _initialPostalCode = '';
  String _initialCountry = '';
  List<int> _initialSelectedVenueTypeIds = [];
  Map<String, ProfileOpeningHour> _initialOpeningHours = {};
  bool _initialValuesSet =
      false; // Track if initial values have been set from ProfileEditViewLoaded

  @override
  void initState() {
    super.initState();

    final bloc = context.read<ProfileBloc>();
    print("ProfileBloc hashCode: ${bloc.hashCode}");
    // bloc.add(LoadCountriesEvent());

    final currentState = bloc.state;

    // Pre-fill instantly if state passed from ManageProfileScreen
    final prefill = widget.profileState;
    if (prefill != null) {
      _venueNameController.text = prefill.venueName ?? '';
      _venueDescriptionController.text = prefill.venueDescription ?? '';
      _emailController.text = prefill.email ?? '';
      _phoneController.text = prefill.phone ?? '';
      _addressController.text = prefill.address ?? '';
      _postalCodeController.text = prefill.postalCode ?? '';
      _countryController.text = prefill.countryName ?? '';

      // Initialize initial values from prefilled state
      _initialVenueName = prefill.venueName ?? '';
      _initialVenueDescription = prefill.venueDescription ?? '';
      _initialEmail = prefill.email ?? '';
      _initialPhone = prefill.phone ?? '';
      _initialAddress = prefill.address ?? '';
      _initialCity = prefill.city ?? '';
      _initialPostalCode = prefill.postalCode ?? '';
      _initialCountry = prefill.countryName ?? '';
      _initialSelectedVenueTypeIds = List<int>.from(
        prefill.selectedVenueTypeIds ?? [],
      );
      _initialOpeningHours = Map<String, ProfileOpeningHour>.from(
        prefill.openingHours ?? {},
      );
    }

    //Only initialize controllers if we already have editable data
    if (currentState is ProfileEditViewLoaded) {
      _initializeControllers();
    } else {
      // Always fetch edit view data to ensure we have the latest
      bloc.add(GetProfileEditViewEvent());
    }

    // Show subtle EasyLoading overlay (optional)
    EasyLoading.show(status: 'Loading profile...');
    Future.delayed(const Duration(milliseconds: 400), () {
      if (EasyLoading.isShow) EasyLoading.dismiss();
    });
  }

  void _initializeControllers() {
    final profileState = widget.profileState;
    if (profileState == null) return;

    _venueNameController.text = profileState.venueName ?? '';
    _venueDescriptionController.text = profileState.venueDescription ?? '';
    _emailController.text = profileState.email ?? '';
    _phoneController.text = profileState.phone ?? '';
    _addressController.text = profileState.address ?? '';
    // _countryController.text = profileState.countryName ?? '';

    _postalCodeController.text = profileState.postalCode ?? '';

    _initialVenueName = profileState.venueName ?? '';
    _initialVenueDescription = profileState.venueDescription ?? '';
    _initialEmail = profileState.email ?? '';
    _initialPhone = profileState.phone ?? '';
    _initialAddress = profileState.address ?? '';
    _initialCity = profileState.city ?? '';
    _initialPostalCode = profileState.postalCode ?? '';
    _initialCountry = profileState.countryName ?? '';

    _initialSelectedVenueTypeIds = List<int>.from(
      profileState.selectedVenueTypeIds ?? [],
    );
    _initialOpeningHours = Map<String, ProfileOpeningHour>.from(
      profileState.openingHours ?? {},
    );
  }

  // Check if text fields changed
  bool _isTextDataChanged() {
    return _venueNameController.text.trim() != _initialVenueName ||
        _venueDescriptionController.text.trim() != _initialVenueDescription ||
        _emailController.text.trim() != _initialEmail ||
        _phoneController.text.trim() != _initialPhone ||
        _addressController.text.trim() != _initialAddress ||
        _postalCodeController.text.trim() != _initialPostalCode ||
        _countryController.text.trim() != _initialCountry;
  }

  // NEW: Check if venue types changed
  bool _isVenueTypesChanged(ProfileState state) {
    if (state.selectedVenueTypeIds.length !=
        _initialSelectedVenueTypeIds.length) {
      return true;
    }

    // Compare sorted lists to handle order differences
    final currentSorted = List<int>.from(state.selectedVenueTypeIds)..sort();
    final initialSorted = List<int>.from(_initialSelectedVenueTypeIds)..sort();

    for (int i = 0; i < currentSorted.length; i++) {
      if (currentSorted[i] != initialSorted[i]) {
        return true;
      }
    }

    return false;
  }

  bool _isOpeningHoursChanged(ProfileState state) {
    // If initial opening hours is empty but state has hours, consider it changed
    if (_initialOpeningHours.isEmpty && state.openingHours.isNotEmpty) {
      return true;
    }

    // If lengths don't match, something changed
    if (state.openingHours.length != _initialOpeningHours.length) {
      return true;
    }

    // Check all days in state
    for (final entry in state.openingHours.entries) {
      final day = entry.key;
      final currentHour = entry.value;
      final initialHour = _initialOpeningHours[day];

      // If day doesn't exist in initial, it's new (changed)
      if (initialHour == null) {
        return true;
      }

      // Deep compare each property
      if (currentHour.isEnabled != initialHour.isEnabled ||
          currentHour.from.hour != initialHour.from.hour ||
          currentHour.from.minute != initialHour.from.minute ||
          currentHour.to.hour != initialHour.to.hour ||
          currentHour.to.minute != initialHour.to.minute ||
          currentHour.id != initialHour.id) {
        return true;
      }
    }

    // Also check if any initial day is missing from current state
    for (final entry in _initialOpeningHours.entries) {
      final day = entry.key;
      if (!state.openingHours.containsKey(day)) {
        return true;
      }
    }

    return false;
  }

  bool _isValidPhoneNumber(String number) {
    final phoneRegex = RegExp(r'^\d{8,10}$');
    return phoneRegex.hasMatch(number);
  }

  @override
  void dispose() {
    _venueNameController.dispose();
    _venueDescriptionController.dispose();
    _emailController.dispose();
    // _passwordController.dispose();
    _phoneController.dispose();
    _countryController.dispose();
    _addressController.dispose();
    // _cityController.dispose();
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
                dialogContext.pop();
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
                  dialogContext.pop();
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
        // ========== LOADING STATE MANAGEMENT ==========
        // Dismiss loading for non-loading states
        if (state is! ProfileEditViewLoading &&
            state is! ProfileUpdateLoading &&
            state is! ProfileImageUploadLoading &&
            state is! GalleryPhotoUploadLoading &&
            state is! GalleryPhotoDeleteLoading &&
            state is! ProfileImageLoadingState &&
            state is! GalleryPhotoLoadingState) {
          if (EasyLoading.isShow) {
            EasyLoading.dismiss();
          }
        }

        if (state is ProfileImageUploadSuccess) {
          final imageUrl = state.profileEditViewResponse?.data?.photo;
          if (imageUrl != null) {
            CachedNetworkImage.evictFromCache(imageUrl);
          }
        }

        // Show specific loading messages for each operation
        if (state is ProfileEditViewLoading) {
          if (!EasyLoading.isShow) {
            EasyLoading.show(status: 'Loading profile...');
          }
        } else if (state is ProfileUpdateLoading) {
          if (!EasyLoading.isShow) {
            EasyLoading.show(status: 'Updating profile...');
          }
        } else if (state is ProfileImageUploadLoading) {
          if (!EasyLoading.isShow) {
            EasyLoading.show(status: 'Uploading image...');
          }
        } else if (state is GalleryPhotoUploadLoading) {
          if (!EasyLoading.isShow) {
            EasyLoading.show(status: 'Uploading gallery...');
          }
        } else if (state is GalleryPhotoDeleteLoading) {
          if (!EasyLoading.isShow) {
            EasyLoading.show(status: 'Deleting...');
          }
        } else if (state is ProfileImageLoadingState) {
          if (!EasyLoading.isShow) {
            EasyLoading.show(status: 'Processing image...');
          }
        } else if (state is GalleryPhotoLoadingState) {
          if (!EasyLoading.isShow) {
            EasyLoading.show(status: 'Processing images...');
          }
        }

        // ========== SUCCESS STATES ==========

        // Handle no changes detected
        if (state is ProfileNoChangeDetected) {
          Fluttertoast.showToast(
            msg: state.message,
            backgroundColor: AppColors.primaryWhiteColor,
            textColor: AppColors.primary,
            fontSize: 14.sp,
          );
        }

        // Handle final save success (may include partial errors)
        if (state is ProfileSaveSuccess) {
          final isFullSuccess = !state.message.contains('failed');

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor:
                  isFullSuccess ? AppColors.appGreenColor : Colors.orange,
              duration: Duration(seconds: isFullSuccess ? 2 : 4),
            ),
          );

          // Update initial values after successful save
          _initialVenueName = state.venueName;
          _initialVenueDescription = state.venueDescription;
          _initialEmail = state.email;
          _initialPhone = state.phone;
          _initialAddress = state.address;
          _initialPostalCode = state.postalCode;
          _initialCountry = state.countryName;
          _initialSelectedVenueTypeIds = List<int>.from(
            state.selectedVenueTypeIds,
          );

          // Deep copy opening hours
          _initialOpeningHours = {};
          for (final entry in state.openingHours.entries) {
            _initialOpeningHours[entry.key] = ProfileOpeningHour(
              isEnabled: entry.value.isEnabled,
              from: entry.value.from,
              to: entry.value.to,
              id: entry.value.id,
            );
          }

          _initialValuesSet = false; // Reset to allow update on next load

          // 🔄 Refresh HomeBloc to ensure updated opening hours are reflected in event creation
          if (mounted) {
            print('🔄 EditProfileScreen: Triggering HomeBloc refresh after successful profile save');
            context.read<HomeBloc>().add(GetHomeDataEvent());
          }
        }

        // Handle gallery delete success
        if (state is GalleryPhotoDeleteSuccess) {
          Fluttertoast.showToast(
            msg: 'Photo deleted successfully',
            backgroundColor: AppColors.primaryWhiteColor,
            textColor: AppColors.appGreenColor,
            fontSize: 14.sp,
          );
        }

        // ========== SYNC CONTROLLERS WITH STATE ==========

        // When edit view loads, sync controllers (only if values differ to avoid cursor jumps)
        if (state is ProfileEditViewLoaded) {
          if (_venueNameController.text != state.venueName) {
            _venueNameController.text = state.venueName;
          }
          if (_venueDescriptionController.text != state.venueDescription) {
            _venueDescriptionController.text = state.venueDescription;
          }
          if (_emailController.text != state.email) {
            _emailController.text = state.email;
          }
          if (_phoneController.text != state.phone) {
            _phoneController.text = state.phone;
          }
          if (_addressController.text != state.address) {
            _addressController.text = state.address;
          }
          if (_postalCodeController.text != state.postalCode) {
            _postalCodeController.text = state.postalCode;
          }
          if (_countryController.text != state.countryName) {
            _countryController.text = state.countryName;
          }

          // Set initial values only once (for change detection)
          if (!_initialValuesSet) {
            _initialVenueName = state.venueName;
            _initialVenueDescription = state.venueDescription;
            _initialEmail = state.email;
            _initialPhone = state.phone;
            _initialAddress = state.address;
            _initialCity = state.profileEditViewResponse.data?.city ?? '';
            _initialPostalCode = state.postalCode;
            _initialCountry = state.country;

            _initialSelectedVenueTypeIds = List<int>.from(
              state.selectedVenueTypeIds,
            );

            // Deep copy opening hours
            _initialOpeningHours = {};
            for (final entry in state.openingHours.entries) {
              _initialOpeningHours[entry.key] = ProfileOpeningHour(
                isEnabled: entry.value.isEnabled,
                from: entry.value.from,
                to: entry.value.to,
                id: entry.value.id,
              );
            }
            _initialValuesSet = true;
          }
        }

        // ========== ERROR STATES ==========

        // Critical profile update error
        if (state is ProfileUpdateError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Save Error: ${state.errorMessage}'),
              backgroundColor: AppColors.appRedColor,
              duration: const Duration(seconds: 3),
            ),
          );
        }

        // Non-critical image upload errors (shown as toast)
        if (state is ProfileImageUploadError) {
          Fluttertoast.showToast(
            msg: 'Image upload failed: ${state.errorMessage}',
            backgroundColor: AppColors.primaryWhiteColor,
            textColor: AppColors.appRedColor,
            fontSize: 14.sp,
          );
        }

        // Non-critical gallery upload errors
        if (state is GalleryPhotoUploadError) {
          Fluttertoast.showToast(
            msg: 'Gallery upload failed: ${state.errorMessage}',
            backgroundColor: AppColors.primaryWhiteColor,
            textColor: AppColors.appRedColor,
            fontSize: 14.sp,
            toastLength: Toast.LENGTH_LONG,
          );
        }

        // Gallery delete error
        if (state is GalleryPhotoDeleteError) {
          Fluttertoast.showToast(
            msg: 'Delete failed: ${state.errorMessage}',
            backgroundColor: AppColors.primaryWhiteColor,
            textColor: AppColors.appRedColor,
            fontSize: 14.sp,
          );
        }

        // Permission denied for profile image
        if (state is ProfileImagePermissionDeniedState) {
          _showPermissionDialog(
            state.isPermanentlyDenied,
            state.errorMessage.toString(),
          );
        }

        // Image selection error
        if (state is ProfileImageErrorState) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage!),
              backgroundColor: AppColors.appRedColor,
            ),
          );
        }

        // Gallery selection error
        if (state is GalleryPhotoErrorState) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage!),
              backgroundColor: AppColors.appRedColor,
              duration: const Duration(seconds: 3),
            ),
          );
        }

        // Permission denied for gallery
        if (state is GalleryPhotoPermissionDeniedState) {
          _showPermissionDialog(
            state.isPermanentlyDenied,
            state.errorMessage.toString(),
          );
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
                    AppColors.secondary,
                  ],
                  stops: [0.0, 0.1, 0.55, 1.0],
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
                              isEditMode: true,
                              controller: _venueNameController,
                              hintText: 'Venue Name',
                              textFieldAnnotationText: 'Venue Name',
                              onChanged: (value) {
                                context.read<ProfileBloc>().add(
                                  UpdateTextField(
                                    (state) => state.copyWith(venueName: value),
                                  ),
                                );
                              },
                            ),
                            CustomTextField(
                              isEditMode: true,
                              height: 112,
                              hintText: 'Your Venue description here',
                              maxLines: 5,
                              controller: _venueDescriptionController,
                              textFieldAnnotationText:
                                  'Your Venue description here',
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
                              isEditMode: true,
                              readOnly: true,
                              controller: _emailController,
                              hintText: 'Email',
                              textFieldAnnotationText: 'Email',
                              onChanged: (value) {
                                context.read<ProfileBloc>().add(
                                  UpdateTextField(
                                    (state) => state.copyWith(email: value),
                                  ),
                                );
                              },
                            ),
                            CustomTextField(
                              isEditMode: true,
                              isPhoneNumber: true,
                              controller: _phoneController,
                              hintText: 'Phone',
                              textFieldAnnotationText: 'Phone',
                              errorText:
                                  !_isValidPhoneNumber(
                                        _phoneController.text.trim(),
                                      )
                                      ? "Please enter a valid phone number"
                                      : null,
                              onChanged: (value) {
                                context.read<ProfileBloc>().add(
                                  UpdateTextField(
                                    (state) => state.copyWith(phone: value),
                                  ),
                                );
                              },
                            ),

                            /*Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 7,
                                horizontal: 0,
                              ),
                              child: BlocBuilder<ProfileBloc, ProfileState>(
                                buildWhen: (previous, current) {
                                  return previous.countries !=
                                          current.countries ||
                                      previous.isLoadingCountries !=
                                          current.isLoadingCountries ||
                                      previous.countryId != current.countryId ||
                                      previous.countryError !=
                                          current.countryError ||
                                      previous.countryName !=
                                          current.countryName;
                                },
                                builder: (context, state) {
                                  if (state.isLoadingCountries) {
                                    return Container(
                                      height: 70,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(
                                          color: Colors.grey,
                                          width: 1.2,
                                        ),
                                      ),
                                      child: const Center(
                                        child: CircularProgressIndicator(
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                AppColors.primary,
                                              ),
                                        ),
                                      ),
                                    );
                                  }

                                  if (state.countryError != null) {
                                    return Container(
                                      height: 70,
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(
                                          color: AppColors.appRedColor,
                                          width: 1.2,
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          const Icon(
                                            Icons.error_outline,
                                            color: AppColors.appRedColor,
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              'Error: ${state.countryError}',
                                              style: const TextStyle(
                                                color: AppColors.appRedColor,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }

                                  // ✅ Find currently selected country from the list
                                  final selectedCountry = state.countries
                                      .firstWhere(
                                        (c) =>
                                            c.id.toString() == state.countryId,
                                        orElse:
                                            () => Country(
                                              id:
                                                  int.tryParse(
                                                    state.countryId.isNotEmpty
                                                        ? state.countryId
                                                        : '0',
                                                  ) ??
                                                  0,
                                              name:
                                                  state.countryName.isNotEmpty
                                                      ? state.countryName
                                                      : '',
                                            ),
                                      );

                                  return Container(
                                    height: 70,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: Colors.grey,
                                        width: 1.2,
                                      ),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                    ),
                                    child: DropdownButtonHideUnderline(
                                      child: DropdownButton<Country>(
                                        value:
                                            state.countries
                                                    .where(
                                                      (c) =>
                                                          c.id.toString() ==
                                                          selectedCountry.id
                                                              .toString(),
                                                    )
                                                    .isNotEmpty
                                                ? selectedCountry
                                                : null,
                                        hint: Text(
                                          selectedCountry.name?.isNotEmpty ==
                                                  true
                                              ? selectedCountry.name!
                                              : "Select Country",
                                          style: TextStyle(
                                            color:
                                                selectedCountry
                                                            .name
                                                            ?.isNotEmpty ==
                                                        true
                                                    ? Colors.black
                                                    : Colors.grey.shade600,
                                            fontSize: 16,
                                          ),
                                        ),
                                        icon: const Icon(
                                          Icons.arrow_drop_down,
                                          color: Colors.grey,
                                        ),
                                        isExpanded: true,
                                        items:
                                            state.countries.map((country) {
                                              return DropdownMenuItem<Country>(
                                                value: country,
                                                child: Text(
                                                  country.name ?? '',
                                                  style: const TextStyle(
                                                    color: Colors.black,
                                                    fontSize: 16,
                                                  ),
                                                ),
                                              );
                                            }).toList(),
                                        onChanged: (selected) {
                                          if (selected != null) {
                                            // ✅ Update text controller for form detection
                                            _countryController.text =
                                                selectedCountry.name ?? '';

                                            // ✅ Update Bloc state
                                            context.read<ProfileBloc>().add(
                                              SelectCountryEvent(
                                                countryId:
                                                    selectedCountry.id
                                                        .toString(),
                                                countryName:
                                                    selectedCountry.name ?? '',
                                              ),
                                            );
                                          }
                                        },
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),*/
                            CustomTextField(
                              isProfile: true,
                              isEditMode: true,
                              readOnly: true,
                              controller: _countryController,
                              hintText: 'Country',
                              textFieldAnnotationText: 'Country',
                              onChanged: (value) {
                                context.read<ProfileBloc>().add(
                                  UpdateTextField(
                                    (state) => state.copyWith(country: value),
                                  ),
                                );
                              },
                            ),
                            CustomTextField(
                              isEditMode: true,
                              controller: _addressController,
                              hintText: 'Street Address',
                              textFieldAnnotationText: 'Street Address',
                              onChanged: (value) {
                                context.read<ProfileBloc>().add(
                                  UpdateTextField(
                                    (state) => state.copyWith(address: value),
                                  ),
                                );
                              },
                            ),
                            CustomTextField(
                              isEditMode: true,
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
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(left: 5.0),
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
                                  BlocBuilder<ProfileBloc, ProfileState>(
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
                                              padding: const EdgeInsets.only(
                                                bottom: 8.0,
                                              ),
                                              child: Builder(
                                                builder: (innerContext) {
                                                  final openingHourData =
                                                      currentState
                                                          .openingHours[day] ??
                                                      ProfileOpeningHour(
                                                        isEnabled: false,
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
                                                  return ProfileOpeningHoursWidget(
                                                    key: ValueKey(
                                                      '${day}_${openingHourData.isEnabled}_${openingHourData.from}_${openingHourData.to}_${openingHourData.id}',
                                                    ),
                                                    day: day,
                                                    data: openingHourData,
                                                    onChanged: (updatedHour) {
                                                      innerContext
                                                          .read<ProfileBloc>()
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
                            Gap(10.h),
                            EditGalleryPhotosWidget(
                              photoUrls: state.gallery ?? [],
                              stagedPhotoFiles: state.galleryPhotoFiles ?? [],
                              onUploadGallery: () {
                                context.read<ProfileBloc>().add(
                                  PickGalleryImagesFromGalleryEvent(),
                                );
                              },
                              onTakePicture: () {
                                context.read<ProfileBloc>().add(
                                  PickGalleryImagesFromCameraEvent(),
                                );
                              },
                              onDelete: (int index, bool isNetworkImage) {
                                final bloc = context.read<ProfileBloc>();
                                final galleryList = List<String>.from(
                                  state.gallery ?? [],
                                );
                                final galleryIds = List<String>.from(
                                  state.galleryIds ?? [],
                                );
                                final localList = List<File>.from(
                                  state.galleryPhotoFiles ?? [],
                                );

                                if (isNetworkImage &&
                                    index < galleryList.length) {
                                  // Server photo deletion - show confirmation dialog
                                  showDialog(
                                    context: context,
                                    builder:
                                        (dialogContext) => AlertDialog(
                                          title: Text(
                                            'Delete Photo?',
                                            style: Theme.of(
                                              context,
                                            ).textTheme.bodyLarge!.copyWith(
                                              color: AppColors.primary,
                                              fontWeight: FontWeight.w600,
                                              fontSize: 16.sp,
                                            ),
                                          ),
                                          content: Text(
                                            'Are you sure you want to delete this photo from your gallery? This action cannot be undone.',
                                            style: Theme.of(
                                              context,
                                            ).textTheme.bodySmall!.copyWith(
                                              color: AppColors.textPrimaryGrey,
                                              fontSize: 14.sp,
                                            ),
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed:
                                                  () => Navigator.pop(
                                                    dialogContext,
                                                  ),
                                              child: Text(
                                                'Cancel',
                                                style: Theme.of(
                                                  context,
                                                ).textTheme.bodySmall!.copyWith(
                                                  color: AppColors.shadowColor,
                                                  fontWeight: FontWeight.w500,
                                                  fontSize: 14.sp,
                                                ),
                                              ),
                                            ),
                                            ElevatedButton(
                                              onPressed: () {
                                                Navigator.pop(dialogContext);

                                                // Get photo ID and dispatch delete event
                                                if (index < galleryIds.length) {
                                                  final photoId =
                                                      galleryIds[index];
                                                  print(
                                                    "Deleting photo with ID: $photoId at index: $index",
                                                  );

                                                  bloc.add(
                                                    DeleteGalleryPhotoEvent(
                                                      photoId: photoId,
                                                      index: index,
                                                      deleteGalleryImageRequest:
                                                          DeleteGalleryImageRequest(
                                                            galleryId:
                                                                int.parse(
                                                                  photoId,
                                                                ),
                                                          ),
                                                    ),
                                                  );
                                                } else {
                                                  Fluttertoast.showToast(
                                                    msg:
                                                        "Error: Invalid photo ID",
                                                    backgroundColor:
                                                        AppColors.appRedColor,
                                                    textColor:
                                                        AppColors
                                                            .primaryWhiteColor,
                                                  );
                                                }
                                              },
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor:
                                                    AppColors.appRedColor,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                              ),
                                              child: Text(
                                                'Delete',
                                                style: Theme.of(
                                                  context,
                                                ).textTheme.bodySmall!.copyWith(
                                                  color:
                                                      AppColors
                                                          .primaryWhiteColor,
                                                  fontWeight: FontWeight.w500,
                                                  fontSize: 14.sp,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                  );
                                } else {
                                  // Local photo deletion
                                  final int localIndex =
                                      index - (state.gallery?.length ?? 0);
                                  if (localIndex >= 0 &&
                                      localIndex <
                                          (state.galleryPhotoFiles?.length ??
                                              0)) {
                                    // 💡 FIX: Dispatch the new event for local deletion
                                    context.read<ProfileBloc>().add(
                                      DeleteLocalGalleryPhotoEvent(
                                        index: localIndex,
                                      ),
                                    );
                                  } else {
                                    print(
                                      "Error: Invalid local photo index: $localIndex",
                                    );
                                    Fluttertoast.showToast(
                                      msg: "Error: Invalid photo index",
                                      backgroundColor: AppColors.appRedColor,
                                      textColor: AppColors.primaryWhiteColor,
                                      fontSize: 14.sp,
                                    );
                                  }
                                }
                              },
                            ),
                            Gap(30.h),
                            InkWell(
                              onTap: () {
                                _onSavePressed(context);
                              },
                              child: ElevatedButtonWidget(
                                height: 70.h,
                                width: MediaQuery.of(context).size.width,
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

  void _onSavePressed(BuildContext context) {
    final bloc = context.read<ProfileBloc>();
    final state = bloc.state;

    // Debug: Print current and initial values for troubleshooting
    debugPrint('=== Save Changes Debug ===');
    debugPrint('Text changed: ${_isTextDataChanged()}');
    debugPrint('Venue types changed: ${_isVenueTypesChanged(state)}');
    debugPrint('Opening hours changed: ${_isOpeningHoursChanged(state)}');
    debugPrint('Profile image changed: ${state.profileImageFile != null}');
    debugPrint('Gallery changed: ${state.galleryPhotoFiles.isNotEmpty}');
    debugPrint('Initial venue types: $_initialSelectedVenueTypeIds');
    debugPrint('Current venue types: ${state.selectedVenueTypeIds}');
    debugPrint(
      'Initial opening hours keys: ${_initialOpeningHours.keys.toList()}',
    );
    debugPrint(
      'Current opening hours keys: ${state.openingHours.keys.toList()}',
    );

    // Detect which sections were changed
    final bool textChanged = _isTextDataChanged();
    final bool venueTypesChanged = _isVenueTypesChanged(state);
    final bool openingHoursChanged = _isOpeningHoursChanged(state);
    final bool profileImageChanged = state.profileImageFile != null;
    final bool galleryChanged = state.galleryPhotoFiles.isNotEmpty;

    // Combined check for all data changes
    final bool anyDataChanged =
        textChanged || venueTypesChanged || openingHoursChanged;

    // If no changes, show info message and exit
    if (!anyDataChanged && !profileImageChanged && !galleryChanged) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No changes detected to save.'),
          backgroundColor: Colors.blueAccent,
        ),
      );
      return;
    }

    final Map<String, dynamic> workingDaysPayload = {};

    for (final entry in state.openingHours.entries) {
      final shortDayKey = entry.key; // 'mon', 'tue', etc.
      final hour = entry.value; // ProfileOpeningHour

      // Create the inner object structure for each day
      workingDaysPayload[shortDayKey] = {
        // Include ID
        'id': hour.id,
        'is_open': hour.isEnabled,
        // Ensure time is in HH:MM:SS format
        'open':
            hour.isEnabled
                ? "${hour.from.hour.toString().padLeft(2, '0')}:${hour.from.minute.toString().padLeft(2, '0')}:00"
                : '00:00:00',
        'close':
            hour.isEnabled
                ? "${hour.to.hour.toString().padLeft(2, '0')}:${hour.to.minute.toString().padLeft(2, '0')}:00"
                : '00:00:00',
      };
    }

    // Build the update request with the latest text + hours data

    final updateRequest = ProfileUpdateRequest(
      name: _venueNameController.text.trim(),
      venueDescription: _venueDescriptionController.text.trim(),
      email: _emailController.text.trim(),
      phone: _phoneController.text.trim(),
      address: _addressController.text.trim(),
      country: state.countryId.isNotEmpty ? state.countryId : state.country,
      postcode: _postalCodeController.text.trim(),
      accommodations:
          state.selectedVenueTypeIds.map((id) => id.toString()).toList(),
      workingDays: workingDaysPayload,
    );

    // Dispatch one save event — bloc will decide what to call
    bloc.add(
      SaveProfileChangesEvent(
        updateRequest: updateRequest,
        isTextDataChanged: anyDataChanged,
        isGalleryChanged: galleryChanged,
        isProfileImageChanged: profileImageChanged,
      ),
    );
  }

  String _formatTimeOfDay(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute:00';
  }

  Widget _buildSliverAppBar() {
    final isTabletOrLarger = ResponsiveBreakpoints.of(
      context,
    ).largerThan(MOBILE);
    final state = context.read<ProfileBloc>().state;
    final subTitle =
        state.profileEditViewResponse?.data?.cafeSince?.toString() ?? "";
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
              height: isTabletOrLarger ? 560.h / 1.8.h : 380.h / 1.8.h,
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
                    Gap(60.h),
                    Text(
                      state.venueName,
                      style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                        color: AppColors.primaryWhiteColor,
                        fontSize: 22.sp,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      subTitle,
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
              buildWhen: (previous, current) {
                final prevLocal = previous.profileImageFile?.path;
                final currLocal = current.profileImageFile?.path;

                final prevUrl = previous.profileEditViewResponse?.data?.photo;
                final currUrl = current.profileEditViewResponse?.data?.photo;

                return prevLocal != currLocal || prevUrl != currUrl;
              },
              builder: (context, state) {
                final localImage = state.profileImageFile;
                // final remoteImageUrl =
                //     state.profileEditViewResponse?.data?.photo;
                String? remoteImageUrl =
                    state.profileEditViewResponse?.data?.photo;

                // If you recently uploaded a new image

                if (remoteImageUrl != null &&
                    remoteImageUrl.isNotEmpty &&
                    (state.imageWasJustUploaded ?? false)) {
                  remoteImageUrl =
                      '$remoteImageUrl?cb=${DateTime.now().millisecondsSinceEpoch}';
                }
                // Choose which image to display
                Widget imageWidget;

                if (localImage != null) {
                  //Show newly picked local image
                  imageWidget = Image.file(
                    localImage,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                  );
                } else if (remoteImageUrl != null &&
                    remoteImageUrl.isNotEmpty) {
                  //Show image from API with shimmer + fade
                  imageWidget = CachedNetworkImage(
                    key: ValueKey(remoteImageUrl),
                    imageUrl: remoteImageUrl,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,

                    // 🔑 FIX: This Shimmer runs when the image is actively downloading/loading.
                    placeholder:
                        (context, url) => Shimmer.fromColors(
                          baseColor: const Color(0xFF003E69),
                          highlightColor: const Color(0xFF0067AF),
                          child: Container(
                            color: Colors.white,
                            width: double.infinity,
                            height: double.infinity,
                          ),
                        ),

                    // 🔑 FIX: This Image.asset runs only if the URL is invalid or download fails.
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

                    fadeInDuration: const Duration(milliseconds: 500),
                    fadeOutDuration: const Duration(milliseconds: 300),
                    fadeInCurve: Curves.easeInOut,
                  );
                } else {
                  //Placeholder if neither exists
                  imageWidget = Container(
                    color: AppColors.secondary,
                    child: const Icon(
                      Icons.person,
                      size: 60,
                      color: Colors.white,
                    ),
                  );
                }
                // Your same positioned structure preserved
                return Positioned(
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
                            child: ClipOval(child: imageWidget),
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
                                  PickProfileImageFromGalleryEvent(),
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
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 0),
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
                _onSavePressed(context);
                // _submitProfile(context, context.read<ProfileBloc>().state);
              },
              icon: SvgPicture.asset('assets/svg/save-form.svg'),
              label: Text(
                "SAVE",
                style: GoogleFonts.roboto(
                  color: AppColors.primary,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 10.h, vertical: 2.h),
                foregroundColor: AppColors.primaryWhiteColor,
                side: const BorderSide(color: AppColors.primaryWhiteColor),
                fixedSize: Size(85.w, 26.h),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
