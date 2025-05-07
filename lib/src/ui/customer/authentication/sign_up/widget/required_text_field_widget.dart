import 'package:dicetable/src/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class RequiredTextField extends StatelessWidget {
  final String hint;
  final bool isRequired;
  final TextEditingController? controller;
  final bool obscureText;
  final String? Function(String?)? validator;
  final TextInputType keyboardType;

  const RequiredTextField({
    super.key,
    required this.hint,
    this.isRequired = false,
    this.controller,
    this.obscureText = false,
    this.validator,
    this.keyboardType = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) {
    final labelText =
        isRequired
            ? TextSpan(
              text: hint,
              style: TextTheme.of(context).bodyMedium!.copyWith(
                color: AppColors.textPrimaryGrey,
                fontWeight: FontWeight.w600,
                fontSize: 14.sp,
              ),
              children: const [
                TextSpan(
                  text: ' *',
                  style: TextStyle(color: AppColors.appRedColor),
                ),
              ],
            )
            : TextSpan(text: hint);

    return Container(
      height: 70.h,
      margin:
      EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: AppColors.primaryWhiteColor,
        borderRadius: BorderRadius.circular(15),
      ),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        validator:
            validator ??
            (value) {
              if (isRequired && (value == null || value.trim().isEmpty)) {
                return '$hint is required';
              }
              return null;
            },
        style: TextTheme.of(context).bodyMedium!.copyWith(
          color: AppColors.textPrimaryGrey,
          fontWeight: FontWeight.w600,
          fontSize: 14.sp,
        ),
        decoration: InputDecoration(
          contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 22),
          filled: true,
          fillColor: AppColors.primaryWhiteColor,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none,
          ),
          hintStyle: TextTheme.of(context).bodyMedium!.copyWith(
            color: AppColors.textPrimaryGrey,
            fontWeight: FontWeight.w600,
            fontSize: 14.sp,
          ),
          hintText: null,
          label:
              isRequired
                  ? RichText(text: labelText)
                  : Text(hint, style: TextTheme.of(context).bodyMedium),
          floatingLabelBehavior: FloatingLabelBehavior.never,
          suffixIconConstraints: const BoxConstraints(
            minWidth: 0,
            minHeight: 0,
          ),
        ),
      ),
    );
  }
}
