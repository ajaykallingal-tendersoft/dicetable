import 'package:soloseaters/src/common/modal_barrier_with_progress_indicator_widget.dart';
import 'package:soloseaters/src/constants/assets.dart';
import 'package:soloseaters/src/model/cafe_owner/auth/login/apple_login_request_response.dart';
import 'package:soloseaters/src/model/cafe_owner/auth/login/google_login_request_response.dart';
import 'package:soloseaters/src/model/cafe_owner/auth/login/login_request_response.dart';
import 'package:soloseaters/src/ui/cafe_owner/authentication/sign_up/bloc/sign_up/sign_up_bloc.dart';
import 'package:soloseaters/src/ui/cafe_owner/authentication/sign_up/sign_up_screen_argument.dart';
import 'package:soloseaters/src/ui/verification/verify_screen_argument.dart';
import 'package:soloseaters/src/utils/data/privacy_terms.dart';
import 'package:soloseaters/src/utils/network_connectivity/network_connectivity_bloc.dart';
import 'package:soloseaters/src/utils/network_connectivity/network_toast_manager.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:soloseaters/src/common/custom_login_text_field.dart';
import 'package:soloseaters/src/common/divider_with_center_text.dart';
import 'package:soloseaters/src/common/elevated_button_widget.dart';
import 'package:soloseaters/src/common/login_or_signup_prompt.dart';
import 'package:soloseaters/src/constants/app_colors.dart';
import 'package:soloseaters/src/resources/api_providers/auth/auth_data_provider.dart';
import 'package:soloseaters/src/ui/cafe_owner/authentication/login/bloc/login_bloc.dart';
import 'package:soloseaters/src/ui/cafe_owner/authentication/login/widget/login_with_google_widget.dart';
import 'package:soloseaters/src/utils/data/object_factory.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:soloseaters/src/ui/cafe_owner/authentication/login/widget/login_with_apple_widget.dart';
import 'cubit/apple_signin_cubit.dart';
import 'dart:ui';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();
  final _formKey = GlobalKey<FormState>();
  bool _isSubmitting = false;
  DateTime? _lastBackPressed;
  final GlobalKey _emailFieldKey = GlobalKey();
  final GlobalKey _passwordFieldKey = GlobalKey();
  String? _navigationSource;
  NetworkConnectivityState? _networkState;

  @override
  void initState() {
    super.initState();
    NetworkConnectivityBloc().add(NetworkObserve());
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
      create: (context) => LoginBloc(authDataProvider: AuthDataProvider()),
      child: Builder(
        builder: (context) {
          return BlocConsumer<LoginBloc, LoginState>(
            listener: (context, state) async {
              // Handle loading states
              if (state is LoginLoadingState ||
                  state is GoogleLoginLoading ||
                  state is LoginWithAppleLoading) {
                EasyLoading.show();
              } else {
                EasyLoading.dismiss();
              }

              // Handle login failure
              if (state is LoginFailureState) {
                _showErrorSnackBar(context, state.message);
              }

              // Handle regular login success
              if (state is LoginSuccessState) {
                _handleLoginSuccess(context, state.loginRequestResponse);
              }

              // Handle Google login success
              if (state is GoogleLoginLoaded) {
                _handleGoogleLoginSuccess(context, state.googleLoginResponse);
              }

              // Handle Apple login success
              if (state is LoginWithAppleLoaded) {
                _handleAppleLoginSuccess(
                  context,
                  state.appleLoginRequestResponse,
                );
              }

              // Handle Google login error
              if (state is GoogleLoginErrorState) {
                _handleGoogleLoginError(context, state.msg);
              }

              // Handle Apple login error
              if (state is LoginWithAppleError) {
                _handleAppleLoginError(context, state.errorMsg, state.appleId);
              }

              // General error handling
              if (state is LoginFailureState ||
                  state is GoogleLoginErrorState ||
                  state is LoginWithAppleError) {
                EasyLoading.dismiss();
                final errorMessage = _getErrorMessage(state);
                _showErrorToast(errorMessage);
              }
            },

            builder: (context, state) {
              final emailError =
                  state is LoginFormState ? state.emailError : null;
              final passwordError =
                  state is LoginFormState ? state.passwordError : null;
              final bool isLoading = state is LoginLoadingState;

              return WillPopScope(
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
                        top: 50,
                        left: 0,
                        right: 0,
                        bottom: 650.h,
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
                        height: MediaQuery.of(context).size.height * 0.72,
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
                                          horizontal: 25.w,
                                          vertical: 25.h,
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
                                                            .read<LoginBloc>()
                                                            .add(
                                                              EmailChanged(
                                                                value,
                                                              ),
                                                            );
                                                      },
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
                                                            .read<LoginBloc>()
                                                            .add(
                                                              PasswordChanged(
                                                                value,
                                                              ),
                                                            );
                                                      },
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
                                                    extra: "cafe-owner",
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
                                                              if (_networkState
                                                                  is NetworkFailure) {
                                                                Fluttertoast.showToast(
                                                                  fontSize:
                                                                      14.sp,
                                                                  msg:
                                                                      "No internet connection",
                                                                  backgroundColor:
                                                                      AppColors
                                                                          .primaryWhiteColor,
                                                                  textColor:
                                                                      AppColors
                                                                          .appRedColor,
                                                                );
                                                                return;
                                                              }
                                                              context
                                                                  .read<
                                                                    LoginBloc
                                                                  >()
                                                                  .add(
                                                                    FormSubmitted(),
                                                                  );
                                                            },
                                                    child: ElevatedButtonWidget(
                                                      height: 70.h,
                                                      width:
                                                          MediaQuery.of(
                                                            context,
                                                          ).size.width,
                                                      iconEnabled: false,
                                                      iconLabel: "LOGIN",
                                                      color: AppColors.primary,
                                                      textColor:
                                                          AppColors
                                                              .primaryWhiteColor,
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
                                                    '/signup',
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
                      ),
                    ],
                  ),
                ),
                onWillPop: () async {
                  EasyLoading.dismiss();
                  if (_navigationSource == 'category_screen') {
                    context.go('/category');
                    return false; // We handle navigation ourselves
                  }
                  final now = DateTime.now();
                  if (_lastBackPressed == null ||
                      now.difference(_lastBackPressed!) >
                          Duration(seconds: 2)) {
                    _lastBackPressed = now;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Press again to quit'),
                        duration: Duration(seconds: 2),
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
              );
            },
          );
        },
      ),
    );
  }

  void _handleLoginSuccess(
    BuildContext context,
    LoginRequestResponse response,
  ) {
    if (response.status == true) {
      final token = response.token;
      final cafeId = response.cafeId;
      final user = response.user;
      final isEmailVerified = user?.isEmailVerified == 1;

      // Handle successful login with complete user data
      if (token?.isNotEmpty == true &&
          cafeId?.isNotEmpty == true &&
          isEmailVerified) {
        _setUserPreferences(response);
        context.go('/home');
      }

      // Handle subscription status
      // if (response.subscriptionStatus == false) {
      //   context.go('/login');
      // }

      // Handle missing cafe linkage
      if (token?.isNotEmpty == true && (cafeId == null || cafeId.isEmpty)) {
        _showErrorSnackBar(
          context,
          "Login failed. Your account is not linked to a cafe. Please contact support.",
        );
      }
    } else {
      // Handle login failure
      EasyLoading.dismiss();
      _showErrorSnackBar(context, response.message ?? "Login failed");

      // Handle email verification requirement
      if (response.message == "Please verify your email first.") {
        _navigateToVerification(context);
      }
    }
  }

  void _handleGoogleLoginSuccess(
    BuildContext context,
    GoogleLoginRequestResponse response,
  ) {
    EasyLoading.dismiss();

    // if (response.status == true) {
    //   if (response.subscriptionStatus == false) {
    //     context.go('/login');
    //   }
    // }

    if (response.status == true && response.token != null) {
      _setGoogleUserPreferences(response);
      context.go('/home');
    } else {
      EasyLoading.dismiss();
      _showErrorToast(response.message ?? "Google login failed");

      if (response.message ==
          "You are not registered in our app. Please complete the signup process!") {
        _navigateToSignup(context, isGoogleSignUp: true);
      }
    }
  }

  void _handleAppleLoginSuccess(
    BuildContext context,
    AppleLoginRequestResponse response,
  ) {
    EasyLoading.dismiss();

    // if (response.status == true) {
    //   if (response.subscriptionStatus == false) {
    //     context.go('/login');
    //   }
    // }

    if (response.status == true && response.token != null) {
      _setAppleUserPreferences(response);
      context.go('/home');
    } else {
      ObjectFactory().prefs.setAppleAuthID(appleAuthID: response.appleId);
      EasyLoading.dismiss();
      _showErrorToast(response.message ?? "Apple login failed");

      if (response.message ==
          "You are not registered in our app. Please complete the signup process!") {
        _navigateToSignup(context, isAppleSignUp: true);
      }
    }
  }

  void _handleGoogleLoginError(BuildContext context, String message) {
    EasyLoading.dismiss();
    _showErrorToast(message);

    if (message ==
        "You are not registered in our app. Please complete the signup process!") {
      _navigateToSignup(context, isGoogleSignUp: true);
    }
  }

  void _handleAppleLoginError(
    BuildContext context,
    String errorMessage,
    String? appleId,
  ) {
    EasyLoading.dismiss();
    ObjectFactory().prefs.setAppleAuthID(appleAuthID: appleId);
    _showErrorToast(errorMessage);

    if (errorMessage ==
        "You are not registered in our app. Please complete the signup process!") {
      _navigateToSignup(context, isAppleSignUp: true);
    }
  }

  void _setUserPreferences(LoginRequestResponse response) {
    final prefs = ObjectFactory().prefs;

    prefs.setIsLoggedIn(true);
    prefs.setEmailVerified(true);
    prefs.setAuthToken(token: response.token);
    prefs.setCafeId(cafeId: response.cafeId);
    prefs.setCafeUserId(cafeUserId: response.user!.id.toString());

    if (response.user?.name != null) {
      prefs.setCafeUserName(cafeUserName: response.user!.name);
    }
  }

  void _setGoogleUserPreferences(GoogleLoginRequestResponse response) {
    final prefs = ObjectFactory().prefs;

    prefs.setIsLoggedIn(true);
    prefs.setIsGoogle(true);
    prefs.setAuthToken(token: response.token);
    prefs.setCafeId(cafeId: response.cafeId);
    prefs.setCafeUserId(cafeUserId: response.user!.id.toString());
    prefs.setCafeUserName(cafeUserName: response.user!.name);
  }

  void _setAppleUserPreferences(AppleLoginRequestResponse response) {
    final prefs = ObjectFactory().prefs;

    prefs.setIsLoggedIn(true);
    prefs.setIsApple(true);
    prefs.setAuthToken(token: response.token);
    prefs.setCafeId(cafeId: response.cafeId);
    prefs.setCafeUserId(cafeUserId: response.user!.id.toString());
    prefs.setCafeUserName(cafeUserName: response.user!.name);
  }

  void _showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppColors.appRedColor),
    );
  }

  void _showErrorToast(String message) {
    Fluttertoast.showToast(
      fontSize: 14.sp,
      msg: message,
      backgroundColor: AppColors.primaryWhiteColor,
      textColor: AppColors.appRedColor,
    );
  }

  void _showEmailVerificationToast(String message) {
    Fluttertoast.showToast(
      fontSize: 14.sp,
      msg: message,
      backgroundColor: AppColors.primaryWhiteColor,
      textColor: AppColors.appRedColor,
    );
  }

  void _navigateToVerification(BuildContext context) {
    context.go(
      '/verify',
      extra: VerifyScreenArguments(
        email: _emailController.text,
        otp: "",
        type: "register",
        from: 'venue_owner',
      ),
    );
  }

  void _navigateToSignup(
    BuildContext context, {
    bool isGoogleSignUp = false,
    bool isAppleSignUp = false,
  }) {
    final prefs = ObjectFactory().prefs;

    context.push(
      '/signup',
      extra: SignUpScreenArgument(
        imageBase64: prefs.getCafeUserImage().toString() ?? "",
        isGoggleSignUp: isGoogleSignUp,
        isAppleSignUp: isAppleSignUp,
        email: prefs.getCafeUserMail().toString() ?? "",
        displayName: prefs.getCafeUserName().toString() ?? "",
        phone: prefs.getCafeUserPhone().toString() ?? "",
      ),
    );
  }

  String _getErrorMessage(dynamic state) {
    if (state is LoginFailureState) {
      return state.message;
    } else if (state is LoginWithAppleError) {
      return state.errorMsg;
    } else if (state is GoogleLoginErrorState) {
      return state.msg;
    }
    return "Something went wrong.";
  }
}
