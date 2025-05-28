part of 'history_bloc.dart';

sealed class HistoryEvent extends Equatable {
  const HistoryEvent();
}

class GetHistoryListEvent extends HistoryEvent {
  @override
  List<Object?> get props => [];

}