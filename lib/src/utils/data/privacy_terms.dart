import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:soloseaters/src/constants/app_colors.dart';
import 'package:url_launcher/url_launcher.dart';

class PrivacyAndTermsText extends StatelessWidget {
  final String privacyUrl;
  final String termsUrl;
  
  const PrivacyAndTermsText({
    Key? key,
    this.privacyUrl = "https://soloseaters.com/privacy-policy/",
    this.termsUrl = "https://soloseaters.com/terms/",
  }) : super(key: key);

 Future<void> _launchUrl(String url) async {
    try {
      final Uri uri = Uri.parse(url);
      
      // Simple approach - just use platformDefault
      await launchUrl(uri, mode: LaunchMode.platformDefault);
      
    } catch (e) {
      debugPrint("Error launching URL: $e");
      // Fallback: try with external browser
      try {
        final Uri uri = Uri.parse(url);
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } catch (fallbackError) {
        debugPrint("Fallback also failed: $fallbackError");
      }
    }
  }

  @override
Widget build(BuildContext context) {
  // Get screen width for responsive design
  final screenWidth = MediaQuery.of(context).size.width;
  
  // Calculate responsive font size
  final fontSize = screenWidth < 350 ? 11.0 : 12.0;
  
  // Get theme colors with fallback
  final textColor = AppColors.primaryWhiteColor;
  
  return Container(
    width: double.infinity, // Forces full width
    padding: const EdgeInsets.symmetric(horizontal: 0.0), // Remove extra padding
    child: Semantics(
      label: "Privacy policy and terms agreement text with clickable links",
      child: RichText(
        textAlign: TextAlign.center,
        textWidthBasis: TextWidthBasis.parent, // Use parent width for text wrapping
        text: TextSpan(
          style: GoogleFonts.montserrat(
            color: textColor,
            fontSize: fontSize,
            fontWeight: FontWeight.w500,
            height: 1.4, // Better line spacing
          ),
          children: [
            const TextSpan(
              text: "By using this app, you agree to our ",
            ),
            TextSpan(
              text: "Privacy Policy",
              style: GoogleFonts.montserrat(
                color: AppColors.secondary,
                decoration: TextDecoration.underline,
                decorationColor: AppColors.secondary,
                decorationThickness: 1.0,
                fontSize: fontSize,
                fontWeight: FontWeight.w600,
              ),
              recognizer: TapGestureRecognizer()
                ..onTap = () => _launchUrl(privacyUrl),
            ),
            const TextSpan(text: " and "),
            TextSpan(
              text: "Terms & Conditions",
              style: GoogleFonts.montserrat(
                color: AppColors.secondary,
                decoration: TextDecoration.underline,
                decorationColor: AppColors.secondary,
                decorationThickness: 1.0,
                fontSize: fontSize,
                fontWeight: FontWeight.w600,
              ),
              recognizer: TapGestureRecognizer()
                ..onTap = () => _launchUrl(termsUrl),
            ),
            const TextSpan(text: "."),
          ],
        ),
      ),
    ),
  );
}
}