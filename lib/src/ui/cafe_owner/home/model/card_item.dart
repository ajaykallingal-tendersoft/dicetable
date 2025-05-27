// card_item.dart
import 'package:dicetable/src/model/cafe_owner/home/venue_owner_home_screen_response.dart';

import '../../../../model/cafe_owner/home/available_days.dart';
import '../../../../model/cafe_owner/home/venue_owner_home_screen_response.dart' as model;
class CardModel {
  final int id;
  final String title;
  final String? subTitle;
  final String? description;
  final String? iconImage;
  final String? moreInfo;
  final List<AvailableDay> availableDays;
  final bool isSelected; // This is the 'selected' parameter from your API
  final bool isExpanded;
  final String availabilityText;
  final String promoText;
  final List<AvailableDay> selectedDays; // These are the days actually selected on the backend for this table

  CardModel({
    required this.id,
    required this.title,
    this.subTitle,
    this.description,
    this.iconImage,
    this.moreInfo,
    required this.availableDays,
    this.isSelected = false,
    this.isExpanded = false,
    this.availabilityText = '',
    this.promoText = '',
    this.selectedDays = const [],
  });

  factory CardModel.fromDiceTable(DiceTable diceTable) {
    List<AvailableDay> availableDaysList = diceTable.availableDays ?? [];

    // The 'selectedDays' in the CardModel should strictly come from the API's actual selection.
    // If diceTable.selected is true, it means there are specific days selected, so use diceTable.availableDays.
    // If diceTable.selected is false, it implies no specific selection, so we pass an empty list.
    List<AvailableDay> initialSelectedDaysForCard = (diceTable.selected ?? false)
        ? (diceTable.availableDays ?? [])
        : [];

    return CardModel(
      id: diceTable.id ?? 0,
      title: diceTable.title ?? '',
      subTitle: diceTable.subTitle,
      description: diceTable.description,
      iconImage: diceTable.iconImage,
      moreInfo: diceTable.moreInfo,
      availableDays: availableDaysList, // All days provided by the API for this table
      isSelected: diceTable.selected ?? false, // The 'selected' status from API
      selectedDays: initialSelectedDaysForCard, // The actual selected days for this dice table
    );
  }

  CardModel copyWith({
    int? id,
    String? title,
    String? subTitle,
    String? description,
    String? iconImage,
    String? moreInfo,
    List<AvailableDay>? availableDays,
    bool? isSelected,
    bool? isExpanded,
    String? availabilityText,
    String? promoText,
    List<AvailableDay>? selectedDays,
  }) {
    return CardModel(
      id: id ?? this.id,
      title: title ?? this.title,
      subTitle: subTitle ?? this.subTitle,
      description: description ?? this.description,
      iconImage: iconImage ?? this.iconImage,
      moreInfo: moreInfo ?? this.moreInfo,
      availableDays: availableDays ?? this.availableDays,
      isSelected: isSelected ?? this.isSelected,
      isExpanded: isExpanded ?? this.isExpanded,
      availabilityText: availabilityText ?? this.availabilityText,
      promoText: promoText ?? this.promoText,
      selectedDays: selectedDays ?? this.selectedDays,
    );
  }
}