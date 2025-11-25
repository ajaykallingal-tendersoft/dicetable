part of 'cafe_list_bloc.dart';



sealed class CafeListState extends Equatable {
  const CafeListState();
}

final class CafeListInitial extends CafeListState {
  @override
  List<Object> get props => [];
}

final class CafeListLoading extends CafeListState {
  @override
  List<Object> get props => [];
}
class CafeListLoaded extends CafeListState {
  final CafeListResponse cafeListResponse;

  const CafeListLoaded({
    required this.cafeListResponse,
  });

  CafeListLoaded copyWith({
    CafeListResponse? cafeListResponse,
  }) {
    return CafeListLoaded(
      cafeListResponse: cafeListResponse ?? this.cafeListResponse,
    );
  }

  @override
  List<Object?> get props => [cafeListResponse];
}
final class CafeListError extends CafeListState {
  final String errorMessage;
  const CafeListError({required this.errorMessage});
  @override
  List<Object> get props => [errorMessage];
}

class FavoriteToggleLoading extends CafeListState {
  final CafeListResponse cafeListResponse;
  final int toggledCafeIndex;

  const FavoriteToggleLoading({
    required this.cafeListResponse,
    required this.toggledCafeIndex,
  });

  @override
  List<Object?> get props => [cafeListResponse,toggledCafeIndex];
}

final class FavListLoading extends CafeListState {
  @override
  List<Object> get props => [];
}

class FavListLoaded extends CafeListState {
  final FavouriteListResponse favListResponse;

  const FavListLoaded({
    required this.favListResponse,
  });

  @override
  List<Object?> get props => [favListResponse];
}
final class FavListError extends CafeListState {
  final String errorMessage;
  const FavListError({required this.errorMessage});
  @override
  List<Object> get props => [errorMessage];
}

class FilterLoading extends CafeListState {
  @override
  List<Object> get props => [];
}

class FilterLoaded extends CafeListState {
  final GetFilterOptionsResponse getFilterOptionsResponse;
  const FilterLoaded({required this.getFilterOptionsResponse});
  @override
  List<Object> get props => [getFilterOptionsResponse];
}
class FilterError extends CafeListState {
  final String message;

  const FilterError(this.message);

  @override
  List<Object?> get props => [message];
}
class UpdateFilter extends CafeListState {
  final Set<String> selectedTableTypes;
  final Set<String> selectedVenueTypes;
  final TimeOfDay openTime;
  final TimeOfDay closeTime;

  const UpdateFilter({
    required this.selectedTableTypes,
    required this.selectedVenueTypes,
    required this.openTime,
    required this.closeTime,
  });

  @override
  List<Object> get props => [selectedTableTypes, selectedVenueTypes, openTime, closeTime];
}

class FilterClear extends CafeListState {
  const FilterClear();

  @override
  List<Object> get props => [];
}

final class SingleCafeDetailsLoading extends CafeListState {
  @override
  List<Object> get props => [];
}

final class SingleCafeDetailsLoaded extends CafeListState {
  final Cafe cafe;

  const SingleCafeDetailsLoaded({required this.cafe});

  @override
  List<Object> get props => [cafe];
}

final class SingleCafeDetailsError extends CafeListState {
  final String errorMessage;

  const SingleCafeDetailsError({required this.errorMessage});

  @override
  List<Object> get props => [errorMessage];
}