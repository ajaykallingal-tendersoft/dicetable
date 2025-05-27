part of 'cafe_list_bloc.dart';

sealed class CafeListEvent extends Equatable {
  const CafeListEvent();
}

class GetCafeListEvent extends CafeListEvent {
  @override
  List<Object> get props => [];
}

class GetFavListEvent extends CafeListEvent {
  @override
  List<Object> get props => [];
}

class ToggleFavoriteEvent extends CafeListEvent {
  final int cafeIndex;

  const ToggleFavoriteEvent(this.cafeIndex);

  @override
  List<Object?> get props => [cafeIndex];
}