import 'package:dicetable/src/common/elevated_button_widget.dart';
import 'package:dicetable/src/common/otp_widget.dart';
import 'package:dicetable/src/constants/app_colors.dart';
import 'package:dicetable/src/model/verification/otp_verify_request.dart';
import 'package:dicetable/src/resources/api_providers/auth/auth_data_provider.dart';
import 'package:dicetable/src/ui/verification/bloc/verification_bloc.dart';
import 'package:dicetable/src/ui/verification/verify_screen_argument.dart';
import 'package:dicetable/src/utils/data/object_factory.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:pinput/pinput.dart';

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
  late final SmsRetriever smsRetriever;
  late final TextEditingController pinController;
  late final FocusNode focusNode;
  late final GlobalKey<FormState> formKey;

  @override
  void initState() {
    super.initState();
    formKey = GlobalKey<FormState>();
    pinController = TextEditingController();
    focusNode = FocusNode();
  }

  @override
  void dispose() {
    pinController.dispose();
    focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create:
          (context) => VerificationBloc(authDataProvider: AuthDataProvider()),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: AppColors.primary,
          leading: SizedBox(),
          title: Text(
            'Dice app',
            style: TextTheme.of(context).labelLarge,
            textAlign: TextAlign.left,
          ),
        ),
        body: BlocConsumer<VerificationBloc, VerificationState>(
          listener: (context, state) {
            if (state is VerificationLoading) {
              EasyLoading.show(status: "Please wait");
            }
            if (state is VerificationLoaded) {
              EasyLoading.dismiss();
              if (state.otpVerificationResponse.status == true &&
                  state.otpVerificationResponse.message ==
                      "Email verified successfully.") {
              if(widget.verifyScreenArguments.from == "venue_owner") {

                ObjectFactory().prefs.setIsLoggedIn(true);
                Fluttertoast.showToast(
                  backgroundColor: AppColors.primaryWhiteColor,
                  textColor: AppColors.appGreenColor,
                  gravity: ToastGravity.BOTTOM,
                  msg: state.otpVerificationResponse.message!,
                );
                context.go('/subscription_prompt');
              }else if(widget.verifyScreenArguments.from == "customer") {

                ObjectFactory().prefs.setIsCustomerLoggedIn(true);
                Fluttertoast.showToast(
                  backgroundColor: AppColors.primaryWhiteColor,
                  textColor: AppColors.appGreenColor,
                  gravity: ToastGravity.BOTTOM,
                  msg: state.otpVerificationResponse.message!,
                );
                context.go('/customer_home');
              }
              }
            }
            if (state is VerificationErrorState) {
              EasyLoading.dismiss();
              Fluttertoast.showToast(
                backgroundColor: AppColors.primaryWhiteColor,
                textColor: AppColors.appGreenColor,
                gravity: ToastGravity.BOTTOM,
                msg: state.errorMessage,
              );
            }
          },
          builder: (context, state) {
            const focusedBorderColor = AppColors.primaryWhiteColor,
                fillColor = AppColors.primaryWhiteColor,
                borderColor = AppColors.borderColor;
            final defaultPinTheme = PinTheme(
              width: 56.w,
              height: 56.h,
              textStyle: TextTheme.of(context).bodyMedium!.copyWith(
                color: AppColors.secondaryGreyTextColor,
                fontWeight: FontWeight.w600,
              ),
              decoration: BoxDecoration(
                color: fillColor, // <-- 👈 ensures white background always
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: borderColor),
              ),
            );
            return SizedBox.expand(
              child: DecoratedBox(
                decoration: BoxDecoration(
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
                    physics: BouncingScrollPhysics(),
                    child: Column(
                      children: [
                        Gap(100),
                        Text(
                          "We have sent the verification code via email to ${widget.verifyScreenArguments.email}",
                          style: TextTheme.of(context).labelLarge!.copyWith(
                            fontSize: 16,
                            color: AppColors.primaryBlackColor,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        Gap(30),
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
                                  separatorBuilder:
                                      (index) => const SizedBox(width: 8),
                                  validator: (value) {
                                    return value ==
                                            widget.verifyScreenArguments.otp
                                        ? null
                                        : 'Pin is incorrect';
                                  },
                                  hapticFeedbackType:
                                      HapticFeedbackType.lightImpact,
                                  onCompleted:
                                      (pin) => debugPrint('onCompleted: $pin'),
                                  onChanged:
                                      (value) => debugPrint('onChanged: $value'),
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
                                    decoration: defaultPinTheme.decoration!
                                        .copyWith(
                                          borderRadius: BorderRadius.circular(8),
                                          border: Border.all(
                                            color: focusedBorderColor,
                                          ),
                                        ),
                                  ),
                                  submittedPinTheme: defaultPinTheme.copyWith(
                                    decoration: defaultPinTheme.decoration!
                                        .copyWith(
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
                                      decoration: BoxDecoration(
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
                        Gap(60),
                        InkWell(
                          onTap: () {
                            context.read<VerificationBloc>().add(
                              VerifyOtpEvent(
                                otpVerifyRequest: OtpVerifyRequest(
                                  email: widget.verifyScreenArguments.email,
                                  otp: pinController.text,
                                  type: widget.verifyScreenArguments.type,
                                ),
                              ),
                            );
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
          },
        ),
      ),
    );
  }
}
