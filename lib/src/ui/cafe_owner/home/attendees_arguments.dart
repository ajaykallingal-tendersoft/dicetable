
import 'package:soloseaters/src/model/cafe_owner/home/venue_owner_home_screen_response.dart';

class AttendeesArguments {
  final int tableId;
  final List<Attendee> attendees;
  
  // Optional: If you still need a single attendee's details for a header/summary
  final String? bookingDate; 

  AttendeesArguments({
    required this.tableId,
    required this.attendees,
    this.bookingDate, 
    // Remove other individual fields like userId, name, email, etc.
  });
}