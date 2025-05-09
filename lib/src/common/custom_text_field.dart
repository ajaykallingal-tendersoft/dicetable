import 'package:dicetable/src/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';

class CustomTextField extends StatefulWidget {
  final String hintText;
  final bool isPassword;
  final TextEditingController controller;
  final int? maxLines;
  final Function(String)? onChanged;
  final String? initialValue;
  final bool isProfile;
  final bool readOnly;
  final String? textFieldAnnotationText;
  final double height;

  const CustomTextField({
    super.key,
    required this.hintText,
    this.isPassword = false,
    required this.controller,
    this.maxLines = 1,
    this.onChanged,
    this.initialValue,
    this.isProfile = false,
    this.readOnly = false,
    this.textFieldAnnotationText,
    this.height = 60,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  late bool _obscureText;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.isPassword;
  }

  double _calculateHeight() {
    if (widget.height > 0) return widget.height;
    if ((widget.maxLines ?? 1) > 1) {
      return (widget.maxLines! * 24.0) + 32.0;
    }
    return 60.0; // fallback height
  }

  @override
  Widget build(BuildContext context) {
    final bool isMultiline = widget.maxLines != null && widget.maxLines! > 1;

    return Container(
      height: _calculateHeight(),
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: widget.isProfile && widget.readOnly
            ? AppColors.primary
            : AppColors.primaryWhiteColor,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: widget.isProfile
              ? AppColors.profileTextFiledBorderColor
              : AppColors.primaryWhiteColor,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.textFieldAnnotationText != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 4.0),
              child: Text(
                widget.textFieldAnnotationText!,
                style: Theme.of(context).textTheme.bodySmall!.copyWith(
                  color: widget.isProfile && widget.readOnly
                      ? AppColors.profileTextFiledSubColor
                      : AppColors.textPrimaryGrey,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          Expanded(
            child: Align(
              alignment: isMultiline
                  ? Alignment.topLeft
                  : Alignment.centerLeft,
              child: TextFormField(
                readOnly: widget.readOnly,
                controller: widget.controller,
                obscureText: widget.isPassword ? _obscureText : false,
                onChanged: widget.onChanged,
                maxLines: isMultiline ? widget.maxLines : 1,
                keyboardType: isMultiline
                    ? TextInputType.multiline
                    : (widget.isPassword
                    ? TextInputType.visiblePassword
                    : TextInputType.text),
                textAlignVertical: isMultiline
                    ? TextAlignVertical.top
                    : TextAlignVertical.center,
                style: Theme.of(context).textTheme.bodySmall!.copyWith(
                  color: widget.isProfile && widget.readOnly
                      ? AppColors.primaryWhiteColor
                      : AppColors.primary,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
                decoration: InputDecoration(
                  isDense: true,
                  hintText: widget.hintText,
                  hintStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(
                    color: AppColors.textPrimaryGrey,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    vertical: isMultiline ? 4.0 : 0.0,
                  ),
                  suffixIcon: widget.isPassword
                      ? InkWell(
                    onTap: () {
                      setState(() {
                        _obscureText = !_obscureText;
                      });
                    },
                    child: _obscureText
                        ? Icon(
                      Icons.visibility_off,
                      color: widget.isProfile && widget.readOnly
                          ? AppColors.primaryWhiteColor
                          : AppColors.primary,
                    )
                        : SvgPicture.asset(
                      'assets/svg/pw-view.svg',
                      fit: BoxFit.scaleDown,
                      color: widget.isProfile && widget.readOnly
                          ? AppColors.primaryWhiteColor
                          : AppColors.primary,
                    ),
                  )
                      : null,


                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

