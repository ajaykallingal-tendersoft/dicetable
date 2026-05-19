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
        padding: const EdgeInsets.all(10.0),
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
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                // mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 1,
                    child: Hero(
                      tag: cafes.id ?? 'unknown',
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child: SizedBox(
                          height:
                              MediaQuery.of(context).size.height *
                              0.15, // 15% of screen height for better responsiveness
                          width:
                              double
                                  .infinity, // Takes full width of the Expanded widget
                          child: CachedNetworkImage(
                            imageUrl: cafes.photo ?? '',
                            fit: BoxFit.cover,
                            httpHeaders: {
                              'User-Agent':
                                  'Mozilla/5.0 (compatible; Flutter app)',
                            },
                            fadeInDuration: Duration(milliseconds: 300),
                            fadeOutDuration: Duration(milliseconds: 300),
                            maxHeightDiskCache: 1000,
                            maxWidthDiskCache: 1000,
                            memCacheHeight: 500,
                            memCacheWidth: 500,
                            placeholder:
                                (context, url) => Container(
                                  height:
                                      MediaQuery.of(context).size.height * 0.15,
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[200],
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  child: Center(
                                    child: Lottie.asset(
                                      Assets.JUMBING_DOT,
                                      height: 20,
                                      width: 20,
                                    ),
                                  ),
                                ),
                            errorWidget: (context, url, error) {
                              // Log the error for debugging
                              print('Image load error for URL: $url');
                              print('Error details: $error');

                              return Container(
                                height:
                                    MediaQuery.of(context).size.height * 0.15,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: Colors.grey[100],
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: Center(
                                  child: SvgPicture.asset(
                                    'assets/svg/cafe-list.svg',
                                    height: 60,
                                    width: 60,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ),

                  Gap(8),
                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: 'Table Type:\n',
                                style: TextTheme.of(
                                  context,
                                ).bodySmall!.copyWith(
                                  color: AppColors.textPrimary,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 10.sp,
                                ),
                              ),
                              WidgetSpan(
                                child: SizedBox(height: 15), // vertical spacing
                              ),
                              TextSpan(
                                text:
                                    cafes.tableTypes != null &&
                                            cafes.tableTypes!.isNotEmpty
                                        ? cafes.tableTypes!.join(', ')
                                        : 'No table types available',
                                style: TextTheme.of(
                                  context,
                                ).bodySmall!.copyWith(
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
                        const Spacer(),
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
                                      cafes.venueDescription ??
                                      "No description",
                                  image: cafes.photo ?? '',
                                  openingHours: cafes.workingHours,
                                  id: cafes.id.toString(),
                                  bookingStatus: cafes.bookingStatus ?? false,
                                  gallery: cafes.gallery ?? [],
                                  attendes: cafes.attendes ?? [],
                                  upcomingEvents: cafes.upcomingEvents ?? [],
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
            ),
          ],
        ),
      ),
    );
  }
}
