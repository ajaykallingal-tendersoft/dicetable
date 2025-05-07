part of 'history_bloc.dart';

@immutable
sealed class HistoryState {}

final class HistoryInitial extends HistoryState {}



class HistoryLoaded extends HistoryState {
  final List<HistoryEntry> history;

  HistoryLoaded(this.history);
}