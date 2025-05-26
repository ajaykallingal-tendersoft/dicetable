import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:dicetable/src/common/elevated_button_widget.dart';
import 'package:dicetable/src/constants/app_colors.dart';
import 'package:dicetable/src/ui/customer/cafe_details/widget/cafe_details_card.dart';
import 'package:dicetable/src/ui/customer/cafe_list/components/cafe_details_arguments.dart';
import 'package:dicetable/src/utils/data/object_factory.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import '../../../model/customer/booking/booking_request.dart';
import 'bloc/cafe_details_bloc.dart';

class CafeDetailsScreen extends StatefulWidget {
  final CafeDetailsArguments cafeDetailsArguments;

  const CafeDetailsScreen({
    super.key,
    required this.cafeDetailsArguments,
  });

  @override
  State<CafeDetailsScreen> createState() => _CafeDetailsScreenState();
}

class _CafeDetailsScreenState extends State<CafeDetailsScreen> {
  bool _isLoadingDialogShown = false;

  @override
  Widget build(BuildContext context) {
    return BlocListener<CafeDetailsBloc, CafeDetailsState>(
      listener: (context, state) {
        if (state is CafeBookingLoaded) {
          EasyLoading.dismiss();
          context.pop();
          // if (_isLoadingDialogShown) {
          //   context.pop();
          //   _isLoadingDialogShown = false;
          // }

          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Booking confirmed successfully!'),
              backgroundColor: AppColors.appGreenColor,
              duration: Duration(seconds: 3),
            ),
          );

          // Navigate to confirmation screen or handle success
          // context.push('/booking-confirmation');

        } else if (state is CafeBookingError) {
          EasyLoading.dismiss();
          context.pop();
          // if (_isLoadingDialogShown) {
          //   Navigator.of(context).pop();
          //   _isLoadingDialogShown = false;
          // }

          // Show error message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 3),
            ),
          );
        } else if (state is CafeBookingLoading) {

          if (!_isLoadingDialogShown) {
            _showLoadingDialog(context);
            _isLoadingDialogShown = true;
          }
        }
      },
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          backgroundColor: AppColors.primary,
          leading: IconButton(
            icon: SvgPicture.asset(
              'assets/svg/back.svg',
              fit: BoxFit.scaleDown,
              color: AppColors.primaryWhiteColor,
            ),
            onPressed: () => context.pop(),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 15),
              child: SvgPicture.asset('assets/svg/notify.svg'),
            )
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
                  CafeDetailsCard(
                    name: widget.cafeDetailsArguments.name,
                    tableType: widget.cafeDetailsArguments.tableType,
                    description: widget.cafeDetailsArguments.description,
                    image: widget.cafeDetailsArguments.image,
                    openingHours: widget.cafeDetailsArguments.openingHours,
                    id: widget.cafeDetailsArguments.id,
                  ),
                  const Gap(40),
                  InkWell(
                    onTap: () => _showBookingDialog(context),
                    child: ElevatedButtonWidget(
                      height: 70.h,
                      width: double.infinity,
                      iconEnabled: false,
                      iconLabel: 'SHOW INTEREST',
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
    String selectedDiceTableType = "1"; // Default value

    // Define the dice table type options
    final List<Map<String, String>> diceTableTypes = [
      {"value": "1", "label": "Table Type 1"},
      {"value": "2", "label": "Table Type 2"},
      {"value": "3", "label": "Table Type 3"},
      {"value": "4", "label": "Table Type 4"},
    ];

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
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Check-in Time
                  TextField(
                    controller: checkInController,
                    readOnly: true,
                    decoration: InputDecoration(
                      labelText: 'Check-in Time',
                      hintText: 'Select check-in time',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      suffixIcon: const Icon(Icons.access_time),
                    ),
                    onTap: () => _selectTime(dialogContext, checkInController),
                  ),
                  const SizedBox(height: 16),
                  // Check-out Time
                  TextField(
                    controller: checkOutController,
                    readOnly: true,
                    decoration: InputDecoration(
                      labelText: 'Check-out Time',
                      hintText: 'Select check-out time',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      suffixIcon: const Icon(Icons.access_time),
                    ),
                    onTap: () => _selectTime(dialogContext, checkOutController),
                  ),
                  const SizedBox(height: 16),
                  // Dice Table Type Dropdown
                  DropdownButtonFormField<String>(
                    value: selectedDiceTableType,
                    decoration: InputDecoration(
                      labelText: 'Table Type',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    items: diceTableTypes.map((tableType) {
                      return DropdownMenuItem<String>(
                        value: tableType["value"],
                        child: Text(tableType["label"]!),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedDiceTableType = newValue!;
                      });
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: Text(
                    'Cancel',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (checkInController.text.isNotEmpty &&
                        checkOutController.text.isNotEmpty) {
                      Navigator.of(dialogContext).pop();
                      _bookNow(
                        context: context,
                        checkInTime: checkInController.text,
                        checkOutTime: checkOutController.text,
                        diceTableType: selectedDiceTableType,
                      );
                    } else {
                      // Show validation message
                      ScaffoldMessenger.of(dialogContext).showSnackBar(
                        const SnackBar(
                          content: Text(
                              'Please select both check-in and check-out times'),
                          backgroundColor: Colors.red,
                        ),
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
                    style: TextStyle(color: AppColors.primaryWhiteColor),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _selectTime(BuildContext context,
      TextEditingController controller) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (BuildContext context, Widget? child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: Theme(
            data: Theme.of(context).copyWith(
              colorScheme: ColorScheme.light(
                primary: AppColors.primary,
              ),
            ),
            child: child!,
          ),
        );
      },
    );

    if (picked != null) {
      // Format time in 24-hour format
      final String formattedTime = '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
      controller.text = formattedTime;
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
        cafeId: widget.cafeDetailsArguments.id,
        diceTableType: diceTableType, // Use the selected value
        currentDate: DateTime.now(),
        checkInTime: checkInTime,
        checkOutTime: checkOutTime,
        userId: _getCurrentUserId(),
        userName: _getCurrentUserName(),
        userEmail: _getCurrentUserEmail(),
        deviceId: await _getDeviceId(),
        additionalInfo: '', // Add if needed
      );

      // Trigger the booking event
      if (mounted) {
        context.read<CafeDetailsBloc>().add(
          BookingRequestEvent(bookingRequest: bookingRequest),
        );
      }
    } catch (e) {
      // Handle any errors in creating the booking request
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error creating booking request: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
        print(e.toString());
      }
    }
  }

  void _showLoadingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
              const SizedBox(height: 16),
              const Text('Processing your booking...'),
            ],
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
      print('Error getting user ID: $e');
      return '';
    }
  }

  String _getCurrentUserName() {
    try {
      final userName = ObjectFactory().prefs.getCustomerUserName();
      return userName?.toString() ?? '';
    } catch (e) {
      print('Error getting user name: $e');
      return '';
    }
  }

  String _getCurrentUserEmail() {
    try {
      final userMail = ObjectFactory().prefs.getCustomerUserMail();
      return userMail?.toString() ?? '';
    } catch (e) {
      print('Error getting user email: $e');
      return '';
    }
  }

  Future<String> _getDeviceId() async {
    try {
      DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
      if (Platform.isAndroid) {
        AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
        return androidInfo.id;
      } else if (Platform.isIOS) {
        IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
        return iosInfo.identifierForVendor ?? '';
      }
      return '';
    } catch (e) {
      print('Error getting device ID: $e');
      return '';
    }
  }
}

