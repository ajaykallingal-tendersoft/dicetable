part of 'history_bloc.dart';

@immutable
sealed class HistoryEvent {}

class LoadHistoryEvent extends HistoryEvent {}