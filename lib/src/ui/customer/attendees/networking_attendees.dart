import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:soloseaters/src/constants/app_colors.dart';
import 'package:soloseaters/src/constants/assets.dart';
import 'package:soloseaters/src/model/cafe_owner/home/venue_owner_home_screen_response.dart';
import 'package:soloseaters/src/model/customer/cafe/cafe_list_response.dart';
import 'package:soloseaters/src/ui/customer/cafe_list/components/cafe_details_arguments.dart';

class NetworkingAttendeesScreen extends StatefulWidget {
  final CafeDetailsArguments arguments;

  const NetworkingAttendeesScreen({super.key, required this.arguments});

  @override
  State<NetworkingAttendeesScreen> createState() =>
      _NetworkingAttendeesScreenState();
}

class _NetworkingAttendeesScreenState extends State<NetworkingAttendeesScreen> {
  int _currentPage = 0;
  @override
  Widget build(BuildContext context) {
    final attendees = widget.arguments.attendes;
    return Container(
      // Gradient background matching the image's overall color blend
      decoration: const BoxDecoration(
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
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: AppColors.primary,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
              context.pop();
            },
          ),
          title: Text(
            'Attendees - ${widget.arguments.name}',
            style: GoogleFonts.montserrat(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _buildVenueImageCard(),
              const SizedBox(height: 20),
              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: attendees.length,
                itemBuilder: (context, index) {
                  final attendee = attendees[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: _buildAttendeeCard(attendee),
                  );
                },
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVenueImageCard() {
    return Center(
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white, // white background
          borderRadius: BorderRadius.circular(24), // smooth rounded corners
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 10,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        // spacing from screen edges
        padding: EdgeInsets.all(8),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child: SizedBox(
            height: 220, // or ScreenUtil: 220.h
            width: double.infinity,
            child: PageView.builder(
              itemCount: widget.arguments.gallery.length,
              onPageChanged: (index) => setState(() => _currentPage = index),
              itemBuilder: (context, index) {
                final imageUrl = widget.arguments.gallery[index];
                final heroTag =
                    index == 0
                        ? widget.arguments.id
                        : '${widget.arguments.id}_$index';
                return Hero(
                  tag: heroTag,
                  child:
                      (imageUrl.trim().isNotEmpty)
                          ? CachedNetworkImage(
                            imageUrl: imageUrl,
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
                                (context, url, error) => SvgPicture.asset(
                                  'assets/svg/cafe-list.svg',
                                ),
                          )
                          : SvgPicture.asset('assets/svg/cafe-list.svg'),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAttendeeCard(Attende attende) {
    final imageUrl = attende.profilePhoto ?? "";
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primaryWhiteColor,
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
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile Photo
              ClipRRect(
                borderRadius: BorderRadius.circular(28),
                child:
                    imageUrl.isNotEmpty
                        ? CachedNetworkImage(
                          imageUrl: imageUrl,
                          width: 56,
                          height: 56,
                          fit: BoxFit.cover,
                          placeholder:
                              (context, url) => _buildPlaceholder(
                                attende.name!,
                              ), // Show initials while loading
                          errorWidget:
                              (context, url, error) => _buildPlaceholder(
                                attende.name!,
                              ), // Show initials on error
                          fadeInDuration: Duration(
                            milliseconds: 400,
                          ), // Smooth fade-in effect
                          fadeOutDuration: Duration(milliseconds: 200),
                        )
                        : _buildPlaceholder(attende.name!),
              ),

              const SizedBox(width: 12),

              // Name and Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      attende.name ?? "",
                      style: GoogleFonts.montserrat(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimaryGrey,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      attende.additionalInfo ?? "",
                      style: GoogleFonts.montserrat(
                        fontSize: 13,
                        color: AppColors.textPrimaryGrey,
                        fontWeight: FontWeight.w500,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
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
          name.isNotEmpty ? name[0].toUpperCase() : 'G',
          style: GoogleFonts.montserrat(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF004B87),
          ),
        ),
      ),
    );
  }
}
