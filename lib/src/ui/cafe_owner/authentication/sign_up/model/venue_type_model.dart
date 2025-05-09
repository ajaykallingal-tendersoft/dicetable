class VenueTypeModel {
  final String id;
  final String name;
  final bool isSelected;

  const VenueTypeModel({
    required this.id,
    required this.name,
    required this.isSelected,
  });

  VenueTypeModel copyWith({bool? isSelected}) {
    return VenueTypeModel(
      id: id,
      name: name,
      isSelected: isSelected ?? this.isSelected,
    );
  }
}