import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:soloseaters/src/constants/app_colors.dart';
import 'package:soloseaters/src/model/customer/cafe/cafe_search_request.dart';
import 'package:soloseaters/src/model/customer/cafe/cafe_search_response.dart';
import 'package:soloseaters/src/model/customer/cafe/get_filter_options_response.dart';
import 'package:soloseaters/src/model/location_permission_result.dart';
import 'package:soloseaters/src/model/state_model.dart';
import 'package:soloseaters/src/resources/api_providers/customer/cafe_data_provider.dart';
import 'package:soloseaters/src/utils/data/object_factory.dart';
import 'package:soloseaters/src/utils/extension/state_model_extension.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';

part 'customer_home_event.dart';

part 'customer_home_state.dart';

class CustomerHomeBloc extends Bloc<CustomerHomeEvent, CustomerHomeState> {
  final CafeDataProvider cafeDataProvider;
  Set<String> _selectedTableTypes = {};
  Set<String> _selectedVenueTypes = {};
  TimeOfDay _openTime = const TimeOfDay(hour: 0, minute: 0);
  TimeOfDay _closeTime = const TimeOfDay(hour: 0, minute: 0);
  GetFilterOptionsResponse? _cachedFilterOptions; // Cache for filter options

  Set<String> get selectedTableTypes => Set.from(_selectedTableTypes);

  Set<String> get selectedVenueTypes => Set.from(_selectedVenueTypes);

  TimeOfDay get openTime => _openTime;

  TimeOfDay get closeTime => _closeTime;

  CustomerHomeBloc({required this.cafeDataProvider})
    : super(CustomerHomeInitial()) {
    on<SearchCafesEvent>(_onSearchCafes);
    on<FilterCafesEvent>(_onFilterCafes);
    on<ResetSearchEvent>(_onResetSearch);
    on<GetFilterOptionsEvent>(_onGetFilterOptions);
    on<UpdateFiltersEvent>(_onUpdateFilters);
    on<ClearFiltersEvent>(_onClearFilters);
    on<FetchLocationEvent>(_onFetchLocation);
  }

  Future<void> _onSearchCafes(
    SearchCafesEvent event,
    Emitter<CustomerHomeState> emit,
  ) async {
    emit(CafeSearchLoading());

    final result = await cafeDataProvider.cafeSearch(event.request);

    if (result == null) {
      emit(const CafeSearchError('No response received from server'));
      return;
    }

    if (result.isSuccess && result.data != null) {
      final cafeLocations = _extractCafeLocations(result.data!);
      emit(
        CafeSearchSuccess(response: result.data!, cafeLocations: cafeLocations),
      );
    } else if (result.isError) {
      emit(CafeSearchError(result.error ?? 'Unknown error occurred'));
    } else {
      emit(const CafeSearchError('Failed to search cafes'));
    }
  }

  Future<void> _onFilterCafes(
    FilterCafesEvent event,
    Emitter<CustomerHomeState> emit,
  ) async {
    emit(CafeSearchLoading());

    final result = await cafeDataProvider.cafeSearch(event.filterRequest);

    if (result == null) {
      emit(const CafeSearchError('No response received from server'));
      return;
    }

    if (result.isSuccess && result.data != null) {
      final cafeLocations = _extractCafeLocations(result.data!);
      emit(
        CafeSearchSuccess(response: result.data!, cafeLocations: cafeLocations),
      );
    } else if (result.isError) {
      emit(CafeSearchError(result.error ?? 'Unknown error occurred'));
    } else {
      emit(const CafeSearchError('Failed to filter cafes'));
    }
  }

  void _onResetSearch(ResetSearchEvent event, Emitter<CustomerHomeState> emit) {
    emit(CafeSearchInitial());
  }

  List<CafeLocation> _extractCafeLocations(SearchRequestResponse response) {
    if (response.cafes == null) return [];

    return response.cafes!
        .where(
          (cafe) =>
              cafe.latitude != null &&
              cafe.longitude != null &&
              cafe.id != null &&
              cafe.name != null,
        )
        .map(
          (cafe) => CafeLocation(
            id: cafe.id!,
            name: cafe.name!,
            latitude: double.tryParse(cafe.latitude!) ?? 0.0,
            longitude: double.tryParse(cafe.longitude!) ?? 0.0,
            photo: cafe.photo,
            description: cafe.venueDescription,
          ),
        )
        .toList();
  }

  Future<void> _onGetFilterOptions(
    GetFilterOptionsEvent event,
    Emitter<CustomerHomeState> emit,
  ) async {
    if (_cachedFilterOptions != null &&
        _cachedFilterOptions!.diceTables!.isNotEmpty &&
        _cachedFilterOptions!.venueTypes!.isNotEmpty) {
      emit(
        FilterOptionsLoaded(getFilterOptionsResponse: _cachedFilterOptions!),
      );
      return;
    }

    emit(FilterOptionsLoading());
    try {
      final StateModel? stateModel = await cafeDataProvider.getFilterOptions();

      if (stateModel is SuccessState) {
        _cachedFilterOptions = stateModel.value; // Cache the response
        emit(FilterOptionsLoaded(getFilterOptionsResponse: stateModel.value));
      } else if (stateModel is ErrorState) {
        emit(FilterOptionsError(stateModel.msg));
      }
    } catch (e, stackTrace) {
      print('Filter Options Error: $e');
      print('StackTrace: $stackTrace');
      emit(FilterOptionsError(e.toString()));
    }
  }

  void _onUpdateFilters(
    UpdateFiltersEvent event,
    Emitter<CustomerHomeState> emit,
  ) {
    _selectedTableTypes = Set.from(event.selectedTableTypes);
    _selectedVenueTypes = Set.from(event.selectedVenueTypes);
    _openTime = event.openTime;
    _closeTime = event.closeTime;

    emit(
      FiltersUpdated(
        selectedTableTypes: _selectedTableTypes,
        selectedVenueTypes: _selectedVenueTypes,
        openTime: _openTime,
        closeTime: _closeTime,
      ),
    );
  }

  void _onClearFilters(
    ClearFiltersEvent event,
    Emitter<CustomerHomeState> emit,
  ) {
    _selectedTableTypes.clear();
    _selectedVenueTypes.clear();
    _openTime = const TimeOfDay(hour: 00, minute: 0);
    _closeTime = const TimeOfDay(hour: 00, minute: 0);

    emit(FiltersCleared());
    // Re-emit cached filter options if available
    if (_cachedFilterOptions != null &&
        _cachedFilterOptions!.diceTables!.isNotEmpty &&
        _cachedFilterOptions!.venueTypes!.isNotEmpty) {
      emit(
        FilterOptionsLoaded(getFilterOptionsResponse: _cachedFilterOptions!),
      );
    } else {
      // Fetch filter options if cache is empty
      add(GetFilterOptionsEvent());
    }
  }

  Future<void> _onFetchLocation(
    FetchLocationEvent event,
    Emitter<CustomerHomeState> emit,
  ) async {
    emit(LocationLoading());

    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        emit(
          const LocationError(
            errorMessage:
                'Location services disabled. Enable in device settings.',
            errorType: LocationErrorType.serviceDisabled,
          ),
        );
        await _showLocationSettingsDialog(
          event.context,
          'Location Services Disabled',
          'Please enable location services in your device settings to use this feature.',
          showSettings: true,
        );
        return;
      }

      final locationPermissionResult = await _handleLocationPermission(
        event.context,
      );

      if (!locationPermissionResult.isGranted) {
        emit(
          LocationError(
            errorMessage: locationPermissionResult.message,
            errorType: locationPermissionResult.errorType,
          ),
        );
        return;
      }

      Position position = await _getCurrentPositionWithRetry();

      await _saveLocationToPreferences(position);

      // Emit the location loaded state with the fetched coordinates
      await Future.delayed(const Duration(milliseconds: 500));

      emit(
        LocationLoaded(
          latitude: position.latitude,
          longitude: position.longitude,
        ),
      );
    } catch (e, stackTrace) {
      debugPrint('Location fetch error: $e');
      debugPrint('Stack trace: $stackTrace');

      emit(
        LocationError(
          errorMessage: _getErrorMessage(e),
          errorType: LocationErrorType.unknown,
        ),
      );
    }
  }

  Future<LocationPermissionResult> _handleLocationPermission(
    BuildContext context,
  ) async {
    LocationPermission permission = await Geolocator.checkPermission();
print('Initial permission: $permission');
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied) {
      await _showLocationSettingsDialog(
        context,
        'Location Permission Denied',
        'Location access is required to fetch your current location.',
        showSettings: false,
      );
      return LocationPermissionResult(
        isGranted: false,
        message: 'Location permission denied by user',
        errorType: LocationErrorType.permissionDenied,
      );
    }

    if (permission == LocationPermission.deniedForever) {
      await _showLocationSettingsDialog(
        context,
        'Location Permission Permanently Denied',
        'Location access is permanently denied. Please open app settings to enable it.',
        showSettings: true,
      );
      return LocationPermissionResult(
        isGranted: false,
        message: 'Location permission permanently denied.',
        errorType: LocationErrorType.permissionDeniedForever,
      );
    }

    // For iOS: check if location is restricted
    if (permission == LocationPermission.unableToDetermine) {
      return LocationPermissionResult(
        isGranted: false,
        message: 'Location access is restricted or not available.',
        errorType: LocationErrorType.permissionRestricted,
      );
    }

    // Granted (WhileInUse or Always)
    return LocationPermissionResult(
      isGranted: true,
      message: 'Location permission granted.',
      errorType: LocationErrorType.none,
    );
  }

  // Future<LocationPermissionResult> _handleLocationPermission(BuildContext context) async {
  //   // Check current permission status
  //   PermissionStatus status = await Permission.location.status;

  //   switch (status) {
  //     case PermissionStatus.granted:
  //       return LocationPermissionResult(
  //         isGranted: true,
  //         message: 'Location permission granted',
  //         errorType: LocationErrorType.none,
  //       );

  //     case PermissionStatus.denied:
  //     // First time asking or user previously denied
  //       status = await Permission.location.request();
  //       return _handlePermissionResponse(context, status);

  //     case PermissionStatus.permanentlyDenied:
  //     // User permanently denied permission
  //       await _showLocationSettingsDialog(
  //         context,
  //         'Location Permission Required',
  //         'Location access is permanently denied. Please enable it in app settings to use this feature.',
  //         showSettings: true,
  //       );
  //       return LocationPermissionResult(
  //         isGranted: false,
  //         message: 'Location permission permanently denied. Enable in app settings.',
  //         errorType: LocationErrorType.permissionDeniedForever,
  //       );

  //     case PermissionStatus.restricted:
  //     // iOS: Permission restricted (e.g., parental controls)
  //       return LocationPermissionResult(
  //         isGranted: false,
  //         message: 'Location access is restricted on this device.',
  //         errorType: LocationErrorType.permissionRestricted,
  //       );

  //     case PermissionStatus.limited:
  //     // iOS 14+: Limited location access
  //       await _showLocationSettingsDialog(
  //         context,
  //         'Limited Location Access',
  //         'You have granted limited location access. For better accuracy, please allow precise location in app settings.',
  //         showSettings: true,
  //       );
  //       return LocationPermissionResult(
  //         isGranted: true, // Still usable but limited
  //         message: 'Limited location access granted',
  //         errorType: LocationErrorType.permissionLimited,
  //       );

  //     default:
  //       return LocationPermissionResult(
  //         isGranted: false,
  //         message: 'Unknown permission status',
  //         errorType: LocationErrorType.unknown,
  //       );
  //   }
  // }

  Future<LocationPermissionResult> _handlePermissionResponse(
    BuildContext context,
    PermissionStatus status,
  ) async {
    switch (status) {
      case PermissionStatus.granted:
        return LocationPermissionResult(
          isGranted: true,
          message: 'Location permission granted',
          errorType: LocationErrorType.none,
        );

      case PermissionStatus.denied:
        await _showLocationSettingsDialog(
          context,
          'Location Permission Denied',
          'Location access is required for this feature. Please grant permission to continue.',
          showSettings: false,
        );
        return LocationPermissionResult(
          isGranted: false,
          message: 'Location permission denied by user',
          errorType: LocationErrorType.permissionDenied,
        );

      case PermissionStatus.permanentlyDenied:
        await _showLocationSettingsDialog(
          context,
          'Location Permission Required',
          'Location access is permanently denied. Please enable it in app settings.',
          showSettings: true,
        );
        return LocationPermissionResult(
          isGranted: false,
          message:
              'Location permission permanently denied. Enable in app settings.',
          errorType: LocationErrorType.permissionDeniedForever,
        );

      case PermissionStatus.limited:
        return LocationPermissionResult(
          isGranted: true,
          message: 'Limited location access granted',
          errorType: LocationErrorType.permissionLimited,
        );

      default:
        return LocationPermissionResult(
          isGranted: false,
          message: 'Unable to get location permission',
          errorType: LocationErrorType.unknown,
        );
    }
  }

  Future<Position> _getCurrentPositionWithRetry({int maxRetries = 3}) async {
    for (int attempt = 1; attempt <= maxRetries; attempt++) {
      try {
        return await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
          timeLimit: const Duration(seconds: 15),
        );
      } catch (e) {
        if (attempt == maxRetries) {
          // Try with lower accuracy on final attempt
          return await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.medium,
            timeLimit: const Duration(seconds: 10),
          );
        }
        // Wait before retry
        await Future.delayed(Duration(seconds: attempt));
      }
    }
    throw Exception('Failed to get location after $maxRetries attempts');
  }

  Future<void> _saveLocationToPreferences(Position position) async {
    try {
      ObjectFactory().prefs.setLatitude(lat: position.latitude.toString());
      ObjectFactory().prefs.setLongitude(long: position.longitude.toString());
    } catch (e) {
      debugPrint('Error saving location to preferences: $e');
      // Don't throw here as the location was still successfully obtained
    }
  }

  Future<void> _showLocationSettingsDialog(
    BuildContext context,
    String title,
    String message, {
    required bool showSettings,
  }) async {
    if (!context.mounted) return;

    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            title,
            style: Theme.of(context).textTheme.bodyLarge!.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
              fontSize: 14.sp,
            ),
          ),
          content: Text(
            message,
            style: Theme.of(context).textTheme.bodyLarge!.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
              fontSize: 14.sp,
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                'Cancel',
                style: Theme.of(context).textTheme.bodySmall!.copyWith(
                  color: AppColors.shadowColor,
                  fontWeight: FontWeight.w500,
                  fontSize: 14.sp,
                ),
              ),
              onPressed: () => context.pop(),
            ),
            if (showSettings)
              TextButton(
                style: TextButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  'Open Settings',
                  style: Theme.of(context).textTheme.bodySmall!.copyWith(
                    color: AppColors.primaryWhiteColor,
                    fontWeight: FontWeight.w500,
                    fontSize: 14.sp,
                  ),
                ),
                onPressed: () {
                  context.pop();
                  openAppSettings();
                },
              )
            else
              TextButton(
                child: Text(
                  'Retry',
                  style: Theme.of(context).textTheme.bodySmall!.copyWith(
                    color: AppColors.primaryWhiteColor,
                    fontWeight: FontWeight.w500,
                    fontSize: 14.sp,
                  ),
                ),
                onPressed: () => context.pop(),
              ),
          ],
        );
      },
    );
  }

  String _getErrorMessage(dynamic error) {
    if (error is LocationServiceDisabledException) {
      return 'Location services are disabled. Please enable them in device settings.';
    } else if (error is PermissionDeniedException) {
      return 'Location permission denied. Please grant permission in app settings.';
    } else if (error is TimeoutException) {
      return 'Location request timed out. Please try again.';
    } else if (error.toString().contains('NETWORK_ERROR')) {
      return 'Network error while getting location. Please check your connection.';
    } else {
      return 'Unable to get location. Please try again.';
    }
  }
}

/// Extended location error types

// Future<void> _onFetchLocation(
//     FetchLocationEvent event,
//     Emitter<CustomerHomeState> emit,
//     ) async {
//   emit(LocationLoading());
//
//   try {
//     bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
//     LocationPermission permission = await Geolocator.checkPermission();
//
//     if (!serviceEnabled) {
//       emit(const LocationError(
//         errorMessage: 'Location services disabled. Enable in device settings.',
//         errorType: LocationErrorType.serviceDisabled,
//       ));
//       _showLocationSettingsDialog(
//             event.context,
//             'Location Services Disabled',
//             'Please enable location services in your device settings to use this feature.');
//       return;
//     }
//
//     if (permission == LocationPermission.denied) {
//       permission = await Geolocator.requestPermission();
//       if (permission != LocationPermission.whileInUse &&
//           permission != LocationPermission.always) {
//         emit(const LocationError(
//           errorMessage: 'Location permission required for full functionality',
//           errorType: LocationErrorType.permissionDenied,
//         ));
//         return;
//       }
//     }
//
//     if (permission == LocationPermission.deniedForever) {
//       emit(const LocationError(
//         errorMessage: 'Enable location in app settings',
//         errorType: LocationErrorType.permissionDeniedForever,
//       ));
//       _showLocationSettingsDialog(
//         event.context,
//         'Location Permission Denied',
//         'Location access is required for this feature. Please grant permission in app settings.',
//       );// Uncomment and use
//       return;
//     }
//
//     Position position = await Geolocator.getCurrentPosition(
//       desiredAccuracy: LocationAccuracy.high,
//     );
//
//     ObjectFactory().prefs.setLatitude(lat: position.latitude.toString());
//     ObjectFactory().prefs.setLongitude(long: position.longitude.toString());
//
//     emit(LocationLoaded(
//       latitude: position.latitude,
//       longitude: position.longitude,
//     ));
//
//   } catch (e, stackTrace) {
//     emit(LocationError(
//       errorMessage: 'Error: ${e.toString()}',
//       errorType: LocationErrorType.unknown,
//     ));
//   }
// }

// Future<void> _onFetchLocation(
//   FetchLocationEvent event,
//   Emitter<CustomerHomeState> emit,
// ) async {
//   emit(LocationLoading());
//
//   try {
//     bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
//     if (!serviceEnabled) {
//       emit(
//         const LocationError(
//           errorMessage:
//           'Location services are disabled. Please enable location services.',
//           errorType: LocationErrorType.serviceDisabled,
//         ),
//       );
//       LocationPermission permission = await Geolocator.checkPermission();
//       permission = await Geolocator.requestPermission();
//
//       // Fluttertoast.showToast(
//       //   msg: 'Please enable location services.',
//       //   toastLength: Toast.LENGTH_LONG,
//       //   gravity: ToastGravity.BOTTOM,
//       //   backgroundColor: AppColors.appRedColor,
//       //   textColor: AppColors.primaryWhiteColor,
//       // );
//       LocationPermission permission = await Geolocator.checkPermission();
//       permission = await Geolocator.requestPermission();
//       // _showLocationSettingsDialog(
//       //     event.context,
//       //     'Location Services Disabled',
//       //     'Please enable location services in your device settings to use this feature.');
//       return;
//     }
//
//     LocationPermission permission = await Geolocator.checkPermission();
//     if (permission == LocationPermission.denied) {
//       permission = await Geolocator.requestPermission();
//       if (permission == LocationPermission.denied) {
//         emit(
//           const LocationError(
//             errorMessage:
//                 'Location permission denied. Please allow location access.',
//             errorType: LocationErrorType.permissionDenied,
//           ),
//         );
//         Fluttertoast.showToast(
//           msg: 'Please allow location access.',
//           toastLength: Toast.LENGTH_LONG,
//           gravity: ToastGravity.BOTTOM,
//           backgroundColor: AppColors.appRedColor,
//           textColor: AppColors.primaryWhiteColor,
//         );
//         _showLocationSettingsDialog(
//           event.context,
//           'Location Permission Denied',
//           'Location access is required for this feature. Please grant permission in app settings.',
//         );
//         return;
//       }
//     }
//
//     if (permission == LocationPermission.deniedForever) {
//       permission = await Geolocator.requestPermission();
//       emit(
//         const LocationError(
//           errorMessage:
//               'Location permission permanently denied. Please enable location access in settings.',
//           errorType: LocationErrorType.permissionDeniedForever,
//         ),
//       );
//       Fluttertoast.showToast(
//         msg: 'Please enable location access in settings.',
//         toastLength: Toast.LENGTH_LONG,
//         gravity: ToastGravity.BOTTOM,
//         backgroundColor: AppColors.appRedColor,
//         textColor: AppColors.primaryWhiteColor,
//       );
//       _showLocationSettingsDialog(
//         event.context,
//         'Location Permission Permanently Denied',
//         'Location access was permanently denied. Please go to app settings and enable location.',
//       );
//       return;
//     }
//
//     // Fetch location
//     Position position = await Geolocator.getCurrentPosition(
//       desiredAccuracy: LocationAccuracy.high,
//     );
//
//     ObjectFactory().prefs.setLatitude(lat: position.latitude.toString());
//     ObjectFactory().prefs.setLongitude(long: position.longitude.toString());
//
//     emit(
//       LocationLoaded(
//         latitude: position.latitude,
//         longitude: position.longitude,
//       ),
//     );
//
//     // Fluttertoast.showToast(
//     //   msg: 'Location saved successfully.',
//     //   toastLength: Toast.LENGTH_SHORT,
//     //   gravity: ToastGravity.BOTTOM,
//     //   backgroundColor: AppColors.primary,
//     //   textColor: AppColors.primaryWhiteColor,
//     // );
//   } catch (e, stackTrace) {
//     print('Location Fetch Error: $e');
//     print('StackTrace: $stackTrace');
//     emit(
//       LocationError(
//         errorMessage: 'Error fetching location: $e',
//         errorType: LocationErrorType.unknown,
//       ),
//     );
//     Fluttertoast.showToast(
//       msg: 'Unable to fetch location. Please try again.',
//       toastLength: Toast.LENGTH_LONG,
//       gravity: ToastGravity.BOTTOM,
//       backgroundColor: AppColors.appRedColor,
//       textColor: AppColors.primaryWhiteColor,
//     );
//   }
// }

// void _showLocationSettingsDialog(
//   BuildContext context,
//   String title,
//   String message,
// ) {
//   showDialog(
//     context: context,
//     barrierDismissible: false,
//     builder: (BuildContext dialogContext) {
//       return AlertDialog(
//         title: Text(
//           title,
//           style: Theme.of(context).textTheme.bodyLarge!.copyWith(
//             color: AppColors.primary,
//             fontWeight: FontWeight.w600,
//             fontSize: 16.sp,
//           ),
//         ),
//         content: Text(message),
//         actions: <Widget>[
//           TextButton(
//             child: Text(
//               'Cancel',
//               style: Theme.of(context).textTheme.bodySmall!.copyWith(
//                 color: AppColors.shadowColor,
//                 fontWeight: FontWeight.w500,
//                 fontSize: 14.sp,
//               ),
//             ),
//             onPressed: () {
//               context.pop(); // Dismiss dialog
//             },
//           ),
//           TextButton(
//             style: TextButton.styleFrom(
//               backgroundColor: AppColors.primary,
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(8),
//               ),
//             ),
//             child: Text(
//               'Open Settings',
//               style: Theme.of(context).textTheme.bodySmall!.copyWith(
//                 color: AppColors.primaryWhiteColor,
//                 fontWeight: FontWeight.w500,
//                 fontSize: 14.sp,
//               ),
//             ),
//             onPressed: () {
//               dialogContext.pop(); // Dismiss dialog
//               openAppSettings(); // Opens app settings
//             },
//           ),
//         ],
//       );
//     },
//   );
// }

enum LocationErrorType {
  none,
  serviceDisabled,
  permissionDenied,
  permissionDeniedForever,
  permissionRestricted,
  permissionLimited,
  timeout,
  networkError,
  unknown,
}
