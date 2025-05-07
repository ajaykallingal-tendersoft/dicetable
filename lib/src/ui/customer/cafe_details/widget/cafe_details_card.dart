import 'package:dicetable/src/common/elevated_button_widget.dart';
import 'package:dicetable/src/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';

class CafeDetailsCard extends StatelessWidget {
  final String name;
  final String id;
  final String tableType;
  final String description;
  final String image;
  final Map<String, String>? openingHours;

  const CafeDetailsCard({
    super.key,
    required this.name,
    required this.tableType,
    required this.description,
    required this.image,
    this.openingHours, required this.id,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16),
      margin: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.primaryWhiteColor,
        borderRadius: BorderRadius.circular(15),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            offset: Offset(0, 1), // Horizontal and vertical offsets
            blurRadius: 4.0, // Softness of the shadow
            spreadRadius: 1.0, // Extent of the shadow
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            name,
            style: TextTheme.of(context).labelMedium!.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
              fontSize: 16.sp,
            ),
          ),
          Gap(10),
          ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: Hero(
              tag: id,
              child: Image.asset(
                image,
                width: double.infinity,
                height: 151.h,
                fit: BoxFit.cover,
              ),
            ),
          ),
          Gap(25),
          Text(
            'Table Type:',
            style: TextTheme.of(context).bodySmall!.copyWith(
              color: AppColors.shadowColor,
              fontWeight: FontWeight.w500,
              fontSize: 10.sp,
            ),
          ),
          Gap(3),
          Text(
            tableType,
            style: TextTheme.of(context).bodyMedium!.copyWith(
              color: AppColors.shadowColor,
              fontWeight: FontWeight.w600,
              fontSize: 12.sp,
            ),
          ),
          Gap(10),
          Divider(color: AppColors.primaryBlackColor,thickness: 0.4,),
          Gap(10),
          Text(
            'Description:',
            style: TextTheme.of(context).bodySmall!.copyWith(
              color: AppColors.shadowColor,
              fontWeight: FontWeight.w500,
              fontSize: 10.sp,
            ),
          ),
          Gap(3),
          Text(
            description,
            style: TextTheme.of(context).bodyMedium!.copyWith(
              color: AppColors.shadowColor,
              fontWeight: FontWeight.w600,
              fontSize: 12.sp,
            ),
          ),
          Gap(10),
          Divider(color: AppColors.primaryBlackColor, thickness: 0.4),
          Gap(10),
          Text(
            'Opening Hours:',
            style: TextTheme.of(context).bodySmall!.copyWith(
              color: AppColors.shadowColor,
              fontWeight: FontWeight.w500,
              fontSize: 10.sp,
            ),
          ),
          Gap(3),
          if (openingHours != null && openingHours!.isNotEmpty)
            ...openingHours!.entries.map(
              (entry) => Text(
                "${entry.key}: ${entry.value}",
                style: TextTheme.of(context).bodyMedium!.copyWith(
                  color: AppColors.shadowColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 12.sp,
                ),
              ),
            )
          else
            Text(
              "Opening hours not available",
              style: TextTheme.of(context).bodyMedium!.copyWith(
                color: AppColors.shadowColor,
                fontWeight: FontWeight.w600,
                fontSize: 12.sp,
              ),
            ),

        ],
      ),
    );
  }
}
