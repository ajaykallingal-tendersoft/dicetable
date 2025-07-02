// required_text_field_widget.dart
import 'package:soloseaters/src/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';

class RequiredTextField extends StatefulWidget {
  final String hint;
  final bool isRequired;
  final bool readOnly;
  final TextEditingController? controller;
  final bool obscureText;
  final TextInputType keyboardType;
  final Function(String)? onChanged;
  final bool isEmail;
  final String? errorText;
  final String? Function(String?)? validator;
  final FocusNode? focusNode;
  final bool? isPhoneNumber;
  final String? customRequiredMessage;

  const RequiredTextField({
    super.key,
    required this.hint,
    this.isRequired = false,
    this.readOnly = false,
    this.controller,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.onChanged,
    this.isEmail = false,
    this.errorText,
    this.validator,
    this.focusNode,
    this.isPhoneNumber,
      this.customRequiredMessage,
  });

  @override
  State<RequiredTextField> createState() => _RequiredTextFieldState();
}

class _RequiredTextFieldState extends State<RequiredTextField> {
  late bool _obscureText;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.obscureText;
  }

  void _handleTextChange(String value) {
    // Call the original onChanged callback if provided
    if (widget.onChanged != null) {
      widget.onChanged!(value);
    }
  }

  @override
  Widget build(BuildContext context) {
    final labelText = TextSpan(
      text: widget.hint,
      style: Theme.of(context).textTheme.bodyMedium!.copyWith(
        color: AppColors.textPrimaryGrey,
        fontWeight: FontWeight.w600,
        fontSize: 14.sp,
      ),
      children:
          widget.isRequired
              ? const [
                TextSpan(
                  text: ' *',
                  style: TextStyle(color: AppColors.appRedColor),
                ),
              ]
              : const [
                TextSpan(
                  text: ' (Optional)',
                  style: TextStyle(color: AppColors.textPrimaryGrey),
                ),
              ],
    );

    return Container(
      height: 70.h,
      margin: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.primaryWhiteColor,
        borderRadius: BorderRadius.circular(15),
      ),
      child: TextFormField(
        focusNode: widget.focusNode,
        textAlignVertical: TextAlignVertical.center,
        readOnly: widget.readOnly,
        controller: widget.controller,
        obscureText: _obscureText,
        keyboardType: widget.keyboardType,
        inputFormatters: [
          if (widget.isPhoneNumber == true) ...[
            LengthLimitingTextInputFormatter(10),
            FilteringTextInputFormatter.digitsOnly,
          ],
        ],
        onChanged: _handleTextChange,
        style: Theme.of(context).textTheme.bodyMedium!.copyWith(
          color: AppColors.textPrimaryGrey,
          fontWeight: FontWeight.w600,
          fontSize: 14.sp,
        ),
    validator:
            widget.errorText != null
                ? null
                : widget.validator ??
                    (value) {
                      if (widget.isRequired &&
                          (value == null || value.trim().isEmpty)) {
                        return widget.customRequiredMessage ??
                            '${widget.hint} is required';
                      }
                      return null;
                    },
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 20,
          ),
          isDense: true,
          filled: true,
          fillColor: AppColors.primaryWhiteColor,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none,
          ),
          hintText: null,
          floatingLabelBehavior: FloatingLabelBehavior.never,
          label: RichText(text: labelText),
          errorText: widget.errorText,
          errorStyle: TextStyle(color: AppColors.appRedColor, fontSize: 12.sp),
          suffixIcon:
              widget.obscureText
                  ? InkWell(
                    onTap: () {
                      setState(() {
                        _obscureText = !_obscureText;
                      });
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(right: 12.0),
                      child:
                          _obscureText
                              ? Icon(
                                Icons.visibility_off,
                                color: AppColors.primary,
                              )
                              : SvgPicture.asset(
                                'assets/svg/pw-view.svg',
                                fit: BoxFit.scaleDown,
                                color: AppColors.primary,
                              ),
                    ),
                  )
                  : null,
          suffixIconConstraints: const BoxConstraints(
            minWidth: 0,
            minHeight: 0,
          ),
        ),
      ),
    );
  }
}
