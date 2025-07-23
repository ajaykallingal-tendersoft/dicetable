import 'dart:io';
import 'package:badges/badges.dart' as badges;
import 'package:device_info_plus/device_info_plus.dart';
import 'package:soloseaters/src/common/elevated_button_widget.dart';
import 'package:soloseaters/src/constants/app_colors.dart';
import 'package:soloseaters/src/model/customer/booking/withdraw_booking_request.dart';
import 'package:soloseaters/src/model/customer/cafe/cafe_list_response.dart';
import 'package:soloseaters/src/model/customer/cafe/favourite_list_response.dart';
import 'package:soloseaters/src/ui/customer/cafe_details/widget/cafe_details_card.dart';
import 'package:soloseaters/src/ui/customer/cafe_list/bloc/cafe_list_bloc.dart';
import 'package:soloseaters/src/ui/customer/cafe_list/components/cafe_details_arguments.dart';
import 'package:soloseaters/src/ui/customer/favourites/widget/fav_details_argument.dart';
import 'package:soloseaters/src/utils/data/object_factory.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
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
  late final List<dynamic> _openingHours;
  late final String _id;
  late final bool _isFromFavorites;
  late bool _bookingStatus;
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
          widget.cafeDetailsArguments!.openingHours as List<WorkingHour>;
      _id = widget.cafeDetailsArguments!.id;
      _bookingStatus = widget.cafeDetailsArguments!.bookingStatus;
    } else if (widget.favDetailsArguments != null) {
      _isFromFavorites = true;
      _name = widget.favDetailsArguments!.name;
      _tableType = widget.favDetailsArguments!.tableType;
      _description = widget.favDetailsArguments!.description;
      _image = widget.favDetailsArguments!.image;
      _openingHours =
          widget.favDetailsArguments!.openingHours as List<FavWorkingHour>;
      _id = widget.favDetailsArguments!.id;
      _bookingStatus = widget.favDetailsArguments!.bookingStatus;
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
          if (_isLoadingDialogShown) {
            Navigator.of(
              context,
              rootNavigator: true,
            ).pop(); // Dismiss the loading dialog
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
                duration: const Duration(seconds: 3),
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  state.bookingRequestResponse.message ?? 'Booking failed',
                ),
                backgroundColor: AppColors.appRedColor,
                duration: const Duration(seconds: 3),
              ),
            );
          }
        } else if (state is CafeBookingError) {
          if (_isLoadingDialogShown) {
            Navigator.of(
              context,
              rootNavigator: true,
            ).pop(); // Dismiss the loading dialog
            _isLoadingDialogShown = false;
          }
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage),
              backgroundColor: AppColors.appRedColor,
              duration: const Duration(seconds: 3),
            ),
          );
        } else if (state is WithdrawBookingLoading) {
          if (!_isLoadingDialogShown) {
            _showLoadingDialog(context);
            _isLoadingDialogShown = true;
          }
        } else if (state is WithdrawBookingLoaded) {
          if (_isLoadingDialogShown) {
            Navigator.of(
              context,
              rootNavigator: true,
            ).pop(); // Dismiss the loading dialog
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
                duration: const Duration(seconds: 3),
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  state.withdrawBookingResponse.message ?? 'Withdrawal failed',
                ),
                backgroundColor: AppColors.appRedColor,
                duration: const Duration(seconds: 3),
              ),
            );
          }
        } else if (state is WithdrawBookingError) {
          if (_isLoadingDialogShown) {
            Navigator.of(
              context,
              rootNavigator: true,
            ).pop(); // Dismiss the loading dialog
            _isLoadingDialogShown = false;
          }
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage),
              backgroundColor: AppColors.appRedColor,
              duration: const Duration(seconds: 3),
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

              // if( _isFromFavorites == false) {
              //   WidgetsBinding.instance.addPostFrameCallback((_) {
              //     // context.read<CafeListBloc>().add(GetCafeListEvent(cafeListRequest: null));
              //   });
              // }else {
              //   WidgetsBinding.instance.addPostFrameCallback((_) {
              //     // context.read<CafeListBloc>().add(GetFavListEvent());
              //   });
              // }
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
                                end: 0,
                              ),
                              badgeAnimation: badges.BadgeAnimation.slide(),
                              showBadge: true,
                              badgeStyle: badges.BadgeStyle(
                                shape: badges.BadgeShape.square,
                                borderRadius: BorderRadius.circular(10.r),
                                badgeColor: Colors.red,
                                padding: EdgeInsets.symmetric(
                                  horizontal: 6.w,
                                  vertical: 2.h,
                                ),
                              ),
                              badgeContent: Text(
                                controller.notificationBadgeAmount.value
                                    .toString(),
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              child:  Icon(
                                Icons.notifications_outlined,
                                color: AppColors.primaryWhiteColor,
                                size: 30.sp,
                              ),
                            )
                            :  Icon(
                              Icons.notifications_outlined,
                              color: AppColors.primaryWhiteColor,
                              size: 30.sp,
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
            child: Padding(
              padding: const EdgeInsets.all(26.0),
              child: Column(
                children: [
                   const Gap(30),
                  CafeDetailsCard(
                    name: _name,
                    tableType: _tableType,
                    description: _description,
                    image: _image,
                    openingHours: _openingHours,
                    id: _id,
                    bookingStatus: _bookingStatus,
                  ),
                  const Gap(40),
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
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showBookingDialog(BuildContext context) {
    final TextEditingController checkInController = TextEditingController();
    final TextEditingController checkOutController = TextEditingController();
    String? selectedDiceTableType;

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
                'Select Time & Table Type',
                style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                  fontSize: 16.sp,
                ),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    style: Theme.of(context).textTheme.bodySmall!.copyWith(
                      color: AppColors.textPrimaryGrey, // Default text color
                      fontWeight: FontWeight.w500,
                      fontSize: 15.sp,
                    ),
                    controller: checkInController,
                    readOnly: true,
                    decoration: InputDecoration(
                      // Label style: Initially grey
                      labelStyle: Theme.of(
                        context,
                      ).textTheme.bodySmall!.copyWith(
                        color: AppColors.textPrimaryGrey,
                        fontWeight: FontWeight.w500,
                        fontSize: 15.sp,
                      ),
                      labelText: 'Check-in Time',
                      // Hint style: Grey
                      hintStyle: Theme.of(
                        context,
                      ).textTheme.bodySmall!.copyWith(
                        color: AppColors.textPrimaryGrey,
                        fontWeight: FontWeight.w500,
                        fontSize: 15.sp,
                      ),
                      hintText: 'Check-in time',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(
                          color: AppColors.textPrimaryGrey,
                        ), // Default border color
                      ),
                      enabledBorder: OutlineInputBorder(
                        // Border when enabled but not focused
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(
                          color: AppColors.textPrimaryGrey,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        // Border when focused
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(
                          color: AppColors.primary,
                        ), // Primary color when focused
                      ),
                      floatingLabelStyle: Theme.of(
                        context,
                      ).textTheme.bodySmall!.copyWith(
                        // Label when focused
                        color: AppColors.primary, // Primary color when focused
                        fontWeight: FontWeight.w500,
                        fontSize: 15.sp,
                      ),
                      suffixIcon: const Icon(
                        Icons.access_time,
                        color: AppColors.textPrimaryGrey,
                      ), // Default icon color
                    ),
                    onTap: () => _selectTime(dialogContext, checkInController),
                  ),
                  const SizedBox(height: 16),
                  // Check-out Time
                  TextField(
                    style: Theme.of(context).textTheme.bodySmall!.copyWith(
                      color: AppColors.textPrimaryGrey, // Default text color
                      fontWeight: FontWeight.w500,
                      fontSize: 15.sp,
                    ),
                    controller: checkOutController,
                    readOnly: true,
                    decoration: InputDecoration(
                      labelStyle: Theme.of(
                        context,
                      ).textTheme.bodySmall!.copyWith(
                        color: AppColors.textPrimaryGrey,
                        fontWeight: FontWeight.w500,
                        fontSize: 15.sp,
                      ),
                      labelText: 'Check-out Time',
                      hintStyle: Theme.of(
                        context,
                      ).textTheme.bodySmall!.copyWith(
                        color: AppColors.textPrimaryGrey,
                        fontWeight: FontWeight.w500,
                        fontSize: 15.sp,
                      ),
                      hintText: 'Check-out time',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(
                          color: AppColors.textPrimaryGrey,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(
                          color: AppColors.textPrimaryGrey,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: AppColors.primary),
                      ),
                      floatingLabelStyle: Theme.of(
                        context,
                      ).textTheme.bodySmall!.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w500,
                        fontSize: 15.sp,
                      ),
                      suffixIcon: const Icon(
                        Icons.access_time,
                        color: AppColors.textPrimaryGrey,
                      ),
                    ),
                    onTap: () => _selectTime(dialogContext, checkOutController),
                  ),
                  const SizedBox(height: 16),
                  // Table Type Dropdown
                  DropdownButtonFormField<String>(
                    value: selectedDiceTableType,
                    decoration: InputDecoration(
                      labelStyle: Theme.of(
                        context,
                      ).textTheme.bodySmall!.copyWith(
                        color: AppColors.textPrimaryGrey,
                        fontWeight: FontWeight.w500,
                        fontSize: 15.sp,
                      ),
                      labelText: 'Table Type',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(
                          color: AppColors.textPrimaryGrey,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(
                          color: AppColors.textPrimaryGrey,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: AppColors.primary),
                      ),
                      floatingLabelStyle: Theme.of(
                        context,
                      ).textTheme.bodySmall!.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w500,
                        fontSize: 15.sp,
                      ),
                    ),
                    hint: Text(
                      'Select table type',
                      style: Theme.of(context).textTheme.bodySmall!.copyWith(
                        color: AppColors.textPrimaryGrey,
                        fontWeight: FontWeight.w500,
                        fontSize: 14.sp,
                      ),
                    ),
                    style: Theme.of(context).textTheme.bodySmall!.copyWith(
                      color: AppColors.textPrimaryGrey,
                      // Default selected item text color
                      fontWeight: FontWeight.w500,
                      fontSize: 15.sp,
                    ),
                    items:
                        _tableType.map((tableType) {
                          return DropdownMenuItem<String>(
                            value: tableType,
                            child: Text(
                              tableType,
                              style: Theme.of(
                                context,
                              ).textTheme.bodySmall!.copyWith(
                                color: AppColors.primary,
                                // Always primary color for items in the dropdown list
                                fontWeight: FontWeight.w500,
                                fontSize: 14.sp,
                              ),
                            ),
                          );
                        }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedDiceTableType = newValue;
                      });
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please select a table type';
                      }
                      return null;
                    },
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
                    if (_validateBookingInputs(
                      checkInController.text,
                      checkOutController.text,
                      selectedDiceTableType,
                      dialogContext,
                    )) {
                      dialogContext.pop();
                      _bookNow(
                        context: context,
                        checkInTime: checkInController.text,
                        checkOutTime: checkOutController.text,
                        diceTableType: selectedDiceTableType!,
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'Book Now',
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
      final checkInTime = TimeOfDay(
        hour: int.parse(checkIn.split(':')[0]),
        minute: int.parse(checkIn.split(':')[1]),
      );
      final checkOutTime = TimeOfDay(
        hour: int.parse(checkOut.split(':')[0]),
        minute: int.parse(checkOut.split(':')[1]),
      );

      final checkInMinutes = checkInTime.hour * 60 + checkInTime.minute;
      final checkOutMinutes = checkOutTime.hour * 60 + checkOutTime.minute;

      if (checkOutMinutes <= checkInMinutes) {
        errors.add('Check-out time must be after check-in time');
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

  Future<void> _selectTime(
    BuildContext context,
    TextEditingController controller,
  ) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (BuildContext context, Widget? child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: Theme(
            data: Theme.of(context).copyWith(
              colorScheme: const ColorScheme.light(primary: AppColors.primary),
            ),
            child: child!,
          ),
        );
      },
    );

    if (picked != null) {
      final String formattedTime =
          '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
      controller.text = formattedTime;
    }
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
            content: Text('Error creating booking request: ${e.toString()}'),
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
            content: Text('Error creating booking request: ${e.toString()}'),
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
