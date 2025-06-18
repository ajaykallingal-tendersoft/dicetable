import 'package:dicetable/src/common/custom_text_field.dart';
import 'package:dicetable/src/common/elevated_button_widget.dart';
import 'package:dicetable/src/constants/app_colors.dart';
import 'package:dicetable/src/model/cafe_owner/auth/forgot_password/forgot_password_request.dart';
import 'package:dicetable/src/resources/api_providers/auth/auth_data_provider.dart';
import 'package:dicetable/src/ui/cafe_owner/authentication/forgot_password/reset_arguments.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

import 'bloc/forgotPassword/forgot_password_bloc.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  late final TextEditingController _controller;
  late final FocusNode focusNode;
  bool _isDisposed = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    focusNode = FocusNode();
  }

  @override
  void dispose() {
    _isDisposed = true;
    _controller.dispose();
    focusNode.dispose();
    super.dispose();
  }

  bool _validateEmail(String email) {
    if (email.isEmpty) {
      _showSnackBar("Please enter your email address", AppColors.appRedColor);
      return false;
    }
    if (!RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$').hasMatch(email)) {
      _showSnackBar("Please enter a valid email address", AppColors.appRedColor);
      return false;
    }

    return true;
  }

  void _showSnackBar(String message, Color color) {
    if (!mounted || _isDisposed) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ForgotPasswordBloc(authDataProvider: AuthDataProvider()),
      child: Scaffold(
        appBar: _buildAppBar(context),
        body: _buildBody(context),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.primary,
      leading: InkWell(
        onTap: () => context.pop(),
        child: SvgPicture.asset(
          'assets/svg/back.svg',
          fit: BoxFit.scaleDown,
        ),
      ),
      title: Text(
        'Forgot Password',
        style: TextTheme.of(context).labelLarge,
        textAlign: TextAlign.left,
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    return SizedBox.expand(
      child: DecoratedBox(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/png/fp-bg.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 10),
          child: SingleChildScrollView(
            key: const ValueKey('forgot_password_scroll'), // Unique key
            physics: const BouncingScrollPhysics(),
            child: _buildContent(context),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    return Column(
      children: [
        const Gap(100),
        _buildInstructionText(context),
        const Gap(30),
        _buildEmailField(),
        const Gap(60),
        _buildSendButton(context),
      ],
    );
  }

  Widget _buildInstructionText(BuildContext context) {
    return Text(
      "Enter your Email ID To send the OTP code",
      style: TextTheme.of(context).labelLarge!.copyWith(
        fontSize: 16,
        color: AppColors.primaryBlackColor,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildEmailField() {
    return CustomTextField(
      hintText: 'Email Address',
      controller: _controller,
      // focusNode: focusNode,
      // keyboardType: TextInputType.emailAddress,
      // textInputAction: TextInputAction.done,
    );
  }

  Widget _buildSendButton(BuildContext context) {
    return BlocConsumer<ForgotPasswordBloc, ForgotPasswordState>(
      listener: (context, state) {
        if (state is ForgotPasswordError) {
          _showSnackBar(state.errorMessage, AppColors.appRedColor);
        }
        if (state is ForgotPasswordLoaded) {
          final response = state.forgotPasswordRequestResponse;
          if (response.status == true) {
            _showSnackBar(
              response.message!,
              AppColors.appGreenColor,
            );

            if (mounted && !_isDisposed) {
              context.push(
                '/forgot_password_otp',
                extra: ResetArguments(
                  email: _controller.text,
                  token: "",
                  expiresAt: response.expiresAt,
                  resendAvailableInSeconds: response.resendAvailableInSeconds,
                ),
              );
            }
          }else if (response.status == false) {
            if (response.errors != null && response.errors!.isNotEmpty) {
              final errorMessages = response.errors!.values
                  .map((e) => e is List ? e.join(', ') : e.toString())
                  .join('\n');

              _showSnackBar(errorMessages, AppColors.appRedColor);
            } else if (response.message != null) {
              _showSnackBar(response.message!, AppColors.appRedColor);
            } else {
              _showSnackBar('Something went wrong', AppColors.appRedColor);
            }
          }
        }
      },
      builder: (context, state) {
        final bool isLoading = state is ForgotPasswordLoading;
        return InkWell(
          onTap: isLoading ? null : () {
            final email = _controller.text.trim();
            if (_validateEmail(email)) {
              context.read<ForgotPasswordBloc>().add(
                GetForgotPasswordEvent(
                  forgotPasswordRequest: ForgotPasswordRequest(
                    email: email,
                  ),
                ),
              );
            }
          },
          child: Stack(
            alignment: Alignment.center,
            children: [
              ElevatedButtonWidget(
                height: 70.h,
                width: 377.w,
                iconEnabled: false,
                iconLabel: isLoading ? "" : "SEND",
                color: isLoading
                    ? AppColors.primary.withOpacity(0.7)
                    : AppColors.primary,
                textColor: AppColors.primaryWhiteColor,
              ),
              if (isLoading)
                const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                    AppColors.primaryWhiteColor,
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}