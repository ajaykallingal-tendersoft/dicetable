import 'package:cached_network_image/cached_network_image.dart';
import 'package:dicetable/src/constants/app_colors.dart';
import 'package:dicetable/src/model/customer/cafe/cafe_list_response.dart';
import 'package:dicetable/src/model/customer/cafe/favourite_list_response.dart';
import 'package:dicetable/src/ui/customer/cafe_list/cafe_model.dart';
import 'package:dicetable/src/ui/customer/cafe_list/components/cafe_details_arguments.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';

import '../../../../constants/assets.dart';
import 'fav_details_argument.dart';

class FavListCard extends StatelessWidget {
  final FavCafe cafes;


  const FavListCard({
    super.key,
    required this.cafes,

  });

  @override
  Widget build(BuildContext context) {
    // Log cafe data for debugging
    print('Rendering FavListCard: id=${cafes.id}, name=${cafes
        .name}, photo=${cafes.photo}');

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: AppColors.primaryWhiteColor,
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            offset: Offset(0, 1),
            blurRadius: 1.0,
            spreadRadius: 1.0,
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
                    cafes.name ?? "Unknown Cafe",
                    style: TextTheme
                        .of(context)
                        .labelMedium!
                        .copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 16.sp,
                    ),
                  ),
                ),
                IconButton(
                  icon: cafes.favourites == true
                      ? SvgPicture.asset(
                    'assets/svg/favourite1-active.svg',
                    fit: BoxFit.scaleDown,
                  )
                      : SvgPicture.asset(
                    'assets/svg/favourite1.svg',
                    fit: BoxFit.scaleDown,
                  ),
                  onPressed: () {
                    // Add logic to toggle favorite status if needed
                    print('Favorite button pressed for cafe: ${cafes.id}');
                  },
                ),
              ],
            ),
            Row(
              children: [
                Expanded(
                  flex: 1,
                  child: Hero(
                    tag: cafes.id ?? 'unknown',
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: CachedNetworkImage(
                        imageUrl: cafes.photo ?? '',
                        fit: BoxFit.cover,
                        placeholder: (context, url) =>
                            Center(
                              child: Lottie.asset(
                                Assets.JUMBING_DOT,
                                height: 20,
                                width: 20,
                              ),
                            ),
                        errorWidget: (context, url, error) =>
                            SvgPicture.asset(
                              'assets/svg/cafe-list.svg',
                              fit: BoxFit.cover,
                            ),
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
                          style: Theme
                              .of(context)
                              .textTheme
                              .bodySmall!
                              .copyWith(
                            fontSize: 10.sp,
                            color: AppColors.shadowColor,
                          ),
                          children: [
                            const TextSpan(
                              text: 'Table Type:\n',
                              style: TextStyle(fontWeight: FontWeight.w400),
                            ),
                            TextSpan(
                              text: cafes.tableTypes?.join(', ') ?? 'N/A',
                              style: const TextStyle(
                                  fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                      Gap(8),
                      Text(
                        cafes.venueDescription ?? "No description available",
                        maxLines: 5,
                        textAlign: TextAlign.left,
                        style: TextTheme
                            .of(context)
                            .bodySmall!
                            .copyWith(
                          color: AppColors.shadowColor,
                          fontWeight: FontWeight.w600,
                          fontSize: 10.sp,
                        ),
                      ),
                      Gap(10),
                      Align(
                        alignment: Alignment.bottomRight,
                        child: TextButton(
                          onPressed: () {
                            context.push(
                              '/cafe_details',
                              extra: FavDetailsArguments(
                                from: "FavList",
                                name: cafes.name ?? "Unknown Cafe",
                                tableType: cafes.tableTypes ?? [],
                                description: cafes.venueDescription ??
                                    "No description",
                                image: cafes.photo ?? '',
                                openingHours: cafes.workingHours,
                                id: cafes.id.toString(), bookingStatus: cafes.bookingStatus ?? false,
                              ),
                            );
                          },
                          child: Text(
                            "VIEW MORE",
                            style: TextTheme
                                .of(context)
                                .bodySmall!
                                .copyWith(
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