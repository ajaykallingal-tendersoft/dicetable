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

  // Copy method for updating state
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