class CardItem {
  final String title;
  final String subtitle;
  final String initialAvailabilityText;
  final String initialPromoText;
  final String editedAvailabilityText;
  final String editedPromoText;
  final bool isExpanded;
  final bool isChecked;

  CardItem({required this.title,required this.subtitle,required this.initialAvailabilityText,required this.initialPromoText,this.editedAvailabilityText = '', this.editedPromoText = '', this.isExpanded = false,this.isChecked = false});

  CardItem copyWith({
    String? title,
    String? subtitle,
    String? initialAvailabilityText,
    String? initialPromoText,
    String? description,
    String? editedAvailabilityText,
    String? editedPromoText,
    bool? isExpanded,
    bool? isChecked,
}) {
    return CardItem(
        title: title ?? this.title,
        subtitle: subtitle ?? this.subtitle,
        initialAvailabilityText: initialAvailabilityText ?? this.initialAvailabilityText,
        initialPromoText: initialPromoText ?? this.initialPromoText,
        editedAvailabilityText: editedAvailabilityText ?? this.editedAvailabilityText,
      editedPromoText: editedPromoText ?? this.editedPromoText,
      isExpanded: isExpanded ?? this.isExpanded,
      isChecked: isChecked ?? this.isChecked,
    );
  }

}