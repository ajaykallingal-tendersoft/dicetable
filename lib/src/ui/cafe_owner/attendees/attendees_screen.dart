import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';
import 'package:soloseaters/src/constants/app_colors.dart';
import 'package:soloseaters/src/constants/assets.dart';
import 'package:soloseaters/src/model/cafe_owner/home/venue_owner_home_screen_response.dart';
import 'package:soloseaters/src/ui/cafe_owner/home/attendees_arguments.dart';

class AttendeesScreen extends StatelessWidget {
  final AttendeesArguments arguments;

  const AttendeesScreen({super.key, required this.arguments});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary,
            AppColors.primary,
            AppColors.secondary,
            AppColors.tertiary,
          ],
          stops: const [0.0, 0.5, 0.75, 1.0],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: AppColors.primary,
          elevation: 0,
          leading: InkWell(
            onTap: () => context.pop(),
            child: SvgPicture.asset(
              Assets.BACK,
              color: Colors.white,
              fit: BoxFit.scaleDown,
            ),
          ),
          title: Text(
            'Attendees - ${arguments.tableTypeName}',
            style: GoogleFonts.montserrat(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
        body: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: arguments.attendees.length,
          itemBuilder: (context, index) {
            final attendee = arguments.attendees[index];
            return _buildAttendeeCard(attendee);
          },
        ),
      ),
    );
  }

  Widget _buildAttendeeCard(Attendee attendee) {
    final name = attendee.name ?? 'Guest User';
    final preferences = attendee.preferences ?? [];

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Profile row
          Row(
            children: [
              if (attendee.profilePhoto != null &&
                  attendee.profilePhoto!.isNotEmpty)
                ClipRRect(
                  borderRadius: BorderRadius.circular(28),
                  child: CachedNetworkImage(
                    imageUrl: attendee.profilePhoto!,
                    width: 56,
                    height: 56,
                    fit: BoxFit.cover,
                    placeholder:
                        (context, url) => _buildPlaceholder(attendee.name ?? ''),
                    errorWidget:
                        (context, url, error) =>
                            _buildPlaceholder(attendee.name ?? ''),
                  ).animate().fadeIn(duration: 400.ms), // smooth fade-in
                )
              else
                _buildPlaceholder(attendee.name ?? ''),

              const SizedBox(width: 12),

              // Name and Badges
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: GoogleFonts.montserrat(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 6),

                    // Badges: Paid/Free + Preferences
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        if (attendee.isPaidUser == 1)
                          _buildBadge(
                            icon: Image.asset(
                              Assets.PREMIUM,
                              width: 16,
                              height: 16,
                            ),
                            label: 'Paid User',
                            backgroundColor: AppColors.premiumBadgeColor,
                            textColor: AppColors.premiumPlanTextColor,
                          )
                        else
                          _buildBadge(
                            icon: Image.asset(
                              Assets.NON_PREMIUM,
                              width: 16,
                              height: 16,
                            ),
                            label: 'Free User',
                            backgroundColor: AppColors.freeUserBadgeColor,
                            textColor: AppColors.freeUserBadgeTextColor,
                          ),

                        // Preferences badges
                        ...preferences.map(
                          (pref) => _buildBadge(
                            icon: const Icon(
                              Icons.check_circle_outline_rounded,
                              size: 16,
                              color: AppColors.tableTypeBadgeTextColor,
                            ),
                            label: pref,
                            backgroundColor: AppColors.tableTypeBadgeColor,
                            textColor: AppColors.tableTypeBadgeTextColor,
                          ),
                        ),
                      ],
                    ),
                    const Gap(10),
                  ],
                ),
              ),
            ],
          ),
          const Gap(10),

          if (attendee.isPaidUser == 1)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6.0),
              child: Divider(color: AppColors.dividerColor, height: 1),
            ),

          if ((attendee.additionalInfo ?? '').isNotEmpty &&
              attendee.isPaidUser == 1) ...[
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.only(left: 5.0),
              child: Text(
                attendee.additionalInfo!,
                style: GoogleFonts.montserrat(
                  fontSize: 12,
                  color: AppColors.textPrimaryGrey,
                  fontWeight: FontWeight.w500,
                  // height: 1.4,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPlaceholder(String name) {
    return Container(
      width: 56,
      height: 56,
      decoration: const BoxDecoration(
        color: Color(0xFFE8F4F8),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          name[0].toUpperCase(),
          style: GoogleFonts.montserrat(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF004B87),
          ),
        ),
      ),
    );
  }

  Widget _buildBadge({
    required Widget icon,
    required String label,
    required Color backgroundColor,
    required Color textColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          icon,
          const SizedBox(width: 4),
          Text(
            label,
            style: GoogleFonts.montserrat(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}
