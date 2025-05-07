import 'package:dicetable/src/common/custom_text_field.dart';
import 'package:dicetable/src/common/elevated_button_widget.dart';
import 'package:dicetable/src/constants/app_colors.dart';
import 'package:dicetable/src/model/cafe_owner/auth/forgot_password/password_reset_request.dart';
import 'package:dicetable/src/resources/api_providers/auth/auth_data_provider.dart';
import 'package:dicetable/src/ui/cafe_owner/authentication/forgot_password/bloc/passowrdReset/password_reset_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

class ResetPasswordScreen extends StatefulWidget {
  final String email;
  const ResetPasswordScreen({super.key,required this.email});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final TextEditingController _controller = TextEditingController();
  final TextEditingController _confirmController = TextEditingController();

  FocusNode focusNode = FocusNode();
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
  create: (context) => PasswordResetBloc(authDataProvider: AuthDataProvider()),
  child: Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        leading: InkWell(
          onTap: () => context.pop(),
            child: SvgPicture.asset('assets/svg/back.svg', fit: BoxFit.scaleDown)),
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
            padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 10),
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
                  hintText: 'New Password',
                  controller: _controller, textFieldAnnotationText: 'New Password',
                ),
                Gap(10),
                CustomTextField(
                  hintText: 'Create New Password',
                  controller: _controller, textFieldAnnotationText: 'Create New Password',
                ),
                Gap(60),
                BlocConsumer<PasswordResetBloc, PasswordResetState>(
  listener: (context, state) {
    if(state is PasswordResetError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(state.errorMessage),
          backgroundColor: AppColors.appRedColor,
        ),
      );
    }
    if(state is PasswordResetLoaded) {
      if(state.passwordResetRequestResponse.message == "Password reset successful.") {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(state.passwordResetRequestResponse.message!),
            backgroundColor: AppColors.appGreenColor,
          ),
        );
        context.go('/login');
      }
    }
  },
  builder: (context, state) {
    final bool isLoading = state is PasswordResetLoading;
    return Stack(
                  children: [
                    InkWell(
                      onTap: () {
                       context.read<PasswordResetBloc>().add(
                         GetPasswordResetEvent(
                           passwordResetRequest: PasswordResetRequest(
                               email: widget.email,
                               token: "",
                               password: _controller.text,
                               passwordConfirmation: _confirmController.text,
                           ),
                         ),);
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
                      CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<
                            Color>(
                          AppColors.primaryWhiteColor,
                        ),
                      ),
                  ],
                );
  },
),
              ],
            ),
          ),
        ),
      ),
    ),
);
  }
}
