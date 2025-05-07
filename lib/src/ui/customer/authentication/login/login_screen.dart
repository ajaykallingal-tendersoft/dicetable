import 'package:dicetable/src/common/custom_login_text_field.dart';
import 'package:dicetable/src/common/divider_with_center_text.dart';
import 'package:dicetable/src/common/elevated_button_widget.dart';
import 'package:dicetable/src/common/login_or_signup_prompt.dart';
import 'package:dicetable/src/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
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
  final ScrollController _scrollController = ScrollController();

  void _scrollToField() {
    Future.delayed(Duration(milliseconds: 300), () {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void initState() {
    super.initState();
    _emailFocusNode.addListener(() {
      if (_emailFocusNode.hasFocus) {
        _scrollToField();
      }
    });

    _passwordFocusNode.addListener(() {
      if (_passwordFocusNode.hasFocus) {
        _scrollToField();
      }
    });
  }

  @override
  void dispose() {
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      // Ensures the screen resizes when keyboard appears
      body: Stack(
        children: [
          // Background Image
          Positioned.fill(
            child: Image.asset('assets/png/login-bg.png', fit: BoxFit.cover),
          ),

          // Logo on top
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

          // Scrollable login box
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: MediaQuery.of(context).size.height * 0.72,
            child: ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(53)),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/png/login-box.png'),
                    fit: BoxFit.cover,
                  ),
                ),
                child: SingleChildScrollView(
                  controller: _scrollController,
                  padding: EdgeInsets.symmetric(
                    horizontal: 26.w,
                    vertical: 26.h,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Welcome Back!',
                        style: Theme.of(
                          context,
                        ).textTheme.headlineLarge!.copyWith(
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primaryWhiteColor,
                        ),
                      ),
                      Gap(10),
                      CustomLoginTextField(
                        hintText: "Email Address",
                        icon: SvgPicture.asset('assets/svg/email.svg'),
                        controller: _emailController,
                        textFieldAnnotationText: 'Email Address',
                        focusNode: _emailFocusNode,
                      ),
                      Gap(10),
                      CustomLoginTextField(
                        isPassword: true,
                        hintText: "Password",
                        icon: SvgPicture.asset('assets/svg/pw.svg'),
                        controller: _passwordController,
                        textFieldAnnotationText: 'Password',
                        focusNode: _passwordFocusNode,
                      ),
                      Gap(8),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          'Forgot Password?',
                          style: Theme.of(
                            context,
                          ).textTheme.bodyMedium!.copyWith(
                            color: AppColors.textFieldTextColor,
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      Gap(15),
                      InkWell(
                        onTap: () {
                          context.go('/home');
                        },
                        child: ElevatedButtonWidget(
                          height: 70.h,
                          width: double.infinity,
                          iconEnabled: false,
                          iconLabel: "LOGIN",
                          color: AppColors.primary,
                          textColor: AppColors.primaryWhiteColor,
                        ),
                      ),
                      Gap(10),
                      DividerWithCenterText(centerText: 'Or Continue with'),
                      Gap(10),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 50.w,
                          vertical: 10.h,
                        ),
                        margin: EdgeInsets.all(16),
                        height: 70.h,
                        decoration: BoxDecoration(
                          color: AppColors.primaryWhiteColor,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SvgPicture.asset('assets/svg/google.svg'),
                            Gap(20),
                            Text(
                              'GOOGLE',
                              style: Theme.of(context).textTheme.labelMedium!
                                  .copyWith(color: AppColors.primary),
                            ),
                          ],
                        ),
                      ),
                      Gap(10),
                      LoginOrSignupPrompt(
                        spanText: 'Don’t have an account yet',
                        promptText: 'Sign Up Now',
                        onSignInTap: () {
                          context.push('/customer_signUp');
                        },
                      ),
                      Gap(10),
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
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
