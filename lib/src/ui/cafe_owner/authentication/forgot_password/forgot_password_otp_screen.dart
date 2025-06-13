import 'dart:async';
import 'package:dicetable/src/common/elevated_button_widget.dart';
import 'package:dicetable/src/constants/app_colors.dart';
import 'package:dicetable/src/model/cafe_owner/auth/forgot_password/resend_otp_request.dart';
import 'package:dicetable/src/model/verification/otp_verification_response.dart';
import 'package:dicetable/src/model/verification/otp_verify_request.dart';
import 'package:dicetable/src/resources/api_providers/auth/auth_data_provider.dart';
import 'package:dicetable/src/ui/cafe_owner/authentication/forgot_password/reset_arguments.dart';
import 'package:dicetable/src/ui/verification/bloc/verification_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:pinput/pinput.dart';

import 'bloc/forgotPassword/forgot_password_bloc.dart';

class ForgotPasswordOtpScreen extends StatefulWidget {
  final ResetArguments resetArguments;

  const ForgotPasswordOtpScreen({super.key, required this.resetArguments});

  @override
  State<ForgotPasswordOtpScreen> createState() =>
      _ForgotPasswordOtpScreenState();
}

class _ForgotPasswordOtpScreenState extends State<ForgotPasswordOtpScreen> {
  late final TextEditingController pinController;
  late final FocusNode focusNode;
  late final GlobalKey<FormState> formKey;
  late int resendTimerSeconds;
  Timer? _timer; // Make timer nullable
  bool canResend = false;
  bool _isDisposed = false; // Track disposal state

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _initializeTimer();
  }

  void _initializeControllers() {
    formKey = GlobalKey<FormState>();
    pinController = TextEditingController();
    focusNode = FocusNode();
  }

  void _initializeTimer() {
    resendTimerSeconds = widget.resetArguments.resendAvailableInSeconds ?? 60;
    canResend = resendTimerSeconds == 0;
    if (!canResend) {
      _startTimer();
    }
  }

  void _startTimer() {
    // Cancel existing timer before starting new one
    _timer?.cancel();

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_isDisposed) {
        timer.cancel();
        return;
      }

      if (resendTimerSeconds > 0) {
        if (mounted) {
          setState(() {
            resendTimerSeconds--;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            canResend = true;
          });
        }
        timer.cancel();
      }
    });
  }

  void _resetTimer(int newResendSeconds) {
    if (_isDisposed || !mounted) return;

    setState(() {
      resendTimerSeconds = newResendSeconds;
      canResend = false;
    });
    _startTimer();
  }

  bool _validateOtp(String otp) {
    if (otp.isEmpty) {
      _showToast("Please enter the OTP", AppColors.appRedColor);
      return false;
    }
    if (otp.length != 4 || !RegExp(r'^\d{4}$').hasMatch(otp)) {
      _showToast("OTP must be exactly 4 digits", AppColors.appRedColor);
      return false;
    }
    return true;
  }

  void _showToast(String message, Color textColor) {
    if (!mounted) return;

    Fluttertoast.showToast(
      backgroundColor: AppColors.primaryWhiteColor,
      textColor: textColor,
      gravity: ToastGravity.BOTTOM,
      msg: message,
    );
  }

  @override
  void dispose() {
    _isDisposed = true;
    _timer?.cancel();
    pinController.dispose();
    focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      body: _buildBody(context),
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
    return BlocConsumer<ForgotPasswordBloc, ForgotPasswordState>(
      listener: _handleForgotPasswordState,
      builder: (context, state) {
        return SizedBox.expand(
          child: DecoratedBox(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/png/fp-bg.png'),
                fit: BoxFit.cover,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 26,
                vertical: 10,
              ),
              child: SingleChildScrollView(
                key: ValueKey('otp_scroll_${widget.resetArguments.email}'), // Unique key
                physics: const BouncingScrollPhysics(),
                child: _buildContent(context),
              ),
            ),
          ),
        );
      },
    );
  }

  void _handleForgotPasswordState(BuildContext context, ForgotPasswordState state) {
    if (state is VerificationLoading || state is ResendOtpLoading) {
      EasyLoading.show(status: "Please wait");
    }

    if (state is ResendOtpSuccess) {
      EasyLoading.dismiss();
      final response = state.forgotPasswordRequestResponse;
      _showToast(
        response.message ?? 'OTP resent successfully',
        AppColors.appGreenColor,
      );
      pinController.clear();
      _resetTimer(response.resendAvailableInSeconds ?? 60);
    }

    if (state is VerificationErrorState || state is ResendOtpError) {
      EasyLoading.dismiss();
      final errorMessage = state is VerificationErrorState
          ? (state as VerificationErrorState).errorMessage
          : (state as ResendOtpError).errorMessage;
      _showToast(errorMessage, AppColors.appRedColor);
    }
  }

  Widget _buildContent(BuildContext context) {
    return Column(
      children: [
        const Gap(100),
        _buildEmailText(context),
        const Gap(30),
        _buildOtpForm(context),
        const Gap(20),
        _buildResendSection(context),
        const Gap(40),
        _buildVerifyButton(context),
      ],
    );
  }

  Widget _buildEmailText(BuildContext context) {
    return Text(
      "We have sent the verification code via email to ${widget.resetArguments.email}",
      style: TextTheme.of(context).labelLarge!.copyWith(
        fontSize: 16,
        color: AppColors.primaryBlackColor,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildOtpForm(BuildContext context) {
    const focusedBorderColor = AppColors.primaryWhiteColor;
    const fillColor = AppColors.primaryWhiteColor;
    const borderColor = AppColors.borderColor;

    final defaultPinTheme = PinTheme(
      width: 56.w,
      height: 56.h,
      textStyle: TextTheme.of(context).bodyMedium!.copyWith(
        color: AppColors.secondaryGreyTextColor,
        fontWeight: FontWeight.w600,
      ),
      decoration: BoxDecoration(
        color: fillColor,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: borderColor),
      ),
    );

    return Form(
      key: formKey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Directionality(
            textDirection: TextDirection.ltr,
            child: Pinput(
              controller: pinController,
              focusNode: focusNode,
              length: 4,
              defaultPinTheme: defaultPinTheme,
              separatorBuilder: (index) => const SizedBox(width: 8),
              hapticFeedbackType: HapticFeedbackType.lightImpact,
              onCompleted: (pin) => debugPrint('onCompleted: $pin'),
              onChanged: (value) => debugPrint('onChanged: $value'),
              cursor: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    margin: const EdgeInsets.only(bottom: 9),
                    width: 22,
                    height: 1,
                    color: AppColors.primaryWhiteColor,
                  ),
                ],
              ),
              focusedPinTheme: defaultPinTheme.copyWith(
                decoration: defaultPinTheme.decoration!.copyWith(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: focusedBorderColor),
                ),
              ),
              submittedPinTheme: defaultPinTheme.copyWith(
                decoration: defaultPinTheme.decoration!.copyWith(
                  color: fillColor,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.primary),
                ),
              ),
              errorPinTheme: defaultPinTheme.copyBorderWith(
                border: Border.all(color: AppColors.appRedColor),
              ),
              preFilledWidget: Center(
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: AppColors.secondaryGreyTextColor,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResendSection(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          canResend
              ? "Didn't receive the OTP?"
              : "Time Remaining $resendTimerSeconds seconds",
          style: Theme.of(context).textTheme.bodyMedium!.copyWith(
            color: AppColors.textFieldTextColor,
            fontSize: 14.sp,
          ),
        ),
        if (canResend) ...[
          const SizedBox(width: 5),
          GestureDetector(
            onTap: () {
              context.read<ForgotPasswordBloc>().add(
                ResendOtpEvent(
                  resendOtpRequest: ResendOtpRequest(
                    email: widget.resetArguments.email,
                  ),
                ),
              );
            },
            child: Text(
              "Send Again",
              style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                color: AppColors.paymentMethodSubText,
                fontSize: 14.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildVerifyButton(BuildContext context) {
    return BlocConsumer<VerificationBloc, VerificationState>(
      listener: (context, state) {
        if (state is VerificationLoading) {
          EasyLoading.show();
        }
        if (state is VerificationLoaded) {
          EasyLoading.dismiss();
          final response = state.otpVerificationResponse;
          if (response.status == true &&
              response.token != null &&
              response.token!.isNotEmpty) {
            _showToast(
              response.message ?? 'OTP verified successfully',
              AppColors.appGreenColor,
            );
            if (mounted) {
              context.go(
                '/reset_password',
                extra: ResetArguments(
                  email: widget.resetArguments.email,
                  token: response.token ?? "",
                ),
              );
            }
          }else if(
          response.status == false
          ){
            _showToast(
              response.message ?? 'Something went wrong!',
              AppColors.appRedColor,
            );
          }
        }

      },
      builder: (context, state) {
        return InkWell(
          onTap: () {
            final otp = pinController.text;
            if (_validateOtp(otp)) {
              context.read<VerificationBloc>().add(
                VerifyOtpEvent(
                  otpVerifyRequest: OtpVerifyRequest(
                    email: widget.resetArguments.email,
                    otp: otp,
                    type: "forgot_password",
                  ),
                ),
              );
            }
          },
          child: ElevatedButtonWidget(
            height: 70.h,
            width: 377.w,
            iconEnabled: false,
            iconLabel: "VERIFY",
            color: AppColors.primary,
            textColor: AppColors.primaryWhiteColor,
          ),
        );
      },
    );
  }
}