import 'dart:async';
import 'package:soloseaters/src/common/elevated_button_widget.dart';
import 'package:soloseaters/src/constants/app_colors.dart';
import 'package:soloseaters/src/model/cafe_owner/auth/forgot_password/resend_otp_request.dart';
import 'package:soloseaters/src/model/verification/otp_verify_request.dart';
import 'package:soloseaters/src/ui/verification/bloc/verification_bloc.dart';
import 'package:soloseaters/src/ui/verification/verify_screen_argument.dart';
import 'package:soloseaters/src/utils/data/object_factory.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:pinput/pinput.dart';
import 'package:flutter/services.dart';
import '../cafe_owner/authentication/forgot_password/bloc/forgotPassword/forgot_password_bloc.dart';

class EmailVerificationScreen extends StatefulWidget {
  final VerifyScreenArguments verifyScreenArguments;

  const EmailVerificationScreen({
    super.key,
    required this.verifyScreenArguments,
  });

  @override
  State<EmailVerificationScreen> createState() =>
      _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
  late final TextEditingController pinController;
  late final FocusNode focusNode;
  late final GlobalKey<FormState> formKey;
  late int resendTimerSeconds;
  Timer? _timer;
  bool canResend = false;
  bool _isMounted = false;
  DateTime? currentBackPressTime;

  @override
  void initState() {
    super.initState();
    _isMounted = true;
    _initializeControllers();
    _initializeTimer();
  }

  void _initializeControllers() {
    formKey = GlobalKey<FormState>();
    pinController = TextEditingController();
    focusNode = FocusNode();
  }

  void _initializeTimer() {
    resendTimerSeconds = 45;
    canResend = false;
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!_isMounted) {
        timer.cancel();
        return;
      }

      if (resendTimerSeconds > 0) {
        setState(() {
          resendTimerSeconds--;
        });
      } else {
        setState(() {
          canResend = true;
        });
        timer.cancel();
      }
    });
  }

  void _resetTimer(int newResendSeconds) {
    if (!_isMounted) return;

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
    if (!_isMounted) return;

    Fluttertoast.showToast(
      backgroundColor: AppColors.primaryWhiteColor,
      textColor: textColor,
      gravity: ToastGravity.BOTTOM,
      msg: message,
    );
  }

  @override
  void dispose() {
    _isMounted = false;
    _timer?.cancel();
    pinController.dispose();
    focusNode.dispose();
    super.dispose();
  }

  Future<bool> onWillPop() async {
    DateTime now = DateTime.now();
    if (currentBackPressTime == null ||
        now.difference(currentBackPressTime!) > const Duration(seconds: 3)) {
      currentBackPressTime = now;
      Fluttertoast.showToast(
        backgroundColor: AppColors.secondary,
        textColor: AppColors.primaryWhiteColor,
        gravity: ToastGravity.BOTTOM,
        msg: "Please verify your email before leaving this screen.",
      );
      return Future.value(false);
    }
    if (Theme.of(context).platform == TargetPlatform.android) {
      SystemNavigator.pop();
      return false;
    }
    return true;

  }


  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: onWillPop,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: AppColors.primary,
          leading: const SizedBox(),
          title: Text(
            'Email Verification',

            style: Theme.of(context).textTheme.labelLarge,
            textAlign: TextAlign.left,
          ),

        ),
        body: MultiBlocListener(
          listeners: [
            BlocListener<VerificationBloc, VerificationState>(
              listener: (context, state) async {
                if (state is VerificationLoading) {
                  await EasyLoading.show(status: "Please wait");
                } else if (state is VerificationLoaded) {
                  await EasyLoading.dismiss();
                  if (state.otpVerificationResponse.status == true &&
                      state.otpVerificationResponse.message ==
                          "Email verified successfully.") {
                    try {
                      if (widget.verifyScreenArguments.from == "venue_owner") {
                        ObjectFactory().prefs.setIsLoggedIn(true);
                        // ObjectFactory().prefs.setAuthToken(token: state.loginRequestResponse.token);
                        _showToast(
                          state.otpVerificationResponse.message ??
                              "Verification successful",
                          AppColors.appGreenColor,
                        );
                        context.go('/subscription_prompt');
                      } else if (widget.verifyScreenArguments.from == "customer") {
                        ObjectFactory().prefs.setIsCustomerLoggedIn(true);
                        _showToast(
                          state.otpVerificationResponse.message ??
                              "Verification successful",
                          AppColors.appGreenColor,
                        );
                        context.go('/customer_home');
                      }
                    } catch (e) {
                      _showToast(
                        "Error saving login state: $e",
                        AppColors.appRedColor,
                      );
                    }
                  } else if(state.otpVerificationResponse.status == false) {
                    _showToast(
                      state.otpVerificationResponse.message!,
                      AppColors.appRedColor,
                    );
                  }
                } else if (state is VerificationErrorState) {
                  await EasyLoading.dismiss();
                  _showToast(
                    state.errorMessage,
                    AppColors.appRedColor,
                  );
                }
              },
            ),
            BlocListener<ForgotPasswordBloc, ForgotPasswordState>(
              listener: (context, state) async {
                if (state is ResendOtpLoading) {
                  await EasyLoading.show(status: "Resending OTP...");
                } else if (state is ResendOtpSuccess) {
                  await EasyLoading.dismiss();
                  _showToast(
                    state.forgotPasswordRequestResponse.message ??
                        'OTP resent successfully',
                    AppColors.appGreenColor,
                  );
                  pinController.clear();
                  _resetTimer(
                      state.forgotPasswordRequestResponse.resendAvailableInSeconds ??
                          60);
                } else if (state is ResendOtpError) {
                  await EasyLoading.dismiss();
                  _showToast(
                    state.errorMessage,
                    AppColors.appRedColor,
                  );
                }
              },
            ),
          ],
          child: _buildBody(context),
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    const focusedBorderColor = AppColors.primaryWhiteColor,
        fillColor = AppColors.primaryWhiteColor,
        borderColor = AppColors.borderColor;
    final defaultPinTheme = PinTheme(
      width: 56.w,
      height: 56.h,
      textStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(
        color: AppColors.secondaryGreyTextColor,
        fontWeight: FontWeight.w600,
      ),
      decoration: BoxDecoration(
        color: fillColor,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: borderColor),
      ),
    );
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
            physics: const BouncingScrollPhysics(),
            child: Column(
              children: [
                const Gap(100),
                Text(
                  "We have sent the verification code via email to ${widget.verifyScreenArguments.email}",
                  style: Theme.of(context).textTheme.labelLarge!.copyWith(
                    fontSize: 16,
                    color: AppColors.primaryBlackColor,
                  ),
                  textAlign: TextAlign.center,
                ),
                const Gap(30),
                Form(
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
                          validator: (value) {
                            return null;
                          },
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
                              border: Border.all(
                                color: focusedBorderColor,
                              ),
                            ),
                          ),
                          submittedPinTheme: defaultPinTheme.copyWith(
                            decoration: defaultPinTheme.decoration!.copyWith(
                              color: fillColor,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                          errorPinTheme: defaultPinTheme.copyBorderWith(
                            border: Border.all(
                              color: AppColors.appRedColor,
                            ),
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
                ),
                const Gap(20),
                _buildResendSection(context),
                const Gap(40),
                InkWell(
                  onTap: () {
                    final otp = pinController.text;
                    if (_validateOtp(otp)) {
                      context.read<VerificationBloc>().add(
                        VerifyOtpEvent(
                          otpVerifyRequest: OtpVerifyRequest(
                            email: widget.verifyScreenArguments.email,
                            otp: pinController.text,
                            type: widget.verifyScreenArguments.type,
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
                ),
              ],
            ),
          ),
        ),
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
                    email: widget.verifyScreenArguments.email,
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
}