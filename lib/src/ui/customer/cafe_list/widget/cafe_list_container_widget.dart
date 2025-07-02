import 'package:cached_network_image/cached_network_image.dart';
import 'package:soloseaters/src/constants/app_colors.dart';
import 'package:soloseaters/src/model/customer/cafe/cafe_list_response.dart';
import 'package:soloseaters/src/ui/customer/cafe_list/components/cafe_details_arguments.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';

import '../../../../constants/assets.dart';

class CafeListCard extends StatelessWidget {
  final Cafe cafes;
  final VoidCallback? onFavoriteToggle;
  final bool isLoading; // Add loading state parameter

  const CafeListCard({
    super.key,
    required this.cafes,
    required this.onFavoriteToggle,
    this.isLoading = false, // Default to false
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
                    cafes.name! ?? "",
                    style: TextTheme.of(context).labelMedium!.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 16.sp,
                    ),
                  ),
                ),
                // Updated favorite button with loading state
                IconButton(
                  icon:
                      isLoading
                          ? SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                AppColors.primary,
                              ),
                            ),
                          )
                          : cafes.favourites!
                          ? SvgPicture.asset(
                            'assets/svg/favourite1-active.svg',
                            fit: BoxFit.scaleDown,
                          )
                          : SvgPicture.asset(
                            'assets/svg/favourite1.svg',
                            fit: BoxFit.scaleDown,
                          ),
                  onPressed:
                      isLoading
                          ? null
                          : onFavoriteToggle, // Disable when loading
                ),
              ],
            ),
            Row(
              // mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Expanded(
                  flex: 1,
                  child: Hero(
                    tag: cafes.id!,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: CachedNetworkImage(
                        imageUrl: cafes.photo ?? '',
                        fit: BoxFit.cover,
                        placeholder:
                            (context, url) => Center(
                              child: Lottie.asset(
                                Assets.JUMBING_DOT,
                                height: 20,
                                width: 20,
                              ),
                            ),
                        errorWidget:
                            (context, url, error) =>
                                SvgPicture.asset('assets/svg/cafe-list.svg'),
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
                      RichText(
                        text: TextSpan(
                          children: [
                             TextSpan(
                              text: 'Table Type:\n',
                              style: TextTheme.of(context).bodySmall!.copyWith(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.w600,
                                fontSize: 10.sp,
                              ),
                            ),
                            WidgetSpan(
                              child: SizedBox(height: 15), // vertical spacing
                            ),
                            TextSpan(
                              text: cafes.tableTypes != null && cafes.tableTypes!.isNotEmpty
                                  ? cafes.tableTypes!.join(', ')
                                  : 'No table types available',
                              style: TextTheme.of(context).bodySmall!.copyWith(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.w600,
                                fontSize: 12.sp,
                              ),
                            ),
                          ],
                        ),
                      ),

                      Gap(8),
                      Text(
                        cafes.venueDescription ?? "",
                        maxLines: 5,
                        textAlign: TextAlign.left,
                        // overflow: TextOverflow.visible,
                        style: TextTheme.of(context).bodySmall!.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w600,
                          fontSize: 11.sp,
                        ),
                      ),
                      Gap(10),
                      Align(
                        alignment: Alignment.bottomRight,
                        child: TextButton(
                          onPressed: () {
                            context.push(
                              '/cafe_details',
                              extra: CafeDetailsArguments(
                                from: "CafeList",
                                name: cafes.name ?? "Unknown Cafe",
                                tableType: cafes.tableTypes ?? [],
                                description:
                                    cafes.venueDescription ?? "No description",
                                image: cafes.photo ?? '',
                                openingHours: cafes.workingHours,
                                id: cafes.id.toString(),
                                bookingStatus: cafes.bookingStatus ?? false,
                              ),
                            );
                          },
                          child: Text(
                            "VIEW MORE",
                            style: TextTheme.of(context).bodyLarge!.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                              fontSize: 11.sp,
                              decoration: TextDecoration.underline,
                              decorationColor: AppColors.primary,
                            ),
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
