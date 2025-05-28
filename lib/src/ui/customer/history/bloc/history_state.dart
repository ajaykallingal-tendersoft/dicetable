part of 'history_bloc.dart';

sealed class HistoryState extends Equatable {
  const HistoryState();
}

final class HistoryInitial extends HistoryState {
  @override
  List<Object> get props => [];
}

final class HistoryLoading extends HistoryState {
  @override
  List<Object> get props => [];
}
final class HistoryLoaded extends HistoryState {
  final HistoryListResponse historyListResponse;
  const HistoryLoaded({required this.historyListResponse});
  @override
  List<Object> get props => [historyListResponse];
}
final class HistoryError extends HistoryState {
  final String errorMessage;
  const HistoryError({required this.errorMessage});
  @override
  List<Object> get props => [errorMessage];
}