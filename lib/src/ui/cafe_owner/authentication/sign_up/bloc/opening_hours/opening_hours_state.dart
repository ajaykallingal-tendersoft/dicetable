part of 'opening_hours_bloc.dart';
//
// @immutable
// sealed class OpeningHoursState {}

class OpeningHoursState {
  final Map<String, OpeningHours> hours;

  OpeningHoursState({required this.hours});

  OpeningHoursState copyWith({
    Map<String, OpeningHours>? hours,
  }) =>
      OpeningHoursState(hours: hours ?? this.hours);
}