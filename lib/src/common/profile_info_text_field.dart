import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:soloseaters/src/constants/app_colors.dart';

class ProfileInfoTextField extends StatelessWidget {
  final TextEditingController controller;
  final double height;
  final int maxLines;
  final String? hintText;
  final ValueChanged<String>? onChanged;

  const ProfileInfoTextField({
    Key? key,
    required this.controller,
    this.height = 110,
    this.maxLines = 5,
    this.hintText,
    this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Color(0xFF094671), // Card background color
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: AppColors.profileTextFiledBorderColor,
        ),
      ),
      child: TextField(
        keyboardType: TextInputType.text,
        textInputAction: TextInputAction.done,
        controller: controller,
        maxLines: maxLines,
        style: GoogleFonts.montserrat(
          color: AppColors.primaryWhiteColor,
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: hintText,
          hintStyle: GoogleFonts.montserrat(
            color: AppColors.primaryWhiteColor.withOpacity(0.5),
            fontWeight: FontWeight.w400,
            fontSize: 14,
          ),
        ),
        onChanged: onChanged,
      ),
    );
  }
}
