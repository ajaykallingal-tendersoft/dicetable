import 'dart:ui';

import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

class AppTextStyles {
  static final heading1 = GoogleFonts.montserrat(
    fontSize: 38,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );

  static final heading2 = GoogleFonts.montserrat(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppColors.primary,
  );

  static final primaryBoldText = GoogleFonts.montserrat(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );
  static final labelLarge = GoogleFonts.montserrat(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.primaryWhiteColor,
  );
  static final bodyMedium = GoogleFonts.montserrat(
    fontSize: 14,
    color: AppColors.primaryWhiteColor,
  );


  static final caption = GoogleFonts.montserrat(
    fontSize: 12,
    color: AppColors.primaryWhiteColor,
  );
}