part of 'favourite_bloc.dart';

sealed class FavouriteState extends Equatable {
  const FavouriteState();
}

final class FavouriteInitial extends FavouriteState {
  @override
  List<Object> get props => [];
}

final class FavouriteLoading extends FavouriteState {
  @override
  List<Object> get props => [];
}
class FavouriteLoaded extends FavouriteState {
  final List<Datum> cafes;
  const FavouriteLoaded({ required this.cafes});

  @override
  List<Object?> get props => [cafes];
}

final class FavouriteError extends FavouriteState {
  final String errorMessage;

  const FavouriteError({required this.errorMessage});

  @override
  List<Object> get props => [errorMessage];
}
