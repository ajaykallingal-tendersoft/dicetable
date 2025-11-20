import 'package:cached_network_image/cached_network_image.dart';
import 'package:soloseaters/src/constants/app_colors.dart';
import 'package:soloseaters/src/model/customer/cafe/cafe_list_response.dart';
import 'package:soloseaters/src/model/customer/cafe/favourite_list_response.dart';
import 'package:soloseaters/src/ui/customer/cafe_list/bloc/cafe_list_bloc.dart';
import 'package:soloseaters/src/ui/customer/cafe_list/cafe_model.dart';
import 'package:soloseaters/src/ui/customer/cafe_list/components/cafe_details_arguments.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';

import '../../../../constants/assets.dart';
import 'fav_details_argument.dart';

class FavListCard extends StatelessWidget {
  final FavCafe cafes;
  final int index;
  final bool isLoading; // Add loading state parameter

  const FavListCard({
    super.key,
    required this.cafes,
    required this.index,
    this.isLoading = false, // Default to false
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    // Log cafe data for debugging
    print(
      'Rendering FavListCard: id=${cafes.id}, name=${cafes.name}, photo=${cafes.photo}',
    );

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
                    style: textTheme.labelMedium?.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 16.sp,
                        ) ??
                        TextStyle(
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
                          : cafes.favourites == true
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
                          ? null // Disable when loading
                          : () {
                            context.read<CafeListBloc>().add(
                              ToggleFavoriteEvent(index, context),
                            );
                            print(
                              'Favorite button pressed for cafe: ${cafes.id}',
                            );
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
                          errorWidget:
                              (context, url, error) => Container(
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
                              ),
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
                          style: textTheme.bodySmall?.copyWith(
                                fontSize: 10.sp,
                                color: AppColors.shadowColor,
                              ) ??
                              TextStyle(
                                fontSize: 10.sp,
                                color: AppColors.shadowColor,
                              ),
                          children: [
                            TextSpan(
                              text: 'Table Type:\n',
                              style: textTheme.bodySmall?.copyWith(
                                    color: AppColors.textPrimary,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 10.sp,
                                  ) ??
                                  TextStyle(
                                    color: AppColors.textPrimary,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 10.sp,
                                  ),
                            ),
                            const WidgetSpan(
                              child: SizedBox(height: 15),
                            ),
                            TextSpan(
                              text:
                                  cafes.tableTypes != null &&
                                          cafes.tableTypes!.isNotEmpty
                                      ? cafes.tableTypes!.join(', ')
                                      : 'No table types available',
                              style: textTheme.bodySmall?.copyWith(
                                    color: AppColors.textPrimary,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12.sp,
                                  ) ??
                                  TextStyle(
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
                        cafes.venueDescription ?? "No description available",
                        maxLines: 5,
                        textAlign: TextAlign.left,
                        style: textTheme.bodySmall?.copyWith(
                              color: AppColors.shadowColor,
                              fontWeight: FontWeight.w600,
                              fontSize: 10.sp,
                            ) ??
                            TextStyle(
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
                                tableType: cafes.tableTypes ?? const [],
                                description:
                                    cafes.venueDescription ?? "No description",
                                image: cafes.photo ?? '',
                                openingHours: cafes.workingHours,
                                id: cafes.id.toString(),
                                bookingStatus: cafes.bookingStatus ?? false,
                                gallery: _mapGallery(cafes.gallery),
                                attendes: _mapAttendees(cafes.attendes),
                                upcomingEvents:
                                    _mapUpcomingEvents(cafes.upcomingEvents),
                              ),
                            );
                          },
                          child: Text(
                            "VIEW MORE",
                            style: textTheme.bodyLarge?.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 11.sp,
                                  decoration: TextDecoration.underline,
                                  decorationColor: AppColors.primary,
                                ) ??
                                TextStyle(
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

  List<String> _mapGallery(List<String>? gallery) {
    if (gallery == null) return const [];
    return List<String>.from(gallery);
  }

  List<Attende> _mapAttendees(List<FavAttende>? attendees) {
    if (attendees == null) return const [];
    return attendees
        .map(
          (fav) => Attende(
            name: fav.name,
            email: fav.email,
            profilePhoto: fav.profilePhoto?.toString(),
            additionalInfo: fav.additionalInfo?.toString(),
          ),
        )
        .toList();
  }

  List<UpcomingEvent> _mapUpcomingEvents(
    List<FavUpcomingEvent>? upcomingEvents,
  ) {
    if (upcomingEvents == null) return const [];

    return upcomingEvents.map((favEvent) {
      final availableDays = favEvent.availableDays
          ?.whereType<Map<String, dynamic>>()
          .map((day) => AvailableDay.fromJson(day))
          .toList();

      return UpcomingEvent(
        id: favEvent.id,
        name: favEvent.name,
        description: favEvent.description,
        availableDays: availableDays,
      );
    }).toList();
  }
}
