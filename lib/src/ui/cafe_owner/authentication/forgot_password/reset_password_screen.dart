import 'package:soloseaters/src/common/custom_text_field.dart';
import 'package:soloseaters/src/common/elevated_button_widget.dart';
import 'package:soloseaters/src/constants/app_colors.dart';
import 'package:soloseaters/src/model/cafe_owner/auth/forgot_password/password_reset_request.dart';
import 'package:soloseaters/src/resources/api_providers/auth/auth_data_provider.dart';
import 'package:soloseaters/src/ui/cafe_owner/authentication/forgot_password/bloc/passowrdReset/password_reset_bloc.dart';
import 'package:soloseaters/src/ui/cafe_owner/authentication/forgot_password/reset_arguments.dart';
import 'package:soloseaters/src/utils/data/object_factory.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

class ResetPasswordScreen extends StatefulWidget {
  final ResetArguments resetArguments;

  const ResetPasswordScreen({super.key, required this.resetArguments});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final TextEditingController _controller = TextEditingController();
  final TextEditingController _confirmController = TextEditingController();
  final userType = ObjectFactory().prefs.getUserDecisionName() == "PUBLIC_USER";

  FocusNode focusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create:
          (context) => PasswordResetBloc(authDataProvider: AuthDataProvider()),
      child: WillPopScope(
        onWillPop: () async {
          userType ? context.go('/customer_login') : context.go('/login');
          return false;
        },
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: AppColors.primary,
            leading: InkWell(
              onTap:
                  () =>
                      userType
                          ? context.go('/customer_login')
                          : context.go('/login'),
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
          ),
          body: SizedBox.expand(
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
                        "Reset your password now",
                        style: TextTheme.of(context).labelLarge!.copyWith(
                          fontSize: 16,
                          color: AppColors.primaryBlackColor,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      Gap(30),
                      CustomTextField(
                        isPassword: true,
                        hintText: 'New Password',
                        controller: _controller,
                      ),
                      Gap(10),
                      CustomTextField(
                        isPassword: true,
                        hintText: 'Confirm Password',
                        controller: _confirmController,
                      ),
                      Gap(60),
                      BlocConsumer<PasswordResetBloc, PasswordResetState>(
                        listener: (context, state) {
                          if (state is PasswordResetError) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(state.errorMessage),
                                backgroundColor: AppColors.appRedColor,
                              ),
                            );
                          }
                          if (state is PasswordResetLoaded) {
                            if (state.passwordResetRequestResponse.status ==
                                true) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    state.passwordResetRequestResponse.message!,
                                  ),
                                  backgroundColor: AppColors.appGreenColor,
                                ),
                              );
                              if (ObjectFactory().prefs.getUserDecisionName() ==
                                  "PUBLIC_USER") {
                                context.go('/customer_login');
                              } else {
                                context.go('/login');
                              }
                            }
                          }
                        },
                        builder: (context, state) {
                          final bool isLoading = state is PasswordResetLoading;
                          return Stack(
                            alignment: Alignment.center,
                            children: [
                              InkWell(
                                onTap:
                                    isLoading
                                        ? null
                                        : () {
                                          if (_controller.text.isEmpty ||
                                              _confirmController.text.isEmpty) {
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              const SnackBar(
                                                content: Text(
                                                  "To proceed, please provide your new password and confirm it.",
                                                ),
                                                backgroundColor:
                                                    AppColors.appRedColor,
                                              ),
                                            );
                                            return; // Stop execution
                                          }
                                          if (_controller.text !=
                                              _confirmController.text) {
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              const SnackBar(
                                                content: Text(
                                                  "Passwords do not match.",
                                                ),
                                                backgroundColor:
                                                    AppColors.appRedColor,
                                              ),
                                            );
                                            return; // Stop execution
                                          }
                                          context.read<PasswordResetBloc>().add(
                                            GetPasswordResetEvent(
                                              passwordResetRequest:
                                                  PasswordResetRequest(
                                                    email:
                                                        widget
                                                            .resetArguments
                                                            .email,
                                                    token:
                                                        widget
                                                            .resetArguments
                                                            .token,
                                                    password: _controller.text,
                                                    passwordConfirmation:
                                                        _confirmController.text,
                                                  ),
                                            ),
                                          );
                                        },
                                child: ElevatedButtonWidget(
                                  height: 70.h,
                                  width: 377.w,
                                  iconEnabled: false,
                                  iconLabel: isLoading ? "" : "UPDATE",
                                  color: AppColors.primary,
                                  textColor: AppColors.primaryWhiteColor,
                                ),
                              ),
                              if (isLoading)
                                const CircularProgressIndicator(
                                  // Changed to const
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    AppColors.primaryWhiteColor,
                                  ),
                                ),
                            ],
                          );
                        },
                      ),
                      // BlocConsumer<PasswordResetBloc, PasswordResetState>(
                      //   listener: (context, state) {
                      //     if (state is PasswordResetError) {
                      //       ScaffoldMessenger.of(context).showSnackBar(
                      //         SnackBar(
                      //           content: Text(state.errorMessage),
                      //           backgroundColor: AppColors.appRedColor,
                      //         ),
                      //       );
                      //     }
                      //     if (state is PasswordResetLoaded) {
                      //       if (state.passwordResetRequestResponse.message ==
                      //           "Password reset successful.") {
                      //         ScaffoldMessenger.of(context).showSnackBar(
                      //           SnackBar(
                      //             content: Text(
                      //               state.passwordResetRequestResponse.message!,
                      //             ),
                      //             backgroundColor: AppColors.appGreenColor,
                      //           ),
                      //         );
                      //         context.go('/login');
                      //       }
                      //     }
                      //   },
                      //   builder: (context, state) {
                      //     final bool isLoading = state is PasswordResetLoading;
                      //     return Stack(
                      //       children: [
                      //         InkWell(
                      //           onTap: () {
                      //             context.read<PasswordResetBloc>().add(
                      //               GetPasswordResetEvent(
                      //                 passwordResetRequest: PasswordResetRequest(
                      //                   email: widget.resetArguments.email,
                      //                   token: widget.resetArguments.token,
                      //                   password: _controller.text,
                      //                   passwordConfirmation:
                      //                       _confirmController.text,
                      //                 ),
                      //               ),
                      //             );
                      //           },
                      //           child: ElevatedButtonWidget(
                      //             height: 70.h,
                      //             width: 377.w,
                      //             iconEnabled: false,
                      //             iconLabel: isLoading ? "" : "UPDATE",
                      //             color: AppColors.primary,
                      //             textColor: AppColors.primaryWhiteColor,
                      //           ),
                      //         ),
                      //         if (isLoading)
                      //           CircularProgressIndicator(
                      //             valueColor: AlwaysStoppedAnimation<Color>(
                      //               AppColors.primaryWhiteColor,
                      //             ),
                      //           ),
                      //       ],
                      //     );
                      //   },
                      // ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
