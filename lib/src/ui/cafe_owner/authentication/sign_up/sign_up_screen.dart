import 'package:dicetable/src/common/custom_text_field.dart';
import 'package:dicetable/src/common/elevated_button_widget.dart';
import 'package:dicetable/src/common/login_or_signup_prompt.dart';
import 'package:dicetable/src/common/modal_barrier_with_progress_indicator_widget.dart';
import 'package:dicetable/src/constants/app_colors.dart';
import 'package:dicetable/src/model/cafe_owner/auth/signUp/sign_up_request.dart';
import 'package:dicetable/src/resources/api_providers/auth/auth_data_provider.dart';
import 'package:dicetable/src/ui/cafe_owner/authentication/sign_up/widget/image_upload_widget.dart';
import 'package:dicetable/src/ui/cafe_owner/authentication/sign_up/widget/opening_hours_widget.dart';

import 'package:dicetable/src/ui/cafe_owner/authentication/sign_up/widget/venue_type_checkboxes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

import 'bloc/sign_up/sign_up_bloc.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController _venueNameController = TextEditingController();
  final TextEditingController _venueDescriptionController =
      TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _postalCodeController = TextEditingController();
  final TextEditingController _countryController = TextEditingController();
  final TextEditingController _regionController = TextEditingController();


  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => SignUpBloc(authDataProvider: AuthDataProvider()),
      child: Builder(
        builder: (context) {
          return Scaffold(
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
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                  child: BlocConsumer<SignUpBloc, SignUpState>(
                    builder: (context, state) {
                      if(state is SignUpImageLoadingState) {
                        return ModalBarrierWithProgressIndicatorWidget();
                      }
                      return Column(
                        children: [
                          CustomTextField(
                            controller: _venueNameController,
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
                                  (state) => state.copyWith(venueDescription: value),
                                ),
                              );
                            },
                          ),
                          CustomTextField(
                            controller: _emailController,
                            hintText: 'Email',

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
                                  (state) => state.copyWith(confirmPassword: value),
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
                          const VenueTypeCheckboxes(), // Already updated separately
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
                                  'Monday',
                                  'Tuesday',
                                  'Wednesday',
                                  'Thursday',
                                  'Friday',
                                  'Saturday',
                                  'Sunday',
                                ])
                                  OpeningHoursWidget(
                                    day: day,
                                    data: (state is SignUpFormState)
                                        ? (state.openingHours[day] ??
                                        const OpeningHour(
                                          isEnabled: false,
                                          from: TimeOfDay(hour: 10, minute: 0),
                                          to: TimeOfDay(hour: 12, minute: 0),
                                        ))
                                        : const OpeningHour(
                                      isEnabled: false,
                                      from: TimeOfDay(hour: 10, minute: 0),
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
                              ],
                            ),
                          ),
                          const Gap(17),
                          ImageUploadWidget(),
                          const Gap(30),
                          BlocBuilder<SignUpBloc, SignUpState>(
                            builder: (context, state) {

                              if (state is SignUpFormState) {
                                return InkWell(
                                  splashColor: AppColors.secondary,
                                  splashFactory: InkRipple.splashFactory,
                                  onTap: () {
                                    final formState = state;

                                    String formatTime(TimeOfDay time) {
                                      final hours = time.hour.toString().padLeft(2, '0');
                                      final minutes = time.minute.toString().padLeft(2, '0');
                                      return '$hours:$minutes';
                                    }

                                    final selectedVenueTypes = formState.venueTypes.entries
                                        .where((entry) => entry.value == true)
                                        .map((entry) => entry.key)
                                        .toList();

                                    final workingDaysMap = <String, Map<String, dynamic>>{};
                                    formState.openingHours.forEach((day, value) {
                                      final dayLower = day.toLowerCase();
                                      if (value.isEnabled) {
                                        workingDaysMap[dayLower] = {
                                          "is_open": true,
                                          "open": formatTime(value.from),
                                          "close": formatTime(value.to),
                                        };
                                      } else {
                                        workingDaysMap[dayLower] = {"is_open": false};
                                      }
                                    });

                                    if (formState.email.isEmpty || formState.password.isEmpty) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text('Please fill in all required fields'),
                                          backgroundColor: AppColors.appRedColor,
                                        ),
                                      );
                                      return;
                                    }

                                    if (formState.password != formState.confirmPassword) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text('Passwords do not match'),
                                          backgroundColor: AppColors.appRedColor,
                                        ),
                                      );
                                      return;
                                    }

                                    final signUpRequest = SignUpRequest(
                                      name: formState.venueName,
                                      email: formState.email,
                                      password: formState.password,
                                      passwordConfirmation: formState.confirmPassword,
                                      address: formState.address,
                                      country: formState.country,
                                      latitude: 0.0,
                                      longitude: 0.0,
                                      loginType: 3,
                                      phone: formState.phone,
                                      postcode: formState.postalCode,
                                      region: formState.region,
                                      accommodations: selectedVenueTypes,
                                      workingDays: workingDaysMap,
                                      blob: formState.base64Image,
                                    );

                                    print("Name: ${formState.venueName}");
                                    print("Email: ${formState.email}");
                                    print("Password: ${formState.password}");
                                    print("Address: ${formState.address}");
                                    print("Phone: ${formState.phone}");
                                    print("Postal: ${formState.postalCode}");
                                    print("Venue: $selectedVenueTypes");
                                    print("WorkingDays: $workingDaysMap");
                                    print("Image: ${formState.base64Image}");

                                    context.read<SignUpBloc>().add(SubmitSignUp(signupRequest: signUpRequest));
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
                              } else if (state is SignUpLoadingState) {
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
                            if (response.errors != null && response.errors!.isNotEmpty) {
                              final firstErrorField = response.errors!.keys.first;
                              final firstErrorMessage = response.errors![firstErrorField]?.first;

                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(firstErrorMessage ?? 'Something went wrong'),
                                  backgroundColor: AppColors.appRedColor,
                                  duration: const Duration(seconds: 3),
                                ),
                              );
                            }
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                               SnackBar(
                                content: Text(state.signUpRequestResponse.message!),
                                backgroundColor: AppColors.appGreenColor,
                                duration: Duration(seconds: 2),
                              ),
                            );
                            context.go('/subscription_prompt');
                          }
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
                      }

                  ),
                ),
              ),
            ),
          );
        }
      ),
    );
  }
}
