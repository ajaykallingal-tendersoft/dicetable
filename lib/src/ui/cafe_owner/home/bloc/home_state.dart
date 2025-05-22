// part of 'home_bloc.dart';
//
// sealed class HomeState extends Equatable {
//   const HomeState();
// }
//
// final class HomeInitial extends HomeState {
//   @override
//   List<Object> get props => [];
// }
//
// final class HomeLoading extends HomeState {
//   @override
//   List<Object> get props => [];
// }
//
// class HomeLoaded extends HomeState {
//   final List<CardModel> cards;
//   const HomeLoaded({required this.cards});
//
//   @override
//   List<Object?> get props => [cards];
// }
//
// class HomeError extends HomeState {
//   final String errorMessage;
//   const HomeError({required this.errorMessage});
//
//   @override
//   List<Object?> get props => throw [errorMessage];
// }