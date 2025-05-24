import 'package:dicetable/src/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';


class RequiredTextField extends StatefulWidget {
  final String hint;
  final bool isRequired;
  final bool readOnly;
  final TextEditingController? controller;
  final bool obscureText;
  final String? Function(String?)? validator;
  final TextInputType keyboardType;
  final Function(String)? onChanged;

  const RequiredTextField({
    super.key,
    required this.hint,
    this.isRequired = false,
    this.readOnly = false,
    this.controller,
    this.obscureText = false,
    this.validator,
    this.keyboardType = TextInputType.text,
    this.onChanged,
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

  @override
  Widget build(BuildContext context) {
    final labelText = widget.isRequired
        ? TextSpan(
      text: widget.hint,
      style: Theme.of(context).textTheme.bodyMedium!.copyWith(
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
        : TextSpan(text: widget.hint);

    return Container(
      height: 70.h,
      margin: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: AppColors.primaryWhiteColor,
        borderRadius: BorderRadius.circular(15),
      ),
      child: TextFormField(
        readOnly: widget.readOnly,
        controller: widget.controller,
        obscureText: _obscureText,
        keyboardType: widget.keyboardType,
        onChanged: widget.onChanged,
        validator: widget.validator ??
                (value) {
              if (widget.isRequired && (value == null || value.trim().isEmpty)) {
                return '${widget.hint} is required';
              }
              return null;
            },
        style: Theme.of(context).textTheme.bodyMedium!.copyWith(
          color: AppColors.textPrimaryGrey,
          fontWeight: FontWeight.w600,
          fontSize: 14.sp,
        ),
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
          filled: true,
          fillColor: AppColors.primaryWhiteColor,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none,
          ),
          hintStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(
            color: AppColors.textPrimaryGrey,
            fontWeight: FontWeight.w600,
            fontSize: 14.sp,
          ),
          hintText: null,
          label: widget.isRequired
              ? RichText(text: labelText)
              : Text(widget.hint, style: Theme.of(context).textTheme.bodyMedium),
          floatingLabelBehavior: FloatingLabelBehavior.never,
          suffixIcon: widget.obscureText
              ? InkWell(
            onTap: () {
              setState(() {
                _obscureText = !_obscureText;
              });
            },
            child: Padding(
              padding: const EdgeInsets.only(right: 12.0),
              child: _obscureText
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
          suffixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
        ),
      ),
    );
  }
}
