part of 'opening_hours_bloc.dart';

@immutable
sealed class OpeningHoursEvent {}
class UpdateOpeningHour extends OpeningHoursEvent {
  final OpeningHours openingHour;
  UpdateOpeningHour(this.openingHour);
}