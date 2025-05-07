import 'package:bloc/bloc.dart';
import 'package:dicetable/src/ui/customer/cafe_list/cafe_model.dart';
import 'package:meta/meta.dart';

part 'cafe_list_event.dart';
part 'cafe_list_state.dart';

class CafeListBloc extends Bloc<CafeListEvent, CafeState> {

  CafeListBloc() : super(CafeState(_dummyData)) {
    on<ToggleFavoriteEvent>((event, emit) {
      final updatedCafes = List<CafeModel>.from(state.cafes);
      updatedCafes[event.index].isFavorite = !updatedCafes[event.index].isFavorite;
      emit(CafeState(updatedCafes));
    });

  }
}
final _dummyData = [
  CafeModel(
    id: "1",
    name: 'Bean & Bliss',
    tableType: 'Business Networking, Social Solos',
    description: 'Explore Eats Cafe’s menu in Grand Cayman, offering a wide range of appetizing kiwi dishes and drinks at budget-friendly prices',
    image: 'assets/png/Mask Group 6.png',
    openingHours: {
      "Monday": "08:00 AM - 10:00 PM",
      "Tuesday": "08:00 AM - 10:00 PM",
      "Wednesday": "08:00 AM - 10:00 PM",
      "Thursday": "08:00 AM - 10:00 PM",
      "Friday": "08:00 AM - 10:00 PM",
      "Saturday": "08:00 AM - 10:00 PM",
      "Sunday": "Closed"
    }
  ),
  CafeModel(
    id: "2",
    name: 'Sun Marie Cafe',
    tableType: 'Social Solos, Solo Singles',
    description: 'Explore Eats Cafe’s menu in Grand Cayman, offering a wide range of appetizing kiwi dishes and drinks at budget-friendly prices',
    image: 'assets/png/Mask Group 6-1.png',
      openingHours: {
        "Monday": "08:00 AM - 10:00 PM",
        "Tuesday": "08:00 AM - 10:00 PM",
        "Wednesday": "08:00 AM - 10:00 PM",
        "Thursday": "08:00 AM - 10:00 PM",
        "Friday": "08:00 AM - 10:00 PM",
        "Saturday": "08:00 AM - 10:00 PM",
        "Sunday": "Closed"
      }

  ),
  CafeModel(
    id: "3",
    name: 'Roast & Relax',
    tableType: 'Prime Time - Over 60’s',
    description: 'Explore Eats Cafe’s menu in Grand Cayman, offering a wide range of appetizing kiwi dishes and drinks at budget-friendly prices',
    image: 'assets/png/Mask Group 6-2.png',
      openingHours: {
        "Monday": "08:00 AM - 10:00 PM",
        "Tuesday": "08:00 AM - 10:00 PM",
        "Wednesday": "08:00 AM - 10:00 PM",
        "Thursday": "08:00 AM - 10:00 PM",
        "Friday": "08:00 AM - 10:00 PM",
        "Saturday": "08:00 AM - 10:00 PM",
        "Sunday": "Closed"
      }
  ),
  CafeModel(
    id: "4",
    name: 'The Cozy Mug',
    tableType: 'Prime Time - Over 60’s',
    description: 'Explore Eats Cafe’s menu in Grand Cayman, offering a wide range of appetizing kiwi dishes and drinks at budget-friendly prices',
    image: 'assets/png/Mask Group 6-3.png',
      openingHours: {
        "Monday": "08:00 AM - 10:00 PM",
        "Tuesday": "08:00 AM - 10:00 PM",
        "Wednesday": "08:00 AM - 10:00 PM",
        "Thursday": "08:00 AM - 10:00 PM",
        "Friday": "08:00 AM - 10:00 PM",
        "Saturday": "08:00 AM - 10:00 PM",
        "Sunday": "Closed"
      }
  ),
];