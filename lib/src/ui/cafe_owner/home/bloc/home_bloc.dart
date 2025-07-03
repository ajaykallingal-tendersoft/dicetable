import 'package:bloc/bloc.dart';
import 'package:soloseaters/src/model/cafe_owner/home/dice_table_type_update_response.dart' show DiceTableTypeUpdateResponse;
import 'package:soloseaters/src/model/cafe_owner/home/dice_table_update_request.dart' show DiceTableTypeUpdateRequest;
import 'package:soloseaters/src/model/cafe_owner/home/venue_owner_home_screen_response.dart';
import 'package:soloseaters/src/model/state_model.dart';
import 'package:soloseaters/src/resources/api_providers/venue_owner/home_data_provider.dart';
import 'package:soloseaters/src/ui/cafe_owner/home/model/card_item.dart';
import 'package:soloseaters/src/utils/extension/state_model_extension.dart';
import 'package:equatable/equatable.dart';

import '../../../../model/cafe_owner/home/available_days.dart';


part 'home_event.dart';
part 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final HomeDataProvider homeDataProvider;

  HomeBloc({required this.homeDataProvider}) : super(HomeInitial()) {
    on<GetHomeDataEvent>(_onGetHomeData);
    on<ToggleCheckEvent>(_onToggleCheck);
    on<ToggleExpandEvent>(_onToggleExpand);
    on<UpdateAvailabilityTextEvent>(_onUpdateAvailabilityText);
    on<UpdatePromoTextEvent>(_onUpdatePromoText);
    on<UpdateSelectedDaysEvent>(_onUpdateSelectedDay);
    on<DiceTableUpdateEvent> (_onDiceTableUpdate);
  }

  void _onToggleCheck(ToggleCheckEvent event, Emitter<HomeState> emit) {
    if (state is HomeLoaded) {
      final loaded = state as HomeLoaded;
      final updatedCards = List<CardModel>.from(loaded.cards);
      final card = updatedCards[event.index];
      updatedCards[event.index] = card.copyWith(isSelected: !card.isSelected);
      emit(loaded.copyWith(cards: updatedCards));
    }
  }

  void _onToggleExpand(ToggleExpandEvent event, Emitter<HomeState> emit) {
    if (state is HomeLoaded) {
      final loaded = state as HomeLoaded;
      final updatedCards = List<CardModel>.from(loaded.cards);
      final card = updatedCards[event.index];
      updatedCards[event.index] = card.copyWith(isExpanded: !card.isExpanded);
      emit(loaded.copyWith(cards: updatedCards));
    }
  }

  void _onUpdateAvailabilityText(UpdateAvailabilityTextEvent event, Emitter<HomeState> emit) {
    if (state is HomeLoaded) {
      final loaded = state as HomeLoaded;
      final updatedCards = List<CardModel>.from(loaded.cards);
      final card = updatedCards[event.index];
      updatedCards[event.index] = card.copyWith(availabilityText: event.newText);
      emit(loaded.copyWith(cards: updatedCards));
    }
  }

  void _onUpdatePromoText(UpdatePromoTextEvent event, Emitter<HomeState> emit) {
    if (state is HomeLoaded) {
      final loaded = state as HomeLoaded;
      final updatedCards = List<CardModel>.from(loaded.cards);
      final card = updatedCards[event.index];
      updatedCards[event.index] = card.copyWith(promoText: event.newText);
      emit(loaded.copyWith(cards: updatedCards));
    }
  }

  void _onUpdateSelectedDay(UpdateSelectedDaysEvent event, Emitter<HomeState> emit) {
    if (state is HomeLoaded) {
      final loaded = state as HomeLoaded;
      final updatedCards = List<CardModel>.from(loaded.cards);
      final card = updatedCards[event.index];
      updatedCards[event.index] = card.copyWith(selectedDays: event.selectedDays);
      emit(loaded.copyWith(cards: updatedCards));
    }
  }

  Future<void> _onGetHomeData(
      GetHomeDataEvent event,
      Emitter<HomeState> emit,
      ) async {
    emit(HomeLoading());
    try {
      final response = await homeDataProvider.getVenueOwnerHomeData();
      final StateModel? stateModel = response;
      if (response != null && response.data != null && response.data.status == true && response.data.diceTables != null) {
        final List<CardModel> cards = response.data.diceTables!
            .map<CardModel>((diceTable) => CardModel.fromDiceTable(diceTable))
            .toList();
        final bool subscriptionStatus = response.data.subscriptionStatus;

        emit(HomeLoaded(
          cards: cards,
          response: response,
          subscriptionStatus: subscriptionStatus,
          homeResponse: response.data,
        ));
      } else {
        if (stateModel is ErrorState) {
          emit(HomeError(errorMessage: stateModel.msg));
        } else {
          emit(HomeError(errorMessage: response?.data == null ? 'Response data is null' : 'Invalid response or no data available'));
        }
      }
    } catch (e, stackTrace) {
      emit(HomeError(errorMessage: e.toString()));
    }
  }

  Future<void> _onDiceTableUpdate(
      DiceTableUpdateEvent event,
      Emitter<HomeState> emit,
      ) async {
    emit(DiceTableUpdateLoading());
    try {
      final StateModel? stateModel = await homeDataProvider.updateDiceTableType(event.diceTableTypeUpdateRequest);

      if (stateModel is SuccessState) {
        final response = stateModel.value as DiceTableTypeUpdateResponse;
        if(response.message == "Solo seater types updated successfully."&& response.status == true){
          add(GetHomeDataEvent());
        }

        emit(DiceTableUpdateLoaded(response: response));

      } else if (stateModel is ErrorState) {
        emit(DiceTableUpdateError(errorMessage: stateModel.msg));
      }
    } catch (e, stackTrace) {
      print('HomeBloc Error: $e');
      print('StackTrace: $stackTrace');
      emit(DiceTableUpdateError(errorMessage: e.toString()));
    }
  }
  
  
}