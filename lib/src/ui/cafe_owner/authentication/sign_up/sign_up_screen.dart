import 'package:dicetable/src/common/custom_text_field.dart';
import 'package:dicetable/src/common/elevated_button_widget.dart';
import 'package:dicetable/src/common/login_or_signup_prompt.dart';
import 'package:dicetable/src/common/modal_barrier_with_progress_indicator_widget.dart';
import 'package:dicetable/src/constants/app_colors.dart';
import 'package:dicetable/src/model/cafe_owner/auth/signUp/google_sign-up_request.dart';
import 'package:dicetable/src/model/cafe_owner/auth/signUp/sign_up_request.dart';
import 'package:dicetable/src/model/verification/otp_verify_request.dart';
import 'package:dicetable/src/resources/api_providers/auth/auth_data_provider.dart';
import 'package:dicetable/src/ui/cafe_owner/authentication/sign_up/sign_up_screen_argument.dart';
import 'package:dicetable/src/ui/cafe_owner/authentication/sign_up/widget/image_upload_widget.dart';
import 'package:dicetable/src/ui/cafe_owner/authentication/sign_up/widget/opening_hours_widget.dart';

import 'package:dicetable/src/ui/cafe_owner/authentication/sign_up/widget/venue_type_checkboxes.dart';
import 'package:dicetable/src/ui/verification/bloc/verification_bloc.dart';
import 'package:dicetable/src/ui/verification/verify_screen_argument.dart';
import 'package:dicetable/src/utils/data/object_factory.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
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

  @override
  void initState() {
    super.initState();
    isGoogleSignUp = widget.signUpScreenArgument.isGoggleSignUp;

    _venueNameController = TextEditingController(
      text: isGoogleSignUp ? ObjectFactory().prefs.getCafeUserName() : '',
    );

    _emailController = TextEditingController(
      text: isGoogleSignUp ? ObjectFactory().prefs.getCafeUserMail() : '',
    );
    _venueDescriptionController = TextEditingController();
    _passwordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
    _addressController = TextEditingController();
    _postalCodeController = TextEditingController();
    _countryController = TextEditingController();
    _regionController = TextEditingController();
    _phoneController = TextEditingController();

    context.read<SignUpBloc>().add(LoadVenueTypes());
  }

  @override
  void dispose() {
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

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        leading: const BackButton(color: AppColors.primaryWhiteColor),
        title: Text(
          'Create Account',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: AppColors.primaryWhiteColor,
          ),
        ),
      ),
      body: GestureDetector(
        onTap: () {
          FocusScopeNode currentFocus = FocusScope.of(context);
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
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 20,
            ),
            child: BlocConsumer<SignUpBloc, SignUpState>(
              builder: (context, state) {
                return Column(
                  children: [
                    CustomTextField(
                      controller: _venueNameController,
                      readOnly:
                      widget.signUpScreenArgument.isGoggleSignUp
                          ? true
                          : false,
                      hintText: 'Venue Name',
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
                      onChanged: (value) {
                        context.read<SignUpBloc>().add(
                          UpdateTextField(
                                (state) =>
                                state.copyWith(venueDescription: value),
                          ),
                        );
                      },
                    ),
                    CustomTextField(
                      controller: _emailController,
                      hintText: 'Email',
                      readOnly:
                      widget.signUpScreenArgument.isGoggleSignUp
                          ? true
                          : false,
                      onChanged: (value) {
                        context.read<SignUpBloc>().add(
                          UpdateTextField(
                                (state) => state.copyWith(email: value),
                          ),
                        );
                      },
                    ),
                    CustomTextField(
                      controller: _passwordController,
                      hintText: 'Password',
                      isPassword: true,
                      onChanged: (value) {
                        context.read<SignUpBloc>().add(
                          UpdateTextField(
                                (state) => state.copyWith(password: value),
                          ),
                        );
                      },
                    ),
                    CustomTextField(
                      controller: _confirmPasswordController,
                      hintText: 'Confirm Password',
                      isPassword: true,
                      onChanged: (value) {
                        context.read<SignUpBloc>().add(
                          UpdateTextField(
                                (state) =>
                                state.copyWith(confirmPassword: value),
                          ),
                        );
                      },
                    ),
                    CustomTextField(
                      controller: _phoneController,
                      hintText: 'Phone',
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
                      onChanged: (value) {
                        context.read<SignUpBloc>().add(
                          UpdateTextField(
                                (state) => state.copyWith(country: value),
                          ),
                        );
                      },
                    ),
                    CustomTextField(
                      controller: _regionController,
                      hintText: 'Region',
                      onChanged: (value) {
                        context.read<SignUpBloc>().add(
                          UpdateTextField(
                                (state) => state.copyWith(region: value),
                          ),
                        );
                      },
                    ),
                    CustomTextField(
                      controller: _addressController,
                      hintText: 'Street Address And City',
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
                      onChanged: (value) {
                        context.read<SignUpBloc>().add(
                          UpdateTextField(
                                (state) => state.copyWith(postalCode: value),
                          ),
                        );
                      },
                    ),
                    const Gap(10),
                    const VenueTypeCheckboxes(),
                    // Already updated separately
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
                                fontSize: 14,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                          const Gap(10),
                          for (final day in [
                            'Mon',
                            'Tues',
                            'Wed',
                            'Thu',
                            'Fri',
                            'Sat',
                            'Sun',
                          ])
                            OpeningHoursWidget(
                              day: day,
                              data:
                              (state is SignUpFormState)
                                  ? (state.openingHours[day] ??
                                  const OpeningHour(
                                    isEnabled: false,
                                    from: TimeOfDay(
                                      hour: 10,
                                      minute: 0,
                                    ),
                                    to: TimeOfDay(
                                      hour: 12,
                                      minute: 0,
                                    ),
                                  ))
                                  : const OpeningHour(
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
                                context.read<SignUpBloc>().add(
                                  UpdateOpeningHour(
                                    day: day,
                                    hour: updatedHour,
                                  ),
                                );
                              },
                            ),
                        ],
                      ),
                    ),
                    const Gap(17),
                    ImageUploadWidget(),
                    const Gap(30),
                    BlocBuilder<SignUpBloc, SignUpState>(
                      builder: (context, state) {
                        if (state is SignUpFormState) {
                          final formState = state;
                          return InkWell(
                            splashColor: AppColors.secondary,
                            splashFactory: InkRipple.splashFactory,
                            onTap: () {
                              String formatTime(TimeOfDay time) {
                                final hours = time.hour
                                    .toString()
                                    .padLeft(2, '0');
                                final minutes = time.minute
                                    .toString()
                                    .padLeft(2, '0');
                                return '$hours:$minutes';
                              }

                              final selectedVenueTypeIds = formState.venueTypes
                                  .where((model) => model.isSelected)
                                  .map((model) => model.id.toString())
                                  .toList();

                              final workingDaysMap =
                              <String, Map<String, dynamic>>{};
                              formState.openingHours.forEach((
                                  day,
                                  value,
                                  ) {
                                final dayLower = day.toLowerCase();
                                if (value.isEnabled) {
                                  workingDaysMap[dayLower] = {
                                    "is_open": true,
                                    "open": formatTime(value.from),
                                    "close": formatTime(value.to),
                                  };
                                } else {
                                  workingDaysMap[dayLower] = {
                                    "is_open": false,
                                    "open": "00:00",
                                    "close": "00:00",
                                  };
                                }
                              });
                              // if (formState.password !=
                              //     formState.confirmPassword) {
                              //   ScaffoldMessenger.of(context)
                              //       .showSnackBar(
                              //     const SnackBar(
                              //       content: Text(
                              //           'Passwords do not match'),
                              //       backgroundColor: AppColors
                              //           .appRedColor,
                              //     ),
                              //   );
                              //   return;
                              // }
                              // if (formState.email.isEmpty ||
                              //     formState.password.isEmpty) {
                              //   ScaffoldMessenger.of(context)
                              //       .showSnackBar(
                              //     const SnackBar(
                              //       content: Text(
                              //           'Please fill in all required fields'),
                              //       backgroundColor: AppColors
                              //           .appRedColor,
                              //     ),
                              //   );
                              //   return;
                              // }

                              if (isGoogleSignUp) {
                                final googleSignUpRequest =
                                GoogleSignUpRequest(
                                  name: _venueNameController.text,
                                  venueDescription:
                                  formState.venueDescription,
                                  email: _emailController.text,
                                  password: formState.password,
                                  passwordConfirmation:
                                  formState.confirmPassword,
                                  address: formState.address,
                                  country: formState.country,
                                  loginType: 3,
                                  phone: formState.phone,
                                  postcode: formState.postalCode,
                                  region: formState.region,
                                  accommodations:
                                  selectedVenueTypeIds,
                                  workingDays: workingDaysMap,
                                  blob:
                                  widget
                                      .signUpScreenArgument
                                      .imageBase64,
                                );

                                context.read<SignUpBloc>().add(
                                  SubmitGoogleSignUp(
                                    signupRequest: googleSignUpRequest,
                                  ),
                                );
                              } else {
                                final signUpRequest = SignUpRequest(
                                  name: formState.venueName,
                                  venueDescription:
                                  formState.venueDescription,
                                  email: formState.email,

                                  password: formState.password,
                                  passwordConfirmation:
                                  formState.confirmPassword,
                                  address: formState.address,
                                  country: formState.country,
                                  loginType: 3,
                                  phone: formState.phone,
                                  postcode: formState.postalCode,
                                  region: formState.region,
                                  accommodations: selectedVenueTypeIds,
                                  workingDays: workingDaysMap,
                                  blob: formState.base64Image,
                                );
                                context.read<SignUpBloc>().add(
                                  SubmitSignUp(
                                    signupRequest: signUpRequest,
                                  ),
                                );
                              }
                            },
                            child: ElevatedButtonWidget(
                              height: 70.h,
                              width: double.infinity,
                              iconEnabled: false,
                              iconLabel: 'SIGN UP',
                              color: AppColors.primary,
                              textColor: AppColors.primaryWhiteColor,
                            ),
                          );
                        } else if (state is SignUpLoadingState ||
                            state is GoogleSignUpLoadingState) {
                          return RefreshProgressIndicator(
                            color: AppColors.primaryWhiteColor,
                            backgroundColor: AppColors.primary,
                          );
                        } else {
                          return SizedBox.shrink();
                        }
                      },
                    ),
                    const Gap(20),
                    LoginOrSignupPrompt(
                      spanText: 'Already have an account',
                      promptText: 'Sign in now',
                      onSignInTap: () => context.go('/login'),
                    ),
                  ],
                );
              },
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
                    ObjectFactory().prefs.setCafeId(cafeId: state.signUpRequestResponse.cafeId);
                    ObjectFactory().prefs.setIsGoogle(false);
                    ObjectFactory().prefs.setEmailVerified(false);

                    context.go('/verify',extra: VerifyScreenArguments(
                      email: state.signUpRequestResponse.user!.email,
                      otp: state.signUpRequestResponse.user!.emailOtp.toString(),
                      type: "register",
                    ),);
                  }
                }
                if (state is GoogleSignUpSuccessState) {
                  final response = state.googleSignUpRequestResponse;
                  if (response.status == false) {
                    if (response.errors != null &&
                        response.errors!.isNotEmpty) {
                      final firstErrorField = response.errors!.keys.first;
                      final firstErrorMessage =
                          response.errors![firstErrorField]?.first;
                      Fluttertoast.showToast(
                        backgroundColor: AppColors.primaryWhiteColor,
                        textColor: AppColors.appGreenColor,
                        gravity: ToastGravity.BOTTOM,
                        msg: firstErrorMessage ?? "Something went wrong",
                      );
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
                    ObjectFactory().prefs.setCafeId(cafeId: state.googleSignUpRequestResponse.cafeId ?? '');
                    ObjectFactory().prefs.setIsGoogle(true);
                    ObjectFactory().prefs.setEmailVerified(true);
                    ObjectFactory().prefs.setIsLoggedIn(true);
                    context.go('/subscription_prompt');
                  }
                }
                if (state is GoogleSignUpErrorState) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.errorMessage),
                      backgroundColor: AppColors.appGreenColor,
                      duration: Duration(seconds: 2),
                    ),
                  );
                }
                if (state is SignUpErrorState) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.errorMessage),
                      backgroundColor: AppColors.appGreenColor,
                      duration: Duration(seconds: 2),
                    ),
                  );
                }
              },
            ),
          ),
        ),
      ),
    );
  }
}
