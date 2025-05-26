part of 'home_bloc.dart';

sealed class HomeState extends Equatable {
  const HomeState();
}

final class HomeInitial extends HomeState {
  @override
  List<Object> get props => [];
}

final class HomeLoading extends HomeState {
  @override
  List<Object> get props => [];
}

class HomeLoaded extends HomeState {
  final List<CardModel> cards;
  final dynamic response; // or use your specific response type

  const HomeLoaded({
    required this.cards,
    required this.response,
  });

  @override
  List<Object?> get props => [cards, response];

  HomeLoaded copyWith({
    List<CardModel>? cards,
    dynamic response,
  }) {
    return HomeLoaded(
      cards: cards ?? this.cards,
      response: response ?? this.response,
    );
  }
}
class HomeError extends HomeState {
  final String errorMessage;
  const HomeError({required this.errorMessage});

  @override
  List<Object?> get props =>  [errorMessage];
}
///Dice Table Update
final class DiceTableUpdateLoading extends HomeState {
  @override
  List<Object> get props => [];
}

class DiceTableUpdateLoaded extends HomeState {
  // final List<CardModel> cards;
  final dynamic response; // or use your specific response type

  const DiceTableUpdateLoaded({
    // required this.cards,
    required this.response,
  });

  @override
  List<Object?> get props => [response];

  DiceTableUpdateLoaded copyWith({
    // List<CardModel>? cards,
    dynamic response,
  }) {
    return DiceTableUpdateLoaded(
      // cards: cards ?? this.cards,
      response: response ?? this.response,
    );
  }
}
class DiceTableUpdateError extends HomeState {
  final String errorMessage;
  const DiceTableUpdateError({required this.errorMessage});

  @override
  List<Object?> get props =>  [errorMessage];
}