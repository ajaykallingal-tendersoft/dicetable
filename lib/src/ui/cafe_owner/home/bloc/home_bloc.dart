import 'package:bloc/bloc.dart';
import 'package:soloseaters/src/model/cafe_owner/home/dice_table_type_update_response.dart'
    show DiceTableTypeUpdateResponse;
import 'package:soloseaters/src/model/cafe_owner/home/dice_table_update_request.dart'
    show DiceTableTypeUpdateRequest;
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
    on<DiceTableUpdateEvent>(_onDiceTableUpdate);
    on<UpdateAlwaysAvailableEvent>(_onUpdateAlwaysAvailable);
  }

  void _onUpdateAlwaysAvailable(
    UpdateAlwaysAvailableEvent event,
    Emitter<HomeState> emit,
  ) {
    if (state is HomeLoaded) {
      final loaded = state as HomeLoaded;
      final updatedCards = List<CardModel>.from(loaded.cards);
      final card = updatedCards[event.index];

      updatedCards[event.index] = card.copyWith(
        isAlwaysAvailable: event.isAlwaysAvailable,
      );
      emit(loaded.copyWith(cards: updatedCards));
    }
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

  void _onUpdateAvailabilityText(
    UpdateAvailabilityTextEvent event,
    Emitter<HomeState> emit,
  ) {
    if (state is HomeLoaded) {
      final loaded = state as HomeLoaded;
      final updatedCards = List<CardModel>.from(loaded.cards);
      final card = updatedCards[event.index];
      updatedCards[event.index] = card.copyWith(
        availabilityText: event.newText,
      );
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

  void _onUpdateSelectedDay(
    UpdateSelectedDaysEvent event,
    Emitter<HomeState> emit,
  ) {
    if (state is HomeLoaded) {
      final loaded = state as HomeLoaded;
      final updatedCards = List<CardModel>.from(loaded.cards);
      final card = updatedCards[event.index];

      bool _isAlwaysAvailable({
        required List<AvailableDay> selectedDays,
        required List<AvailableDay> registrationDays,
      }) {
        if (selectedDays.isEmpty) return false;

        String _n(String time) {
          final parts = time.split(':');
          if (parts.length == 2)
            return '${parts[0].padLeft(2, '0')}:${parts[1].padLeft(2, '0')}:00';
          if (parts.length == 1) return '${parts[0].padLeft(2, '0')}:00:00';
          return '${parts[0].padLeft(2, '0')}:${parts[1].padLeft(2, '0')}:${parts[2].padLeft(2, '0')}';
        }

        final openRegDays =
            registrationDays.where((d) => (d.isOpen ?? true)).toList();
        if (selectedDays.length != openRegDays.length) return false;

        final Map<String, (String open, String close)> defaultByDay = {
          for (final d in openRegDays)
            (d.day ?? '').toLowerCase(): (
              _n(
                (d.timings?.isNotEmpty ?? false)
                    ? d.timings!.first.open
                    : '10:00:00',
              ),
              _n(
                (d.timings?.isNotEmpty ?? false)
                    ? d.timings!.first.close
                    : '22:00:00',
              ),
            ),
        };

        for (final sd in selectedDays) {
          final key = (sd.day ?? '').toLowerCase();
          if (!defaultByDay.containsKey(key)) return false;
          if ((sd.timings?.length ?? 0) != 1) return false;
          final t = sd.timings!.first;
          final (defOpen, defClose) = defaultByDay[key]!;
          if (_n(t.open) != defOpen || _n(t.close) != defClose) return false;
        }
        return true;
      }

      // ✅ Preserve manual toggle if it was already ON
      final computedAlwaysAvailable = _isAlwaysAvailable(
        selectedDays: event.selectedDays,
        registrationDays: card.availableDays,
      );

      final finalAlwaysAvailable =
          card.isAlwaysAvailable || computedAlwaysAvailable;

      updatedCards[event.index] = card.copyWith(
        selectedDays: event.selectedDays,
        isAlwaysAvailable: finalAlwaysAvailable,
      );

      print(
        '🧩 UpdateSelectedDaysEvent → preserving isAlwaysAvailable=$finalAlwaysAvailable for "${card.title}"',
      );
      emit(loaded.copyWith(cards: updatedCards));
    }
  }

  

  Future<void> _onGetHomeData(
    GetHomeDataEvent event,
    Emitter<HomeState> emit,
  ) async {
    print('🏠 HomeBloc: Fetching fresh home data... [${DateTime.now().toIso8601String()}]');
    emit(HomeLoading());
    try {
      final response = await homeDataProvider.getVenueOwnerHomeData();
      final StateModel? stateModel = response;
      if (response != null &&
          response.data != null &&
          response.data.status == true &&
          response.data.diceTables != null) {
        final List<CardModel> cards =
            response.data.diceTables!.map<CardModel>((diceTable) {
              final card = CardModel.fromDiceTable(
                diceTable,
                status: response.data.status,
              );
              // ✅ Add debug log to see what's being created
              print(
                '🏗️ Creating card "${card.title}": isAlwaysAvailable=${card.isAlwaysAvailable}, selectedDays=${card.selectedDays.length}',
              );
              return card;
            }).toList();
        final bool subscriptionStatus = response.data.subscriptionStatus;

        emit(
          HomeLoaded(
            cards: cards,
            response: response,
            subscriptionStatus: subscriptionStatus,
            homeResponse: response.data,
          ),
        );
      } else {
        if (stateModel is ErrorState) {
          emit(HomeError(errorMessage: stateModel.msg));
        } else {
          emit(
            HomeError(
              errorMessage:
                  response?.data == null
                      ? 'Response data is null'
                      : 'Invalid response or no data available',
            ),
          );
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
      final StateModel? stateModel = await homeDataProvider.updateDiceTableType(
        event.diceTableTypeUpdateRequest,
      );

      if (stateModel is SuccessState) {
        final response = stateModel.value as DiceTableTypeUpdateResponse;

        // ✅ Add debug to see what was sent
        print(
          '📤 Sent to API: ${event.diceTableTypeUpdateRequest.availableDays!.map((d) => "${d.day}: ${d.timings?.length} timings").join(", ")}',
        );

        if (response.message == "Solo seater types updated successfully." &&
            response.status == true) {
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
