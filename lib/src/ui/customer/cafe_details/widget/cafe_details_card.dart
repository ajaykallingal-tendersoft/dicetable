import 'package:cached_network_image/cached_network_image.dart';
import 'package:soloseaters/src/constants/app_colors.dart';
import 'package:soloseaters/src/constants/assets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
import 'package:lottie/lottie.dart';

class CafeDetailsCard extends StatelessWidget {
  final String name;
  final String id;
  final List<String> tableType;
  final String description;
  final String image;
  final List<dynamic>? openingHours;
  final bool bookingStatus;

  const CafeDetailsCard({
    super.key,
    required this.name,
    required this.tableType,
    required this.description,
    required this.image,
    this.openingHours, required this.id,
    required this.bookingStatus,
  });

  @override
  Widget build(BuildContext context) {
    final bool hasDescription = description != null &&
        description.trim().isNotEmpty &&
        description.trim().toLowerCase() != 'null';
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
              child: (image != null && image!.trim().isNotEmpty)
                  ? CachedNetworkImage(
                imageUrl: image!,
                fit: BoxFit.scaleDown,
                placeholder: (context, url) => Center(
                  child: Lottie.asset(Assets.JUMBING_DOT, height: 20, width: 20),
                ),
                errorWidget: (context, url, error) =>
                    SvgPicture.asset('assets/svg/cafe-list.svg'),
              )
                  : SvgPicture.asset('assets/svg/cafe-list.svg'), // fallback when no image
            ),
          ),
          Gap(25),
          RichText(
            text: TextSpan(
              style: Theme.of(context).textTheme.bodySmall!.copyWith(
                fontSize: 10.sp,
                color: AppColors.shadowColor,
              ),
              children: [
                 TextSpan(
                  text: 'Table Type:\n',
                  style: TextTheme.of(context).bodySmall!.copyWith(
                    color: AppColors.shadowColor,
                    fontWeight: FontWeight.w500,
                    fontSize: 10.sp,
                  ),
                ),
                TextSpan(
                  text: tableType.join(', ') ?? '',
                  style: TextTheme.of(context).bodyMedium!.copyWith(
                  color: AppColors.shadowColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 12.sp,
                ),
                ),
              ],
            ),
          ),

          Gap(10),
          Divider(color: AppColors.primaryBlackColor,thickness: 0.4,),
          Gap(10),
          Visibility(
            visible: hasDescription,
            child: Text(
              'Description:',
              style: TextTheme.of(context).bodySmall!.copyWith(
                color: AppColors.shadowColor,
                fontWeight: FontWeight.w500,
                fontSize: 10.sp,
              ),
            ),
          ),
          Gap(hasDescription ? 3 : 0),
          Visibility(
            visible: hasDescription,
            child: Text(
              description,
              style: TextTheme.of(context).bodyMedium!.copyWith(
                color: AppColors.shadowColor,
                fontWeight: FontWeight.w600,
                fontSize: 12.sp,
              ),
            ),
          ),
          Gap(10),
          if (hasDescription)
            Divider(color: AppColors.primaryBlackColor, thickness: 0.4),
          Gap(hasDescription ? 10 : 0),

          Gap(hasDescription ? 10 : 0),
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
            ...openingHours!.map(
              (entry) => Text(
                "${entry.day}: ${entry.opening} - ${entry.closing}",
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
