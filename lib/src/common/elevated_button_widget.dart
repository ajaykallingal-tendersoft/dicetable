import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';

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
      ),
      child: Row(
        mainAxisAlignment:
            iconEnabled == true
                ? MainAxisAlignment.spaceAround
                : MainAxisAlignment.center,
        children: [
          iconEnabled == true
           ? Expanded(child: AutoSizeText(
            iconLabel,
            style: TextTheme.of(
              context,
            ).labelLarge!.copyWith(color: textColor,fontSize: 18.sp,fontWeight: FontWeight.bold),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
           )
      
          )
          :
          AutoSizeText(
            iconLabel,
            style: TextTheme.of(
              context,
            ).labelLarge!.copyWith(color: textColor,fontSize: 18.sp,fontWeight: FontWeight.bold),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
         
          iconEnabled == true ? Gap(20.w) : SizedBox(),
          iconEnabled == true ? icon! : SizedBox(),
        ],
      ),
    );
  }
}
