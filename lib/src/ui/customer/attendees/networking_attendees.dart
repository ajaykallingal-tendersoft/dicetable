import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:soloseaters/src/constants/app_colors.dart';
import 'package:soloseaters/src/constants/assets.dart';
import 'package:soloseaters/src/model/cafe_owner/home/venue_owner_home_screen_response.dart';
import 'package:soloseaters/src/model/customer/cafe/cafe_list_request.dart';
import 'package:soloseaters/src/model/customer/cafe/cafe_list_response.dart';
import 'package:soloseaters/src/ui/customer/cafe_list/bloc/cafe_list_bloc.dart';
import 'package:soloseaters/src/ui/customer/cafe_list/components/cafe_details_arguments.dart';
import 'package:soloseaters/src/utils/data/object_factory.dart';

class NetworkingAttendeesScreen extends StatefulWidget {
  final CafeDetailsArguments arguments;
  final bool? shouldRefresh; // New parameter to indicate if we need to refresh

  const NetworkingAttendeesScreen({
    super.key,
    required this.arguments,
    this.shouldRefresh = false,
  });

  @override
  State<NetworkingAttendeesScreen> createState() =>
      _NetworkingAttendeesScreenState();
}

class _NetworkingAttendeesScreenState extends State<NetworkingAttendeesScreen> {
  late final String latitude;
  late final String longitude;
  int _currentPage = 0;
  List<Attende> _currentAttendees = [];
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    latitude = ObjectFactory().prefs.getLatitude().toString();
    longitude = ObjectFactory().prefs.getLongitude().toString();

    // Initialize with the passed attendees
    _currentAttendees = widget.arguments.attendes;

    // Only fetch if shouldRefresh is true (after booking success)
    if (widget.shouldRefresh == true) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _fetchUpdatedCafeDetails();
      });
    }
  }

  void _fetchUpdatedCafeDetails() {
    final double? lat = latitude != null ? double.tryParse(latitude) : 0.0;
    final double? lon = longitude != null ? double.tryParse(longitude) : 0.0;
    final isGuest = ObjectFactory().prefs.isGuestUser() == true;
    final deviceToken =
        isGuest ? ObjectFactory().prefs.getDeviceID() ?? '' : '';

    setState(() {
      _isRefreshing = true;
    });

    if (lat != null && lon != null) {
      context.read<CafeListBloc>().add(
        RefreshCafeDetailsEvent(
          cafeId: widget.arguments.id,
          cafeListRequest: CafeListRequest(
            latitude: lat,
            longitude: lon,
            diceTableFilter: [],
            accommodationsFilter: [],
            openTime: "",
            closeTime: "",
            search: "",
            deviceToken: deviceToken,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
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
        body: BlocListener<CafeListBloc, CafeListState>(
          listener: (context, state) {
            if (state is SingleCafeDetailsLoaded) {
              setState(() {
                _isRefreshing = false;
                // Update attendees from the refreshed cafe data
                _currentAttendees = state.cafe.attendes ?? [];
              });
            } else if (state is SingleCafeDetailsError) {
              setState(() {
                _isRefreshing = false;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Failed to refresh attendees'),
                  backgroundColor: AppColors.appRedColor,
                  behavior: SnackBarBehavior.floating,
                  duration: const Duration(seconds: 2),
                ),
              );
            }
          },
          child: RefreshIndicator(
            onRefresh: () async {
              _fetchUpdatedCafeDetails();
              // Wait for the refresh to complete
              await Future.delayed(Duration(seconds: 2));
            },
            child: SingleChildScrollView(
              physics: AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child:
                  _isRefreshing
                      ? _buildLoadingUI()
                      : _currentAttendees.isEmpty
                      ? _buildEmptyAttendeesUI(context)
                      : Column(
                        children: [
                          _buildVenueImageCard(),
                          const SizedBox(height: 20),
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _currentAttendees.length,
                            itemBuilder: (context, index) {
                              final attendee = _currentAttendees[index];
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
        ),
      ),
    );
  }

  Widget _buildLoadingUI() {
    return SizedBox(
      height: MediaQuery.sizeOf(context).height * 0.7,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
            const SizedBox(height: 16),
            Text(
              "Loading attendees...",
              style: GoogleFonts.montserrat(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVenueImageCard() {
    return Center(
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 10,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        padding: EdgeInsets.all(8),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child: AspectRatio(
            aspectRatio: 4 / 3,
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
                              (context, url) =>
                                  _buildPlaceholder(attende.name!),
                          errorWidget:
                              (context, url, error) =>
                                  _buildPlaceholder(attende.name!),
                          fadeInDuration: Duration(milliseconds: 400),
                          fadeOutDuration: Duration(milliseconds: 200),
                        )
                        : _buildPlaceholder(attende.name!),
              ),
              const SizedBox(width: 12),
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

  Widget _buildEmptyAttendeesUI(BuildContext context) {
    return SizedBox(
      height: MediaQuery.sizeOf(context).height * 0.7,
      width: MediaQuery.sizeOf(context).width,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            "No attendees found!",
            style: GoogleFonts.montserrat(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const Gap(8),
          Text(
            "Once people start joining this event,\nyou can view them.",
            textAlign: TextAlign.center,
            style: GoogleFonts.montserrat(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: Colors.white.withOpacity(0.9),
            ),
          ),
        ],
      ),
    );
  }
}
