import 'package:equatable/equatable.dart';
import 'package:dicetable/src/model/cafe_owner/home/venue_owner_home_screen_response.dart';

class CardModel extends Equatable {
  final String title;
  final bool isChecked;
  final bool isExpanded;
  final String editedAvailabilityText;
  final String editedPromoText;
  final AvailableDay? selectedDay;
  final DiceTable dice;

  const CardModel({
    required this.title,
    required this.isChecked,
    required this.isExpanded,
    required this.editedAvailabilityText,
    required this.editedPromoText,
    required this.selectedDay,
    required this.dice,
  });

  CardModel copyWith({
    String? title,
    bool? isChecked,
    bool? isExpanded,
    String? editedAvailabilityText,
    String? editedPromoText,
    AvailableDay? selectedDay,
    DiceTable? dice,
  }) {
    return CardModel(
      title: title ?? this.title,
      isChecked: isChecked ?? this.isChecked,
      isExpanded: isExpanded ?? this.isExpanded,
      editedAvailabilityText: editedAvailabilityText ?? this.editedAvailabilityText,
      editedPromoText: editedPromoText ?? this.editedPromoText,
      selectedDay: selectedDay ?? this.selectedDay,
      dice: dice ?? this.dice,
    );
  }

  @override
  List<Object?> get props => [
    title,
    isChecked,
    isExpanded,
    editedAvailabilityText,
    editedPromoText,
    selectedDay,
    dice,
  ];
}
