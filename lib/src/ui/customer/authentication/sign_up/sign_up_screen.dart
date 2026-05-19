import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:soloseaters/src/common/elevated_button_widget.dart';
import 'package:soloseaters/src/constants/app_colors.dart';
import 'package:soloseaters/src/model/cafe_owner/auth/signUp/apple_sign-up_request.dart';
import 'package:soloseaters/src/model/cafe_owner/auth/signUp/sign_up_request.dart';
import 'package:soloseaters/src/resources/api_providers/auth/auth_data_provider.dart';
import 'package:soloseaters/src/ui/customer/authentication/sign_up/bloc/customer_sign_up_bloc.dart';
import 'package:soloseaters/src/ui/customer/authentication/sign_up/widget/required_text_field_widget.dart';
import 'package:soloseaters/src/ui/verification/verify_screen_argument.dart';
import 'package:soloseaters/src/utils/data/object_factory.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import '../../../../model/cafe_owner/auth/signUp/google_sign-up_request.dart';
import '../../../cafe_owner/authentication/sign_up/sign_up_screen_argument.dart';
import 'package:soloseaters/src/common/login_or_signup_prompt.dart';

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

    final args = widget.signUpScreenArgument;
    isGoogleSignUp = args.isGoggleSignUp ?? false;
    isAppleSignUp = args.isAppleSignUp ?? false;
    final rawAppleEmail = args.email?.trim() ?? '';
    appleMail = isAppleSignUp ? rawAppleEmail : '';

    _nameController = TextEditingController(
      text:
          isGoogleSignUp
              ? args.displayName
              : (isAppleSignUp ? args.displayName : ''),
    );

    _emailController = TextEditingController(
      text: isGoogleSignUp ? args.email : (isAppleSignUp ? appleMail : ''),
    );

    _passwordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
    _phoneController = TextEditingController();
    _countryController = TextEditingController();
    _regionController = TextEditingController();

    _emailController.addListener(() {
      final text = _emailController.text;
      if (text.contains(' ')) {
        final newText = text.replaceAll(' ', '');
        _emailController.text = newText;
        _emailController.selection = TextSelection.fromPosition(
          TextPosition(offset: newText.length),
        );

        final bloc = context.read<CustomerSignUpBloc>();
        bloc.add(EmailChanged(email: newText));
        bloc.add(ValidateForm());
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final bloc = context.read<CustomerSignUpBloc>();
      if (isGoogleSignUp) {
        bloc.add(
          UpdateTextField(
            (state) => state.copyWith(
              name: args.displayName ?? '',
              email: args.email ?? '',
            ),
          ),
        );
      } else if (isAppleSignUp) {
        bloc.add(
          UpdateTextField(
            (state) =>
                state.copyWith(name: args.displayName ?? '', email: appleMail),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _emailController.removeListener(() {});
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
          (context) => CustomerSignUpBloc(
            authDataProvider: AuthDataProvider(),
            isAppleSignUp: isAppleSignUp,
            isGoogleSignUp: isGoogleSignUp,
          ),
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

                    behavior: SnackBarBehavior.floating,
                    duration: const Duration(seconds: 3),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                );
              }
            } else if (response.status == true) {
              ObjectFactory().prefs.setCustomerUserMail(
                customerUserMail: state.signUpRequestResponse.user!.email,
              );
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
              ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(state.signUpRequestResponse.message!, style: TextStyle(color: AppColors.appGreenColor)),
        backgroundColor: AppColors.primaryWhiteColor,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
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
                ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(firstErrorMessage ?? "Something went wrong", style: TextStyle(color: AppColors.appGreenColor)),
        backgroundColor: AppColors.primaryWhiteColor,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(firstErrorMessage ?? 'Something went wrong'),
                    backgroundColor: AppColors.appRedColor,
                    behavior: SnackBarBehavior.floating,
                    duration: const Duration(seconds: 3),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                );
              }
            } else if (response.status == true) {
              ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(state.googleSignUpRequestResponse.message!, style: TextStyle(color: AppColors.appGreenColor)),
        backgroundColor: AppColors.primaryWhiteColor,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );

              ObjectFactory().prefs.setCustomerAuthToken(
                token: state.googleSignUpRequestResponse.token,
              );
              ObjectFactory().prefs.setCustomerUserMail(
                customerUserMail: state.googleSignUpRequestResponse.user!.email,
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
                ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(firstErrorMessage ?? "Something went wrong", style: TextStyle(color: AppColors.appGreenColor)),
        backgroundColor: AppColors.primaryWhiteColor,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(firstErrorMessage ?? 'Something went wrong'),
                    backgroundColor: AppColors.appRedColor,
                    behavior: SnackBarBehavior.floating,
                    duration: const Duration(seconds: 3),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                );
              }
            } else if (response.status == true) {
              ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(state.appleSignUpRequestResponse.message!, style: TextStyle(color: AppColors.appGreenColor)),
        backgroundColor: AppColors.primaryWhiteColor,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );

              ObjectFactory().prefs.setCustomerAuthToken(
                token: state.appleSignUpRequestResponse.token,
              );
              ObjectFactory().prefs.setCustomerUserMail(
                customerUserMail: state.appleSignUpRequestResponse.user!.email,
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
          if (state is AppleSignUpErrorState) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage ?? 'Something went wrong'),
                backgroundColor: AppColors.appRedColor,
                behavior: SnackBarBehavior.floating,
                duration: const Duration(seconds: 3),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            );
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
                behavior: SnackBarBehavior.floating,
                duration: const Duration(seconds: 3),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
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
                    physics: const BouncingScrollPhysics(),
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
                          readOnly:
                              isGoogleSignUp ||
                              (isAppleSignUp &&
                                  _emailController.text.isNotEmpty),

                          hint: 'Email',
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
                        (!isAppleSignUp && !isGoogleSignUp)
                            ? RequiredTextField(
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
                            )
                            : SizedBox.shrink(),
                        (!isAppleSignUp && !isGoogleSignUp)
                            ? RequiredTextField(
                              hint: 'Confirm Password',
                              isRequired: true,
                              obscureText: true,
                              controller: _confirmPasswordController,
                              errorText: formState.confirmPasswordError,
                              onChanged: (value) {
                                context.read<CustomerSignUpBloc>().add(
                                  ConfirmPasswordChanged(
                                    confirmPassword: value,
                                  ),
                                );
                              },
                            )
                            : SizedBox.shrink(),
                        RequiredTextField(
                          isPhoneNumber: true,
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
                                state is GoogleSignUpLoadingState ||
                                state is AppleSignUpLoadingState) {
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
                                final password =
                                    _passwordController.text.trim();
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

                                autovalidateMode =
                                    AutovalidateMode.onUserInteraction;

                                /*context.read<CustomerSignUpBloc>().add(
                                  ValidateForm(),
                                );*/

                                Future.delayed(
                                  const Duration(milliseconds: 100),
                                  () {
                                    final currentState =
                                        context
                                            .read<CustomerSignUpBloc>()
                                            .state;

                                    if (currentState is SignUpFormState &&
                                        _formKey.currentState!.validate()) {
                                      if (isGoogleSignUp) {
                                        final googleSignUpRequest =
                                            GoogleSignUpRequest(
                                              name: name,
                                              email: email,
                                              // password: password,
                                              // passwordConfirmation:
                                              //     confirmPassword,
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
                                      } else if (isAppleSignUp) {
                                        final fcmToken =
                                            ObjectFactory().prefs
                                                .getFcmToken()
                                                .toString();
                                        final appleId =
                                            ObjectFactory().prefs
                                                .getAppleAuthID();
                                        final appleSignUpRequest =
                                            AppleSignUpRequest(
                                              name: name,
                                              email: email,
                                              country: country,
                                              loginType: 5,
                                              phone: phone,
                                              region: region,
                                              fcmToken: fcmToken,
                                              apple_id: appleId,
                                            );

                                        context.read<CustomerSignUpBloc>().add(
                                          SubmitCustomerAppleSignUp(
                                            appleSignUpRequest:
                                                appleSignUpRequest,
                                          ),
                                        );
                                      } else if (!isAppleSignUp &&
                                          !isGoogleSignUp) {
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
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            'Please fill all required fields before submitting.',
                                          ),
                                          backgroundColor:
                                              AppColors.appRedColor,
                                          behavior: SnackBarBehavior.floating,
                                          duration: const Duration(seconds: 3),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                          ),
                                        ),
                                      );
                                    }
                                  },
                                );
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
                          },
                        ),
                        const Gap(20),
                        LoginOrSignupPrompt(
                          spanText: 'Already have an account',
                          promptText: 'Sign in now',
                          onSignInTap: () => context.go('/customer_login'),
                        ),
                        const Gap(40),
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
