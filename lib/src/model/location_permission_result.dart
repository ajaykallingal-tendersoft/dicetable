

import '../ui/customer/home/bloc/customer_home_bloc.dart';

class LocationPermissionResult {
  final bool isGranted;
  final String message;
  final LocationErrorType errorType;

  LocationPermissionResult({
    required this.isGranted,
    required this.message,
    required this.errorType,
  });
}