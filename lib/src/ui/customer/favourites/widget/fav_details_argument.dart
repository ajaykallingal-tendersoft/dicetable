import 'package:soloseaters/src/model/customer/cafe/cafe_list_response.dart';
import 'package:soloseaters/src/model/customer/cafe/favourite_list_response.dart';

class FavDetailsArguments {
  final String from;
  final String id;
  final String name;
  final List<String> tableType;
  final String description;
  final String image;
  final List<dynamic>? openingHours;
  final bool bookingStatus;
  final List<String> gallery;
  final List<Attende> attendes;
  final List<UpcomingEvent> upcomingEvents;

  const FavDetailsArguments({
    required this.from,
    required this.id,
    required this.name,
    required this.tableType,
    required this.description,
    required this.image,
    required this.openingHours,
    required this.bookingStatus,
    required this.gallery,
    required this.attendes,
    required this.upcomingEvents,
  });
}