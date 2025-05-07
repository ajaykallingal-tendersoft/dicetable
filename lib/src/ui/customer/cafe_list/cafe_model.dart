class CafeModel {
  final String id;
  final String name;
  final String tableType;
  final String description;
  final String image;
  bool isFavorite;
  Map<String, String>? openingHours;

  CafeModel({
    required this.id,
    required this.name,
    required this.tableType,
    required this.description,
    required this.image,
    this.isFavorite = false,
    this.openingHours
  });
}