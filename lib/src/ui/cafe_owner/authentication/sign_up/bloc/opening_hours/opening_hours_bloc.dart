import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

import '../../model/opening_hours.dart';

part 'opening_hours_event.dart';
part 'opening_hours_state.dart';


class OpeningHoursBloc extends Bloc<OpeningHoursEvent, OpeningHoursState> {
  OpeningHoursBloc()
      : super(OpeningHoursState(hours: {
    for (var day in ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'])
      day: OpeningHours(
        day: day,
        from: const TimeOfDay(hour: 10, minute: 0),
        to: const TimeOfDay(hour: 12, minute: 0),
        isEnabled: day != 'Sun',
      )
  })) {
    on<UpdateOpeningHour>((event, emit) {
      final updated = Map<String, OpeningHours>.from(state.hours);
      updated[event.openingHour.day] = event.openingHour;
      emit(state.copyWith(hours: updated));
    });
  }
}
