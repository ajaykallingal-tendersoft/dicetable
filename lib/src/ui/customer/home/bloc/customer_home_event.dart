part of 'customer_home_bloc.dart';

sealed class CustomerHomeEvent extends Equatable {
  const CustomerHomeEvent();
}

class SearchCafesEvent extends CustomerHomeEvent {
  final CafeSearchRequest request;
  final bool isUserInitiated;

  const SearchCafesEvent(this.request, {this.isUserInitiated = true});

  @override
  List<Object?> get props => [request, isUserInitiated];
}

class FilterCafesEvent extends CustomerHomeEvent {
  final CafeSearchRequest filterRequest;

  const FilterCafesEvent(this.filterRequest);

  @override
  List<Object?> get props => [filterRequest];
}

class ResetSearchEvent extends CustomerHomeEvent {
  @override
  List<Object?> get props => [];
}

class GetFilterOptionsEvent extends CustomerHomeEvent {
  @override
  List<Object?> get props => [];
}

class UpdateFiltersEvent extends CustomerHomeEvent {
  final Set<String> selectedTableTypes;
  final Set<String> selectedVenueTypes;
  final TimeOfDay openTime;
  final TimeOfDay closeTime;

  const UpdateFiltersEvent({
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

class ClearFiltersEvent extends CustomerHomeEvent {
  const ClearFiltersEvent();

  @override
  List<Object> get props => [];
}

class FetchLocationEvent extends CustomerHomeEvent {
  final BuildContext context;
  const FetchLocationEvent({required this.context});

  @override
  List<Object> get props => [context];
}
