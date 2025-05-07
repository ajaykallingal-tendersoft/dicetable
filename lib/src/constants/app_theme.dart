import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';
import 'app_textStyle.dart';

class AppTheme {
  static ThemeData get lightTheme => ThemeData(
    visualDensity: VisualDensity.adaptivePlatformDensity,
    useMaterial3: true,
    brightness: Brightness.light,
    // scaffoldBackgroundColor: AppColors.background,
    primaryColor: AppColors.primary,
    fontFamily: GoogleFonts.montserrat().fontFamily,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.primaryWhiteColor,
      elevation: 0,
      iconTheme: IconThemeData(color: AppColors.textPrimary),
      titleTextStyle: TextStyle(
        color: AppColors.textPrimary,
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
    ),
    textTheme: TextTheme(
      headlineLarge: AppTextStyles.heading1,
      bodyMedium: AppTextStyles.bodyMedium,
      bodySmall: AppTextStyles.caption,
      bodyLarge: AppTextStyles.heading2,
      labelMedium: AppTextStyles.primaryBoldText,
      labelLarge: AppTextStyles.labelLarge,


    ),
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primaryWhiteColor,
      brightness: Brightness.light,
    ),
  );
}