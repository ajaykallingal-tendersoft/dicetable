import 'package:dicetable/src/model/customer/cafe/cafe_list_response.dart';

class CafeDetailsArguments {
  final String from;
  final String id;
  final String name;
  final List<String> tableType;
  final String description;
  final String image;
  final List<WorkingHour>? openingHours;
  final bool bookingStatus;

  const CafeDetailsArguments({
    required this.from,
    required this.id,
    required this.name,
    required this.tableType,
    required this.description,
    required this.image,
    required this.openingHours,
    required this.bookingStatus
  });
}
