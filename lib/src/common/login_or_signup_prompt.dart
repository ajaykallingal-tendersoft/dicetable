import 'package:google_fonts/google_fonts.dart';
import 'package:soloseaters/src/constants/app_colors.dart';
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
          style: GoogleFonts.montserrat(
            color: AppColors.primaryWhiteColor,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
          children: [
            TextSpan(
              text: promptText,
              style: GoogleFonts.montserrat(
                color: AppColors.primaryWhiteColor,
                decoration: TextDecoration.underline,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),

              recognizer: TapGestureRecognizer()..onTap = onSignInTap,
            ),
          ],
        ),
      ),
    );
  }
}
