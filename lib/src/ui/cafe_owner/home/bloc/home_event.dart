part of 'home_bloc.dart';

sealed class HomeEvent extends Equatable {
  const HomeEvent();
}

class GetHomeDataEvent extends HomeEvent {
  @override
  List<Object?> get props =>  [];
}

class ToggleCheckEvent extends HomeEvent {
  final int index;
  const ToggleCheckEvent(this.index);

  @override
  List<Object?> get props => [index];
}

class ToggleExpandEvent extends HomeEvent {
  final int index;
  const ToggleExpandEvent(this.index);

  @override
  List<Object?> get props => [index];
}

class UpdateAvailabilityTextEvent extends HomeEvent {
  final int index;
  final String newText;
  const UpdateAvailabilityTextEvent(this.index, this.newText);

  @override
  List<Object?> get props => [index, newText];
}

class UpdatePromoTextEvent extends HomeEvent {
  final int index;
  final String newText;
  const UpdatePromoTextEvent(this.index, this.newText);

  @override
  List<Object?> get props => [index, newText];
}

class UpdateSelectedDaysEvent extends HomeEvent {
  final int index;
  final List<AvailableDay> selectedDays;

  const UpdateSelectedDaysEvent(this.index, this.selectedDays);

  @override
  List<Object?> get props => [index, selectedDays];
}


class SaveCardDataEvent extends HomeEvent {
  final int index;
  const SaveCardDataEvent(this.index);

  @override
  List<Object?> get props => [index];
}

class DiceTableUpdateEvent extends HomeEvent {
  final DiceTableTypeUpdateRequest diceTableTypeUpdateRequest;
  const DiceTableUpdateEvent({required this.diceTableTypeUpdateRequest});
  @override
  List<Object?> get props =>  [diceTableTypeUpdateRequest];
}