import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';

class ElevatedButtonWidget extends StatelessWidget {
  ElevatedButtonWidget({
    super.key,
    required this.height,
    required this.width,
    required this.iconEnabled,
    required this.iconLabel,
    this.icon,
    required this.color,
    required this.textColor,
  });

  final double height;
  final double width;
  final bool iconEnabled;
  final String iconLabel;
  Widget? icon;
  final Color color;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 40.w, vertical: 10.h),
      margin: EdgeInsets.all(16),
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1), // subtle shadow color
            blurRadius: 8,
            offset: Offset(0, 4), // vertical shadow
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment:
            iconEnabled == true
                ? MainAxisAlignment.spaceAround
                : MainAxisAlignment.center,
        children: [
          iconEnabled == true
              ? Expanded(
                child: AutoSizeText(
                  iconLabel,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.montserrat(
                    color: textColor,
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
              : AutoSizeText(
                iconLabel,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.montserrat(
                  color: textColor,
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
          iconEnabled == true ? Gap(20.w) : SizedBox(),
          iconEnabled == true ? icon! : SizedBox(),
        ],
      ),
    );
  }
}
