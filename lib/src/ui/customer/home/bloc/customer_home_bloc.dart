import 'package:bloc/bloc.dart';
import 'package:dicetable/src/constants/app_colors.dart';
import 'package:dicetable/src/model/customer/cafe/cafe_search_request.dart';
import 'package:dicetable/src/model/customer/cafe/cafe_search_response.dart';
import 'package:dicetable/src/model/customer/cafe/get_filter_options_response.dart';
import 'package:dicetable/src/model/state_model.dart';
import 'package:dicetable/src/resources/api_providers/customer/cafe_data_provider.dart';
import 'package:dicetable/src/utils/data/object_factory.dart';
import 'package:dicetable/src/utils/extension/state_model_extension.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
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
  TimeOfDay _openTime = const TimeOfDay(hour: 10, minute: 0);
  TimeOfDay _closeTime = const TimeOfDay(hour: 14, minute: 0);
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

  Future<void> _onSearchCafes(SearchCafesEvent event,
      Emitter<CustomerHomeState> emit,) async {
    emit(CafeSearchLoading());

    final result = await cafeDataProvider.cafeSearch(event.request);

    if (result == null) {
      emit(const CafeSearchError('No response received from server'));
      return;
    }

    if (result.isSuccess && result.data != null) {
      final cafeLocations = _extractCafeLocations(result.data!);
      emit(CafeSearchSuccess(
        response: result.data!,
        cafeLocations: cafeLocations,
      ));
    } else if (result.isError) {
      emit(CafeSearchError(result.error ?? 'Unknown error occurred'));
    } else {
      emit(const CafeSearchError('Failed to search cafes'));
    }
  }

  Future<void> _onFilterCafes(FilterCafesEvent event,
      Emitter<CustomerHomeState> emit,) async {
    emit(CafeSearchLoading());

    final result = await cafeDataProvider.cafeSearch(event.filterRequest);

    if (result == null) {
      emit(const CafeSearchError('No response received from server'));
      return;
    }

    if (result.isSuccess && result.data != null) {
      final cafeLocations = _extractCafeLocations(result.data!);
      emit(CafeSearchSuccess(
        response: result.data!,
        cafeLocations: cafeLocations,
      ));
    } else if (result.isError) {
      emit(CafeSearchError(result.error ?? 'Unknown error occurred'));
    } else {
      emit(const CafeSearchError('Failed to filter cafes'));
    }
  }

  void _onResetSearch(ResetSearchEvent event,
      Emitter<CustomerHomeState> emit,) {
    emit(CafeSearchInitial());
  }

  List<CafeLocation> _extractCafeLocations(SearchRequestResponse response) {
    if (response.cafes == null) return [];

    return response.cafes!
        .where((cafe) =>
    cafe.latitude != null &&
        cafe.longitude != null &&
        cafe.id != null &&
        cafe.name != null)
        .map((cafe) =>
        CafeLocation(
          id: cafe.id!,
          name: cafe.name!,
          latitude: double.tryParse(cafe.latitude!) ?? 0.0,
          longitude: double.tryParse(cafe.longitude!) ?? 0.0,
          photo: cafe.photo,
          description: cafe.venueDescription,
        ))
        .toList();
  }

  Future<void> _onGetFilterOptions(GetFilterOptionsEvent event,
      Emitter<CustomerHomeState> emit,) async {
    if (_cachedFilterOptions != null &&
        _cachedFilterOptions!.diceTables!.isNotEmpty &&
        _cachedFilterOptions!.venueTypes!.isNotEmpty) {
      emit(
          FilterOptionsLoaded(getFilterOptionsResponse: _cachedFilterOptions!));
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

  void _onUpdateFilters(UpdateFiltersEvent event,
      Emitter<CustomerHomeState> emit,) {
    _selectedTableTypes = Set.from(event.selectedTableTypes);
    _selectedVenueTypes = Set.from(event.selectedVenueTypes);
    _openTime = event.openTime;
    _closeTime = event.closeTime;

    emit(FiltersUpdated(
      selectedTableTypes: _selectedTableTypes,
      selectedVenueTypes: _selectedVenueTypes,
      openTime: _openTime,
      closeTime: _closeTime,
    ));
  }

  void _onClearFilters(ClearFiltersEvent event,
      Emitter<CustomerHomeState> emit,) {
    _selectedTableTypes.clear();
    _selectedVenueTypes.clear();
    _openTime = const TimeOfDay(hour: 10, minute: 0);
    _closeTime = const TimeOfDay(hour: 14, minute: 0);

    emit(FiltersCleared());
    // Re-emit cached filter options if available
    if (_cachedFilterOptions != null &&
        _cachedFilterOptions!.diceTables!.isNotEmpty &&
        _cachedFilterOptions!.venueTypes!.isNotEmpty) {
      emit(
          FilterOptionsLoaded(getFilterOptionsResponse: _cachedFilterOptions!));
    } else {
      // Fetch filter options if cache is empty
      add(GetFilterOptionsEvent());
    }
  }

  Future<void> _onFetchLocation(FetchLocationEvent event,
      Emitter<CustomerHomeState> emit,) async {
    emit(LocationLoading());

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        emit(const LocationError(
          errorMessage: 'Location services are disabled. Please enable location services.',
          errorType: LocationErrorType.serviceDisabled,
        ));
        Fluttertoast.showToast(
          msg: 'Please enable location services.',
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: AppColors.appRedColor,
          textColor: AppColors.primaryWhiteColor,
        );

        _showLocationSettingsDialog(
            event.context,
            'Location Services Disabled',
            'Please enable location services in your device settings to use this feature.');
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          emit(const LocationError(
            errorMessage: 'Location permission denied. Please allow location access.',
            errorType: LocationErrorType.permissionDenied,
          ));
          Fluttertoast.showToast(
            msg: 'Please allow location access.',
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: AppColors.appRedColor,
            textColor: AppColors.primaryWhiteColor,
          );
          _showLocationSettingsDialog(
              event.context,
              'Location Permission Denied',
              'Location access is required for this feature. Please grant permission in app settings.');
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        emit(const LocationError(
          errorMessage: 'Location permission permanently denied. Please enable location access in settings.',
          errorType: LocationErrorType.permissionDeniedForever,
        ));
        Fluttertoast.showToast(
          msg: 'Please enable location access in settings.',
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: AppColors.appRedColor,
          textColor: AppColors.primaryWhiteColor,
        );
        _showLocationSettingsDialog(
            event.context,
            'Location Permission Permanently Denied',
            'Location access was permanently denied. Please go to app settings and enable location.');
        return;
      }

      // Fetch location
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );


      ObjectFactory().prefs.setLatitude(lat: position.latitude.toString());
      ObjectFactory().prefs.setLongitude(long: position.longitude.toString());

      emit(LocationLoaded(
        latitude: position.latitude,
        longitude: position.longitude,
      ));

      Fluttertoast.showToast(
        msg: 'Location saved successfully.',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: AppColors.primary,
        textColor: AppColors.primaryWhiteColor,
      );
    } catch (e, stackTrace) {
      print('Location Fetch Error: $e');
      print('StackTrace: $stackTrace');
      emit(LocationError(
        errorMessage: 'Error fetching location: $e',
        errorType: LocationErrorType.unknown,
      ));
      Fluttertoast.showToast(
        msg: 'Unable to fetch location. Please try again.',
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: AppColors.appRedColor,
        textColor: AppColors.primaryWhiteColor,
      );
    }
  }

  void _showLocationSettingsDialog(BuildContext context, String title,
      String message) {
    showDialog(
      context: context,
      barrierDismissible: false, // User must tap a button
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(dialogContext).pop(); // Dismiss dialog
              },
            ),
            TextButton(
              child: const Text('Open Settings'),
              onPressed: () {
                dialogContext.pop(); // Dismiss dialog
                openAppSettings(); // Opens app settings
              },
            ),
          ],
        );
      },
    );
  }
}