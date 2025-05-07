class CafeDetailsArguments {
  final String id;
  final String name;
  final String tableType;
  final String description;
  final String image;
  final Map<String, String>? openingHours;

  const CafeDetailsArguments({
    required this.id,
    required this.name,
    required this.tableType,
    required this.description,
    required this.image,
    required this.openingHours
  });
}
