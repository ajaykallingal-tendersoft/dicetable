import 'package:bloc/bloc.dart';
import 'package:dicetable/src/ui/customer/history/model/history_entry_model.dart';
import 'package:meta/meta.dart';

part 'history_event.dart';
part 'history_state.dart';

class HistoryBloc extends Bloc<HistoryEvent, HistoryState> {
  HistoryBloc() : super(HistoryInitial()) {
    on<LoadHistoryEvent>((event, emit) {
      // Sample static data, replace this with backend/DB data
      final history = [
        HistoryEntry(
          action: "Expressed interest in",
          cafeName: "Bean & Bliss cafe",
          tableType: "Business Networking",
          dateTime: DateTime(2025, 3, 18, 12, 0),
        ),
        HistoryEntry(
          action: "The Cozy Mug has been added to the favorite list.",
          cafeName: "The Cozy Mug",
          tableType: "Solo Singles",
          dateTime: DateTime(2025, 3, 18, 12, 0),
        ),
        HistoryEntry(
          action: "Withdrew interest in",
          cafeName: "Roast & Relax cafe",
          tableType: "Social Solos",
          dateTime: DateTime(2025, 3, 18, 12, 0),
        ),
      ];
      emit(HistoryLoaded(history));
    });
  }
}
