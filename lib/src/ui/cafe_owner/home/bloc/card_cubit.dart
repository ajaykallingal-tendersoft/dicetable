import 'package:bloc/bloc.dart';
import 'package:dicetable/src/ui/cafe_owner/home/model/card_item.dart';

part 'card_state.dart';

class CardCubit extends Cubit<CardState> {
  CardCubit()
      : super(
          CardState(
            cards: [
              CardItem(
                  title: "Business Networking",
                  initialAvailabilityText: "10:00 AM - 2:30 PM Saturdays",
                  subtitle: 'Professional networking peoples',
                  initialPromoText:
                      'Professional Networking, Your next business opportunity could start with a simple introduction and a shared meal.'),
              CardItem(
                  title: "Social Solos",
                  initialAvailabilityText: "All days",
                  subtitle: 'Mix - new to town or passing through',
                  initialPromoText:
                      'New to town or just passing through, The place to meet a mix of great people, ideal if you’re wanting to meet new people in your area, new to town or passing through.'),
              CardItem(
                  title: "Solo Singles",
                  initialAvailabilityText: "All days",
                  subtitle: 'Authentic face to face conversations',
                  initialPromoText:
                      'Real world singles, No swiping, no pressure, just authentic, face-to-face conversations at a local Dice Table. Real connections.'),
              CardItem(
                  title: "Prime Time - Over 60’s",
                  initialAvailabilityText: "Available: 10:00 AM - 02:30 PM Sundays",
                  subtitle: 'People at same stage of life',
                  initialPromoText:
                  'People at the same stage of life, Meet likeminded people at the same stage of life. Staying social is healthy at any age. Enjoy meeting new people.'),
            ],
          ),
        );

  void toggleCheck(int index) {
    final updated = state.cards.asMap().entries.map((entry) {
      if (entry.key == index) {
        return entry.value.copyWith(isChecked: !entry.value.isChecked);
      }
      return entry.value;
    }).toList();
    emit(CardState(cards: updated));
  }

  void toggleExpand(int index) {
    final updated = state.cards.asMap().entries.map((entry) {
      if (entry.key == index) {
        return entry.value.copyWith(isExpanded: !entry.value.isExpanded);
      }
      return entry.value;
    }).toList();
    emit(CardState(cards: updated));
  }

  void updateText(int index, String newText) {
    final updated = state.cards.asMap().entries.map((entry) {
      if (entry.key == index) {
        return entry.value
            .copyWith(editedAvailabilityText: newText, isExpanded: false);
      }
      return entry.value;
    }).toList();
    emit(CardState(cards: updated));
  }

  void updatePromoText(int index, String newText) {
    final updated = state.cards.asMap().entries.map((entry) {
      if (entry.key == index) {
        return entry.value
            .copyWith(editedPromoText: newText, isExpanded: false);
      }
      return entry.value;
    }).toList();
    emit(CardState(cards: updated));
  }
}
