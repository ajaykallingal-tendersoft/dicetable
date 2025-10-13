import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:soloseaters/src/constants/app_colors.dart';
import 'package:soloseaters/src/constants/assets.dart';
import 'package:soloseaters/src/model/cafe_owner/attendees/attendees.dart';


class AttendeesScreen extends StatelessWidget {
   AttendeesScreen({super.key});

  
  final List<Attendee> attendees =  [
    Attendee(
      name: 'Liam Andrew',
      hasImage: true,
      description:
          'Hi! I am from TechSolutions. I\'d love to connect and discuss potential collaboration opportunities for...',
      isPaidUser: true,
      isSocialSolo: true,
    ),

    // Adam Dollis (Free User)
    Attendee(
      name: 'Adam Dollis',
      hasImage: false,
      isFreeUser: true,
    ),

    // Liam Andrew (Paid User, Social Solo) - Duplicate for list length
    Attendee(
      name: 'Liam Andrew',
      hasImage: true,
      description:
          'Hi! I am from TechSolutions. I\'d love to connect and discuss potential collaboration opportunities for...',
      isPaidUser: true,
      isSocialSolo: true,
    ),

    // Adam Dollis (Free User) - Duplicate for list length
    Attendee(
      name: 'Adam Dollis',
      hasImage: false,
      isFreeUser: true,
    ),

    // Another Free User
    Attendee(
      name: 'Sarah Connor',
      hasImage: false,
      isFreeUser: true,
    ),
  ];

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
          stops: [0.0, 0.5, 0.75, 1.0],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent, // Required for gradient
        appBar: AppBar(
          backgroundColor: AppColors.primary,
          elevation: 0,
          leading: InkWell(
            onTap: () {
             context.pop();
            },
            child: SvgPicture.asset(
              Assets.BACK,
              color: Colors.white,
              fit: BoxFit.scaleDown,

            ),
          ),
          title: Text(
            'Attendees - Business Networking',
            style: GoogleFonts.roboto(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: attendees.map((attendee) {
            return _buildAttendeeCard(attendee); // Pass the entire object
          }).toList(),
        ),
      ),
    );
  }


  Widget _buildAttendeeCard(Attendee attendee) {
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
          // Header with profile picture and name
          Row(
            children: [
              // Profile Picture or Initial
              if (attendee.hasImage) // Use attendee.hasImage
                ClipRRect(
                  borderRadius: BorderRadius.circular(28),
                  child: Container(
                    width: 56,
                    height: 56,
                    color: Colors.grey[300],
                    child: Icon(
                      Icons.person,
                      size: 32,
                      color: Colors.grey[600],
                    ),
                  ),
                )
              else
                Container(
                  width: 56,
                  height: 56,
                  decoration: const BoxDecoration(
                    color: Color(0xFFE8F4F8),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      attendee.name[0].toUpperCase(), // Use attendee.name
                      style: GoogleFonts.roboto(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF004B87),
                      ),
                    ),
                  ),
                ),
              const SizedBox(width: 12),

              // Name and Badges
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      attendee.name, // Use attendee.name
                      style: GoogleFonts.roboto(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textFieldTextColor
                        ),
                      ),
                    
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        if (attendee.isPaidUser) // Use attendee.isPaidUser
                          _buildBadge(
                            icon: Image.asset(Assets.PREMIUM, width: 16, height: 16,),
                            label: 'Paid User',
                            backgroundColor: AppColors.premiumBadgeColor,
                            textColor: AppColors.premiumPlanTextColor,
                          ),
                        if (attendee.isSocialSolo) // Use attendee.isSocialSolo
                          _buildBadge(
                            icon: Icon(Icons.check_circle, size: 16, color: AppColors.tableTypeBadgeTextColor,),
                            label: 'Social solo',
                            backgroundColor: AppColors.tableTypeBadgeColor,
                            textColor: AppColors.tableTypeBadgeTextColor,
                          ),
                        if (attendee.isFreeUser) // Use attendee.isFreeUser
                          _buildBadge(
                            icon: Image.asset(Assets.PREMIUM, width: 16, height: 16,),
                            label: 'Free User',
                            backgroundColor: AppColors.freeUserBadgeColor,
                            textColor: AppColors.freeUserBadgeTextColor,
                          ),
                      ],
                    ),
                    Gap(10),
                  ],
                ),
              ),
            ],
          ),
          Gap(10),
            if (attendee.isPaidUser)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6.0),
                      child: Divider(color: AppColors.dividerColor, height: 1),
                    ),

          // Description
          if (attendee.description != null && attendee.description!.isNotEmpty) ...[
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.only(left: 5.0),
              child: Text(
                attendee.description!, // Use attendee.description
                style: GoogleFonts.roboto(
                  fontSize: 12,
                  color: AppColors.textPrimaryGrey,
                  fontWeight: FontWeight.w400,
                  height: 1.4,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBadge({
    required Widget icon,
    required String label,
    required Color backgroundColor,
    required Color textColor,
  }) {
    // ... (This function remains unchanged)
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
            style: GoogleFonts.roboto(
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