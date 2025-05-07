import 'package:dicetable/src/constants/app_colors.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class LoginOrSignupPrompt extends StatelessWidget {
  const LoginOrSignupPrompt({
    super.key,
    required this.onSignInTap,
    required this.spanText,
    required this.promptText,
  });

  final VoidCallback onSignInTap;
  final String spanText;
  final String promptText;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: RichText(
        text: TextSpan(
          text: '$spanText? ',
          style: TextTheme.of(context).bodyMedium!.copyWith(
            color: AppColors.primaryWhiteColor,
            fontWeight: FontWeight.w500,
          ),
          children: [
            TextSpan(
              text: promptText,
              style: TextTheme.of(context).bodyMedium!.copyWith(
                color: AppColors.primaryWhiteColor,
                fontWeight: FontWeight.w500,
                decoration: TextDecoration.underline,
                decorationColor: AppColors.primaryWhiteColor,
              ),
              recognizer: TapGestureRecognizer()..onTap = onSignInTap,
            ),
          ],
        ),
      ),
    );
  }
}
