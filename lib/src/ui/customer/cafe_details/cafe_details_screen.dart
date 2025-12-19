import 'dart:io';
import 'package:badges/badges.dart' as badges;
import 'package:device_info_plus/device_info_plus.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:soloseaters/src/common/elevated_button_widget.dart';
import 'package:soloseaters/src/constants/app_colors.dart';
import 'package:soloseaters/src/model/customer/booking/withdraw_booking_request.dart';
import 'package:soloseaters/src/model/customer/cafe/cafe_list_request.dart';
import 'package:soloseaters/src/model/customer/cafe/cafe_list_response.dart';
import 'package:soloseaters/src/model/customer/cafe/favourite_list_response.dart';
import 'package:soloseaters/src/ui/cafe_owner/notification/bloc/notification_bloc.dart';
import 'package:soloseaters/src/ui/customer/cafe_details/widget/cafe_details_card.dart';
import 'package:soloseaters/src/ui/customer/cafe_list/bloc/cafe_list_bloc.dart';
import 'package:soloseaters/src/ui/customer/cafe_list/components/cafe_details_arguments.dart';
import 'package:soloseaters/src/ui/customer/favourites/widget/fav_details_argument.dart';
import 'package:soloseaters/src/utils/data/object_factory.dart';
import 'package:soloseaters/src/purchase/bloc/bloc/purchase_bloc.dart';
import 'package:soloseaters/src/purchase/bloc/bloc/purchase_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import '../../../model/customer/booking/booking_request.dart';
import '../../cafe_owner/notification/count_controller.dart';
import 'bloc/cafe_details_bloc.dart';

class CafeDetailsScreen extends StatefulWidget {
  final CafeDetailsArguments? cafeDetailsArguments;
  final FavDetailsArguments? favDetailsArguments;

  const CafeDetailsScreen({
    super.key,
    this.cafeDetailsArguments,
    this.favDetailsArguments,
  });

  @override
  State<CafeDetailsScreen> createState() => _CafeDetailsScreenState();
}

class _CafeDetailsScreenState extends State<CafeDetailsScreen> {
  bool _isLoadingDialogShown = false;
  final isGuest = ObjectFactory().prefs.isGuestUser() == true;

  late final String _name;
  late final List<String> _tableType;
  late final String _description;
  late final String _image;
  late final List<WorkingHour>? _openingHours;
  // late final dynamic _openingHours;
  // late final List<FavWorkingHour> _favOpeningHours;
  late final String _id;
  late final bool _isFromFavorites;
  late bool _bookingStatus;
  late final List<String> _gallery;
  late final List<Attende> _attendes;
  late final List<UpcomingEvent> _upcomingEvents;
  bool savePrefToggle = false;

  final CounterController controller = Get.find<CounterController>();

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  void _initializeData() {
    if (widget.cafeDetailsArguments != null) {
      _isFromFavorites = false;
      _name = widget.cafeDetailsArguments!.name;
      _tableType = widget.cafeDetailsArguments!.tableType;
      _description = widget.cafeDetailsArguments!.description;
      _image = widget.cafeDetailsArguments!.image;
      _openingHours =
          widget.cafeDetailsArguments!.openingHours as List<WorkingHour>?;
      // _openingHours = widget.cafeDetailsArguments!.openingHours;
      _id = widget.cafeDetailsArguments!.id;
      _bookingStatus = widget.cafeDetailsArguments!.bookingStatus;
      _gallery = widget.cafeDetailsArguments!.gallery;
      _attendes = widget.cafeDetailsArguments!.attendes;
      _upcomingEvents = widget.cafeDetailsArguments!.upcomingEvents;
    } else if (widget.favDetailsArguments != null) {
      _isFromFavorites = true;
      final List<dynamic>? favHoursDynamic =
          widget.favDetailsArguments!.openingHours;
      if (favHoursDynamic != null && favHoursDynamic.isNotEmpty) {
        final List<FavWorkingHour> favHours =
            favHoursDynamic.cast<FavWorkingHour>();

        _openingHours =
            favHours
                .map((favHour) => WorkingHour.fromFavWorkingHour(favHour))
                .toList();
      } else {
        _openingHours = null;
      }

      _name = widget.favDetailsArguments!.name;
      _tableType = widget.favDetailsArguments!.tableType;
      _description = widget.favDetailsArguments!.description;
      _image = widget.favDetailsArguments!.image;
      // _openingHours = widget.favDetailsArguments!.openingHours;
      _id = widget.favDetailsArguments!.id;
      _bookingStatus = widget.favDetailsArguments!.bookingStatus;
      _gallery = widget.favDetailsArguments!.gallery; // Now available
      _attendes = widget.favDetailsArguments!.attendes; // Now available
      _upcomingEvents = widget.favDetailsArguments!.upcomingEvents;
    } else {
      throw Exception(
        'Both cafeDetailsArguments and favDetailsArguments cannot be null',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<CafeDetailsBloc, CafeDetailsState>(
      listener: (context, state) {
        if (state is CafeBookingLoading) {
          if (!_isLoadingDialogShown) {
            _showLoadingDialog(context);
            _isLoadingDialogShown = true;
          }
        } else if (state is CafeBookingLoaded) {
          if (state.bookingRequestResponse.message != null) {
            if (state.bookingRequestResponse.status == true) {
              context.read<NotificationBloc>().add(FetchNotifications());
            }
          }
          if (_isLoadingDialogShown) {
            Navigator.of(context, rootNavigator: true).pop();
            _isLoadingDialogShown = false;
          }
          if (state.bookingRequestResponse.status == true) {
            setState(() {
              _bookingStatus = true;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.bookingRequestResponse.message!),
                backgroundColor: AppColors.appGreenColor,
                behavior: SnackBarBehavior.floating,
                duration: const Duration(seconds: 3),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            );

            final double? lat = double.tryParse(
              ObjectFactory().prefs.getLatitude().toString(),
            );
            final double? lon = double.tryParse(
              ObjectFactory().prefs.getLongitude().toString(),
            );
            final isGuest = ObjectFactory().prefs.isGuestUser() == true;
            final deviceToken =
                isGuest ? ObjectFactory().prefs.getDeviceID() ?? '' : '';

            context.read<CafeListBloc>().add(
              RefreshCafeDetailsEvent(
                cafeId: _id,
                cafeListRequest: CafeListRequest(
                  latitude: lat ?? 0.0,
                  longitude: lon ?? 0.0,
                  // Pass the *Active* filters from the Bloc so the API request is correct
                  diceTableFilter:
                      context.read<CafeListBloc>().selectedTableTypes.toList(),
                  accommodationsFilter:
                      context.read<CafeListBloc>().selectedVenueTypes.toList(),
                  openTime: context.read<CafeListBloc>().openTime.format(
                    context,
                  ),
                  closeTime: context.read<CafeListBloc>().closeTime.format(
                    context,
                  ),
                  search: "",
                  deviceToken: deviceToken,
                ),
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Booking failed. Please try again later.'),
                backgroundColor: AppColors.appRedColor,
                behavior: SnackBarBehavior.floating,
                duration: const Duration(seconds: 3),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            );
          }
        } else if (state is CafeBookingError) {
          if (_isLoadingDialogShown) {
            Navigator.of(context, rootNavigator: true).pop();
            _isLoadingDialogShown = false;
          }
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Something went wrong! Please try again later."),
              backgroundColor: AppColors.appRedColor,
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 3),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
        } else if (state is WithdrawBookingLoading) {
          if (!_isLoadingDialogShown) {
            _showLoadingDialog(context);
            _isLoadingDialogShown = true;
          }
        } else if (state is WithdrawBookingLoaded) {
          if (_isLoadingDialogShown) {
            Navigator.of(context, rootNavigator: true).pop();
            _isLoadingDialogShown = false;
          }
          if (state.withdrawBookingResponse.status == true) {
            setState(() {
              _bookingStatus = false;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.withdrawBookingResponse.message!),
                backgroundColor: AppColors.appGreenColor,
                behavior: SnackBarBehavior.floating,
                duration: const Duration(seconds: 3),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            );

            // ALSO REFRESH AFTER WITHDRAW TO UPDATE ATTENDEES LIST
            final double? lat = double.tryParse(
              ObjectFactory().prefs.getLatitude().toString(),
            );
            final double? lon = double.tryParse(
              ObjectFactory().prefs.getLongitude().toString(),
            );
            final isGuest = ObjectFactory().prefs.isGuestUser() == true;
            final deviceToken =
                isGuest ? ObjectFactory().prefs.getDeviceID() ?? '' : '';

            // Debug logging
            print('🔄 Triggering refresh for cafe ID: $_id');
            print('📍 Location: lat=$lat, lon=$lon');

            context.read<CafeListBloc>().add(
              RefreshCafeDetailsEvent(
                cafeId: _id.toString(),
                cafeListRequest: CafeListRequest(
                  latitude: lat ?? 0.0,
                  longitude: lon ?? 0.0,
                  // Pass active filters here too
                  diceTableFilter:
                      context.read<CafeListBloc>().selectedTableTypes.toList(),
                  accommodationsFilter:
                      context.read<CafeListBloc>().selectedVenueTypes.toList(),
                  openTime: context.read<CafeListBloc>().openTime.format(
                    context,
                  ),
                  closeTime: context.read<CafeListBloc>().closeTime.format(
                    context,
                  ),
                  search: "",
                  deviceToken: deviceToken,
                ),
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Withdrawal failed.Please try again later.'),
                backgroundColor: AppColors.appRedColor,
                behavior: SnackBarBehavior.floating,
                duration: const Duration(seconds: 3),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            );
          }
        } else if (state is WithdrawBookingError) {
          if (_isLoadingDialogShown) {
            Navigator.of(context, rootNavigator: true).pop();
            _isLoadingDialogShown = false;
          }
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Withdrawal failed.Please try again later.'),
              backgroundColor: AppColors.appRedColor,
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 3),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          flexibleSpace: SizedBox(height: 70),
          elevation: 0,
          backgroundColor: AppColors.primary,
          leading: IconButton(
            icon: SvgPicture.asset(
              'assets/svg/back.svg',
              fit: BoxFit.scaleDown,
              color: AppColors.primaryWhiteColor,
            ),
            onPressed: () {
              context.pop();
            },
          ),
          actionsPadding: EdgeInsets.only(right: 10),
          actions: [
            InkWell(
              onTap: () {
                context.push('/notification');
              },
              child:
                  isGuest
                      ? SizedBox.shrink()
                      : Obx(() {
                        return controller.notificationBadgeAmount.value > 0
                            ? badges.Badge(
                              position: badges.BadgePosition.topEnd(
                                top: 0,
                                end:
                                    int.parse(
                                              controller
                                                  .notificationBadgeAmount
                                                  .value
                                                  .toString(),
                                            ) >
                                            99
                                        ? -12
                                        : -2,
                              ),
                              badgeAnimation: badges.BadgeAnimation.slide(),
                              showBadge: true,
                              badgeStyle: badges.BadgeStyle(
                                shape: badges.BadgeShape.circle,
                                borderRadius: BorderRadius.circular(10.r),
                                badgeColor: Colors.red,
                                padding: EdgeInsets.symmetric(
                                  horizontal: 6.w,
                                  vertical: 2.h,
                                ),
                              ),
                              badgeContent: Text(
                                int.parse(
                                          controller
                                              .notificationBadgeAmount
                                              .value
                                              .toString(),
                                        ) >
                                        99
                                    ? "99+"
                                    : controller.notificationBadgeAmount.value
                                        .toString(),
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              child: Icon(
                                Icons.notifications_outlined,
                                color: AppColors.primaryWhiteColor,
                                size: 28.w,
                              ),
                            )
                            : Icon(
                              Icons.notifications_outlined,
                              color: AppColors.primaryWhiteColor,
                              size: 28.w,
                            );
                      }),
            ),
          ],
        ),
        body: Container(
          height: double.infinity,
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
          child: SingleChildScrollView(
            physics: BouncingScrollPhysics(),
            child: Padding(
              padding: EdgeInsets.only(left: 13, right: 13, bottom: 30.h),
              child: Column(
                children: [
                  const Gap(20),
                  CafeDetailsCard(
                    name: _name,
                    tableType: _tableType,
                    description: _description,
                    image: _image,
                    openingHours: _openingHours,
                    id: _id,
                    bookingStatus: _bookingStatus,
                    gallery: _gallery,
                    attendes: _attendes,
                    upcomingEvents: _upcomingEvents,
                  ),
                  const Gap(30),
                  InkWell(
                    onTap: () {
                      if (isGuest) {
                        Fluttertoast.showToast(
                          fontSize: 14.sp,
                          msg: "Please signup to proceed.",
                          backgroundColor: AppColors.appRedColor,
                          textColor: AppColors.primaryWhiteColor,
                          gravity: ToastGravity.BOTTOM,
                        );

                        Future.delayed(Duration.zero, () {
                          ObjectFactory().prefs.setIsGuestUser(false);
                          context.go('/customer_login');
                        });

                        return;
                      }

                      _bookingStatus == true
                          ? _showWithdrawDialog(context)
                          : _showBookingDialog(context);
                    },
                    child: ElevatedButtonWidget(
                      height: 70.h,
                      width: MediaQuery.of(context).size.width,
                      iconEnabled: false,
                      iconLabel:
                          _bookingStatus
                              ? "WITHDRAW INTEREST"
                              : "SHOW INTEREST",
                      color: AppColors.primary,
                      textColor: AppColors.primaryWhiteColor,
                    ),
                  ),
                  const Gap(40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Helper method to map table type names to preference IDs
  int? _getPreferenceIdFromTableType(String? tableType) {
    if (tableType == null) return null;

    // Debug: Print exact string and character codes
    print('🔍 [Mapping] Table type: "$tableType"');
    print('🔍 [Mapping] Character codes: ${tableType.codeUnits}');

    // Normalize apostrophes to handle both standard (') and fancy (’) characters
    final normalized = tableType.replaceAll('\u2019', '\'');
    print('🔍 [Mapping] Normalized: "$normalized"');

    switch (normalized) {
      case 'Business Networking':
        return 1;
      case 'Social Solos':
        return 2;
      case 'Solo Singles':
        return 3;
      case 'Prime Time - Over 60\'s':
        return 4;
      default:
        print('⚠️ [Mapping] No match found for: "$tableType"');
        return null;
    }
  }

  /// Helper method to get preference state from SharedPreferences
  /// This screen is customer-only, so we only check customer user ID
  Future<bool> _getPreferenceState(String? tableType) async {
    print(
      '🔍 [Cafe Details] _getPreferenceState called with tableType: $tableType',
    );

    final preferenceId = _getPreferenceIdFromTableType(tableType);
    print('🔍 [Cafe Details] Mapped preferenceId: $preferenceId');

    if (preferenceId == null) {
      print('⚠️ [Cafe Details] preferenceId is null, returning false');
      return false;
    }

    final prefs = ObjectFactory().prefs;
    // Customer user ID (this screen is only for customers, not cafe owners)
    final userId = prefs.getUserId() ?? 'anonymous';
    final key = 'paid_profile_preference_${preferenceId}_$userId';

    print('🔍 [Cafe Details] Generated key: $key');
    print('🔍 [Cafe Details] UserId: $userId');

    // Use the existing SharedPreferences instance
    final sharedPrefs = prefs.getSharedPrefs;
    if (sharedPrefs == null) {
      print('⚠️ [Cafe Details] SharedPreferences is null');
      return false;
    }

    final value = sharedPrefs.getBool(key) ?? false;
    print('✅ [Cafe Details] Retrieved value for key $key: $value');

    // Debug: Print all keys that start with 'paid_profile_preference_'
    final allKeys = sharedPrefs.getKeys();
    final prefKeys =
        allKeys.where((k) => k.startsWith('paid_profile_preference_')).toList();
    print('📋 [Cafe Details] All preference keys in SharedPreferences:');
    for (var k in prefKeys) {
      print('   - $k: ${sharedPrefs.getBool(k)}');
    }

    return value;
  }

  void _showBookingDialog(BuildContext context) {
    final TextEditingController checkInController = TextEditingController();
    final TextEditingController checkOutController = TextEditingController();
    final TextEditingController apiCheckInController = TextEditingController();
    final TextEditingController apiCheckOutController = TextEditingController();
    String? selectedDiceTableType;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              backgroundColor: AppColors.primaryWhiteColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.r),
              ),
              insetPadding: EdgeInsets.symmetric(
                horizontal: 20.w,
                vertical: 4.h,
              ),
              child: Container(
                constraints: BoxConstraints(
                  maxWidth: 500.w,
                  maxHeight: MediaQuery.of(context).size.height * 0.8,
                ),
                child: SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.all(16.w),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            IconButton(
                              padding: EdgeInsets.zero,
                              constraints: BoxConstraints(),
                              onPressed: () => dialogContext.pop(),
                              icon: Icon(
                                Icons.close,
                                color: AppColors.textPrimaryGrey.withOpacity(
                                  0.6,
                                ),
                                size: 24.w,
                              ),
                            ),
                          ],
                        ),

                        Text(
                          'Select Time and Table Type',
                          style: GoogleFonts.montserrat(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                            fontSize: 21.sp,
                          ),
                        ),

                        Gap(24.h),

                        // SELECT TIME Label
                        Text(
                          'SELECT TIME',
                          style: GoogleFonts.montserrat(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                            fontSize: 15.sp,
                            // letterSpacing: 0.8,
                          ),
                        ),
                        Gap(12.h),

                        // Time Selection Row
                        Container(
                          padding: EdgeInsets.all(12.w),
                          decoration: BoxDecoration(
                            color: AppColors.primaryWhiteColor,
                            borderRadius: BorderRadius.circular(15.r),
                            border: Border.all(
                              color: AppColors.textPrimaryGrey.withOpacity(0.2),
                              width: 1,
                            ),
                          ),
                          child: IntrinsicHeight(
                            child: Row(
                              children: [
                                // Check In
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Check In:',
                                        style: TextStyle(
                                          color: AppColors.textPrimaryGrey,
                                          fontWeight: FontWeight.w500,
                                          fontSize: 14.sp,
                                        ),
                                      ),
                                      Gap(6.h),
                                      InkWell(
                                        onTap:
                                            () => _selectTime(
                                              dialogContext,
                                              checkInController,
                                              apiCheckInController,
                                              setState,
                                            ),

                                        child: Container(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 8.w,
                                            vertical: 10.h,
                                          ),
                                          decoration: BoxDecoration(
                                            color:
                                                AppColors.signUpContainerColor,
                                            borderRadius: BorderRadius.circular(
                                              8.r,
                                            ),
                                            border: Border.all(
                                              color: AppColors.textPrimaryGrey
                                                  .withOpacity(0.3),
                                            ),
                                          ),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(
                                                Icons.access_time,
                                                size: 16.w,
                                                color: AppColors.textPrimaryGrey
                                                    .withOpacity(0.6),
                                              ),
                                              SizedBox(width: 4.w),
                                              Flexible(
                                                child: Text(
                                                  checkInController
                                                          .text
                                                          .isNotEmpty
                                                      ? checkInController.text
                                                      : '10:00 AM',
                                                  style: TextStyle(
                                                    color:
                                                        checkInController
                                                                .text
                                                                .isNotEmpty
                                                            ? AppColors
                                                                .textPrimaryGrey
                                                            : AppColors
                                                                .textPrimaryGrey
                                                                .withOpacity(
                                                                  0.5,
                                                                ),
                                                    fontWeight: FontWeight.w500,
                                                    fontSize: 13.sp,
                                                  ),
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                              SizedBox(width: 2.w),
                                              Icon(
                                                Icons.unfold_more,
                                                size: 16.w,
                                                color: AppColors.textPrimaryGrey
                                                    .withOpacity(0.6),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                // "To" Text
                                Padding(
                                  padding: EdgeInsets.only(
                                    top: 20.w,
                                    right: 10.w,
                                  ),
                                  child: Text(
                                    'To',
                                    style: TextStyle(
                                      color: AppColors.textPrimaryGrey,
                                      fontWeight: FontWeight.w500,
                                      fontSize: 13.sp,
                                    ),
                                  ),
                                ),

                                // Check Out
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Check Out:',
                                        style: TextStyle(
                                          color: AppColors.textPrimaryGrey,
                                          fontWeight: FontWeight.w500,
                                          fontSize: 14.sp,
                                        ),
                                      ),
                                      Gap(6.h),
                                      InkWell(
                                        onTap:
                                            () => _selectTime(
                                              dialogContext,
                                              checkOutController,
                                              apiCheckOutController,
                                              setState,
                                            ),
                                        child: Container(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 8.w,
                                            vertical: 10.h,
                                          ),
                                          decoration: BoxDecoration(
                                            color:
                                                AppColors.signUpContainerColor,
                                            borderRadius: BorderRadius.circular(
                                              8.r,
                                            ),
                                            border: Border.all(
                                              color: AppColors.textPrimaryGrey
                                                  .withOpacity(0.3),
                                            ),
                                          ),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(
                                                Icons.access_time,
                                                size: 16.w,
                                                color: AppColors.textPrimaryGrey
                                                    .withOpacity(0.6),
                                              ),
                                              SizedBox(width: 4.w),
                                              Flexible(
                                                child: Text(
                                                  checkOutController
                                                          .text
                                                          .isNotEmpty
                                                      ? checkOutController.text
                                                      : '12:00 PM',
                                                  style: TextStyle(
                                                    color:
                                                        checkOutController
                                                                .text
                                                                .isNotEmpty
                                                            ? AppColors
                                                                .textPrimaryGrey
                                                            : AppColors
                                                                .textPrimaryGrey
                                                                .withOpacity(
                                                                  0.5,
                                                                ),
                                                    fontWeight: FontWeight.w500,
                                                    fontSize: 13.sp,
                                                  ),
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                              SizedBox(width: 2.w),
                                              Icon(
                                                Icons.unfold_more,
                                                size: 16.w,
                                                color: AppColors.textPrimaryGrey
                                                    .withOpacity(0.6),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        Gap(24.h),

                        // SELECT TABLE TYPE Label
                        Text(
                          'SELECT TABLE TYPE',
                          style: GoogleFonts.montserrat(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                            fontSize: 15.sp,
                            // letterSpacing: 0.8,
                          ),
                        ),
                        Gap(12.h),

                        // Table Type Dropdown using dropdown_button2 package
                        DropdownButtonFormField2<String>(
                          value: selectedDiceTableType,
                          isExpanded:
                              true, // Ensures dropdown fills width and positions correctly
                          decoration: InputDecoration(
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 16.w,
                              vertical:
                                  16.h, // Increased from 14 to prevent text cutoff
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15.r),
                              borderSide: BorderSide(
                                color: AppColors.textPrimaryGrey.withOpacity(
                                  0.3,
                                ),
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15.r),
                              borderSide: BorderSide(
                                color: AppColors.textPrimaryGrey.withOpacity(
                                  0.3,
                                ),
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15.r),
                              borderSide: BorderSide(
                                color: AppColors.textPrimaryGrey.withOpacity(
                                  0.3,
                                ), // ✅ Changed from primary color to grey
                              ),
                            ),
                            filled: true,
                            fillColor: AppColors.primaryWhiteColor,
                          ),
                          hint: Text(
                            'Select Table Type',
                            style: TextStyle(
                              color: AppColors.textPrimaryGrey.withOpacity(0.6),
                              fontWeight: FontWeight.w400,
                              fontSize: 14.sp,
                            ),
                          ),
                          items:
                              _tableType.map((tableType) {
                                return DropdownMenuItem<String>(
                                  value: tableType,
                                  child: Text(
                                    tableType,
                                    style: TextStyle(
                                      color: AppColors.textPrimaryGrey,
                                      fontWeight: FontWeight.w500,
                                      fontSize: 14.sp,
                                    ),
                                  ),
                                );
                              }).toList(),
                          onChanged: (value) {
                            setState(() {
                              selectedDiceTableType = value;
                            });
                          },
                          buttonStyleData: ButtonStyleData(
                            padding: EdgeInsets.only(right: 8.w),
                          ),
                          iconStyleData: IconStyleData(
                            icon: Icon(
                              Icons.keyboard_arrow_down,
                              color: AppColors.textPrimaryGrey,
                            ),
                            iconSize: 24.w,
                          ),
                          dropdownStyleData: DropdownStyleData(
                            maxHeight: 250.h,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12.r),
                              color: AppColors.primaryWhiteColor,
                            ),
                            elevation: 8,
                            offset: const Offset(
                              0,
                              -5,
                            ), // ✅ Positions menu directly below field
                          ),
                          menuItemStyleData: MenuItemStyleData(
                            height: 48.h,
                            padding: EdgeInsets.symmetric(horizontal: 16.w),
                          ),
                        ),

                        Gap(20.h),
                        BlocBuilder<PaymentPlanBloc, PaymentPlanState>(
                          builder: (context, paymentState) {
                            final isPaidUser =
                                paymentState.canAccessPremiumFeatures ||
                                paymentState.isSubscriptionActive;

                            if (!isPaidUser) {
                              // Upgrade Info Box
                              return Container(
                                padding: EdgeInsets.all(14.w),
                                decoration: BoxDecoration(
                                  color: Color(0xFFE8F4F8),
                                  borderRadius: BorderRadius.circular(12.r),
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      padding: EdgeInsets.all(2.w),
                                      child: Icon(
                                        Icons.info_outline,
                                        color: AppColors.primary,
                                        size: 20.w,
                                      ),
                                    ),
                                    Gap(10.w),
                                    Expanded(
                                      child: RichText(
                                        text: TextSpan(
                                          style: TextStyle(
                                            color: AppColors.textPrimaryGrey,
                                            fontWeight: FontWeight.w400,
                                            fontSize: 13.sp,
                                            height: 1.4,
                                          ),
                                          children: [
                                            TextSpan(
                                              text:
                                                  'Upgrade to Serious Networker to unlock the full profile, save preferences, and more. ',
                                            ),

                                            WidgetSpan(
                                              child: GestureDetector(
                                                onTap: () {
                                                  // Navigate to upgrade page
                                                  Navigator.of(context).pop();
                                                  context.push('/payment_plan');
                                                },
                                                child: Text(
                                                  'Upgrade Now',
                                                  style: TextStyle(
                                                    color: AppColors.primary,
                                                    fontWeight: FontWeight.w600,
                                                    fontSize: 13.sp,
                                                    decoration:
                                                        TextDecoration
                                                            .underline,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            } else {
                              // Toggle for paid users - displays actual preference state from SharedPreferences
                              // Non-interactive - preferences managed in Profile screen
                              return FutureBuilder<bool>(
                                key: ValueKey(
                                  selectedDiceTableType,
                                ), // Force rebuild when table type changes
                                future: _getPreferenceState(
                                  selectedDiceTableType,
                                ),
                                builder: (context, snapshot) {
                                  final isPreferenceEnabled =
                                      snapshot.data ?? false;

                                  return Row(
                                    children: [
                                      SizedBox(
                                        width: 50.0,
                                        height: 36.0,
                                        child: FittedBox(
                                          fit: BoxFit.fill,
                                          child: Switch(
                                            value: isPreferenceEnabled,
                                            onChanged:
                                                null, // Always non-interactive
                                            activeColor:
                                                AppColors.primaryWhiteColor,
                                            activeTrackColor:
                                                AppColors.secondary,
                                            inactiveThumbColor: Colors.white,
                                            inactiveTrackColor:
                                                Colors.grey.shade400,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Save as Preference',
                                              style: GoogleFonts.montserrat(
                                                fontSize: 14,
                                                color: AppColors.primary
                                                    .withOpacity(0.7),
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            Text(
                                              isPreferenceEnabled
                                                  ? 'Set in profile'
                                                  : 'Not set in profile',
                                              style: GoogleFonts.montserrat(
                                                fontSize: 11,
                                                color: AppColors.primary
                                                    .withOpacity(0.5),
                                                fontStyle: FontStyle.italic,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              );
                            }
                          },
                        ),

                        Gap(24.h),

                        // Book Now Button
                        Center(
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 5,
                            ),
                            child: SizedBox(
                              // width: double.infinity,
                              height: 50.h,
                              child: ElevatedButton(
                                onPressed: () {
                                  if (_validateBookingInputs(
                                    checkInController.text,
                                    checkOutController.text,
                                    selectedDiceTableType,
                                    dialogContext,
                                  )) {
                                    dialogContext.pop();
                                    _bookNow(
                                      context: context,
                                      checkInTime: apiCheckInController.text,
                                      checkOutTime: apiCheckOutController.text,
                                      diceTableType: selectedDiceTableType!,
                                      setAsPref:
                                          false, // ✅ Preference already in profile - no need to send
                                    );
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(18.r),
                                  ),
                                  elevation: 0,
                                ),
                                child: Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 24,
                                  ), // or whatever value fits visually
                                  child: Text(
                                    'BOOK NOW',
                                    style: TextStyle(
                                      color: AppColors.primaryWhiteColor,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14.sp,
                                      letterSpacing: 0.8,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  // Update the _selectTime method to format time in 12-hour format
  Future<void> _selectTime(
    BuildContext context,
    TextEditingController controller,
    TextEditingController apiController,
    void Function(void Function()) updateState,
  ) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      initialEntryMode: TimePickerEntryMode.dial,
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onSurface: AppColors.textPrimaryGrey,
            ),
            timePickerTheme: TimePickerThemeData(
              backgroundColor: AppColors.primaryWhiteColor,
              // Assuming r is defined (e.g., using flutter_screenutil or similar)
              hourMinuteShape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
              dayPeriodShape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
            ),
          ),
          child: MediaQuery(
            data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
            child: child!,
          ),
        );
      },
    );

    if (picked != null) {
      final hour24 = picked.hour;
      final minute = picked.minute;
      final period = hour24 < 12 ? 'AM' : 'PM';
      final hour12 = hour24 % 12 == 0 ? 12 : hour24 % 12;

      final apiTime =
          '${hour24.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
      final formattedTime =
          '${hour12.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')} $period';
      updateState(() {
        controller.text = formattedTime;
        apiController.text = apiTime;
      });
    }
  }

  void _showWithdrawDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              title: Text(
                'Are you sure?',
                style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                  fontSize: 16.sp,
                ),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Are you sure you want to withdraw your interest in this cafe? If you proceed, your active booking will be canceled. You will no longer have a reservation.",
                    style: Theme.of(context).textTheme.bodySmall!.copyWith(
                      color: AppColors.textPrimaryGrey,
                      fontWeight: FontWeight.w500,
                      fontSize: 15.sp,
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => dialogContext.pop(),
                  child: Text(
                    'Cancel',
                    style: Theme.of(context).textTheme.bodySmall!.copyWith(
                      color: AppColors.shadowColor,
                      fontWeight: FontWeight.w500,
                      fontSize: 14.sp,
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    dialogContext.pop();
                    _withdrawBooking();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'Continue',
                    style: Theme.of(context).textTheme.bodySmall!.copyWith(
                      color: AppColors.primaryWhiteColor,
                      fontWeight: FontWeight.w500,
                      fontSize: 14.sp,
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  bool _validateBookingInputs(
    String checkIn,
    String checkOut,
    String? tableType,
    BuildContext dialogContext,
  ) {
    List<String> errors = [];

    if (checkIn.isEmpty) {
      errors.add('Please select check-in time');
    }
    if (checkOut.isEmpty) {
      errors.add('Please select check-out time');
    }
    if (tableType == null || tableType.isEmpty) {
      errors.add('Please select a table type');
    }

    if (checkIn.isNotEmpty && checkOut.isNotEmpty) {
      try {
        final checkInTime = _parseTime(checkIn);
        final checkOutTime = _parseTime(checkOut);

        final checkInMinutes = checkInTime.hour * 60 + checkInTime.minute;
        final checkOutMinutes = checkOutTime.hour * 60 + checkOutTime.minute;

        if (checkOutMinutes <= checkInMinutes) {
          errors.add('Check-out time must be after check-in time');
        }
      } catch (e) {
        errors.add('Invalid time format selected');
      }
    }

    if (errors.isNotEmpty) {
      ScaffoldMessenger.of(dialogContext).showSnackBar(
        SnackBar(
          content: Text(errors.join('\n')),
          backgroundColor: AppColors.appRedColor,
          duration: const Duration(seconds: 4),
        ),
      );
      return false;
    }

    return true;
  }

  TimeOfDay _parseTime(String timeString) {
    // Example: "07:15 PM"
    final parts = timeString.trim().split(' ');

    if (parts.length != 2) {
      throw FormatException("Invalid time format");
    }

    final time = parts[0]; // "07:15"
    final period = parts[1]; // "PM"

    final hourMinute = time.split(':');
    int hour = int.parse(hourMinute[0]);
    int minute = int.parse(hourMinute[1]);

    // Convert 12-hour time to 24-hour format
    if (period.toUpperCase() == 'PM' && hour != 12) {
      hour += 12;
    } else if (period.toUpperCase() == 'AM' && hour == 12) {
      hour = 0;
    }

    return TimeOfDay(hour: hour, minute: minute);
  }

  Future<void> _withdrawBooking() async {
    try {
      final request = WithdrawBookingRequest(cafeId: _id);

      if (mounted) {
        context.read<CafeDetailsBloc>().add(
          WithdrawBookingRequestEvent(withdrawBookingRequest: request),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to create request. Please try again later.'),
            backgroundColor: AppColors.appRedColor,
            duration: const Duration(seconds: 3),
          ),
        );
        debugPrint('Booking error: $e');
      }
    }
  }

  Future<void> _bookNow({
    required BuildContext context,
    required String checkInTime,
    required String checkOutTime,
    required String diceTableType,
    required bool setAsPref,
  }) async {
    try {
      final bookingRequest = BookingRequest(
        cafeId: _id,
        diceTableType: diceTableType,
        currentDate: DateTime.now(),
        checkInTime: checkInTime,
        checkOutTime: checkOutTime,
        userId: _getCurrentUserId(),
        userName: _getCurrentUserName(),
        userEmail: _getCurrentUserEmail(),
        deviceId: await _getDeviceId(),
        additionalInfo:
            _isFromFavorites
                ? 'Booked from favorites'
                : 'Booked from cafe list',
        // setAsPref = setAsPref,
      );

      if (mounted) {
        context.read<CafeDetailsBloc>().add(
          BookingRequestEvent(bookingRequest: bookingRequest),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to create request. Please try again later.'),
            backgroundColor: AppColors.appRedColor,
            duration: const Duration(seconds: 3),
          ),
        );
        debugPrint('Booking error: $e');
      }
    }
  }

  void _showLoadingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return PopScope(
          canPop: false,
          child: AlertDialog(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                RefreshProgressIndicator(
                  backgroundColor: AppColors.primary,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    AppColors.primaryWhiteColor,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Processing your request...',
                  style: Theme.of(context).textTheme.bodySmall!.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w500,
                    fontSize: 14.sp,
                  ),
                ), // Generic message
              ],
            ),
          ),
        );
      },
    );
  }

  String _getCurrentUserId() {
    try {
      final userId = ObjectFactory().prefs.getUserId();
      return userId?.toString() ?? '';
    } catch (e) {
      debugPrint('Error getting user ID: $e');
      return '';
    }
  }

  String _getCurrentUserName() {
    try {
      final userName = ObjectFactory().prefs.getCustomerUserName();
      return userName?.toString() ?? '';
    } catch (e) {
      debugPrint('Error getting user name: $e');
      return '';
    }
  }

  String _getCurrentUserEmail() {
    try {
      final userMail = ObjectFactory().prefs.getCustomerUserMail();
      return userMail?.toString() ?? '';
    } catch (e) {
      debugPrint('Error getting user email: $e');
      return '';
    }
  }

  Future<String> _getDeviceId() async {
    try {
      DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
      if (Platform.isAndroid) {
        AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
        print("DeviceID: ${androidInfo.id}");
        return androidInfo.id;
      } else if (Platform.isIOS) {
        IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
        return iosInfo.identifierForVendor ?? '';
      }
      return '';
    } catch (e) {
      debugPrint('Error getting device ID: $e');
      return '';
    }
  }
}
