import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:soloseaters/src/common/custom_text_field.dart';
import 'package:soloseaters/src/common/elevated_button_widget.dart';
import 'package:soloseaters/src/common/login_or_signup_prompt.dart';
import 'package:soloseaters/src/constants/app_colors.dart';
import 'package:soloseaters/src/model/cafe_owner/auth/signUp/apple_sign-up_request.dart';
import 'package:soloseaters/src/model/cafe_owner/auth/signUp/google_sign-up_request.dart';
import 'package:soloseaters/src/model/cafe_owner/auth/signUp/sign_up_request.dart';
import 'package:soloseaters/src/ui/cafe_owner/authentication/sign_up/sign_up_screen_argument.dart';
import 'package:soloseaters/src/ui/cafe_owner/authentication/sign_up/widget/image_upload_widget.dart';
import 'package:soloseaters/src/ui/cafe_owner/authentication/sign_up/widget/opening_hours_widget.dart';
import 'package:soloseaters/src/ui/cafe_owner/authentication/sign_up/widget/venue_type_checkboxes.dart';
import 'package:soloseaters/src/ui/verification/verify_screen_argument.dart';
import 'package:soloseaters/src/utils/data/object_factory.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
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
  late final TextEditingController _countryController;
  late final TextEditingController _regionController;
  late final bool isGoogleSignUp;
  late final bool isAppleSignUp;
  bool showValidationErrors = false;
  String? appleMail;
  @override
  void initState() {
    super.initState();
    context.read<SignUpBloc>().add(LoadVenueTypes());
    context.read<SignUpBloc>().add(ClearImageEvent());
    context.read<SignUpBloc>().add(const ResetFormEvent());

    isGoogleSignUp = widget.signUpScreenArgument.isGoggleSignUp ?? false;
    isAppleSignUp = widget.signUpScreenArgument.isAppleSignUp ?? false;
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
    _countryController = TextEditingController();
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
    _countryController.dispose();
    _regionController.dispose();
    super.dispose();
  }

  bool _isValidPhoneNumber(String number) {
    final phoneRegex = RegExp(r'^\d{8,10}$');
    return phoneRegex.hasMatch(number);
  }

  bool _validateForm(SignUpFormState state) {
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    final hasPasswords = !isAppleSignUp || !isGoogleSignUp;
    return state.venueName.trim().isNotEmpty &&
        state.venueDescription.trim().isNotEmpty &&
        state.email.trim().isNotEmpty &&
        emailRegex.hasMatch(state.email) &&
        (hasPasswords
            ? state.password.trim().isNotEmpty &&
                state.confirmPassword.trim().isNotEmpty &&
                state.password == state.confirmPassword
            : true) &&
        // state.password.trim().isNotEmpty &&
        // state.confirmPassword.trim().isNotEmpty &&
        state.password == state.confirmPassword &&
        state.phone.trim().isNotEmpty &&
        _isValidPhoneNumber(state.phone.trim()) &&
        state.postalCode.trim().isNotEmpty &&
        state.address.trim().isNotEmpty &&
        state.venueTypes.any((venue) => venue.isSelected) &&
        state.openingHours.values.any((hour) => hour.isEnabled) &&
        state.base64Image != null &&
        state.country.trim().isNotEmpty &&
        state.base64Image!.isNotEmpty;
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
                    Fluttertoast.showToast(
                      fontSize: 14.sp,
                      backgroundColor: AppColors.primaryWhiteColor,
                      textColor: AppColors.appGreenColor,
                      gravity: ToastGravity.BOTTOM,
                      msg: state.signUpRequestResponse.message!,
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
                    Fluttertoast.showToast(
                      fontSize: 14.sp,
                      backgroundColor: AppColors.primaryWhiteColor,
                      textColor: AppColors.appGreenColor,
                      gravity: ToastGravity.BOTTOM,
                      msg: state.googleSignUpRequestResponse.message!,
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
                    Fluttertoast.showToast(
                      fontSize: 14.sp,
                      backgroundColor: AppColors.primaryWhiteColor,
                      textColor: AppColors.appGreenColor,
                      gravity: ToastGravity.BOTTOM,
                      msg: state.appleSignUpRequestResponse.message!,
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
                    (!isAppleSignUp&& !isGoogleSignUp)
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
                    (!isAppleSignUp&&!isGoogleSignUp)
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
                    CustomTextField(
                      controller: _countryController,
                      hintText: 'Country',
                      errorText:
                          showValidationErrors &&
                                  formState != null &&
                                  _countryController.text.isEmpty
                              ? 'Country is required'
                              : null,
                      onChanged: (value) {
                        context.read<SignUpBloc>().add(
                          UpdateTextField(
                            (state) => state.copyWith(country: value),
                          ),
                        );
                      },
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
                    ),
                    const Gap(30),

                    BlocBuilder<SignUpBloc, SignUpState>(
                      builder: (context, state) {
                        if (isLoading) {
                          // EasyLoading.show();
                          return RefreshProgressIndicator(
                            color: AppColors.primaryWhiteColor,
                            backgroundColor: AppColors.primary,
                          );
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
                                  print("Name:${_venueNameController.text}");
                                  final googleSignUpRequest =
                                      GoogleSignUpRequest(
                                        name: _venueNameController.text,
                                        venueDescription:
                                            state.venueDescription,
                                        email: _emailController.text.trim(),
                                        // password: state.password,
                                        // passwordConfirmation:
                                            // state.confirmPassword,
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
                                      );

                                  context.read<SignUpBloc>().add(
                                    SubmitGoogleSignUp(
                                      googleSignUpRequest: googleSignUpRequest,
                                    ),
                                  );
                                } else if (isAppleSignUp) {
                                  print("IS_APPLE${isAppleSignUp}");
                                  print("Name: ${_venueNameController.text}.");
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
                                  );

                                  context.read<SignUpBloc>().add(
                                    SubmitAppleSignUp(
                                      appleSignUpRequest: appleSignUpRequest,
                                    ),
                                  );
                                } else {
                                  // Regular sign up (not Google or Apple)
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
                                    blob: state.base64Image,
                                    fcmToken:
                                        ObjectFactory().prefs.getFcmToken(),
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
