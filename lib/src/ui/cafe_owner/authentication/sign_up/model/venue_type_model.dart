import 'package:dicetable/src/model/venue_type_response.dart';

class VenueTypeModel {
  final int id;
  final String name;
  final bool isSelected;

  VenueTypeModel({
    required this.id,
    required this.name,
    this.isSelected = false,
  });

  factory VenueTypeModel.fromVenueType(VenueType venueType) {
    return VenueTypeModel(
      id: venueType.id ?? 0,
      name: venueType.title ?? '',
      isSelected: false,
    );
  }

  VenueTypeModel copyWith({bool? isSelected}) {
    return VenueTypeModel(
      id: id,
      name: name,
      isSelected: isSelected ?? this.isSelected,
    );
  }
}
