import 'dart:io';
import 'package:dicetable/src/common/custom_login_text_field.dart';
import 'package:dicetable/src/common/divider_with_center_text.dart';
import 'package:dicetable/src/common/elevated_button_widget.dart';
import 'package:dicetable/src/common/login_or_signup_prompt.dart';
import 'package:dicetable/src/constants/app_colors.dart';
import 'package:dicetable/src/resources/api_providers/auth/auth_data_provider.dart';
import 'package:dicetable/src/ui/cafe_owner/authentication/login/widget/login_with_google_widget.dart';
import 'package:dicetable/src/ui/customer/authentication/login/bloc/customer_login_bloc.dart';
import 'package:dicetable/src/utils/data/object_factory.dart';
import 'package:dicetable/src/utils/network_connectivity/network_connectivity_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

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
      create: (context) => CustomerLoginBloc(authDataProvider: AuthDataProvider()),
      child: Builder(
        builder: (context) {
          return BlocListener<NetworkConnectivityBloc, NetworkConnectivityState>(
            listener: (context, state) {
              if (state is NetworkFailure) {
                setState(() {
                  _isConnected = false;
                });
                Fluttertoast.showToast(
                  msg: "No internet connection",
                  backgroundColor: AppColors.appRedColor,
                  textColor: AppColors.primaryWhiteColor,
                );
              } else if (state is NetworkSuccess) {
                setState(() {
                  _isConnected = true;
                });
                Fluttertoast.showToast(
                  msg: "Back online",
                  backgroundColor:  AppColors.appGreenColor,
                  textColor: AppColors.primaryWhiteColor,
                );
              }
            },
            child: BlocConsumer<CustomerLoginBloc, CustomerLoginState>(
            listener: (context, state) {
              print('Login state: $state');
              if (state is CustomerLoginLoadingState) {
                setState(() {
                  _isSubmitting = true;
                });
              } else {
                setState(() {
                  _isSubmitting = false;
                });
              }

              if (state is CustomerLoginSuccessState) {
                ObjectFactory().prefs.setCustomerAuthToken(token: state.loginRequestResponse.token);
                ObjectFactory().prefs.setIsCustomerLoggedIn(true);
                context.go('/customer_home');
                Fluttertoast.showToast(
                  backgroundColor: AppColors.primaryWhiteColor,
                  textColor: AppColors.appGreenColor,
                  gravity: ToastGravity.BOTTOM,
                  msg: "Successfully Logged In.",
                );
              }

              if (state is CustomerLoginFailureState) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                    backgroundColor: AppColors.appRedColor,
                  ),
                );
              }

              if (state is LoginFormState) {
                if (state.emailError != null || state.passwordError != null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text(
                        'Please provide all the required details to continue!',
                      ),
                      backgroundColor: AppColors.appRedColor,
                    ),
                  );
                }
              }
            },
            builder: (context, state) {
              final emailError = state is LoginFormState
                  ? state.emailError
                  : null;
              final passwordError = state is LoginFormState
                  ? state.passwordError
                  : null;
              final bool isLoading = state is CustomerLoginLoadingState;

              return WillPopScope(
                onWillPop: () async {
                  if (_navigationSource == 'category_screen') {
                    context.go('/category');
                    return false; // We handle navigation ourselves
                  }
                  final now = DateTime.now();
                  if (_lastBackPressed == null ||
                      now.difference(_lastBackPressed!) > Duration(seconds: 2)) {
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
                child: Scaffold(
                  resizeToAvoidBottomInset: false,
                  body: Stack(
                    children: [
                      // Background image with fade-in animation
                      Positioned.fill(
                        child: Image.asset(
                          'assets/png/login-bg.png',
                          fit: BoxFit.cover,
                        ).animate()
                            .fadeIn(duration: 800.ms, curve: Curves.easeOut),
                      ),

                      Positioned(
                        top: 0,
                        bottom: 650.h,
                        left: 0,
                        right: 0,
                        child: SvgPicture.asset(
                          'assets/svg/login-logo.svg',
                          height: 162.h,
                          width: 114.w,
                          fit: BoxFit.scaleDown,
                        ).animate()
                            .scale(
                            begin: const Offset(0.8, 0.8),
                            end: const Offset(1, 1),
                            duration: 600.ms,
                            curve: Curves.easeOutBack
                        )
                            .fadeIn(duration: 500.ms),
                      ),

                      Positioned(
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
                              child: LayoutBuilder(
                                builder: (context, constraints) {
                                  return NotificationListener<OverscrollIndicatorNotification>(
                                    onNotification: (overscroll) {
                                      overscroll.disallowIndicator();
                                      return true;
                                    },
                                    child: Padding(
                                      padding: EdgeInsets.only(
                                        bottom: MediaQuery.of(context).viewInsets.bottom,
                                      ),
                                      child: SingleChildScrollView(
                                        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
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
                                                  fontWeight: FontWeight.w600,
                                                  color: AppColors.primaryWhiteColor,
                                                ),
                                              ).animate()
                                                  .fadeIn(duration: 600.ms, delay: 300.ms)
                                                  .scale(
                                                  begin: const Offset(0.9, 0.9),
                                                  duration: 600.ms,
                                                  curve: Curves.easeOutBack,
                                                  delay: 300.ms
                                              ),

                                              Gap(10),

                                              Container(
                                                key: _emailFieldKey,
                                                child: CustomLoginTextField(
                                                  hintText: "Email Address",
                                                  icon: SvgPicture.asset('assets/svg/email.svg'),
                                                  controller: _emailController,
                                                  focusNode: _emailFocusNode,
                                                  errorText: emailError,
                                                  onChanged: (value) {
                                                    context.read<CustomerLoginBloc>().add(
                                                      EmailChanged(value),
                                                    );
                                                  },
                                                ),
                                              ).animate()
                                                  .fadeIn(duration: 600.ms, delay: 400.ms)
                                                  .slideX(
                                                  begin: 0.2,
                                                  end: 0,
                                                  duration: 600.ms,
                                                  curve: Curves.easeOutQuad,
                                                  delay: 400.ms
                                              ),

                                              Gap(10),

                                              // Password field with slide-in animation
                                              Container(
                                                key: _passwordFieldKey,
                                                child: CustomLoginTextField(
                                                  isPassword: true,
                                                  hintText: "Password",
                                                  icon: SvgPicture.asset('assets/svg/pw.svg'),
                                                  controller: _passwordController,
                                                  focusNode: _passwordFocusNode,
                                                  errorText: passwordError,
                                                  onChanged: (value) {
                                                    context.read<CustomerLoginBloc>().add(
                                                      PasswordChanged(value),
                                                    );
                                                  },
                                                ),
                                              ).animate()
                                                  .fadeIn(duration: 600.ms, delay: 500.ms)
                                                  .slideX(
                                                  begin: 0.2,
                                                  end: 0,
                                                  duration: 600.ms,
                                                  curve: Curves.easeOutQuad,
                                                  delay: 500.ms
                                              ),

                                              Gap(8),

                                              // Forgot Password with fade-in animation
                                              InkWell(
                                                splashColor: AppColors.secondary,
                                                splashFactory: InkRipple.splashFactory,
                                                onTap: () {
                                                  context.push('/forgot_password');
                                                },
                                                child: Align(
                                                  alignment: Alignment.centerRight,
                                                  child: Text(
                                                    'Forgot Password?',
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .bodyMedium!
                                                        .copyWith(
                                                      color: AppColors.textFieldTextColor,
                                                      fontWeight: FontWeight.w600,
                                                      fontSize: 16,
                                                    ),
                                                  ),
                                                ),
                                              ).animate()
                                                  .fadeIn(duration: 400.ms, delay: 600.ms),
                                              Gap(15),
                                              InkWell(
                                                splashColor: AppColors.borderColor,
                                                splashFactory: InkRipple.splashFactory,
                                                onTap: isLoading
                                                    ? null
                                                    : () {
                                                  NetworkConnectivityBloc().add(NetworkObserve());
                                                  if (!_isConnected) {
                                                    Fluttertoast.showToast(
                                                      msg: "Please check your internet connection.",
                                                      backgroundColor: AppColors.appRedColor,
                                                      textColor: AppColors.primaryWhiteColor,
                                                    );
                                                    return;
                                                  }
                                                  context.read<CustomerLoginBloc>().add(
                                                    FormSubmitted(),
                                                  );
                                                },
                                                child: Stack(
                                                  alignment: Alignment.center,
                                                  children: [
                                                    ElevatedButtonWidget(
                                                      height: 70.h,
                                                      width: double.infinity,
                                                      iconEnabled: false,
                                                      iconLabel: isLoading ? "" : "LOGIN",
                                                      color: AppColors.primary,
                                                      textColor: AppColors.primaryWhiteColor,
                                                    ),
                                                    if (isLoading)
                                                      CircularProgressIndicator(
                                                        valueColor: AlwaysStoppedAnimation<Color>(
                                                          AppColors.primaryWhiteColor,
                                                        ),
                                                      ),
                                                  ],
                                                ),
                                              ).animate()
                                                  .fadeIn(duration: 600.ms, delay: 700.ms)
                                                  .slideY(
                                                  begin: 0.2,
                                                  end: 0,
                                                  duration: 600.ms,
                                                  curve: Curves.easeOutQuad,
                                                  delay: 700.ms
                                              )
                                                  .shimmer(
                                                  duration: 1200.ms,
                                                  delay: 1000.ms,
                                                  color: AppColors.primaryWhiteColor.withOpacity(0.3)
                                              ),

                                              Gap(10),

                                              DividerWithCenterText(
                                                centerText: 'Or Continue with',
                                              ).animate()
                                                  .fadeIn(duration: 500.ms, delay: 800.ms),

                                              Gap(10),

                                              LoginWithGoogleWidget()
                                                  .animate()
                                                  .fadeIn(duration: 600.ms, delay: 900.ms)
                                                  .scale(
                                                  begin: const Offset(0.9, 0.9),
                                                  end: const Offset(1, 1),
                                                  duration: 500.ms,
                                                  curve: Curves.elasticOut,
                                                  delay: 900.ms
                                              ),

                                              Gap(30),

                                              LoginOrSignupPrompt(
                                                spanText: 'Dont have an account yet',
                                                promptText: 'Sign Up Now',
                                                onSignInTap: () {
                                                  context.push('/customer_signUp');
                                                },
                                              ).animate()
                                                  .fadeIn(duration: 500.ms, delay: 1000.ms),

                                              // Skip sign in with pulse animation
                                              TextButton(
                                                onPressed: () => context.go('/customer_home'),
                                                child: Text(
                                                  'SKIP SIGN IN',
                                                  style: Theme.of(
                                                    context,
                                                  ).textTheme.labelMedium!.copyWith(
                                                    color: AppColors.primaryWhiteColor,
                                                    fontSize: 16.sp,
                                                  ),
                                                ),
                                              ).animate()
                                                  .fadeIn(duration: 500.ms, delay: 1100.ms)
                                                  .then()
                                                  .animate(onPlay: (controller) => controller.repeat(reverse: true))
                                                  .fadeIn(
                                                  begin: 0.6,
                                                  duration: 1500.ms
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
                      ).animate()
                          .fadeIn(duration: 800.ms)
                          .slideY(
                          begin: 0.1,
                          end: 0,
                          duration: 800.ms,
                          curve: Curves.easeOutQuint
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
);
        },
      ),
    );
  }
}
