import 'package:dicetable/src/common/modal_barrier_with_progress_indicator_widget.dart';
import 'package:dicetable/src/ui/cafe_owner/authentication/sign_up/sign_up_screen_argument.dart';
import 'package:dicetable/src/utils/network_connectivity/network_connectivity_bloc.dart';
import 'package:dicetable/src/utils/network_connectivity/network_toast_manager.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:dicetable/src/common/custom_login_text_field.dart';
import 'package:dicetable/src/common/divider_with_center_text.dart';
import 'package:dicetable/src/common/elevated_button_widget.dart';
import 'package:dicetable/src/common/login_or_signup_prompt.dart';
import 'package:dicetable/src/constants/app_colors.dart';
import 'package:dicetable/src/resources/api_providers/auth/auth_data_provider.dart';
import 'package:dicetable/src/ui/cafe_owner/authentication/login/bloc/login_bloc.dart';
import 'package:dicetable/src/ui/cafe_owner/authentication/login/widget/login_with_google_widget.dart';
import 'package:dicetable/src/utils/data/object_factory.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

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
    // Delay slightly to allow keyboard to appear
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

  void _handleLoginSuccess(
    BuildContext context,
    String token,
    String name, {
    bool isGoogle = false,
  }) {
    ObjectFactory().prefs.setAuthToken(token: token);
    ObjectFactory().prefs.setIsLoggedIn(true);
    if (isGoogle) {
      ObjectFactory().prefs.setCafeUserName(cafeUserName: name);
      ObjectFactory().prefs.setAuthToken(token: token);
      ObjectFactory().prefs.setIsLoggedIn(true);
    }

    context.go('/home');
    Fluttertoast.showToast(
      backgroundColor: AppColors.primaryWhiteColor,
      textColor: AppColors.appGreenColor,
      gravity: ToastGravity.BOTTOM,
      msg:
          isGoogle
              ? "Successfully Logged In with Google."
              : "Successfully Logged In.",
    );
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
              print('Login state: $state');
              debugPrint('Login state: $state');

              if (state is LoginLoadingState) {
                EasyLoading.show(status: 'Please wait...');
              } else if (state is GoogleLoginLoading) {
                EasyLoading.show(status: 'Please wait...');
              } else {
                EasyLoading.dismiss();
              }

              // Normal login success
              if (state is LoginSuccessState) {
                _handleLoginSuccess(
                  context,
                  state.loginRequestResponse.token!,
                  '',
                  isGoogle: false,
                );
              }

              if (state is GoogleLoginLoaded) {
                final response = state.googleLoginResponse;

                if (response.status == true && response.token != null) {
                  _handleLoginSuccess(
                    context,
                    response.token!,
                    response.user?.name ?? '',
                    isGoogle: true,
                  );
                } else {
                  print("Message: ${response.message}");
                  Fluttertoast.showToast(
                    msg: response.message ?? "Google login failed",
                    backgroundColor: AppColors.primaryWhiteColor,
                    textColor: AppColors.appRedColor,
                  );

                  if (response.message ==
                      "You are not registered in our app. Please complete the signup process!") {
                    context.push(
                      '/signup',
                      extra: SignUpScreenArgument(
                        imageBase64:
                            ObjectFactory().prefs
                                .getCafeUserImage()
                                .toString() ??
                            "",
                        isGoggleSignUp: true,
                        email:
                            ObjectFactory().prefs
                                .getCafeUserMail()
                                .toString() ??
                            "",
                        displayName:
                            ObjectFactory().prefs
                                .getCafeUserName()
                                .toString() ??
                            "",
                        phone:
                            ObjectFactory().prefs
                                .getCafeUserPhone()
                                .toString() ??
                            "",
                      ),
                    );
                  }
                }
              }
              if (state is GoogleLoginErrorState) {
                print('GoogleLoginErrorState reached');
                Fluttertoast.showToast(
                  msg: state.msg,
                  backgroundColor: AppColors.primaryWhiteColor,
                  textColor: AppColors.appRedColor,
                );

                if (state.msg ==
                    "You are not registered in our app. Please complete the signup process!") {
                  print('Navigating to /signup');
                  context.push(
                    '/signup',
                    extra: SignUpScreenArgument(
                      imageBase64:
                          ObjectFactory().prefs.getCafeUserImage().toString() ??
                          "",
                      isGoggleSignUp: true,
                      email:
                          ObjectFactory().prefs.getCafeUserMail().toString() ??
                          "",
                      displayName:
                          ObjectFactory().prefs.getCafeUserName().toString() ??
                          "",
                      phone:
                          ObjectFactory().prefs.getCafeUserPhone().toString() ??
                          "",
                    ),
                  );
                }
              }

              // Error handling
              if (state is LoginFailureState ||
                  state is GoogleLoginErrorState) {
                final errorMessage =
                    state is LoginFailureState
                        ? state.message
                        : (state as GoogleLoginErrorState).msg;

                Fluttertoast.showToast(
                  msg: errorMessage,
                  backgroundColor: AppColors.primaryWhiteColor,
                  textColor: AppColors.appRedColor,
                );
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
                        top: 0,
                        bottom: 650.h,
                        left: 0,
                        right: 0,
                        child: SvgPicture.asset(
                              'assets/svg/login-logo.svg',
                              height: 162.h,
                              width: 114.w,
                              fit: BoxFit.scaleDown,
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
                                                    child: Stack(
                                                      alignment:
                                                          Alignment.center,
                                                      children: [
                                                        ElevatedButtonWidget(
                                                          height: 70.h,
                                                          width:
                                                              double.infinity,
                                                          iconEnabled: false,
                                                          iconLabel:
                                                              isLoading
                                                                  ? ""
                                                                  : "LOGIN",
                                                          color:
                                                              AppColors.primary,
                                                          textColor:
                                                              AppColors
                                                                  .primaryWhiteColor,
                                                        ),
                                                        if (isLoading)
                                                          CircularProgressIndicator(
                                                            valueColor:
                                                                AlwaysStoppedAnimation<
                                                                  Color
                                                                >(
                                                                  AppColors
                                                                      .primaryWhiteColor,
                                                                ),
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
                                              Gap(10),
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
                                              Gap(30),
                                              LoginOrSignupPrompt(
                                                spanText:
                                                    'Dont have an account yet',
                                                promptText: 'Sign Up Now',
                                                onSignInTap: () {
                                                  context.push('/signup');
                                                },
                                              ).animate().fadeIn(
                                                duration: 500.ms,
                                                delay: 1000.ms,
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
}
