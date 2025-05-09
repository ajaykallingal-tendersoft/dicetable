part of 'favourite_bloc.dart';

sealed class FavouriteEvent extends Equatable {
  const FavouriteEvent();
}

class GetFavEvent extends FavouriteEvent {
  @override
  List<Object?> get props =>  [];

}

class ToggleFavStatusEvent extends FavouriteEvent {
  final int index;
  const ToggleFavStatusEvent(this.index);

  @override
  List<Object?> get props => [index];
}