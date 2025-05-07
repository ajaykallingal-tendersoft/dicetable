import 'dart:io';

import 'package:dicetable/src/common/custom_login_text_field.dart';
import 'package:dicetable/src/common/divider_with_center_text.dart';
import 'package:dicetable/src/common/elevated_button_widget.dart';
import 'package:dicetable/src/common/login_or_signup_prompt.dart';
import 'package:dicetable/src/constants/app_colors.dart';
import 'package:dicetable/src/model/cafe_owner/auth/login/login_request.dart';
import 'package:dicetable/src/resources/api_providers/auth/auth_data_provider.dart';
import 'package:dicetable/src/ui/cafe_owner/authentication/login/bloc/login_bloc.dart';
import 'package:dicetable/src/ui/cafe_owner/authentication/login/cubit/google_sign_in_cubit.dart';
import 'package:dicetable/src/ui/cafe_owner/authentication/login/widget/login_with_google_widget.dart';
import 'package:dicetable/src/utils/data/object_factory.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:online_payments_sdk/online_payments_sdk.dart';

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

  @override
  void initState() {
    super.initState();

    // Add listeners to ensure fields are visible when focused
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
            listener: (context, state) {
              print('Login state: $state');
              if (state is LoginLoadingState) {
                setState(() {
                  _isSubmitting = true;
                });
              } else {
                setState(() {
                  _isSubmitting = false;
                });
              }

              if (state is LoginSuccessState) {
                ObjectFactory().prefs.setAuthToken(token: state.loginRequestResponse.token);
                ObjectFactory().prefs.setIsLoggedIn(true);
                context.go('/home');
              }

              if (state is LoginFailureState) {
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
              final bool isLoading = state is LoginLoadingState;

              return WillPopScope(child: Scaffold(
                resizeToAvoidBottomInset: false,
                body: Stack(
                  children: [
                    Positioned.fill(
                      child: Image.asset(
                        'assets/png/login-bg.png',
                        fit: BoxFit.cover,
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
                      ),
                    ),
                    // Main content box
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
                                                  context.read<LoginBloc>().add(
                                                    EmailChanged(value),
                                                  );
                                                },
                                              ),
                                            ),
                                            Gap(10),
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
                                                  context.read<LoginBloc>().add(
                                                    PasswordChanged(value),
                                                  );
                                                },
                                              ),
                                            ),
                                            Gap(8),
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
                                            ),
                                            Gap(15),
                                            InkWell(
                                              splashColor: AppColors.borderColor,
                                              splashFactory: InkRipple.splashFactory,
                                              onTap: isLoading
                                                  ? null
                                                  : () {
                                                context.read<LoginBloc>().add(
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
                                            ),
                                            Gap(10),
                                            DividerWithCenterText(
                                              centerText: 'Or Continue with',
                                            ),
                                            Gap(10),
                                            LoginWithGoogleWidget(),
                                            Gap(30),
                                            LoginOrSignupPrompt(
                                              spanText: 'Dont have an account yet',
                                              promptText: 'Sign Up Now',
                                              onSignInTap: () {
                                                context.push('/signup');
                                              },
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
              ),   onWillPop: () async {
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
                exit(0);

              },);
            },
          );
        },
      ),
    );
  }
}