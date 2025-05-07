import 'package:dicetable/src/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';

class CustomLoginTextField extends StatefulWidget {
  final String hintText;
  final String? textFieldAnnotationText;
  final Widget icon;
  final bool isPassword;
  final TextEditingController controller;
  final FocusNode focusNode;
  final String? Function(String?)? validator;
  final TextInputType keyboardType;
  final String? errorText;
  final Function(String)? onChanged;

  const CustomLoginTextField({
    super.key,
    required this.hintText,
    required this.icon,
    this.isPassword = false,
    required this.controller,
    this.textFieldAnnotationText,
    required this.focusNode,
    this.validator,
    this.keyboardType = TextInputType.text,
    this.errorText,
    this.onChanged
  });

  @override
  State<CustomLoginTextField> createState() => _CustomLoginTextFieldState();
}

class _CustomLoginTextFieldState extends State<CustomLoginTextField> {
  bool showHint = true;
  @override
  void initState() {
    super.initState();
    widget.focusNode.addListener(() {
      setState(() {}); // Rebuild on focus change
    });
    widget.controller.addListener(() {
      setState(() {}); // Rebuild on text change
    });
  }
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70.h,
      margin: const EdgeInsets.symmetric(vertical: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.primaryWhiteColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Gap(20),
          widget.icon,
          Gap(20),
          const VerticalDivider(
            color: AppColors.verticalDividerColor,
            thickness: 1,
            // width: 20,
            indent: 8,
            endIndent: 8,
          ),
          Gap(20),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 2,
                    child: TextFormField(
                      focusNode: widget.focusNode,
                      controller: widget.controller,
                      obscureText: widget.isPassword,
                      onChanged: widget.onChanged,

                      keyboardType: widget.keyboardType,
                      style: TextTheme.of(context).bodyMedium!.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                        fontSize: 16.sp,
                      ),
                      decoration: InputDecoration(
                        isDense: true,
                        hintText: (showHint && widget.controller.text.isEmpty) ? widget.hintText : null,
                        errorText: widget.errorText,
                        hintStyle: TextTheme.of(context).bodyMedium!.copyWith(
                          color: AppColors.textFieldTextColor,
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
