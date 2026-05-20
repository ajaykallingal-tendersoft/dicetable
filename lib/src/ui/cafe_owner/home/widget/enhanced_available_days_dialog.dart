import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gap/gap.dart';
import 'package:soloseaters/src/constants/app_colors.dart';
import 'package:soloseaters/src/constants/assets.dart';
import 'package:soloseaters/src/model/cafe_owner/home/available_days.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:soloseaters/src/ui/cafe_owner/profile/bloc/profile_bloc.dart';

class EnhancedAvailableDaysDialog extends StatefulWidget {
  final List<AvailableDay> availableDays;
  final List<AvailableDay>? initialSelectedDays;
  final String tableTypeName;
  final bool? initiallyAlwaysAvailable;

  const EnhancedAvailableDaysDialog({
    required this.availableDays,
    this.initialSelectedDays,
    this.tableTypeName = "Business Networking",
    this.initiallyAlwaysAvailable,
    super.key,
  });

  @override
  State<EnhancedAvailableDaysDialog> createState() =>
      _EnhancedAvailableDaysDialogState();
}

class _EnhancedAvailableDaysDialogState
    extends State<EnhancedAvailableDaysDialog> {
  Map<String, DaySelection> daySelections = {};
  bool alwaysAvailable = false;
  final ScrollController _scrollController = ScrollController(); // Change 6

  @override
  void initState() {
    super.initState();

    // ✅ Initialize day selections first to compute the state
    final computedAlwaysAvailable = _initializeDaySelections();

    // ✅ If widget.initiallyAlwaysAvailable is explicitly provided (not null), use it
    // BUT we must guard against API inconsistencies. If the API says 'Always Available' is true,
    // but the actual timeslots have custom hours or missing days, we MUST force it to false.
    if (widget.initiallyAlwaysAvailable != null) {
      if (widget.initiallyAlwaysAvailable! && !computedAlwaysAvailable) {
        print('🚨 WARNING: API says alwaysAvailable=true, but actual timeslots are custom/incomplete! Guarding by forcing alwaysAvailable=false.');
        alwaysAvailable = false;
      } else {
        alwaysAvailable = widget.initiallyAlwaysAvailable!;
      }
      print(
        '🎯 Dialog initState: Using provided alwaysAvailable=${widget.initiallyAlwaysAvailable} (Guarded to $alwaysAvailable)',
      );
    } else {
      alwaysAvailable = computedAlwaysAvailable;
      print(
        '🎯 Dialog initState: Using computed alwaysAvailable=$computedAlwaysAvailable',
      );
    }

    print(
      '🎯 Dialog initState FINAL: alwaysAvailable=$alwaysAvailable (from widget: ${widget.initiallyAlwaysAvailable}, computed: $computedAlwaysAvailable)',
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  // Normalize malformed API or user-entered time values to "HH:mm:ss"
  /// Normalises any time string to "HH:mm:ss" in 24-hour format.
  /// Handles:
  ///   - 24-hour  : "22:00:00", "14:30"
  ///   - 12-hour  : "10:00 PM", "8:30 AM", "12:00 PM" (noon), "12:00 AM" (midnight)
  String _normalizeTime(String time) {
    if (time.isEmpty) return "00:00:00";

    final trimmed = time.trim();
    final upper = trimmed.toUpperCase();

    // Detect 12-hour AM/PM format
    final hasPm = upper.contains('PM');
    final hasAm = upper.contains('AM');

    if (hasPm || hasAm) {
      // Strip AM/PM and any surrounding spaces
      final cleaned = upper.replaceAll('PM', '').replaceAll('AM', '').trim();
      final parts = cleaned.split(':').map((p) => p.trim()).toList();
      int hh = int.tryParse(parts.isNotEmpty ? parts[0] : '0') ?? 0;
      int mm = int.tryParse(parts.length > 1 ? parts[1] : '0') ?? 0;

      // 12-hour → 24-hour conversion
      if (hasPm && hh != 12) hh += 12; // 1 PM–11 PM → 13–23
      if (hasAm && hh == 12) hh = 0; // 12 AM (midnight) → 0

      return '${hh.toString().padLeft(2, '0')}:${mm.toString().padLeft(2, '0')}:00';
    }

    // 24-hour format (existing logic — unchanged)
    final parts = trimmed.split(':').where((p) => p.isNotEmpty).toList();
    final normalized = parts.take(3).toList();
    while (normalized.length < 3) {
      normalized.add('00');
    }

    final hh = int.tryParse(normalized[0]) ?? 0;
    final mm = int.tryParse(normalized[1]) ?? 0;
    final ss = int.tryParse(normalized[2]) ?? 0;

    return '${hh.toString().padLeft(2, '0')}:${mm.toString().padLeft(2, '0')}:${ss.toString().padLeft(2, '0')}';
  }

  bool _initializeDaySelections() {
    daySelections.clear();

    // ✅ Fix: Compute actual VENUE open days from ProfileBloc, 
    // because widget.availableDays.isOpen means "table selected", NOT venue open.
    final profileState = context.read<ProfileBloc>().state;
    int openRegDaysCount = 0;
    for (var day in widget.availableDays) {
      final masterHour = profileState.openingHours[day.day?.toLowerCase()];
      if (masterHour != null && masterHour.isEnabled) {
        openRegDaysCount++;
      }
    }
    // Fallback if ProfileBloc is somehow empty
    if (openRegDaysCount == 0) {
      openRegDaysCount = widget.availableDays.length;
    }

    // Track how many days are selected with ONLY default timing
    int daysWithOnlyDefault = 0;
    int totalSelectedDays = 0;

    for (var day in widget.availableDays) {
      final hasDefaultTiming = day.timings != null && day.timings!.isNotEmpty;

      // ─── RAW API DATA ─────────────────────────────────────────────────────
      // This is the EXACT value the API returned for this day's opening hours.
      // If you update your profile hours and this doesn't change, the API
      // is not returning fresh data.
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      print('📅 DAY: ${day.day} | hasDefaultTiming: $hasDefaultTiming');
      if (hasDefaultTiming) {
        print(
          '  🌐 RAW API open  = "${day.timings!.first.open}"  (exact string from server)',
        );
        print(
          '  🌐 RAW API close = "${day.timings!.first.close}"  (exact string from server)',
        );
      } else {
        print(
          '  ⚠️  No timings from API — using fallback: open=10:00:00 close=22:00:00',
        );
      }

      String defaultOpen = _normalizeTime(
        hasDefaultTiming ? day.timings!.first.open : "10:00:00",
      );
      String defaultClose = _normalizeTime(
        hasDefaultTiming ? day.timings!.first.close : "22:00:00",
      );

      // 🚨 MASTER OVERRIDE: Use hours from ProfileBloc if available
      final profileState = context.read<ProfileBloc>().state;
      final masterHour = profileState.openingHours[day.day?.toLowerCase()];
      if (masterHour != null && masterHour.isEnabled) {
        final masterOpen =
            '${masterHour.from.hour.toString().padLeft(2, '0')}:${masterHour.from.minute.toString().padLeft(2, '0')}:00';
        final masterClose =
            '${masterHour.to.hour.toString().padLeft(2, '0')}:${masterHour.to.minute.toString().padLeft(2, '0')}:00';

        print(
          '⭐ Master Override for ${day.day}: Using Profile Hours ($masterOpen - $masterClose) instead of Table API ($defaultOpen - $defaultClose)',
        );
        defaultOpen = masterOpen;
        defaultClose = masterClose;
      }

      print('  ✅ NORMALISED open  = "$defaultOpen"  (24h HH:mm:ss)');
      print('  ✅ NORMALISED close = "$defaultClose"  (24h HH:mm:ss)');
      print(
        '  🕑 OPEN  as minutes = ${int.parse(defaultOpen.split(":")[0]) * 60 + int.parse(defaultOpen.split(":")[1])}',
      );
      print(
        '  🕑 CLOSE as minutes = ${int.parse(defaultClose.split(":")[0]) * 60 + int.parse(defaultClose.split(":")[1])}',
      );
      // ─────────────────────────────────────────────────────────────────────

      // Find if this day is in initialSelectedDays
      final initialDay = widget.initialSelectedDays?.firstWhere(
        (d) => d.day?.toLowerCase() == day.day?.toLowerCase(),
        orElse: () => AvailableDay(),
      );

      // Check if this day is selected
      final isDaySelected =
          widget.initialSelectedDays?.any(
            (d) => d.day?.toLowerCase() == day.day?.toLowerCase(),
          ) ??
          false;

      if (isDaySelected) {
        totalSelectedDays++;
      }

      // Change 1: Load timings[1+] as user event slots (all equal, no isDefault).
      // timings[0] is always the venue hours record — skip it here, it is sent
      // back automatically in _getSelectedDays as timings[0].
      List<TimeSlot> slots;
      if (initialDay != null && (initialDay.timings ?? []).length > 1) {
        // API returned timings[1+] = user-configured event slots
        print(
          '  📦 Loading ${initialDay.timings!.length - 1} saved event slot(s) from API (skipping timings[0]=venue hours)',
        );
        slots =
            initialDay.timings!
                .skip(1)
                .map(
                  (t) => TimeSlot(
                    from: _normalizeTime(t.open),
                    to: _normalizeTime(t.close),
                    isDefault: false,
                  ),
                )
                .toList();
      } else {
        // No saved event slots yet — seed with one pre-populated from venue hours
        print(
          '  🌱 No saved event slots — seeding first slot with venue hours: $defaultOpen – $defaultClose',
        );
        slots = [
          TimeSlot(from: defaultOpen, to: defaultClose, isDefault: false),
        ];
      }

      // A day has "only default" when it was saved with no event slots:
      // i.e. the API returned exactly 1 timing (the venue hours record).
      bool hasOnlyDefaultTiming = false;
      if (isDaySelected &&
          initialDay?.timings != null &&
          initialDay!.timings!.isNotEmpty) {
        hasOnlyDefaultTiming = initialDay.timings!.length == 1;
        if (hasOnlyDefaultTiming) {
          daysWithOnlyDefault++;
        }
      }

      // Day is expanded if it has saved event slots
      final hasCustomSlots =
          slots.isNotEmpty &&
          !(slots.length == 1 &&
              slots.first.from == defaultOpen &&
              slots.first.to == defaultClose);

      daySelections[day.day!.toLowerCase()] = DaySelection(
        isSelected: isDaySelected,
        isExpanded: hasCustomSlots,
        cafeOpenTime: defaultOpen,
        cafeCloseTime: defaultClose,
        timeSlots: slots,
      );
    }

    // ✅ Determine if "Always Available" should be ON:
    // 1. All open registration days must be selected
    // 2. Every selected day must have ONLY default timing (no custom slots)
    final allOpenDaysSelected = totalSelectedDays == openRegDaysCount;
    final allHaveOnlyDefaults = daysWithOnlyDefault == totalSelectedDays;

    print(
      '🔍 _initializeDaySelections: totalSelected=$totalSelectedDays, openDays=$openRegDaysCount, onlyDefaults=$daysWithOnlyDefault',
    );
    print(
      '✅ Should be Always Available: ${allOpenDaysSelected && allHaveOnlyDefaults}',
    );

    return allOpenDaysSelected && allHaveOnlyDefaults && totalSelectedDays > 0;
  }

  String _capitalizeFirstLetter(String text) {
    final map = {
      'mon': 'Monday',
      'tue': 'Tuesday',
      'wed': 'Wednesday',
      'thu': 'Thursday',
      'fri': 'Friday',
      'sat': 'Saturday',
      'sun': 'Sunday',
    };

    final key = text.toLowerCase();

    // If it matches a day, return full name, else fallback to your original logic
    if (map.containsKey(key)) {
      return map[key]!;
    }

    if (text.isEmpty) return text;
    return "${text[0].toUpperCase()}${text.substring(1).toLowerCase()}";
  }

  void _disableAlwaysAvailable() {
    if (alwaysAvailable) {
      alwaysAvailable = false;
      // Unfreeze all slots across all selected days so they become editable/deletable
      for (var key in daySelections.keys.toList()) {
        final sel = daySelections[key]!;
        if (sel.isSelected) {
          daySelections[key] = DaySelection(
            isSelected: sel.isSelected,
            isExpanded: sel.isExpanded,
            cafeOpenTime: sel.cafeOpenTime,
            cafeCloseTime: sel.cafeCloseTime,
            timeSlots: sel.timeSlots.map((s) => 
              TimeSlot(from: s.from, to: s.to, isDefault: false)
            ).toList(),
          );
        }
      }
    }
  }

  // String _capitalizeFirstLetter(String text) {
  //   if (text.isEmpty) return text;
  //   return "${text[0].toUpperCase()}${text.substring(1).toLowerCase()}";
  // }

  void _toggleAlwaysAvailable(bool value) {
    setState(() {
      alwaysAvailable = value;

      print('🔄 Toggle Always Available: $value');

      if (value) {
        // ✅ When toggled ON: Select ALL days using their default open-close timings
        print(
          '✅ Selecting all ${widget.availableDays.length} cafe operating days',
        );

        for (var day in widget.availableDays) {
          final dayKey = day.day!.toLowerCase();

          // ✅ Use the already-initialised cafeOpenTime/cafeCloseTime from
          // daySelections — these already have the ProfileBloc master override
          // applied by _initializeDaySelections. Re-reading from the raw API
          // day.timings here would silently discard that override and could
          // produce invalid ranges (e.g. API open=10:00 / close=09:00) that
          // _validateAllSlots then rejects at Done (QA issue 0028392).
          final existing = daySelections[dayKey];
          final openTime =
              existing?.cafeOpenTime ??
              _normalizeTime(
                (day.timings?.isNotEmpty ?? false)
                    ? day.timings!.first.open
                    : "10:00:00",
              );
          final closeTime =
              existing?.cafeCloseTime ??
              _normalizeTime(
                (day.timings?.isNotEmpty ?? false)
                    ? day.timings!.first.close
                    : "22:00:00",
              );

          // ✅ Update all days to have a single default slot (no custom events)
          daySelections[dayKey] = DaySelection(
            isSelected: true,
            isExpanded: false,
            cafeOpenTime: openTime,
            cafeCloseTime: closeTime,
            timeSlots: [
              TimeSlot(from: openTime, to: closeTime, isDefault: true),
            ],
          );

          print('  ✓ $dayKey → $openTime - $closeTime');

        }
      } else {
        // ✅ When toggled OFF: Keep only days that have custom event slots
        print('❌ Toggled OFF - Keeping only custom event days');

        for (var entry in daySelections.entries) {
          final hasCustomSlots = entry.value.timeSlots.length > 1;

          // Preserve only custom days; others remain but unselected
          daySelections[entry.key] = DaySelection(
            isSelected: hasCustomSlots,
            isExpanded: false,
            cafeOpenTime: entry.value.cafeOpenTime,
            cafeCloseTime: entry.value.cafeCloseTime,
            timeSlots:
                hasCustomSlots
                    ? entry.value.timeSlots
                    : [
                      TimeSlot(
                        from: entry.value.cafeOpenTime,
                        to: entry.value.cafeCloseTime,
                        isDefault: false,
                      ),
                    ],
          );

          if (hasCustomSlots) {
            print('  ✓ Kept ${entry.key} (has custom slots)');
          } else {
            print('  ✗ Cleared ${entry.key} (no custom slots)');
          }
        }
      }
    });

    // ✅ Debug summary after toggle
    final selectedDays =
        daySelections.entries
            .where((e) => e.value.isSelected)
            .map((e) => e.key)
            .toList();
    print('📅 Selected days after toggle: $selectedDays');
  }

  void _toggleDay(String day) {
    setState(() {
      final current = daySelections[day]!;
      final newIsSelected = !current.isSelected;
      
      daySelections[day] = DaySelection(
        isSelected: newIsSelected,
        isExpanded: newIsSelected,
        cafeOpenTime: current.cafeOpenTime,
        cafeCloseTime: current.cafeCloseTime,
        timeSlots: newIsSelected
            ? current.timeSlots.map((s) => TimeSlot(
                from: s.from,
                to: s.to,
                isDefault: false,
              )).toList()
            : [
                TimeSlot(
                  from: current.cafeOpenTime,
                  to: current.cafeCloseTime,
                  isDefault: false,
                ),
              ],
      );

      if (!newIsSelected) {
        _disableAlwaysAvailable();
      }
    });
  }

  void _toggleExpand(String day) {
    final current = daySelections[day]!;
    if (current.isSelected) {
      setState(() {
        daySelections[day] = DaySelection(
          isSelected: current.isSelected,
          isExpanded: !current.isExpanded,
          cafeOpenTime: current.cafeOpenTime,
          cafeCloseTime: current.cafeCloseTime,
          timeSlots: List<TimeSlot>.from(current.timeSlots),
        );
      });
    }
  }

  void _addTimeSlot(String day) {
    final selection = daySelections[day]!;
    final openMins = _timeToMinutes(_normalizeTime(selection.cafeOpenTime));
    final closeMins = _closeTimeToMinutes(_normalizeTime(selection.cafeCloseTime));

    // All user slots sorted by start time (no isDefault distinction)
    final userSlots = List<TimeSlot>.from(
      selection.timeSlots,
    )..sort((a, b) => _timeToMinutes(a.from).compareTo(_timeToMinutes(b.from)));

    // ✅ FIX: Find the latest end time among all custom slots
    int nextStartMin = openMins;
    for (final slot in userSlots) {
      final slotEnd = _closeTimeToMinutes(slot.to);
      // Always update to the latest end time (no early break)
      if (slotEnd > nextStartMin) {
        nextStartMin = slotEnd;
      }
    }

    print('🔍 Next available start: $nextStartMin minutes');
    print(
      '🔍 Existing slots: ${userSlots.map((s) => '${s.from}-${s.to}').toList()}',
    );

    // Calculate remaining time
    final remainingTime = closeMins - nextStartMin;

    if (remainingTime < 15) {
      Fluttertoast.showToast(msg: 'Not enough time left to create a new slot.');
      return;
    }

    // Create a slot with remaining time or max 60 minutes
    final nextEndMin =
        nextStartMin + (remainingTime >= 60 ? 60 : remainingTime);

    final newStart =
        '${(nextStartMin ~/ 60).toString().padLeft(2, '0')}:${(nextStartMin % 60).toString().padLeft(2, '0')}:00';
    final newEnd =
        '${(nextEndMin ~/ 60).toString().padLeft(2, '0')}:${(nextEndMin % 60).toString().padLeft(2, '0')}:00';

    print('🔍 Adding new slot: $newStart - $newEnd');

    if (_validateNewSlot(day, newStart, newEnd)) {
      setState(() {
        _disableAlwaysAvailable();
        final current = daySelections[day]!;
        final updatedSlots = List<TimeSlot>.from(current.timeSlots)
          ..add(TimeSlot(from: newStart, to: newEnd, isDefault: false));
        daySelections[day] = DaySelection(
          isSelected: current.isSelected,
          isExpanded: current.isExpanded,
          cafeOpenTime: current.cafeOpenTime,
          cafeCloseTime: current.cafeCloseTime,
          timeSlots: updatedSlots,
        );
      });
    }
  }

  // Change 2: Guard — prevent deleting the last slot for a day.
  void _removeTimeSlot(String day, int index) {
    final current = daySelections[day]!;
    final slots = current.timeSlots;
    if (slots.length <= 1) {
      Fluttertoast.showToast(
        msg:
            'At least one time slot is required. Uncheck the day to remove it entirely.',
      );
      return;
    }
    setState(() {
      final updatedSlots = List<TimeSlot>.from(current.timeSlots)..removeAt(index);
      daySelections[day] = DaySelection(
        isSelected: current.isSelected,
        isExpanded: current.isExpanded,
        cafeOpenTime: current.cafeOpenTime,
        cafeCloseTime: current.cafeCloseTime,
        timeSlots: updatedSlots,
      );
    });
  }

  Future<String?> _selectTime(
    BuildContext context,
    String initialTime,
    String minTime,
    String maxTime,
  ) async {
    final initial = _parseTime(_normalizeTime(initialTime));

    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: initial,
      builder: (BuildContext context, Widget? child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child!,
        );
      },
    );

    if (picked != null) {
      int selectedMinutes = picked.hour * 60 + picked.minute;
      final minMinutes = _timeToMinutes(_normalizeTime(minTime));
      final maxMinutes = _closeTimeToMinutes(_normalizeTime(maxTime));

      if (selectedMinutes == 0 && minMinutes > 0) {
        selectedMinutes = 1440;
      }

      // ─── TIME PICKER DEBUG ────────────────────────────────────────────────
      print(
        '🕐 Time picker selected: ${picked.hour}:${picked.minute.toString().padLeft(2, "0")} = $selectedMinutes min',
      );
      print(
        '   minTime raw="$minTime" → normalised="${_normalizeTime(minTime)}" → $minMinutes min',
      );
      print(
        '   maxTime raw="$maxTime" → normalised="${_normalizeTime(maxTime)}" → $maxMinutes min',
      );
      print(
        '   In range? ${selectedMinutes >= minMinutes && selectedMinutes <= maxMinutes}',
      );
      // ─────────────────────────────────────────────────────────────────────

      if (selectedMinutes < minMinutes || selectedMinutes > maxMinutes) {
        Fluttertoast.showToast(
          msg: 'Time must be between $minTime and $maxTime',
        );

        return null;
      }

      return '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}:00';
    }
    return null;
  }

  /// Validate that a new event slot is inside café hours and non-overlapping
  bool _validateNewSlot(String day, String newStart, String newEnd) {
    final selection = daySelections[day]!;
    final open = _normalizeTime(selection.cafeOpenTime);
    final close = _normalizeTime(selection.cafeCloseTime);
    newStart = _normalizeTime(newStart);
    newEnd = _normalizeTime(newEnd);

    final newStartMins = _timeToMinutes(newStart);
    final newEndMins = _closeTimeToMinutes(newEnd);
    final openMins = _timeToMinutes(open);
    final closeMins = _closeTimeToMinutes(close);

    // Validate: must lie inside the default café hours
    if (newStartMins < openMins || newEndMins > closeMins) {
      Fluttertoast.showToast(
        msg: 'Time slot must be within café hours $open - $close',
      );
      return false;
    }

    // Validate: start must be before end
    if (newEndMins <= newStartMins) {
      Fluttertoast.showToast(msg: 'End time must be after start time');
      return false;
    }

    // Overlap check against ALL other slots (no isDefault skip)
    for (final slot in selection.timeSlots) {
      final existingStart = _timeToMinutes(slot.from);
      final existingEnd = _closeTimeToMinutes(slot.to);
      final overlaps = newStartMins < existingEnd && newEndMins > existingStart;
      if (overlaps) {
        Fluttertoast.showToast(
          msg:
              'Time slot overlaps with an existing one (${slot.from} - ${slot.to})',
        );
        return false;
      }
    }

    // Prevent exact duplicate
    final duplicateExists = selection.timeSlots.any(
      (s) =>
          _normalizeTime(s.from) == newStart && _normalizeTime(s.to) == newEnd,
    );
    if (duplicateExists) {
      Fluttertoast.showToast(msg: 'This time slot already exists');
      return false;
    }

    return true;
  }

  bool _validateEditedSlot(
    String day,
    String newStart,
    String newEnd,
    int currentIndex,
  ) {
    final selection = daySelections[day]!;
    final open = _normalizeTime(selection.cafeOpenTime);
    final close = _normalizeTime(selection.cafeCloseTime);

    final newStartMins = _timeToMinutes(_normalizeTime(newStart));
    final newEndMins = _closeTimeToMinutes(_normalizeTime(newEnd));
    final openMins = _timeToMinutes(open);
    final closeMins = _closeTimeToMinutes(close);

    // Inside open–close
    if (newStartMins < openMins || newEndMins > closeMins) {
      Fluttertoast.showToast(
        msg: 'Time must be within café hours ($open - $close)',
      );
      return false;
    }

    // Start before end
    if (newEndMins <= newStartMins) {
      Fluttertoast.showToast(msg: 'End time must be after start time');
      return false;
    }

    // Change 7: Overlap check against ALL other slots (no isDefault skip)
    for (int i = 0; i < selection.timeSlots.length; i++) {
      if (i == currentIndex) continue; // Skip self
      final s = selection.timeSlots[i];
      final sStart = _timeToMinutes(_normalizeTime(s.from));
      final sEnd = _closeTimeToMinutes(_normalizeTime(s.to));
      final overlaps = newStartMins < sEnd && newEndMins > sStart;
      if (overlaps) {
        Fluttertoast.showToast(
          msg: 'This time overlaps with another slot (${s.from} - ${s.to})',
        );
        return false;
      }
    }

    return true;
  }

  bool _validateAllSlots() {
    for (final entry in daySelections.entries) {
      final selection = entry.value;
      if (!selection.isSelected) continue;

      final open = _normalizeTime(selection.cafeOpenTime);
      final close = _normalizeTime(selection.cafeCloseTime);
      final openMins = _timeToMinutes(open);
      final closeMins = _closeTimeToMinutes(close);

      for (int i = 0; i < selection.timeSlots.length; i++) {
        final slot = selection.timeSlots[i];
        // Change 7: validate ALL slots (no isDefault skip)

        final startMins = _timeToMinutes(_normalizeTime(slot.from));
        final endMins = _closeTimeToMinutes(_normalizeTime(slot.to));

        if (endMins <= startMins) {
          Fluttertoast.showToast(
            msg:
                '${_capitalizeFirstLetter(entry.key)} has invalid time range (${slot.from} - ${slot.to})',
          );
          return false;
        }

        if (startMins < openMins || endMins > closeMins) {
          Fluttertoast.showToast(
            msg:
                '${_capitalizeFirstLetter(entry.key)} slot must be within café hours ($open - $close)',
          );
          return false;
        }

        for (int j = 0; j < selection.timeSlots.length; j++) {
          if (i == j) continue;
          final other = selection.timeSlots[j];
          // Change 7: no isDefault skip
          final otherStart = _timeToMinutes(_normalizeTime(other.from));
          final otherEnd = _closeTimeToMinutes(_normalizeTime(other.to));
          final overlaps = startMins < otherEnd && endMins > otherStart;
          if (overlaps) {
            Fluttertoast.showToast(
              msg:
                  '${_capitalizeFirstLetter(entry.key)} has overlapping slots (${slot.from} - ${slot.to}) and (${other.from} - ${other.to})',
            );
            return false;
          }
        }
      }
    }
    return true;
  }

  TimeOfDay _parseTime(String time) {
    final clean = _normalizeTime(time);
    final parts = clean.split(':');
    int hour = int.parse(parts[0]);
    int minute = int.parse(parts[1]);
    return TimeOfDay(hour: hour, minute: minute);
  }

  int _timeToMinutes(String time) {
    final clean = _normalizeTime(time);
    final parts = clean.split(':');
    return int.parse(parts[0]) * 60 + int.parse(parts[1]);
  }

  int _closeTimeToMinutes(String time) {
    final clean = _normalizeTime(time);
    if (clean == "00:00:00") {
      return 1440;
    }
    return _timeToMinutes(clean);
  }

  List<AvailableDay> _getSelectedDays() {
    List<AvailableDay> selected = [];

    daySelections.forEach((day, selection) {
      final defaultSlot = selection.timeSlots.firstWhere(
        (s) => s.isDefault,
        orElse:
            () => TimeSlot(
              from: selection.cafeOpenTime,
              to: selection.cafeCloseTime,
              isDefault: true,
            ),
      );

      // CASE 1: Always Available → send all days with default slot only
      if (alwaysAvailable) {
        selected.add(
          AvailableDay(
            id:
                widget.availableDays
                    .firstWhere(
                      (d) => d.day?.toLowerCase() == day.toLowerCase(),
                      orElse: () => AvailableDay(),
                    )
                    .id,
            day: day,
            timings: [
              Timing(
                open: _normalizeTime(defaultSlot.from),
                close: _normalizeTime(defaultSlot.to),
              ),
            ],
            isOpen: true,
          ),
        );
      }
      // CASE 2: Custom event days
      // Change 5: timings[0] = venue hours (always from cafeOpenTime/cafeCloseTime,
      // never from the user's slot list). timings[1+] = ALL user event slots.
      else if (selection.isSelected && selection.timeSlots.isNotEmpty) {
        final timings = <Timing>[
          // timings[0] — venue hours, hardcoded from original API data
          Timing(
            open: _normalizeTime(selection.cafeOpenTime),
            close: _normalizeTime(selection.cafeCloseTime),
          ),
        ];

        // timings[1+] — all user-configured event slots
        for (final slot in selection.timeSlots) {
          timings.add(
            Timing(
              open: _normalizeTime(slot.from),
              close: _normalizeTime(slot.to),
            ),
          );
        }

        selected.add(
          AvailableDay(
            id:
                widget.availableDays
                    .firstWhere(
                      (d) => d.day?.toLowerCase() == day.toLowerCase(),
                      orElse: () => AvailableDay(),
                    )
                    .id,
            day: day,
            timings: timings,
            isOpen: true,
          ),
        );
      }
    });

    return selected;
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isSmallScreen = screenWidth < 360;

    return Dialog(
      backgroundColor: Colors.white,
      insetPadding: EdgeInsets.symmetric(
        horizontal: screenWidth * 0.05,
        vertical: screenHeight * 0.05,
      ),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: screenHeight * 0.9,
          maxWidth: 600,
        ),
        decoration: BoxDecoration(
          color: AppColors.primaryWhiteColor,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
              decoration: BoxDecoration(
                color: AppColors.primaryWhiteColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      'Select Available Days',
                      style: GoogleFonts.montserrat(
                        fontSize: isSmallScreen ? 18 : 22,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(
                      Icons.close,
                      color: AppColors.secondaryGreyTextColor,
                      size: 24,
                    ),
                  ),
                ],
              ),
            ),

            // Content
            Flexible(
              child: SingleChildScrollView(
                controller: _scrollController, // Change 6
                physics: const BouncingScrollPhysics(),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: isSmallScreen ? 16 : 20,
                    vertical: 0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Table Type Info
                      Container(
                        height: 60.h,
                        width: double.infinity,
                        padding: EdgeInsets.all(isSmallScreen ? 10 : 12),
                        decoration: BoxDecoration(
                          color: AppColors.subscriptionPromptSubColor,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Table Type',
                              style: GoogleFonts.montserrat(
                                fontSize: isSmallScreen ? 11 : 12,
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                widget.tableTypeName,
                                style: GoogleFonts.montserrat(
                                  fontSize: isSmallScreen ? 12 : 16,
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w700,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Gap(8),
                      // Always Available Toggle
                      Row(
                        children: [
                          SizedBox(
                            width: 50.0,
                            height: 36.0,
                            child: FittedBox(
                              fit: BoxFit.fill,
                              child: Switch(
                                value: alwaysAvailable,
                                onChanged: _toggleAlwaysAvailable,
                                activeThumbColor: AppColors.primaryWhiteColor,
                                activeTrackColor: AppColors.secondary,
                                inactiveThumbColor: Colors.white,
                                inactiveTrackColor: Colors.grey.shade400,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Always Available',
                              style: GoogleFonts.montserrat(
                                fontSize: isSmallScreen ? 13 : 14,
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Gap(8),

                      ...widget.availableDays.map((day) {
                        return _buildDayTile(
                          day.day!.toLowerCase(),
                          isSmallScreen,
                        );
                      }).toList(),
                    ],
                  ),
                ),
              ),
            ),

            // Footer Button
            Padding(
              padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
              child: SizedBox(
                width: MediaQuery.of(context).size.width / 2.7,
                height: isSmallScreen ? 44 : 48,
                child: ElevatedButton(
                  onPressed: () {
                    // ✅ Validate all before closing
                    if (_validateAllSlots()) {
                      Navigator.pop(context, {
                        'days': _getSelectedDays(),
                        'alwaysAvailable': alwaysAvailable,
                      });
                    }
                  },
                  // onPressed: () {
                  //   // Validate all before closing
                  //   if (_validateAllSlots()) {
                  //     Navigator.pop(context, _getSelectedDays(), alwaysAvailable,);
                  //   }
                  // },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: Text(
                    'DONE',
                    style: GoogleFonts.montserrat(
                      fontSize: isSmallScreen ? 14 : 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeSlot(String day, int index, TimeSlot slot) {
    Future<void> _pickNewTime({required bool isFrom}) async {
      // Always read the CURRENT state at the time the picker opens —
      // not the stale build-time captures of `selection` and `slot`.
      final liveSelection = daySelections[day]!;
      final liveSlot = liveSelection.timeSlots[index];

      final newTime = await _selectTime(
        context,
        isFrom ? liveSlot.from : liveSlot.to,
        liveSelection.cafeOpenTime,
        liveSelection.cafeCloseTime,
      );

      if (newTime != null) {
        setState(() {
          final currentSelection = daySelections[day]!;
          final slots = List<TimeSlot>.from(currentSelection.timeSlots);
          final currentSlot = slots[index];

          if (isFrom) {
            final newFromMins = _timeToMinutes(newTime);
            final currentToMins = _closeTimeToMinutes(currentSlot.to);

            String updatedTo = currentSlot.to;
            if (newFromMins >= currentToMins) {
              int newToMins = newFromMins + 60;
              final closeMins = _closeTimeToMinutes(currentSelection.cafeCloseTime);
              if (newToMins > closeMins) {
                newToMins = closeMins;
              }
              if (newToMins - newFromMins < 15) {
                newToMins = newFromMins + 15;
                if (newToMins > closeMins) {
                  newToMins = closeMins;
                }
              }
              final normalizedToMins = newToMins % 1440;
              final hours = normalizedToMins ~/ 60;
              final minutes = normalizedToMins % 60;
              updatedTo = '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:00';
            }

            slots[index] = TimeSlot(
              from: newTime,
              to: updatedTo,
              isDefault: false,
            );
          } else {
            // TO edit: validate the fully-assembled slot.
            if (_validateEditedSlot(
              day,
              currentSlot.from,
              newTime,
              index,
            )) {
              slots[index] = TimeSlot(
                from: currentSlot.from,
                to: newTime,
                isDefault: false,
              );
            } else {
              return;
            }
          }

          daySelections[day] = DaySelection(
            isSelected: currentSelection.isSelected,
            isExpanded: currentSelection.isExpanded,
            cafeOpenTime: currentSelection.cafeOpenTime,
            cafeCloseTime: currentSelection.cafeCloseTime,
            timeSlots: slots,
          );
        });
      }
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Change 3: FROM — always active (no isDefault guard)
          Expanded(
            flex: 1,
            child: GestureDetector(
              onTap: () => _pickNewTime(isFrom: true),
              child: _buildTimeBox(slot.from, false),
            ),
          ),
          const SizedBox(width: 12),
          // TO — always active
          Expanded(
            flex: 1,
            child: GestureDetector(
              onTap: () => _pickNewTime(isFrom: false),
              child: _buildTimeBox(slot.to, false),
            ),
          ),
          const SizedBox(width: 10),
          // DELETE — always shown; _removeTimeSlot guards the last slot
          InkWell(
            onTap: () => _removeTimeSlot(day, index),
            borderRadius: BorderRadius.circular(20),
            child: Padding(
              padding: const EdgeInsets.all(6),
              child: Image.asset(Assets.DELETE, fit: BoxFit.cover, scale: 3),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeBox(String time, bool isDisabled) {
    String _formatTime(String time) {
      final parsed = DateFormat.Hms().parse(time); // Parses "HH:mm:ss"
      return DateFormat.jm().format(parsed); // Converts to "10:00 AM"
    }

    return Container(
      height: 42.h,
      decoration: BoxDecoration(
        color: AppColors.primaryWhiteColor,
        borderRadius: BorderRadius.circular(10),
        // border: Border.all(
        //   color: const Color(0xFFDADADA),
        // ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              children: [
                const Icon(
                  Icons.access_time,
                  size: 16,
                  color: Color(0xFF9E9E9E),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      _formatTime(time),
                      style: GoogleFonts.montserrat(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF1A1A1A),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.unfold_more, size: 18, color: Color(0xFF9E9E9E)),
        ],
      ),
    );
  }

  Widget _buildDayTile(String day, bool isSmallScreen) {
    final selection = daySelections[day];
    if (selection == null) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.subscriptionPromptSubColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => _toggleDay(day),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: AppColors.primaryWhiteColor,
                        border: Border.all(
                          color: AppColors.primary,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child:
                          selection.isSelected
                              ? SvgPicture.asset(
                                Assets.CHECK,
                                fit: BoxFit.scaleDown,
                                height: 10,
                              )
                              : null,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GestureDetector(
                    onTap: selection.isSelected ? () => _toggleExpand(day) : null,
                    behavior: HitTestBehavior.opaque,
                    child: Text(
                      _capitalizeFirstLetter(day),
                      style: GoogleFonts.montserrat(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF1A1A1A),
                      ),
                    ),
                  ),
                ),
                if (selection.isSelected)
                  GestureDetector(
                    onTap: () => _toggleExpand(day),
                    behavior: HitTestBehavior.opaque,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      child: SvgPicture.asset(
                        selection.isExpanded
                            ? Assets.TAB_ARROW_UP
                            : Assets.TAB_ARROW_DOWN,
                        height: 10,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          if (selection.isSelected && selection.isExpanded)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Add "From" and "To" labels above the first slot
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 1,
                          child: Text(
                            'From',
                            style: GoogleFonts.montserrat(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: AppColors.timeTextColor,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 1,
                          child: Text(
                            'To',
                            style: GoogleFonts.montserrat(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: AppColors.timeTextColor,
                            ),
                          ),
                        ),
                        const SizedBox(
                          width: 38,
                        ), // Space for delete icon alignment
                      ],
                    ),
                  ),
                  ...List.generate(selection.timeSlots.length, (index) {
                    final slot = selection.timeSlots[index];
                    return _buildTimeSlot(day, index, slot);
                  }),
                  if (selection.timeSlots.length < 5)
                    Align(
                      alignment: Alignment.centerRight,
                      child: InkWell(
                        onTap: () => _addTimeSlot(day),
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.add,
                                color: Colors.white,
                                size: 13,
                              ),
                              const SizedBox(width: 5),
                              Text(
                                'ADD NEW',
                                style: GoogleFonts.montserrat(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class DaySelection {
  final bool isSelected;
  final bool isExpanded;
  final String cafeOpenTime;
  final String cafeCloseTime;
  final List<TimeSlot> timeSlots;

  const DaySelection({
    required this.isSelected,
    required this.isExpanded,
    required this.cafeOpenTime,
    required this.cafeCloseTime,
    required this.timeSlots,
  });
}

class TimeSlot {
  final String from;
  final String to;
  final bool isDefault;

  const TimeSlot({required this.from, required this.to, required this.isDefault});
}

class NoGlowScrollBehavior extends ScrollBehavior {
  @override
  Widget buildOverscrollIndicator(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) {
    // Returns the child widget directly, effectively removing the glow effect.
    return child;
  }
}
