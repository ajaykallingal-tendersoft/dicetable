import 'dart:io';

import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:soloseaters/src/common/custom_text_field.dart';
import 'package:soloseaters/src/common/elevated_button_widget.dart';
import 'package:soloseaters/src/common/login_or_signup_prompt.dart';
import 'package:soloseaters/src/constants/app_colors.dart';
import 'package:soloseaters/src/model/cafe_owner/auth/signUp/apple_sign-up_request.dart';
import 'package:soloseaters/src/model/cafe_owner/auth/signUp/google_sign-up_request.dart';
import 'package:soloseaters/src/model/cafe_owner/auth/signUp/sign_up_request.dart';
import 'package:soloseaters/src/resources/api_providers/auth/auth_data_provider.dart';
import 'package:soloseaters/src/ui/cafe_owner/authentication/sign_up/sign_up_screen_argument.dart';
import 'package:soloseaters/src/ui/cafe_owner/authentication/sign_up/widget/image_upload_widget.dart';
import 'package:soloseaters/src/ui/cafe_owner/authentication/sign_up/widget/multiple_image_upload_widget.dart';
import 'package:soloseaters/src/ui/cafe_owner/authentication/sign_up/widget/opening_hours_widget.dart';
import 'package:soloseaters/src/ui/cafe_owner/authentication/sign_up/widget/venue_type_checkboxes.dart';
import 'package:soloseaters/src/ui/verification/verify_screen_argument.dart';
import 'package:soloseaters/src/utils/data/object_factory.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'bloc/sign_up/sign_up_bloc.dart';

class SignUpScreen extends StatefulWidget {
  final SignUpScreenArgument signUpScreenArgument;

  const SignUpScreen({super.key, required this.signUpScreenArgument});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  late final TextEditingController _venueNameController;
  late final TextEditingController _venueDescriptionController;
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;
  late final TextEditingController _confirmPasswordController;
  late final TextEditingController _phoneController;
  late final TextEditingController _addressController;
  late final TextEditingController _postalCodeController;
  // late final TextEditingController _countryController;
  late final TextEditingController _regionController;
  // List<String> _countryList = [];
  late final bool isGoogleSignUp;
  late final bool isAppleSignUp;
  bool showValidationErrors = false;
  String? appleMail;
  String? selectedCountry;
  @override
  void initState() {
    super.initState();
    isGoogleSignUp = widget.signUpScreenArgument.isGoggleSignUp ?? false;
    isAppleSignUp = widget.signUpScreenArgument.isAppleSignUp ?? false;
    context.read<SignUpBloc>().add(
      SetSignUpType(
        isGoogleSignUp: isGoogleSignUp,
        isAppleSignUp: isAppleSignUp,
      ),
    );
    // _countryList = [
    //   'India',
    //   'United Kingdom',
    //   'Germany',
    //   'France',
    //   'United States',
    // ];
    context.read<SignUpBloc>().add(LoadVenueTypes());
    context.read<SignUpBloc>().add(LoadCountries());
    context.read<SignUpBloc>().add(ClearImageEvent());
    context.read<SignUpBloc>().add(const ResetFormEvent());

    final args = widget.signUpScreenArgument;
    final rawApple = args.email.trim() ?? '';
    final isGoogle = args.isGoggleSignUp ?? false;
    final isApple = args.isAppleSignUp ?? false;

    final appleMail = isAppleSignUp ? rawApple : '';

    _venueNameController = TextEditingController(
      text: isGoogle ? args.displayName : (isApple ? args.displayName : ''),
    );
    _emailController = TextEditingController(
      text: isGoogle ? args.email : appleMail,
    );
    print("AppleMail: $appleMail");
    print("AppleMail: ${ObjectFactory().prefs.getCafeUserMail()}");

    _venueDescriptionController = TextEditingController();
    _passwordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
    _addressController = TextEditingController();
    _postalCodeController = TextEditingController();
    // _countryController = TextEditingController();
    _regionController = TextEditingController();
    _phoneController = TextEditingController();

    // Real-time space removal for email field
    _emailController.addListener(() {
      final text = _emailController.text;
      final newText = text.replaceAll(' ', '');
      if (text != newText) {
        // Update text and cursor position
        final selection = _emailController.selection;
        _emailController.text = newText;
        _emailController.selection = TextSelection.fromPosition(
          TextPosition(offset: newText.length),
        );
        context.read<SignUpBloc>().add(
          UpdateTextField((state) => state.copyWith(email: newText)),
        );
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (isGoogleSignUp || isAppleSignUp) {
        context.read<SignUpBloc>().add(
          UpdateTextField(
            (state) => state.copyWith(
              venueName: _venueNameController.text,
              email: _emailController.text,
            ),
          ),
        );
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (isGoogleSignUp || isAppleSignUp) {
        context.read<SignUpBloc>().add(
          UpdateTextField(
            (state) => state.copyWith(
              venueName: _venueNameController.text,
              email: _emailController.text,
            ),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _emailController.removeListener(() {});
    _venueNameController.dispose();
    _venueDescriptionController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _postalCodeController.dispose();
    // _countryController.dispose();
    _regionController.dispose();
    super.dispose();
  }

  bool _isValidPhoneNumber(String number) {
    final phoneRegex = RegExp(r'^\d{8,10}$');
    return phoneRegex.hasMatch(number);
  }

  bool _validateForm(SignUpFormState state) {
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    final isPasswordRequired = !isGoogleSignUp && !isAppleSignUp;

    return state.venueName.trim().isNotEmpty &&
        state.venueDescription.trim().isNotEmpty &&
        state.email.trim().isNotEmpty &&
        emailRegex.hasMatch(state.email) &&
        // Only validate passwords if not social sign-up
        (!isPasswordRequired ||
            (state.password.trim().isNotEmpty &&
                state.confirmPassword.trim().isNotEmpty &&
                state.password == state.confirmPassword)) &&
        state.phone.trim().isNotEmpty &&
        _isValidPhoneNumber(state.phone.trim()) &&
        state.postalCode.trim().isNotEmpty &&
        state.address.trim().isNotEmpty &&
        state.venueTypes.any((venue) => venue.isSelected) &&
        state.openingHours.values.any((hour) => hour.isEnabled) &&
        state.image != null &&
        state.country.trim().isNotEmpty &&
        state.multipleImages != null ;
        
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        leading: BackButton(
          color: AppColors.primaryWhiteColor,
          onPressed: () {
            context.pop();
            EasyLoading.dismiss();
          },
        ),
        title: Text(
          'Create Account',
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: AppColors.primaryWhiteColor,
            fontSize: 20.sp,
          ),
        ),
      ),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Container(
          height: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
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
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            child: BlocConsumer<SignUpBloc, SignUpState>(
              listener: (context, state) {
                if (state is SignUpSuccessState ||
                    state is SignUpErrorState ||
                    state is GoogleSignUpSuccessState ||
                    state is GoogleSignUpErrorState ||
                    state is AppleSignUpSuccessState ||
                    state is AppleSignUpErrorState) {
                  EasyLoading.dismiss();
                }

                if (state is SignUpSuccessState) {
                  final response = state.signUpRequestResponse;
                  if (response.status == false) {
                    if (response.errors != null &&
                        response.errors!.isNotEmpty) {
                      final firstErrorField = response.errors!.keys.first;
                      final firstErrorMessage =
                          response.errors![firstErrorField]?.first;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            firstErrorMessage ?? 'Something went wrong',
                          ),
                          backgroundColor: AppColors.appRedColor,
                          duration: const Duration(seconds: 3),
                        ),
                      );
                    }
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(state.signUpRequestResponse.message!, style: TextStyle(color: AppColors.appGreenColor)),
        backgroundColor: AppColors.primaryWhiteColor,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
                    ObjectFactory().prefs.setAuthToken(
                      token: state.signUpRequestResponse.token,
                    );
                    ObjectFactory().prefs.setCafeUserName(
                      cafeUserName: _venueNameController.text,
                    );
                    ObjectFactory().prefs.setCafeId(
                      cafeId: state.signUpRequestResponse.cafeId,
                    );
                    ObjectFactory().prefs.setCafeUserId(
                      cafeUserId:
                          state.signUpRequestResponse.user!.id.toString(),
                    );
                    ObjectFactory().prefs.setIsGoogle(false);
                    ObjectFactory().prefs.setEmailVerified(false);

                    context.go(
                      '/verify',
                      extra: VerifyScreenArguments(
                        email: state.signUpRequestResponse.user!.email,
                        otp:
                            state.signUpRequestResponse.user!.emailOtp
                                .toString(),
                        type: "register",
                        from: 'venue_owner',
                      ),
                    );
                  }
                } else if (state is GoogleSignUpSuccessState) {
                  final response = state.googleSignUpRequestResponse;
                  if (response.status == false) {
                    if (response.errors != null &&
                        response.errors!.isNotEmpty) {
                      final firstErrorField = response.errors!.keys.first;
                      final firstErrorMessage =
                          response.errors![firstErrorField]?.first;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            firstErrorMessage ?? 'Something went wrong',
                          ),
                          backgroundColor: AppColors.appRedColor,
                          duration: const Duration(seconds: 3),
                        ),
                      );
                    }
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(state.googleSignUpRequestResponse.message!, style: TextStyle(color: AppColors.appGreenColor)),
        backgroundColor: AppColors.primaryWhiteColor,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
                    ObjectFactory().prefs.setAuthToken(
                      token: state.googleSignUpRequestResponse.token,
                    );
                    ObjectFactory().prefs.setCafeUserName(
                      cafeUserName: _venueNameController.text,
                    );
                    ObjectFactory().prefs.setCafeId(
                      cafeId: state.googleSignUpRequestResponse.cafeId ?? '',
                    );
                    ObjectFactory().prefs.setCafeUserId(
                      cafeUserId:
                          state.googleSignUpRequestResponse.user!.id.toString(),
                    );
                    ObjectFactory().prefs.setIsGoogle(true);
                    ObjectFactory().prefs.setEmailVerified(true);
                    ObjectFactory().prefs.setIsLoggedIn(true);
                    context.go('/subscription_prompt');
                  }
                } else if (state is AppleSignUpSuccessState) {
                  final response = state.appleSignUpRequestResponse;
                  if (response.status == false) {
                    if (response.errors != null &&
                        response.errors!.isNotEmpty) {
                      final firstErrorField = response.errors!.keys.first;
                      final firstErrorMessage =
                          response.errors![firstErrorField]?.first;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            firstErrorMessage ?? 'Something went wrong',
                          ),
                          backgroundColor: AppColors.appRedColor,
                          duration: const Duration(seconds: 3),
                        ),
                      );
                    }
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(state.appleSignUpRequestResponse.message!, style: TextStyle(color: AppColors.appGreenColor)),
        backgroundColor: AppColors.primaryWhiteColor,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
                    ObjectFactory().prefs.setAuthToken(
                      token: state.appleSignUpRequestResponse.token,
                    );
                    ObjectFactory().prefs.setCafeUserName(
                      cafeUserName: _venueNameController.text,
                    );
                    ObjectFactory().prefs.setCafeId(
                      cafeId: state.appleSignUpRequestResponse.cafeId ?? '',
                    );
                    ObjectFactory().prefs.setCafeUserId(
                      cafeUserId:
                          state.appleSignUpRequestResponse.user!.id.toString(),
                    );
                    ObjectFactory().prefs.setIsApple(true);
                    ObjectFactory().prefs.setEmailVerified(true);
                    ObjectFactory().prefs.setIsLoggedIn(true);
                    context.go('/subscription_prompt');
                  }
                } else if (state is SignUpErrorState ||
                    state is GoogleSignUpErrorState ||
                    state is AppleSignUpErrorState) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        state is SignUpErrorState
                            ? state.errorMessage
                            : state is GoogleSignUpErrorState
                            ? state.errorMessage
                            : state is AppleSignUpErrorState
                            ? state.errorMessage
                            : "Something went wrong.",
                      ),
                      backgroundColor: AppColors.appRedColor,
                      duration: const Duration(seconds: 3),
                    ),
                  );
                }
              },
              builder: (context, state) {
                final isLoading =
                    state is SignUpLoadingState ||
                    state is GoogleSignUpLoadingState ||
                    state is AppleSignUpLoadingState;
                final formState = state is SignUpFormState ? state : null;

                return Column(
                  children: [
                    CustomTextField(
                      controller: _venueNameController,
                      readOnly: isGoogleSignUp,
                      hintText: 'Venue Name',
                      errorText:
                          showValidationErrors &&
                                  formState != null &&
                                  _venueNameController.text.isEmpty
                              ? 'Venue name is required'
                              : null,
                      onChanged: (value) {
                        context.read<SignUpBloc>().add(
                          UpdateTextField(
                            (state) => state.copyWith(venueName: value),
                          ),
                        );
                      },
                    ),
                    CustomTextField(
                      hintText: 'Your Venue description here',
                      maxLines: 5,
                      height: 116.h,
                      controller: _venueDescriptionController,
                      errorText:
                          showValidationErrors &&
                                  formState != null &&
                                  _venueDescriptionController.text.isEmpty
                              ? 'Venue description is required'
                              : null,
                      onChanged: (value) {
                        context.read<SignUpBloc>().add(
                          UpdateTextField(
                            (state) => state.copyWith(venueDescription: value),
                          ),
                        );
                      },
                    ),
                    CustomTextField(
                      controller: _emailController,
                      hintText: 'Email',
                      readOnly:
                          isGoogleSignUp ||
                          (isAppleSignUp && _emailController.text.isNotEmpty),

                      errorText:
                          showValidationErrors && formState != null
                              ? (_emailController.text.isEmpty
                                  ? 'Email is required'
                                  : !RegExp(
                                    r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                                  ).hasMatch(_emailController.text)
                                  ? 'Invalid email format'
                                  : null)
                              : null,
                      onChanged: (value) {
                        context.read<SignUpBloc>().add(
                          UpdateTextField(
                            (state) => state.copyWith(
                              email: value,
                            ), // Remove .trim() since listener ensures no spaces
                          ),
                        );
                      },
                    ),
                    (!isAppleSignUp && !isGoogleSignUp)
                        ? CustomTextField(
                          controller: _passwordController,
                          hintText: 'Password',
                          isPassword: true,
                          errorText:
                              showValidationErrors && formState != null
                                  ? (_passwordController.text.isEmpty
                                      ? 'Password is required'
                                      : _passwordController.text.length < 6
                                      ? 'Password must be at least 6 characters'
                                      : null)
                                  : null,
                          onChanged: (value) {
                            context.read<SignUpBloc>().add(
                              UpdateTextField(
                                (state) => state.copyWith(password: value),
                              ),
                            );
                          },
                        )
                        : SizedBox.shrink(),
                    (!isAppleSignUp && !isGoogleSignUp)
                        ? CustomTextField(
                          controller: _confirmPasswordController,
                          hintText: 'Confirm Password',
                          isPassword: true,
                          errorText:
                              showValidationErrors && formState != null
                                  ? (_confirmPasswordController.text.isEmpty
                                      ? 'Confirm password is required'
                                      : _confirmPasswordController.text !=
                                          _passwordController.text
                                      ? 'Passwords do not match'
                                      : null)
                                  : null,
                          onChanged: (value) {
                            context.read<SignUpBloc>().add(
                              UpdateTextField(
                                (state) =>
                                    state.copyWith(confirmPassword: value),
                              ),
                            );
                          },
                        )
                        : SizedBox.shrink(),
                    CustomTextField(
                      isPhoneNumber: true,
                      controller: _phoneController,
                      hintText: 'Phone',
                      errorText:
                          showValidationErrors &&
                                  formState != null &&
                                  _phoneController.text.isEmpty
                              ? 'Phone number is required'
                              : showValidationErrors &&
                                  formState != null &&
                                  !_isValidPhoneNumber(
                                    _phoneController.text.trim(),
                                  )
                              ? "Please enter a valid phone number"
                              : null,
                      onChanged: (value) {
                        context.read<SignUpBloc>().add(
                          UpdateTextField(
                            (state) => state.copyWith(phone: value),
                          ),
                        );
                      },
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 7,
                        horizontal: 0,
                      ),
                      child: BlocBuilder<SignUpBloc, SignUpState>(
                        builder: (context, state) {
                          if (state is SignUpFormState) {
                            if (state.isLoadingCountries) {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            }

                            if (state.countryError != null) {
                              return Text(
                                'Error: ${state.countryError}',
                                style: const TextStyle(color: Colors.red),
                              );
                            }

                            final showError =
                                showValidationErrors &&
                                state.country.trim().isEmpty;

                            return Stack(
                              alignment: Alignment.centerLeft,
                              children: [
                                // The Dropdown styled as your TextField
                                Container(
                                  height: 70,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color:
                                          showError
                                              ? const Color(0xFFD32F2F)
                                              : Colors.grey,
                                      width: 1.2,
                                    ),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                  ),
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButton<String>(
                                      value:
                                          state.country.isNotEmpty
                                              ? state.country
                                              : null,
                                      hint: Text(
                                        "Select Country",
                                        style: Theme.of(
                                          context,
                                        ).textTheme.bodyMedium!.copyWith(
                                          color: AppColors.textPrimaryGrey,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 14,
                                        ),
                                      ),
                                      icon: const Icon(
                                        Icons.arrow_drop_down,
                                        color: Colors.grey,
                                      ),
                                      isExpanded: true,
                                      items:
                                          state.countries.map((country) {
                                            return DropdownMenuItem<String>(
                                              value: country.id.toString(),
                                              child: Text(
                                                country.name ?? '',
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodyMedium!
                                                    .copyWith(
                                                      color:
                                                          AppColors
                                                              .textPrimaryGrey,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      fontSize: 14,
                                                    ),
                                              ),
                                            );
                                          }).toList(),
                                      onChanged: (selectedId) {
                                        if (selectedId != null) {
                                          final selectedCountry = state
                                              .countries
                                              .firstWhere(
                                                (c) =>
                                                    c.id.toString() ==
                                                    selectedId,
                                              );
                                          context.read<SignUpBloc>().add(
                                            SelectCountryEvent(
                                              countryId:
                                                  selectedCountry.id.toString(),
                                              countryName:
                                                  selectedCountry.name ?? '',
                                            ),
                                          );
                                        }
                                      },
                                    ),
                                  ),
                                ),

                                // The inline error text (positioned inside field)
                                if (showError)
                                  Positioned(
                                    left: 20,
                                    bottom: 6,
                                    child: Text(
                                      "Please select a country",
                                      style: const TextStyle(
                                        color: Color(0xFFD32F2F),
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                              ],
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                    ),

                    CustomTextField(
                      controller: _addressController,
                      hintText: 'Street Address And City',
                      errorText:
                          showValidationErrors &&
                                  formState != null &&
                                  _addressController.text.isEmpty
                              ? 'Address is required'
                              : null,
                      onChanged: (value) {
                        context.read<SignUpBloc>().add(
                          UpdateTextField(
                            (state) => state.copyWith(address: value),
                          ),
                        );
                      },
                    ),
                    CustomTextField(
                      controller: _postalCodeController,
                      hintText: 'Postal Code',
                      errorText:
                          showValidationErrors &&
                                  formState != null &&
                                  _postalCodeController.text.isEmpty
                              ? 'Postal code is required'
                              : null,
                      onChanged: (value) {
                        context.read<SignUpBloc>().add(
                          UpdateTextField(
                            (state) => state.copyWith(postalCode: value),
                          ),
                        );
                      },
                    ),
                    const Gap(10),
                    BlocBuilder<SignUpBloc, SignUpState>(
                      builder: (context, state) {
                        final venueTypes =
                            state is SignUpFormState ? state.venueTypes : [];
                        final hasSelectedVenue = venueTypes.any(
                          (venue) => venue.isSelected,
                        );
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            VenueTypeCheckboxes(
                              state: SignUpFormState(),
                              hasSelectedVenue: !hasSelectedVenue,
                              showValidationErrors: showValidationErrors,
                            ),
                          ],
                        );
                      },
                    ),
                    const Gap(17),
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
                                fontSize: 14.sp,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                          const Gap(10),
                          BlocBuilder<SignUpBloc, SignUpState>(
                            builder: (context, state) {
                              final openingHours =
                                  state is SignUpFormState
                                      ? state.openingHours
                                      : {};
                              final hasEnabledDay = openingHours.values.any(
                                (hour) => hour.isEnabled,
                              );
                              return Column(
                                children: [
                                  for (final day in [
                                    'Mon',
                                    'Tue',
                                    'Wed',
                                    'Thu',
                                    'Fri',
                                    'Sat',
                                    'Sun',
                                  ])
                                    OpeningHoursWidget(
                                      day: day,
                                      data:
                                          openingHours[day] ??
                                          const OpeningHour(
                                            isEnabled: false,
                                            from: TimeOfDay(
                                              hour: 10,
                                              minute: 0,
                                            ),
                                            to: TimeOfDay(hour: 12, minute: 0),
                                          ),
                                      onChanged: (updatedHour) {
                                        context.read<SignUpBloc>().add(
                                          UpdateOpeningHour(
                                            day: day,
                                            hour: updatedHour,
                                          ),
                                        );
                                      },
                                    ),
                                  if (showValidationErrors &&
                                      !hasEnabledDay &&
                                      state is SignUpFormState)
                                    Padding(
                                      padding: const EdgeInsets.only(
                                        left: 16.0,
                                        top: 4.0,
                                      ),
                                      child: Align(
                                        alignment: Alignment.centerLeft,
                                        child: Text(
                                          'Please enable at least one day',
                                          style: TextStyle(
                                            color: AppColors.appRedColor,
                                            fontSize: 14.sp,
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    const Gap(17),
                    ImageUploadWidget(
                      showValidationErrors: showValidationErrors,
                      state: SignUpFormState(),
                      // SignUpFormState(),
                    ),
                    const Gap(30),

                    // Column(
                    //   crossAxisAlignment: CrossAxisAlignment.start,
                    //   children: [
                    //     MultipleImageUploadWidget(
                    //       showValidationErrors: showValidationErrors,
                    //       state: SignUpFormState(),
                    //     ),
                    //     if (showValidationErrors &&
                    //         formState != null &&
                    //         formState.multipleImages.isEmpty)
                    //       Padding(
                    //         padding: const EdgeInsets.only(
                    //           left: 16.0,
                    //           top: 4.0,
                    //         ),
                    //         child: Text(
                    //           'Please upload at least one gallery image',
                    //           style: TextStyle(
                    //             color: AppColors.appRedColor,
                    //             fontSize: 14.sp,
                    //           ),
                    //         ),
                    //       ),
                    //   ],
                    // ),
                    MultipleImageUploadWidget(
                      showValidationErrors: showValidationErrors,
                      state: SignUpFormState(),
                      // SignUpFormState(),
                    ),
                    const Gap(30),
                    BlocBuilder<SignUpBloc, SignUpState>(
                      builder: (context, state) {
                        if (isLoading) {
                          EasyLoading.show();
                          return SizedBox.shrink(); // Or a placeholder widget
                        } else if (state is SignUpFormState) {
                          final isFormValid = _validateForm(state);

                          return InkWell(
                            splashColor:
                                isFormValid
                                    ? AppColors.secondary
                                    : Colors.transparent,
                            splashFactory:
                                isFormValid
                                    ? InkRipple.splashFactory
                                    : NoSplash.splashFactory,
                            onTap: () {
                              // Always show validation errors when button is tapped
                              setState(() {
                                showValidationErrors = true;
                              });

                              // Only proceed with API call if form is valid
                              if (isFormValid) {
                                String formatTime(TimeOfDay time) {
                                  final hours = time.hour.toString().padLeft(
                                    2,
                                    '0',
                                  );
                                  final minutes = time.minute
                                      .toString()
                                      .padLeft(2, '0');
                                  return '$hours:$minutes:00';
                                }

                                final selectedVenueTypeIds =
                                    state.venueTypes
                                        .where((model) => model.isSelected)
                                        .map((model) => model.id.toString())
                                        .toList();

                                final workingDaysMap =
                                    <String, Map<String, dynamic>>{};
                                state.openingHours.forEach((day, value) {
                                  final dayLower = day.toLowerCase();
                                  workingDaysMap[dayLower] = {
                                    "is_open": value.isEnabled,
                                    "open":
                                        value.isEnabled
                                            ? formatTime(value.from)
                                            : "00:00:00",
                                    "close":
                                        value.isEnabled
                                            ? formatTime(value.to)
                                            : "00:00:00",
                                  };
                                });

                                if (isGoogleSignUp) {
                                  print("Image path: ${state.image?.path}");
                                  print(
                                    "Multiple images count: ${state.multipleImages.length}",
                                  );
                                  final googleSignUpRequest = GoogleSignUpRequest(
                                    name: _venueNameController.text,
                                    venueDescription: state.venueDescription,
                                    email: _emailController.text.trim(),
                                    // password: state.password,
                                    // passwordConfirmation:
                                    // state.confirmPassword,
                                    country:
                                        state
                                            .country, // Already contains the country ID
                                    address: state.address,
                                    loginType: 3,
                                    phone: state.phone,
                                    postcode: state.postalCode,
                                    accommodations: selectedVenueTypeIds,
                                    workingDays: workingDaysMap,
                                    blob: state.base64Image,
                                    fcmToken:
                                        ObjectFactory().prefs.getFcmToken(),
                                    image:
                                        state.image != null
                                            ? File(state.image!.path)
                                            : null,
                                    multipleImages:
                                        state.multipleImages
                                            .map((x) => File(x.path))
                                            .toList(),
                                  );

                                  context.read<SignUpBloc>().add(
                                    SubmitGoogleSignUp(
                                      googleSignUpRequest: googleSignUpRequest,
                                    ),
                                  );
                                } else if (isAppleSignUp) {
                                  final appleAuthID =
                                      ObjectFactory().prefs.getAppleAuthID();
                                  final appleSignUpRequest = AppleSignUpRequest(
                                    name: _venueNameController.text,
                                    venueDescription: state.venueDescription,
                                    email: _emailController.text.trim(),
                                    country: state.country,
                                    address: state.address,
                                    loginType: 3,
                                    phone: state.phone,
                                    postcode: state.postalCode,
                                    accommodations: selectedVenueTypeIds,
                                    workingDays: workingDaysMap,
                                    blob: state.base64Image,
                                    fcmToken:
                                        ObjectFactory().prefs.getFcmToken(),
                                    apple_id: appleAuthID,
                                    image:
                                        state.image != null
                                            ? File(state.image!.path)
                                            : null,
                                    multipleImages:
                                        state.multipleImages
                                            .map((x) => File(x.path))
                                            .toList(),
                                  );

                                  context.read<SignUpBloc>().add(
                                    SubmitAppleSignUp(
                                      appleSignUpRequest: appleSignUpRequest,
                                    ),
                                  );
                                } else {
                                  print("Image path: ${state.image?.path}");
                                  print(
                                    "Multiple images count: ${state.multipleImages.length}",
                                  ); // Regular sign up (not Google or Apple)
                                  final signUpRequest = SignUpRequest(
                                    name: state.venueName,
                                    venueDescription: state.venueDescription,
                                    email: state.email.trim(),
                                    password: state.password,
                                    passwordConfirmation: state.confirmPassword,
                                    country: state.country,
                                    address: state.address,
                                    loginType: 3,
                                    phone: state.phone,
                                    postcode: state.postalCode,
                                    accommodations: selectedVenueTypeIds,
                                    workingDays: workingDaysMap,
                                    fcmToken:
                                        ObjectFactory().prefs.getFcmToken(),
                                    image:
                                        state.image != null
                                            ? File(state.image!.path)
                                            : null,
                                    multipleImages:
                                        state.multipleImages
                                            .map((x) => File(x.path))
                                            .toList(),
                                  );
                                  context.read<SignUpBloc>().add(
                                    SubmitSignUp(signupRequest: signUpRequest),
                                  );
                                }
                              } else {
                                // Show error message only if form is invalid
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Please fill all required fields before submitting.',
                                    ),
                                    backgroundColor: AppColors.appRedColor,
                                    duration: Duration(seconds: 2),
                                  ),
                                );
                              }
                            },
                            child: ElevatedButtonWidget(
                              height: 70.h,
                              width: MediaQuery.of(context).size.width,
                              iconEnabled: false,
                              iconLabel: 'SIGN UP',
                              color: AppColors.primary,
                              textColor: AppColors.primaryWhiteColor,
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                    const Gap(20),
                    LoginOrSignupPrompt(
                      spanText: 'Already have an account',
                      promptText: 'Sign in now',
                      onSignInTap: () => context.go('/login'),
                    ),
                    const Gap(34),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
