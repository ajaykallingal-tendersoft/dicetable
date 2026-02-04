import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:soloseaters/src/common/custom_login_text_field.dart';
import 'package:soloseaters/src/common/divider_with_center_text.dart';
import 'package:soloseaters/src/common/elevated_button_widget.dart';
import 'package:soloseaters/src/common/login_or_signup_prompt.dart';
import 'package:soloseaters/src/constants/app_colors.dart';
import 'package:soloseaters/src/model/customer/guest/guest_user_request.dart';
import 'package:soloseaters/src/resources/api_providers/auth/auth_data_provider.dart';
import 'package:soloseaters/src/ui/cafe_owner/authentication/login/widget/login_with_apple_widget.dart';
import 'package:soloseaters/src/ui/cafe_owner/authentication/login/widget/login_with_google_widget.dart';
import 'package:soloseaters/src/ui/customer/authentication/login/bloc/customer_login_bloc.dart';
import 'package:soloseaters/src/ui/verification/verify_screen_argument.dart';
import 'package:soloseaters/src/utils/data/object_factory.dart';
import 'package:soloseaters/src/utils/data/privacy_terms.dart';
import 'package:soloseaters/src/utils/network_connectivity/network_connectivity_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

import '../../../cafe_owner/authentication/sign_up/sign_up_screen_argument.dart';

class CustomerLoginScreen extends StatefulWidget {
  const CustomerLoginScreen({super.key});

  @override
  State<CustomerLoginScreen> createState() => _CustomerLoginScreenState();
}

class _CustomerLoginScreenState extends State<CustomerLoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();
  final _formKey = GlobalKey<FormState>();
  bool _isSubmitting = false;
  DateTime? _lastBackPressed;
  String? _navigationSource;
  final GlobalKey _emailFieldKey = GlobalKey();
  final GlobalKey _passwordFieldKey = GlobalKey();
  bool _isConnected = true;
  bool _isMounted = false;

  @override
  void initState() {
    super.initState();
    _isMounted = true;
    // NetworkConnectivityBloc().add(NetworkObserve());
    print("UserCate: ${ObjectFactory().prefs.getUserDecisionName()}");
    _navigationSource = ObjectFactory().prefs.getNavigationSource();
    ObjectFactory().prefs.clearNavigationSource();
    _emailFocusNode.addListener(() {
      if (_emailFocusNode.hasFocus) {
        _ensureVisible(_emailFieldKey);
      }
    });

    _passwordFocusNode.addListener(() {
      if (_passwordFocusNode.hasFocus) {
        _ensureVisible(_passwordFieldKey);
      }
    });
  }

  void _ensureVisible(GlobalKey key) {
    Future.delayed(Duration(milliseconds: 300), () {
      if (key.currentContext != null) {
        Scrollable.ensureVisible(
          key.currentContext!,
          alignmentPolicy: ScrollPositionAlignmentPolicy.keepVisibleAtEnd,
          duration: Duration(milliseconds: 300),
        );
      }
    });
  }

  @override
  void dispose() {
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create:
          (context) => CustomerLoginBloc(authDataProvider: AuthDataProvider()),
      child: Builder(
        builder: (context) {
          return BlocConsumer<CustomerLoginBloc, CustomerLoginState>(
            listener: (context, state) {
              print('Login state: $state');
              if (state is CustomerLoginLoadingState) {
                setState(() {
                  _isSubmitting = true;
                });
                EasyLoading.show();
              } else {
                setState(() {
                  _isSubmitting = false;
                });
                EasyLoading.dismiss();
              }

              if (state is CustomerLoginSuccessState) {
                EasyLoading.dismiss();
              } else if (state is GoogleLoginLoading) {
                EasyLoading.show();
              } else if (state is LoginWithAppleLoading) {
                EasyLoading.show();
              }
              if (state is CustomerLoginFailureState) {
                EasyLoading.dismiss();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                    backgroundColor: AppColors.appRedColor,
                    behavior: SnackBarBehavior.floating,
                    duration: const Duration(seconds: 3),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                );
              }

              if (state is CustomerLoginSuccessState) {
                if (state.loginRequestResponse.status == true) {
                  EasyLoading.dismiss();
                  if (state.loginRequestResponse.token!.isNotEmpty &&
                      state.loginRequestResponse.user!.isEmailVerified == 1) {
                    ObjectFactory().prefs.setIsCustomerLoggedIn(true);
                    ObjectFactory().prefs.setCustomerAuthToken(
                      token: state.loginRequestResponse.token,
                    );
                    ObjectFactory().prefs.setCustomerUserMail(
                      customerUserMail: state.loginRequestResponse.user!.email,
                    );
                    ObjectFactory().prefs.setUserId(
                      userId: state.loginRequestResponse.user!.id.toString(),
                    );
                    if (state.loginRequestResponse.user != null &&
                        state.loginRequestResponse.user!.name != null) {
                      ObjectFactory().prefs.setCustomerUserName(
                        customerUserName: state.loginRequestResponse.user!.name,
                      );
                    }
                    context.go('/customer_home');
                  }
                } else if (state.loginRequestResponse.status == false) {
                  EasyLoading.dismiss();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.loginRequestResponse.message!),
                      backgroundColor: AppColors.appRedColor,
                      behavior: SnackBarBehavior.floating,
                      duration: const Duration(seconds: 3),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  );
                }
                if (state.loginRequestResponse.status == false &&
                    state.loginRequestResponse.message ==
                        "Please verify your email first.") {
                  context.go(
                    '/verify',
                    extra: VerifyScreenArguments(
                      email: _emailController.text,
                      otp: "",
                      type: "register",
                      from: 'customer',
                      expiresAt: state.loginRequestResponse.expiresAt,
                      resendAvailableInSeconds:
                          state.loginRequestResponse.resendAvailableInSeconds,
                    ),
                  );
                }
              }
              if (state is CustomerLoginFailureState) {
                EasyLoading.dismiss();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                    backgroundColor: AppColors.appRedColor,
                    behavior: SnackBarBehavior.floating,
                    duration: const Duration(seconds: 3),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                );
              }
              if (state is GoogleLoginLoaded) {
                final response = state.googleLoginResponse;
                EasyLoading.dismiss();
                if (response.status == true && response.token != null) {
                  ObjectFactory().prefs.setIsCustomerLoggedIn(true);
                  ObjectFactory().prefs.setIsGoogle(true);
                  ObjectFactory().prefs.setCustomerAuthToken(
                    token: state.googleLoginResponse.token,
                  );
                  ObjectFactory().prefs.setCustomerUserMail(
                    customerUserMail: state.googleLoginResponse.user!.email,
                  );
                  ObjectFactory().prefs.setUserId(
                    userId: state.googleLoginResponse.user!.id.toString(),
                  );
                  ObjectFactory().prefs.setCustomerUserName(
                    customerUserName: state.googleLoginResponse.user!.name,
                  );
                  context.go('/customer_home');
                  Fluttertoast.showToast(
                    fontSize: 14.sp,
                    msg: response.message!,
                    backgroundColor: AppColors.primaryWhiteColor,
                    textColor: AppColors.appGreenColor,
                  );
                }
              }
              if (state is GoogleLoginErrorState) {
                EasyLoading.dismiss();
                print('GoogleLoginErrorState reached');
                Fluttertoast.showToast(
                  fontSize: 14.sp,
                  msg: state.msg,
                  backgroundColor: AppColors.primaryWhiteColor,
                  textColor: AppColors.appRedColor,
                );

                if (state.msg ==
                    "You are not registered in our app. Please complete the signup process!") {
                  print('Navigating to /signup');
                  print(ObjectFactory().prefs.getCustomerUserName()!);
                  print(ObjectFactory().prefs.getCustomerUserMail()!);
                  context.push(
                    '/customer_signUp',
                    extra: SignUpScreenArgument(
                      imageBase64: "",
                      isGoggleSignUp: true,
                      email: ObjectFactory().prefs.getCustomerUserMail()!,
                      displayName: ObjectFactory().prefs.getCustomerUserName()!,
                      phone: "",
                    ),
                  );
                }
              }
              if (state is LoginWithAppleLoaded) {
                final response = state.appleLoginRequestResponse;
                EasyLoading.dismiss();
                if (response.status == true && response.token != null) {
                  ObjectFactory().prefs.setIsCustomerLoggedIn(true);
                  ObjectFactory().prefs.setIsGoogle(true);
                  ObjectFactory().prefs.setCustomerAuthToken(
                    token: state.appleLoginRequestResponse.token,
                  );
                  ObjectFactory().prefs.setCustomerUserMail(
                    customerUserMail:
                        state.appleLoginRequestResponse.user!.email,
                  );
                  ObjectFactory().prefs.setUserId(
                    userId: state.appleLoginRequestResponse.user!.id.toString(),
                  );
                  ObjectFactory().prefs.setCustomerUserName(
                    customerUserName:
                        state.appleLoginRequestResponse.user!.name,
                  );
                  context.go('/customer_home');
                  Fluttertoast.showToast(
                    fontSize: 14.sp,
                    msg: response.message!,
                    backgroundColor: AppColors.primaryWhiteColor,
                    textColor: AppColors.appGreenColor,
                  );
                }
              }
              if (state is LoginWithAppleError) {
                ObjectFactory().prefs.setAppleAuthID(
                  appleAuthID: state.appleId,
                );
                EasyLoading.dismiss();
                print('AppleLoginErrorState reached');
                Fluttertoast.showToast(
                  fontSize: 14.sp,
                  msg: state.errorMsg,
                  backgroundColor: AppColors.primaryWhiteColor,
                  textColor: AppColors.appRedColor,
                );

                if (state.errorMsg ==
                    "You are not registered in our app. Please complete the signup process!") {
                  // print('Navigating to /signup');
                  // print(ObjectFactory().prefs.getCustomerUserName()!);
                  // print(ObjectFactory().prefs.getCustomerUserMail()!);
                  context.push(
                    '/customer_signUp',
                    extra: SignUpScreenArgument(
                      imageBase64: "",
                      isGoggleSignUp: false,
                      isAppleSignUp: true,
                      email: ObjectFactory().prefs.getCustomerUserMail()!,
                      displayName: ObjectFactory().prefs.getCustomerUserName()!,
                      phone: "",
                    ),
                  );
                }
              }
            },
            builder: (context, state) {
              final emailError =
                  state is LoginFormState ? state.emailError : null;
              final passwordError =
                  state is LoginFormState ? state.passwordError : null;
              final bool isLoading = state is CustomerLoginLoadingState;

              return WillPopScope(
                onWillPop: () async {
                  if (_navigationSource == 'category_screen') {
                    context.go('/category');
                    return false;
                  }
                  final now = DateTime.now();
                  if (_lastBackPressed == null ||
                      now.difference(_lastBackPressed!) >
                          Duration(seconds: 2)) {
                    _lastBackPressed = now;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        backgroundColor: AppColors.primary,

                        content: Text(
                          'Press again to quit',
                          style: TextStyle(color: AppColors.primaryWhiteColor),
                        ),
                        behavior: SnackBarBehavior.floating,
                        duration: const Duration(seconds: 2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    );
                    return false;
                  }
                  if (Theme.of(context).platform == TargetPlatform.android) {
                    SystemNavigator.pop();
                    return false;
                  }
                  return true;
                },
                child: Scaffold(
                  resizeToAvoidBottomInset: false,
                  body: Stack(
                    children: [
                      Positioned.fill(
                        child: Image.asset(
                          'assets/png/login-bg.png',
                          fit: BoxFit.cover,
                        ).animate().fadeIn(
                          duration: 800.ms,
                          curve: Curves.easeOut,
                        ),
                      ),

                      Positioned(
                        top: 50.h,
                        left: 0,
                        right: 0,
                        child: Align(
                          alignment: Alignment.topCenter,
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              maxWidth: 200.w,
                              maxHeight: 200.h,
                            ),
                            child: Container(
                                  height: 200.h,
                                  width: 200.w,
                                  decoration: BoxDecoration(
                                    color: AppColors.primary,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  padding: EdgeInsets.all(16),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(20),
                                    child: Image.asset(
                                      'assets/png/solo.png',
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                )
                                .animate()
                                .scale(
                                  begin: const Offset(0.8, 0.8),
                                  end: const Offset(1, 1),
                                  duration: 600.ms,
                                  curve: Curves.easeOutBack,
                                )
                                .fadeIn(duration: 500.ms),
                          ),
                        ),
                      ),

                      Positioned(
                        top: 270.h,
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: ClipRRect(
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(53),
                          ),
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image: AssetImage('assets/png/login-box.png'),
                                fit: BoxFit.cover,
                              ),
                            ),
                            child: SafeArea(
                              top: false,
                              left: false,
                              right: false,
                              child: LayoutBuilder(
                                builder: (context, constraints) {
                                  return NotificationListener<
                                    OverscrollIndicatorNotification
                                  >(
                                    onNotification: (overscroll) {
                                      overscroll.disallowIndicator();
                                      return true;
                                    },
                                    child: Padding(
                                      padding: EdgeInsets.only(
                                        bottom:
                                            MediaQuery.of(
                                              context,
                                            ).viewInsets.bottom,
                                      ),
                                      child: SingleChildScrollView(
                                        keyboardDismissBehavior:
                                            ScrollViewKeyboardDismissBehavior
                                                .onDrag,
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 26.w,
                                          vertical: 26.h,
                                        ),
                                        child: Form(
                                          key: _formKey,
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Text(
                                                    'Welcome Back!',
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .headlineLarge!
                                                        .copyWith(
                                                          fontSize: 24,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          color:
                                                              AppColors
                                                                  .primaryWhiteColor,
                                                        ),
                                                  )
                                                  .animate()
                                                  .fadeIn(
                                                    duration: 600.ms,
                                                    delay: 300.ms,
                                                  )
                                                  .scale(
                                                    begin: const Offset(
                                                      0.9,
                                                      0.9,
                                                    ),
                                                    duration: 600.ms,
                                                    curve: Curves.easeOutBack,
                                                    delay: 300.ms,
                                                  ),

                                              Gap(10),

                                              Container(
                                                    key: _emailFieldKey,
                                                    child: CustomLoginTextField(
                                                      hintText: "Email Address",
                                                      icon: SvgPicture.asset(
                                                        'assets/svg/email.svg',
                                                      ),
                                                      controller:
                                                          _emailController,
                                                      focusNode:
                                                          _emailFocusNode,
                                                      errorText: emailError,
                                                      onChanged: (value) {
                                                        context
                                                            .read<
                                                              CustomerLoginBloc
                                                            >()
                                                            .add(
                                                              EmailChanged(
                                                                value,
                                                              ),
                                                            );
                                                      },
                                                    ),
                                                  )
                                                  .animate()
                                                  .fadeIn(
                                                    duration: 600.ms,
                                                    delay: 400.ms,
                                                  )
                                                  .slideX(
                                                    begin: 0.2,
                                                    end: 0,
                                                    duration: 600.ms,
                                                    curve: Curves.easeOutQuad,
                                                    delay: 400.ms,
                                                  ),

                                              Gap(10),

                                              Container(
                                                    key: _passwordFieldKey,
                                                    child: CustomLoginTextField(
                                                      isPassword: true,
                                                      hintText: "Password",
                                                      icon: SvgPicture.asset(
                                                        'assets/svg/pw.svg',
                                                      ),
                                                      controller:
                                                          _passwordController,
                                                      focusNode:
                                                          _passwordFocusNode,
                                                      errorText: passwordError,
                                                      onChanged: (value) {
                                                        context
                                                            .read<
                                                              CustomerLoginBloc
                                                            >()
                                                            .add(
                                                              PasswordChanged(
                                                                value,
                                                              ),
                                                            );
                                                      },
                                                    ),
                                                  )
                                                  .animate()
                                                  .fadeIn(
                                                    duration: 600.ms,
                                                    delay: 500.ms,
                                                  )
                                                  .slideX(
                                                    begin: 0.2,
                                                    end: 0,
                                                    duration: 600.ms,
                                                    curve: Curves.easeOutQuad,
                                                    delay: 500.ms,
                                                  ),

                                              Gap(8),

                                              InkWell(
                                                splashColor:
                                                    AppColors.secondary,
                                                splashFactory:
                                                    InkRipple.splashFactory,
                                                onTap: () {
                                                  context.push(
                                                    '/forgot_password',
                                                    extra: "customer",
                                                  );
                                                },
                                                child: Align(
                                                  alignment:
                                                      Alignment.centerRight,
                                                  child: Text(
                                                    'Forgot Password?',
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .bodyMedium!
                                                        .copyWith(
                                                          color:
                                                              AppColors
                                                                  .textFieldTextColor,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          fontSize: 16,
                                                        ),
                                                  ),
                                                ),
                                              ).animate().fadeIn(
                                                duration: 400.ms,
                                                delay: 600.ms,
                                              ),
                                              Gap(15),
                                              InkWell(
                                                    splashColor:
                                                        AppColors.borderColor,
                                                    splashFactory:
                                                        InkRipple.splashFactory,
                                                    onTap:
                                                        isLoading
                                                            ? null
                                                            : () {
                                                              context
                                                                  .read<
                                                                    CustomerLoginBloc
                                                                  >()
                                                                  .add(
                                                                    FormSubmitted(),
                                                                  );
                                                            },
                                                    child: Stack(
                                                      alignment:
                                                          Alignment.center,
                                                      children: [
                                                        ElevatedButtonWidget(
                                                          height: 70.h,
                                                          width:
                                                              MediaQuery.of(
                                                                context,
                                                              ).size.width,
                                                          iconEnabled: false,
                                                          iconLabel: "LOGIN",
                                                          color:
                                                              AppColors.primary,
                                                          textColor:
                                                              AppColors
                                                                  .primaryWhiteColor,
                                                        ),
                                                      ],
                                                    ),
                                                  )
                                                  .animate()
                                                  .fadeIn(
                                                    duration: 600.ms,
                                                    delay: 700.ms,
                                                  )
                                                  .slideY(
                                                    begin: 0.2,
                                                    end: 0,
                                                    duration: 600.ms,
                                                    curve: Curves.easeOutQuad,
                                                    delay: 700.ms,
                                                  )
                                                  .shimmer(
                                                    duration: 1200.ms,
                                                    delay: 1000.ms,
                                                    color: AppColors
                                                        .primaryWhiteColor
                                                        .withOpacity(0.3),
                                                  ),

                                              Gap(10),

                                              DividerWithCenterText(
                                                centerText: 'Or Continue with',
                                              ).animate().fadeIn(
                                                duration: 500.ms,
                                                delay: 800.ms,
                                              ),
                                              Gap(20),
                                              LoginWithGoogleWidget()
                                                  .animate()
                                                  .fadeIn(
                                                    duration: 600.ms,
                                                    delay: 900.ms,
                                                  )
                                                  .scale(
                                                    begin: const Offset(
                                                      0.9,
                                                      0.9,
                                                    ),
                                                    end: const Offset(1, 1),
                                                    duration: 500.ms,
                                                    curve: Curves.elasticOut,
                                                    delay: 900.ms,
                                                  ),
                                              Gap(20),
                                              LoginWithAppleWidget()
                                                  .animate()
                                                  .fadeIn(
                                                    duration: 600.ms,
                                                    delay: 900.ms,
                                                  )
                                                  .scale(
                                                    begin: const Offset(
                                                      0.9,
                                                      0.9,
                                                    ),
                                                    end: const Offset(1, 1),
                                                    duration: 500.ms,
                                                    curve: Curves.elasticOut,
                                                    delay: 900.ms,
                                                  ),
                                              Gap(30),

                                              LoginOrSignupPrompt(
                                                spanText:
                                                    'Don\'t have an account yet',
                                                promptText: 'Sign Up Now',
                                                onSignInTap: () {
                                                  context.push(
                                                    '/customer_signUp',
                                                    extra: SignUpScreenArgument(
                                                      isGoggleSignUp: false,
                                                      email: "",
                                                      displayName: "",
                                                      phone: "",
                                                      imageBase64: "",
                                                    ),
                                                  );
                                                },
                                              ).animate().fadeIn(
                                                duration: 500.ms,
                                                delay: 1000.ms,
                                              ),
                                              Gap(10),
                                              BlocListener<
                                                CustomerLoginBloc,
                                                CustomerLoginState
                                              >(
                                                listener: (context, state) {
                                                  if (state
                                                      is GuestUserLoadingState) {
                                                    EasyLoading.show();
                                                  }
                                                  if (state
                                                      is GuestUserLoadedState) {
                                                    if (state
                                                            .guestSignInResponse
                                                            .status ==
                                                        true) {
                                                      EasyLoading.dismiss();
                                                      ObjectFactory().prefs
                                                          .setDeviceID(
                                                            deviceID:
                                                                state
                                                                    .guestSignInResponse
                                                                    .deviceToken,
                                                          );
                                                      ObjectFactory().prefs
                                                          .setIsGuestUser(true);
                                                      _showToast(
                                                        state
                                                                .guestSignInResponse
                                                                .message! ??
                                                            "",
                                                        AppColors.appGreenColor,
                                                      );
                                                      context.go(
                                                        '/customer_home',
                                                      );
                                                    } else if (state
                                                            .guestSignInResponse
                                                            .status ==
                                                        false) {
                                                      EasyLoading.dismiss();
                                                      ObjectFactory().prefs
                                                          .setIsGuestUser(
                                                            false,
                                                          );
                                                      _showToast(
                                                        state
                                                                .guestSignInResponse
                                                                .message! ??
                                                            "",
                                                        AppColors.appRedColor,
                                                      );
                                                    }
                                                  }
                                                  if (state
                                                      is GuestUserErrorState) {
                                                    EasyLoading.dismiss();
                                                    ObjectFactory().prefs
                                                        .setIsGuestUser(false);
                                                    _showToast(
                                                      state.errorMessage ?? "",
                                                      AppColors.appRedColor,
                                                    );
                                                  }
                                                },
                                                child: TextButton(
                                                  onPressed: () async {
                                                    context
                                                        .read<
                                                          CustomerLoginBloc
                                                        >()
                                                        .add(
                                                          GuestUserEvent(
                                                            guestUserRequest:
                                                                GuestUserRequest(
                                                                  deviceToken:
                                                                      await _getDeviceId(),
                                                                ),
                                                          ),
                                                        );
                                                  },
                                                  child: Text(
                                                    'SKIP SIGN IN',
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .labelMedium!
                                                        .copyWith(
                                                          color:
                                                              AppColors
                                                                  .primaryWhiteColor,
                                                          fontSize: 16,
                                                        ),
                                                  ),
                                                ),
                                              ),
                                              Gap(20),
                                              PrivacyAndTermsText()
                                                  .animate()
                                                  .fadeIn(
                                                    duration: 600.ms,
                                                    delay: 1100.ms,
                                                  ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                      ).animate().fadeIn(duration: 800.ms).slideY(begin: 0.1, end: 0, duration: 800.ms, curve: Curves.easeOutQuint),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _showToast(String message, Color textColor) {
    if (!_isMounted) return;

    Fluttertoast.showToast(
      fontSize: 14.sp,
      backgroundColor: AppColors.primaryWhiteColor,
      textColor: textColor,
      gravity: ToastGravity.BOTTOM,
      msg: message,
    );
  }

  Future<String> _getDeviceId() async {
    try {
      DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
      if (Platform.isAndroid) {
        AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
        print("DeviceID: ${androidInfo.id}");
        ObjectFactory().prefs.setDeviceID(deviceID: androidInfo.id);
        return androidInfo.id;
      } else if (Platform.isIOS) {
        IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
        ObjectFactory().prefs.setDeviceID(
          deviceID: iosInfo.identifierForVendor,
        );
        return iosInfo.identifierForVendor ?? '';
      }
      return '';
    } catch (e) {
      debugPrint('Error getting device ID: $e');
      return '';
    }
  }
}
