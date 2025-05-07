part of 'cafe_list_bloc.dart';

@immutable
sealed class CafeListEvent {}
class ToggleFavoriteEvent extends CafeListEvent {
  final int index;

  ToggleFavoriteEvent(this.index);
}