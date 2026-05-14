part of 'customer_home_bloc.dart';

sealed class CustomerHomeState extends Equatable {
  const CustomerHomeState();
}

final class CustomerHomeInitial extends CustomerHomeState {
  @override
  List<Object> get props => [];
}

final class CafeSearchInitial extends CustomerHomeState {
  @override
  List<Object> get props => [];
}

class CafeSearchLoading extends CustomerHomeState {
  @override
  List<Object> get props => [];
}

class CafeSearchSuccess extends CustomerHomeState {
  final SearchRequestResponse response;
  final List<CafeLocation> cafeLocations;
  final bool isFilterResult;
  final String searchQuery;

  const CafeSearchSuccess({
    required this.response,
    required this.cafeLocations,
    this.isFilterResult = false,
    this.searchQuery = '',
  });

  @override
  List<Object?> get props =>
      [response, cafeLocations, isFilterResult, searchQuery];
}

class CafeSearchError extends CustomerHomeState {
  final String message;

  const CafeSearchError(this.message);

  @override
  List<Object?> get props => [message];
}

class FilterOptionsLoading extends CustomerHomeState {
  @override
  List<Object> get props => [];
}

class FilterOptionsLoaded extends CustomerHomeState {
  final GetFilterOptionsResponse getFilterOptionsResponse;
  const FilterOptionsLoaded({required this.getFilterOptionsResponse});
  @override
  List<Object> get props => [getFilterOptionsResponse];
}

class FilterOptionsError extends CustomerHomeState {
  final String message;

  const FilterOptionsError(this.message);

  @override
  List<Object?> get props => [message];
}

class FiltersUpdated extends CustomerHomeState {
  final Set<String> selectedTableTypes;
  final Set<String> selectedVenueTypes;
  final TimeOfDay openTime;
  final TimeOfDay closeTime;

  const FiltersUpdated({
    required this.selectedTableTypes,
    required this.selectedVenueTypes,
    required this.openTime,
    required this.closeTime,
  });

  @override
  List<Object> get props => [
    selectedTableTypes,
    selectedVenueTypes,
    openTime,
    closeTime,
  ];
}

class FiltersCleared extends CustomerHomeState {
  const FiltersCleared();

  @override
  List<Object> get props => [];
}

// Helper class for cafe locations
class CafeLocation extends Equatable {
  final int id;
  final String name;
  final double latitude;
  final double longitude;
  final String? photo;
  final String? description;

  const CafeLocation({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    this.photo,
    this.description,
  });

  @override
  List<Object?> get props => [
    id,
    name,
    latitude,
    longitude,
    photo,
    description,
  ];
}

class LocationLoading extends CustomerHomeState {
  @override
  List<Object> get props => [];
}

class LocationLoaded extends CustomerHomeState {
  final double latitude;
  final double longitude;

  const LocationLoaded({required this.latitude, required this.longitude});

  @override
  List<Object?> get props => [latitude, longitude];
}

class LocationError extends CustomerHomeState {
  final String errorMessage;
  final LocationErrorType errorType;

  const LocationError({required this.errorMessage, required this.errorType});

  @override
  List<Object?> get props => [errorMessage, errorType];
}

// enum LocationErrorType {
//   serviceDisabled,
//   permissionDenied,
//   permissionDeniedForever,
//   unknown,
// }
