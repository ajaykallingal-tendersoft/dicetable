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
  bool _hasUserSearched = false;
  bool _isFetchingLocation = false;

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
    // If user has manually searched, don't override with automatic searches
    if (_hasUserSearched && !event.isUserInitiated) {
      return;
    }

    if (event.isUserInitiated) {
      _hasUserSearched = true;
    }
    emit(CafeSearchLoading());

    final result = await cafeDataProvider.cafeSearch(event.request);

    if (result == null) {
      emit(const CafeSearchError('No response received from server'));
      return;
    }

    if (result.isSuccess && result.data != null) {
      final cafeLocations = _extractCafeLocations(result.data!);
      emit(
        CafeSearchSuccess(
          response: result.data!,
          cafeLocations: cafeLocations,
          isFilterResult: event.isFilterResult,
          searchQuery: event.request.search,
        ),
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
    _hasUserSearched = false;
    emit(CafeSearchInitial());
  }

  List<CafeLocation> _extractCafeLocations(SearchRequestResponse response) {
    if (response.cafes == null) return [];

    return response.cafes!
        .where((cafe) {
          // Filter out cafes with null or empty fields
          if (cafe.latitude == null ||
              cafe.longitude == null ||
              cafe.id == null ||
              cafe.name == null) {
            return false;
          }

          // Filter out cafes with empty coordinate strings
          final latStr = cafe.latitude!.trim();
          final lngStr = cafe.longitude!.trim();
          if (latStr.isEmpty || lngStr.isEmpty) {
            return false;
          }

          // Parse coordinates
          final lat = double.tryParse(latStr);
          final lng = double.tryParse(lngStr);

          // Filter out cafes with invalid or 0.0 coordinates (Null Island)
          if (lat == null || lng == null || (lat == 0.0 && lng == 0.0)) {
            debugPrint(
              'Filtering out cafe "${cafe.name}" with invalid coordinates: ($latStr, $lngStr)',
            );
            return false;
          }

          return true;
        })
        .map(
          (cafe) => CafeLocation(
            id: cafe.id!,
            name: cafe.name!,
            latitude: double.parse(cafe.latitude!.trim()),
            longitude: double.parse(cafe.longitude!.trim()),
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

    // Reload all cafes with no active filters so the map refreshes
    final double lat =
        double.tryParse(ObjectFactory().prefs.getLatitude().toString()) ?? 0.0;
    final double lng =
        double.tryParse(ObjectFactory().prefs.getLongitude().toString()) ?? 0.0;
    final bool isGuest = ObjectFactory().prefs.isGuestUser() == true;
    final String deviceToken =
        isGuest ? ObjectFactory().prefs.getDeviceID() ?? '' : '';

    add(
      SearchCafesEvent(
        CafeSearchRequest(
          search: '',
          openTime: '',
          closeTime: '',
          diceTableFilter: [],
          accommodationsFilter: [],
          deviceToken: deviceToken,
          latitude: lat,
          longitude: lng,
        ),
        isUserInitiated: true,
        isFilterResult: false,
      ),
    );
  }

  Future<void> _onFetchLocation(
    FetchLocationEvent event,
    Emitter<CustomerHomeState> emit,
  ) async {
    if (_isFetchingLocation) return;
    _isFetchingLocation = true;

    emit(LocationLoading());

    try {
      // Step 1: Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        emit(
          const LocationError(
            errorMessage:
                'Location services disabled. Enable in device settings.',
            errorType: LocationErrorType.serviceDisabled,
          ),
        );

        if (event.context.mounted) {
          await _showLocationSettingsDialog(
            event.context,
            'Location Services Disabled',
            'Please enable location services in your device settings to use this feature.',
            showSettings: true,
          );
        }
        return;
      }

      // Step 2: Handle location permissions
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

      // Step 3: Get current position with retry mechanism
      Position position = await _getCurrentPositionWithRetry();

      // Step 4: Save location to preferences
      await _saveLocationToPreferences(position);

      // Step 5: Add small delay to ensure UI stability
      await Future.delayed(const Duration(milliseconds: 500));

      // Step 6: Emit success state
      emit(
        LocationLoaded(
          latitude: position.latitude,
          longitude: position.longitude,
        ),
      );

      debugPrint(
        'Location loaded successfully: ${position.latitude}, ${position.longitude}',
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
    } finally {
      _isFetchingLocation = false;
    }
  }

  Future<LocationPermissionResult> _handleLocationPermission(
    BuildContext context,
  ) async {
    LocationPermission permission = await Geolocator.checkPermission();
    debugPrint('Initial permission status: $permission');

    // Handle denied permission - request it
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      debugPrint('Permission after request: $permission');
    }

    // Still denied after request
    if (permission == LocationPermission.denied) {
      if (context.mounted) {
        await _showLocationSettingsDialog(
          context,
          'Location Permission Denied',
          'Location access is required to show your position on the map. Please grant permission to continue.',
          showSettings: false,
        );
      }
      return LocationPermissionResult(
        isGranted: false,
        message: 'Location permission denied by user',
        errorType: LocationErrorType.permissionDenied,
      );
    }

    // Permanently denied
    if (permission == LocationPermission.deniedForever) {
      if (context.mounted) {
        await _showLocationSettingsDialog(
          context,
          'Location Permission Required',
          'Location access is permanently denied. Please enable it in app settings to use location features.',
          showSettings: true,
        );
      }
      return LocationPermissionResult(
        isGranted: false,
        message:
            'Location permission permanently denied. Enable in app settings.',
        errorType: LocationErrorType.permissionDeniedForever,
      );
    }

    // Unable to determine (iOS specific case)
    if (permission == LocationPermission.unableToDetermine) {
      return LocationPermissionResult(
        isGranted: false,
        message: 'Location access is restricted or unavailable on this device.',
        errorType: LocationErrorType.permissionRestricted,
      );
    }

    // Success cases: whileInUse or always
    if (permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always) {
      debugPrint('Location permission granted: $permission');
      return LocationPermissionResult(
        isGranted: true,
        message: 'Location permission granted.',
        errorType: LocationErrorType.none,
      );
    }

    // Fallback for any other unexpected states
    return LocationPermissionResult(
      isGranted: false,
      message: 'Unknown permission status: $permission',
      errorType: LocationErrorType.unknown,
    );
  }

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
