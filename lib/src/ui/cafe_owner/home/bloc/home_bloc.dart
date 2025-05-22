// import 'package:bloc/bloc.dart';
// import 'package:dicetable/src/model/cafe_owner/home/venue_owner_home_screen_response.dart';
// import 'package:dicetable/src/model/state_model.dart';
// import 'package:dicetable/src/resources/api_providers/venue_owner/home_data_provider.dart';
// import 'package:dicetable/src/ui/cafe_owner/home/model/card_item.dart';
// import 'package:dicetable/src/utils/extension/state_model_extension.dart';
// import 'package:equatable/equatable.dart';
//
// part 'home_event.dart';
// part 'home_state.dart';
//
// class HomeBloc extends Bloc<HomeEvent, HomeState> {
//   final HomeDataProvider homeDataProvider;
//   HomeBloc({required this.homeDataProvider}) : super(HomeInitial()) {
//     on<GetHomeDataEvent>(_onGetHomeData);
//     on<ToggleCheckEvent>(_onToggleCheck);
//     on<ToggleExpandEvent>(_onToggleExpand);
//     on<UpdateAvailabilityTextEvent>(_onUpdateText);
//     on<UpdatePromoTextEvent>(_onUpdatePromoText);
//     on<UpdateSelectedDayEvent>(_onUpdateSelectedDay);
//   }
//
//   void _onToggleCheck(ToggleCheckEvent event, Emitter<HomeState> emit) {
//     if (state is HomeLoaded) {
//       final current = state as HomeLoaded;
//       final updatedCards = current.cards.asMap().entries.map((entry) {
//         if (entry.key == event.index) {
//           return entry.value.copyWith(isChecked: !entry.value.isChecked);
//         }
//         return entry.value;
//       }).toList();
//
//       emit(current.copyWith(cards: updatedCards));
//     }
//   }
//   void _onToggleExpand(ToggleExpandEvent event, Emitter<HomeState> emit) {
//     if (state is HomeLoaded) {
//       final current = state as HomeLoaded;
//       final updatedCards = current.cards.asMap().entries.map((entry) {
//         if (entry.key == event.index) {
//           return entry.value.copyWith(isExpanded: !entry.value.isExpanded);
//         }
//         return entry.value;
//       }).toList();
//
//       emit(current.copyWith(cards: updatedCards));
//     }
//   }
//
//   void _onUpdateText(UpdateAvailabilityTextEvent event, Emitter<HomeState> emit) {
//     if (state is HomeLoaded) {
//       final current = state as HomeLoaded;
//       final updatedCards = current.cards.asMap().entries.map((entry) {
//         if (entry.key == event.index) {
//           return entry.value.copyWith(
//             editedAvailabilityText: event.newText,
//             isExpanded: false,
//           );
//         }
//         return entry.value;
//       }).toList();
//
//       emit(current.copyWith(cards: updatedCards));
//     }
//   }
//   void _onUpdatePromoText(UpdatePromoTextEvent event, Emitter<HomeState> emit) {
//     if (state is HomeLoaded) {
//       final current = state as HomeLoaded;
//       final updatedCards = current.cards.asMap().entries.map((entry) {
//         if (entry.key == event.index) {
//           return entry.value.copyWith(
//             editedPromoText: event.newText,
//             isExpanded: false,
//           );
//         }
//         return entry.value;
//       }).toList();
//
//       emit(current.copyWith(cards: updatedCards));
//     }
//   }
//
//   void _onUpdateSelectedDay(UpdateSelectedDayEvent event, Emitter<HomeState> emit) {
//     if (state is HomeLoaded) {
//       final current = state as HomeLoaded;
//       final updatedCards = current.cards.asMap().entries.map((entry) {
//         if (entry.key == event.index) {
//           return entry.value.copyWith(
//             selectedDay: event.selectedDay,
//           );
//         }
//         return entry.value;
//       }).toList();
//
//       emit(current.copyWith(cards: updatedCards));
//     }
//   }
//
//   Future<void> _onGetHomeData(
//       GetHomeDataEvent event,
//       Emitter<HomeState> emit,
//       ) async {
//     emit(HomeLoading());
//     try {
//       final response = await homeDataProvider.getVenueOwnerHomeData();
//       final cards = response!.data!.map((e) => CardModel(
//         title: e.title ?? '',
//         isChecked: false,
//         isExpanded: false,
//         editedAvailabilityText: '',
//         editedPromoText: '',
//         selectedDay: e.availableDays?.isNotEmpty == true ? e.availableDays!.first : null,
//         dice: e,
//       )).toList();
//       emit(HomeLoaded(cards: cards));
//     } catch (e) {
//       emit(HomeError(errorMessage: e.toString()));
//     }
//   }
//
// }
