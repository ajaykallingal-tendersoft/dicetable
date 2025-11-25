part of 'cafe_list_bloc.dart';

sealed class CafeListEvent extends Equatable {
  const CafeListEvent();
}

class GetCafeListEvent extends CafeListEvent {
  final CafeListRequest cafeListRequest;
  const GetCafeListEvent({required this.cafeListRequest});
   @override
  List<Object> get props => [cafeListRequest];
}

class GetFavListEvent extends CafeListEvent {
  @override
  List<Object> get props => [];
}

class ToggleFavoriteEvent extends CafeListEvent {
  final int cafeIndex;
  final BuildContext context;

  const ToggleFavoriteEvent(this.cafeIndex,this.context);

  @override
  List<Object?> get props => [cafeIndex];
}

class FilterOptionsEvent extends CafeListEvent {
  @override
  List<Object?> get props => [];
}

class FiltersUpdateEvent extends CafeListEvent {
  final Set<String> selectedTableTypes;
  final Set<String> selectedVenueTypes;
  final TimeOfDay openTime;
  final TimeOfDay closeTime;

  const FiltersUpdateEvent({
    required this.selectedTableTypes,
    required this.selectedVenueTypes,
    required this.openTime,
    required this.closeTime,
  });

  @override
  List<Object> get props => [selectedTableTypes, selectedVenueTypes, openTime, closeTime];
}


class FiltersClearEvent extends CafeListEvent {
  const FiltersClearEvent();

  @override
  List<Object> get props => [];
}

// Add this new event to your cafe_list_event.dart file

class RefreshCafeDetailsEvent extends CafeListEvent {
  final String cafeId;
  final CafeListRequest cafeListRequest;

  const RefreshCafeDetailsEvent({
    required this.cafeId,
    required this.cafeListRequest,
  });

  @override
  List<Object> get props => [cafeId, cafeListRequest];
}