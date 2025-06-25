import 'package:dicetable/src/common/elevated_button_widget.dart';
import 'package:dicetable/src/constants/app_colors.dart';
import 'package:dicetable/src/model/cafe_owner/auth/signUp/apple_sign-up_request.dart';
import 'package:dicetable/src/model/cafe_owner/auth/signUp/sign_up_request.dart';
import 'package:dicetable/src/resources/api_providers/auth/auth_data_provider.dart';
import 'package:dicetable/src/ui/customer/authentication/sign_up/bloc/customer_sign_up_bloc.dart';
import 'package:dicetable/src/ui/customer/authentication/sign_up/widget/required_text_field_widget.dart';
import 'package:dicetable/src/ui/verification/verify_screen_argument.dart';
import 'package:dicetable/src/utils/data/object_factory.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import '../../../../model/cafe_owner/auth/signUp/google_sign-up_request.dart';
import '../../../cafe_owner/authentication/sign_up/sign_up_screen_argument.dart';
import 'package:dicetable/src/common/login_or_signup_prompt.dart';

class CustomerSignUpScreen extends StatefulWidget {
  final SignUpScreenArgument signUpScreenArgument;
  const CustomerSignUpScreen({super.key, required this.signUpScreenArgument});

  @override
  State<CustomerSignUpScreen> createState() => _CustomerSignUpScreenState();
}

class _CustomerSignUpScreenState extends State<CustomerSignUpScreen> {
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;
  late final TextEditingController _confirmPasswordController;
  late final TextEditingController _phoneController;
  late final TextEditingController _countryController;
  late final TextEditingController _regionController;
  late final bool isGoogleSignUp;
  late final bool isAppleSignUp;
  String? appleMail;
  final _formKey = GlobalKey<FormState>();
  AutovalidateMode autovalidateMode = AutovalidateMode.disabled;


  @override
  void initState() {
    super.initState();
    isGoogleSignUp = widget.signUpScreenArgument.isGoggleSignUp ?? false;
    isAppleSignUp = widget.signUpScreenArgument.isAppleSignUp ?? false;
    if (isAppleSignUp) {
      if (!widget.signUpScreenArgument.email.contains('privaterelay')) {
        appleMail = widget.signUpScreenArgument.email ?? "";
      }
    }

    _nameController = TextEditingController(
      text:
          isGoogleSignUp
              ? widget.signUpScreenArgument.displayName
              : isAppleSignUp
              ? widget.signUpScreenArgument.displayName
              : '',
    );
    _emailController = TextEditingController(
      text:
          isGoogleSignUp
              ? widget.signUpScreenArgument.email
              : isAppleSignUp
              ? appleMail
              : '',
    );
    _passwordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
    _phoneController = TextEditingController();
    _countryController = TextEditingController();
    _regionController = TextEditingController();

    if (isGoogleSignUp) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final bloc = context.read<CustomerSignUpBloc>();
        bloc.add(
          UpdateTextField(
            (state) => state.copyWith(
              name: widget.signUpScreenArgument.displayName ?? '',
              email: widget.signUpScreenArgument.email ?? '',
            ),
          ),
        );
      });
    }
    if (isAppleSignUp) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final bloc = context.read<CustomerSignUpBloc>();
        bloc.add(
          UpdateTextField(
            (state) => state.copyWith(
              name: widget.signUpScreenArgument.displayName ?? '',
              email: appleMail,
            ),
          ),
        );
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _phoneController.dispose();
    _countryController.dispose();
    _regionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create:
          (context) => CustomerSignUpBloc(authDataProvider: AuthDataProvider()),
      child: BlocConsumer<CustomerSignUpBloc, CustomerSignUpState>(
        listener: (context, state) {
          if (state is CustomerSignUpSuccessState) {
            final response = state.signUpRequestResponse;
            if (response.status == false) {
              if (response.errors != null && response.errors!.isNotEmpty) {
                final firstErrorField = response.errors!.keys.first;
                final firstErrorMessage =
                    response.errors![firstErrorField]?.first;

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(firstErrorMessage ?? 'Something went wrong'),
                    backgroundColor: AppColors.appRedColor,
                    duration: const Duration(seconds: 3),
                  ),
                );
              }
            } else if (response.status == true) {
              ObjectFactory().prefs.setCustomerAuthToken(
                token: state.signUpRequestResponse.token,
              );
              ObjectFactory().prefs.setCustomerUserName(
                customerUserName: state.signUpRequestResponse.user!.name,
              );
              ObjectFactory().prefs.setUserId(
                userId: state.signUpRequestResponse.user!.id.toString(),
              );
              ObjectFactory().prefs.setIsGoogle(false);
              context.go(
                '/verify',
                extra: VerifyScreenArguments(
                  from: "customer",
                  email: state.signUpRequestResponse.user!.email,
                  otp: state.signUpRequestResponse.user!.emailOtp.toString(),
                  type: "register",
                ),
              );
              Fluttertoast.showToast(
                backgroundColor: AppColors.primaryWhiteColor,
                textColor: AppColors.appGreenColor,
                gravity: ToastGravity.BOTTOM,
                msg: state.signUpRequestResponse.message!,
              );
            }
          }
          if (state is GoogleSignUpSuccessState) {
            final response = state.googleSignUpRequestResponse;
            if (response.status == false) {
              if (response.errors != null && response.errors!.isNotEmpty) {
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
                    content: Text(firstErrorMessage ?? 'Something went wrong'),
                    backgroundColor: AppColors.appRedColor,
                    duration: const Duration(seconds: 3),
                  ),
                );
              }
            } else if (response.status == true) {
              Fluttertoast.showToast(
                msg: state.googleSignUpRequestResponse.message!,
                backgroundColor: AppColors.primaryWhiteColor,
                textColor: AppColors.appGreenColor,
                gravity: ToastGravity.BOTTOM,
                toastLength: Toast.LENGTH_SHORT,
                timeInSecForIosWeb: 1,
                fontSize: 14.0,
                webPosition:
                    "bottom: 80px; left: 50%; transform: translateX(-50%);",
              );

              ObjectFactory().prefs.setCustomerAuthToken(
                token: state.googleSignUpRequestResponse.token,
              );
              ObjectFactory().prefs.setUserId(
                userId: state.googleSignUpRequestResponse.user!.id.toString(),
              );
              ObjectFactory().prefs.setCustomerUserName(
                customerUserName: state.googleSignUpRequestResponse.user!.name,
              );
              ObjectFactory().prefs.setIsGoogle(true);
              ObjectFactory().prefs.setIsCustomerLoggedIn(true);
              context.go('/customer_home');
            }
          }
          if (state is AppleSignUpSuccessState) {
            final response = state.appleSignUpRequestResponse;
            if (response.status == false) {
              if (response.errors != null && response.errors!.isNotEmpty) {
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
                    content: Text(firstErrorMessage ?? 'Something went wrong'),
                    backgroundColor: AppColors.appRedColor,
                    duration: const Duration(seconds: 3),
                  ),
                );
              }
            } else if (response.status == true) {
              Fluttertoast.showToast(
                msg: state.appleSignUpRequestResponse.message!,
                backgroundColor: AppColors.primaryWhiteColor,
                textColor: AppColors.appGreenColor,
                gravity: ToastGravity.BOTTOM,
                toastLength: Toast.LENGTH_SHORT,
                timeInSecForIosWeb: 1,
                fontSize: 14.0,
              );

              ObjectFactory().prefs.setCustomerAuthToken(
                token: state.appleSignUpRequestResponse.token,
              );
              ObjectFactory().prefs.setUserId(
                userId: state.appleSignUpRequestResponse.user!.id.toString(),
              );
              ObjectFactory().prefs.setCustomerUserName(
                customerUserName: state.appleSignUpRequestResponse.user!.name,
              );
              ObjectFactory().prefs.setIsGoogle(true);
              ObjectFactory().prefs.setIsCustomerLoggedIn(true);
              context.go('/customer_home');
            }
          }

          if (state is CustomerSignUpErrorState ||
              state is GoogleSignUpErrorState ||
              state is AppleSignUpLoadingState) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  state is CustomerSignUpErrorState
                      ? state.errorMessage
                      : state is GoogleSignUpErrorState
                      ? state.errorMessage
                      : state is AppleSignUpErrorState
                      ? state.errorMessage
                      : "Something went wrong.",
                ),
                backgroundColor: AppColors.appRedColor,
                duration: const Duration(seconds: 2),
              ),
            );
          }
        },
        builder: (context, state) {
          final formState =
              state is SignUpFormState
                  ? state
                  : const SignUpFormState(); // Safe default state
          return Scaffold(
            extendBody: true,
            appBar: AppBar(
              backgroundColor: AppColors.primary,
              leading: IconButton(
                icon: SvgPicture.asset(
                  'assets/svg/back.svg',
                  fit: BoxFit.scaleDown,
                  color: AppColors.primaryWhiteColor,
                ),
                onPressed: () => context.pop(),
              ),
              title: Text(
                'Create Account',
                style: Theme.of(context).textTheme.labelLarge!.copyWith(
                  color: AppColors.primaryWhiteColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 18.sp,
                ),
              ),
            ),
            body: Form(
              key: _formKey,
              autovalidateMode: autovalidateMode,
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
                child: Padding(
                  padding: const EdgeInsets.only(
                    left: 20.0,
                    right: 20,
                    bottom: 30,
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        const Gap(10),
                        RequiredTextField(
                          readOnly: isGoogleSignUp,
                          hint: 'Name',
                          isRequired: true,
                          controller: _nameController,
                          errorText: formState.nameError,
                          onChanged: (value) {
                            context.read<CustomerSignUpBloc>().add(
                              NameChanged(name: value),
                            );
                          },
                        ),
                        RequiredTextField(
                          readOnly: isGoogleSignUp,
                          hint:
                              isAppleSignUp
                                  ? 'Personal email is required for contact'
                                  : 'Email',
                          isRequired: true,
                          isEmail: true,
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          errorText: formState.emailError,
                          onChanged: (value) {
                            context.read<CustomerSignUpBloc>().add(
                              EmailChanged(email: value),
                            );
                          },
                        ),
                        RequiredTextField(
                          hint: 'Password',
                          isRequired: true,
                          obscureText: true,
                          controller: _passwordController,
                          errorText: formState.passwordError,
                          onChanged: (value) {
                            context.read<CustomerSignUpBloc>().add(
                              PasswordChanged(password: value),
                            );
                          },
                        ),
                        RequiredTextField(
                          hint: 'Confirm Password',
                          isRequired: true,
                          obscureText: true,
                          controller: _confirmPasswordController,
                          errorText: formState.confirmPasswordError,
                          onChanged: (value) {
                            context.read<CustomerSignUpBloc>().add(
                              ConfirmPasswordChanged(confirmPassword: value),
                            );
                          },
                        ),
                        RequiredTextField(
                          hint: 'Phone number',
                          isRequired: false,
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                          errorText: formState.phoneError,
                          onChanged: (value) {
                            context.read<CustomerSignUpBloc>().add(
                              PhoneChanged(phone: value),
                            );
                          },
                        ),
                        RequiredTextField(
                          hint: 'Country',
                          isRequired: true,
                          controller: _countryController,
                          errorText: formState.countryError,
                          onChanged: (value) {
                            context.read<CustomerSignUpBloc>().add(
                              CountryChanged(country: value),
                            );
                          },
                        ),
                        RequiredTextField(
                          hint: 'Region',
                          isRequired: true,
                          controller: _regionController,
                          errorText: formState.regionError,
                          onChanged: (value) {
                            context.read<CustomerSignUpBloc>().add(
                              RegionChanged(region: value),
                            );
                          },
                        ),
                        BlocBuilder<CustomerSignUpBloc, CustomerSignUpState>(
                          builder: (context, state) {
                            if (state is CustomerSignUpLoadingState ||
                                state is GoogleSignUpLoadingState) {
                              return const Center(
                                child: RefreshProgressIndicator(
                                  color: AppColors.primaryWhiteColor,
                                  backgroundColor: AppColors.primary,
                                ),
                              );
                            }

                            return InkWell(
                              onTap: () {
                                final name = _nameController.text.trim();
                                final email = _emailController.text.trim();
                                final password = _passwordController.text.trim();
                                final confirmPassword =
                                    _confirmPasswordController.text.trim();
                                final phone = _phoneController.text.trim();
                                final country = _countryController.text.trim();
                                final region = _regionController.text.trim();

                                // First, update the form state with current controller values
                                context.read<CustomerSignUpBloc>().add(
                                  UpdateTextField(
                                    (state) => state.copyWith(
                                      name: name,
                                      email: email,
                                      password: password,
                                      confirmPassword: confirmPassword,
                                      phone: phone,
                                      country: country,
                                      region: region,
                                    ),
                                  ),
                                );

                                autovalidateMode = AutovalidateMode.onUserInteraction;

                                /*context.read<CustomerSignUpBloc>().add(
                                  ValidateForm(),
                                );*/

                                Future.delayed(const Duration(milliseconds: 100), () {
                                  final currentState =
                                      context.read<CustomerSignUpBloc>().state;

                                  // Check if current state is valid before submitting
                                  if (currentState is SignUpFormState &&
                                      _formKey.currentState!.validate()) {
                                    if (isGoogleSignUp) {
                                      final googleSignUpRequest =
                                          GoogleSignUpRequest(
                                            name: name,
                                            email: email,
                                            password: password,
                                            passwordConfirmation: confirmPassword,
                                            country: country,
                                            loginType: 5,
                                            phone: phone,
                                            region: region,
                                            fcmToken:
                                                ObjectFactory().prefs
                                                    .getFcmToken()
                                                    .toString(),
                                          );
                                      context.read<CustomerSignUpBloc>().add(
                                        SubmitGoogleSignUp(
                                          signupRequest: googleSignUpRequest,
                                        ),
                                      );
                                    }
                                    else if (isAppleSignUp) {
                                      final appleSignUpRequest =
                                          AppleSignUpRequest(
                                            name: name,
                                            email: email,
                                            password: password,
                                            passwordConfirmation: confirmPassword,
                                            country: country,
                                            loginType: 5,
                                            phone: phone,
                                            region: region,
                                            fcmToken:
                                                ObjectFactory().prefs
                                                    .getFcmToken()
                                                    .toString(),
                                          );
                                          context.read<CustomerSignUpBloc>().add(
                                        SubmitCustomerAppleSignUp(
                                          appleSignUpRequest: appleSignUpRequest,
                                        ),
                                      );
                                    }
                                    else if(!isAppleSignUp && !isGoogleSignUp){
                                      final signUpRequest = SignUpRequest(
                                        name: name,
                                        email: email,
                                        password: password,
                                        passwordConfirmation: confirmPassword,
                                        country: country,
                                        loginType: 5,
                                        phone: phone,
                                        region: region,
                                        fcmToken:
                                            ObjectFactory().prefs
                                                .getFcmToken()
                                                .toString(),
                                      );
                                      context.read<CustomerSignUpBloc>().add(
                                        SubmitSignUp(
                                          signupRequest: signUpRequest,
                                        ),
                                      );
                                    }

                                  } else {
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
                                });
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
                          },
                        ),
                        const Gap(20),
                        LoginOrSignupPrompt(
                          spanText: 'Already have an account',
                          promptText: 'Sign in now',
                          onSignInTap: () => context.go('/customer_login'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
