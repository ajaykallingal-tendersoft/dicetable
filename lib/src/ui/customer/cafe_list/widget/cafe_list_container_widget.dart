import 'package:dicetable/src/constants/app_colors.dart';
import 'package:dicetable/src/ui/customer/cafe_list/cafe_model.dart';
import 'package:dicetable/src/ui/customer/cafe_list/components/cafe_details_arguments.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

class CafeListCard extends StatelessWidget {
  final CafeModel cafe;
  final VoidCallback onFavoriteToggle;

  const CafeListCard({
    super.key,
    required this.cafe,
    required this.onFavoriteToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
        color: AppColors.primaryWhiteColor,
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            offset: Offset(0, 1), // Horizontal and vertical offsets
            blurRadius: 1.0, // Softness of the shadow
            spreadRadius: 1.0, // Extent of the shadow
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    cafe.name,
                    style: TextTheme.of(context).labelMedium!.copyWith(
                      color: AppColors.primary,
                      fontWeight:  FontWeight.bold,
                      fontSize: 16.sp,
                    ),
                  ),
                ),
                IconButton(
                  icon: cafe.isFavorite
                      ? SvgPicture.asset(
                    'assets/svg/favourite1-active.svg',
                    fit: BoxFit.scaleDown,
                    // color: AppColors.primaryWhiteColor,
                  )
                      : SvgPicture.asset(
                    'assets/svg/favourite1.svg',
                    fit: BoxFit.scaleDown,
                    // color: AppColors.primaryWhiteColor,
                  ),
                  onPressed: onFavoriteToggle,
                ),
              ],
            ),
            Row(
               // mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Expanded(
                  flex: 1,
                  child: Hero(
                    tag: cafe.id,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: Image.asset(
                        cafe.image,
                        width: 139.w,
                        height: 151.h,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
                Gap(10),
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    mainAxisSize: MainAxisSize.max,
                    children: [

                      Text(
                        "Table Type: ${cafe.tableType}",
                        style: TextTheme.of(context).bodySmall!.copyWith(
                          color: AppColors.shadowColor,
                          fontWeight:  FontWeight.w600,
                          fontSize: 10.sp,
                        ),
                      ),
                     Gap(8),
                      Text(
                        cafe.description,
                        maxLines: 5,
                        textAlign: TextAlign.left,
                        // overflow: TextOverflow.visible,
                          style: TextTheme.of(context).bodySmall!.copyWith(
                            color: AppColors.shadowColor,
                            fontWeight:  FontWeight.w600,
                            fontSize: 10.sp,
                          )
                      ),
                      Gap(10),
                      Align(
                        alignment: Alignment.bottomRight,
                        child: TextButton(
                          onPressed: () {
                            context.push('/cafe_details',
                                extra: CafeDetailsArguments(
                                    name: cafe.name,
                                    tableType: cafe.tableType,
                                    description: cafe.description,
                                    image: cafe.image,
                                    openingHours: cafe.openingHours,
                                    id: cafe.id,
                                ),
                            );
                          },
                          child: Text(
                              "VIEW MORE",
                              style: TextTheme.of(context).bodySmall!.copyWith(
                                color: AppColors.primary,
                                fontWeight:  FontWeight.bold,
                                fontSize: 11.sp,
                                decoration: TextDecoration.underline,
                                decorationColor: AppColors.primary,
                              )
                          ),
                        ),
                      ),

                    ],
                  ),
                ),
              ],
            ),


          ],
        ),
      ),
    );
  }
}
