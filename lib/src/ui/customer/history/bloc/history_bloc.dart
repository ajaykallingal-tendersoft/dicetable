import 'package:bloc/bloc.dart';
import 'package:soloseaters/src/model/customer/history/history_list_response.dart';
import 'package:soloseaters/src/model/state_model.dart';
import 'package:soloseaters/src/resources/api_providers/customer/history_data_provider.dart';
import 'package:equatable/equatable.dart';

part 'history_event.dart';
part 'history_state.dart';

class HistoryBloc extends Bloc<HistoryEvent, HistoryState> {
  final HistoryDataProvider historyDataProvider;
  HistoryBloc({required this.historyDataProvider}) : super(HistoryInitial()) {
    on<GetHistoryListEvent> (_onGetHistoryList);
  }
  Future<void> _onGetHistoryList(
      GetHistoryListEvent event,
      Emitter<HistoryState> emit,
      ) async {
    emit(HistoryLoading());
    try {
      final StateModel? stateModel = await historyDataProvider.getHistory();

      if (stateModel is SuccessState) {
        emit(HistoryLoaded(historyListResponse: stateModel.value));
      } else if (stateModel is ErrorState) {
        emit(HistoryError(errorMessage: stateModel.msg));
      }
    } catch (e, stackTrace) {
      print('History Error: $e');
      print('StackTrace: $stackTrace');
      emit(HistoryError(errorMessage: e.toString()));
    }
  }
}
