part of 'card_cubit.dart';

class CardState {
  final List<CardItem> cards;
  const CardState({required this.cards});

  CardState copyWith({List<CardItem>? cards}) {
    return CardState(cards: cards ?? this.cards);
  }
}


