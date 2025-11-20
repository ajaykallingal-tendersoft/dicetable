import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:soloseaters/src/constants/app_colors.dart';
import 'package:soloseaters/src/constants/assets.dart';
import 'package:soloseaters/src/model/cafe_owner/home/available_days.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

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

  @override
  void initState() {
    super.initState();

    // ✅ Initialize day selections first to compute the state
    final computedAlwaysAvailable = _initializeDaySelections();

    // ✅ If widget.initiallyAlwaysAvailable is explicitly provided (not null), use it
    // Otherwise, use the computed value from day selections
    if (widget.initiallyAlwaysAvailable != null) {
      alwaysAvailable = widget.initiallyAlwaysAvailable!;
      print(
        '🎯 Dialog initState: Using provided alwaysAvailable=${widget.initiallyAlwaysAvailable}',
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

  // Normalize malformed API or user-entered time values to "HH:mm:ss"
  String _normalizeTime(String time) {
    if (time.isEmpty) return "00:00:00";

    final parts = time.split(':').where((p) => p.isNotEmpty).toList();

    // Keep only first 3 (HH, mm, ss)
    final normalized = parts.take(3).toList();
    while (normalized.length < 3) {
      normalized.add("00");
    }

    final hh = int.tryParse(normalized[0]) ?? 0;
    final mm = int.tryParse(normalized[1]) ?? 0;
    final ss = int.tryParse(normalized[2]) ?? 0;

    return '${hh.toString().padLeft(2, '0')}:${mm.toString().padLeft(2, '0')}:${ss.toString().padLeft(2, '0')}';
  }

  bool _initializeDaySelections() {
    daySelections.clear();

    // Get all open registration days
    final openRegDays =
        widget.availableDays.where((d) => d.isOpen ?? true).toList();

    // Track how many days are selected with ONLY default timing
    int daysWithOnlyDefault = 0;
    int totalSelectedDays = 0;

    for (var day in widget.availableDays) {
      final hasDefaultTiming = day.timings != null && day.timings!.isNotEmpty;

      final defaultOpen = _normalizeTime(
        hasDefaultTiming ? day.timings!.first.open : "10:00:00",
      );
      final defaultClose = _normalizeTime(
        hasDefaultTiming ? day.timings!.first.close : "22:00:00",
      );

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

      // Identify custom event slots (non-default timings)
      final List<Timing> apiCustomSlots = [];
      if (initialDay != null && (initialDay.timings ?? []).isNotEmpty) {
        for (var t in initialDay.timings!) {
          final open = _normalizeTime(t.open);
          final close = _normalizeTime(t.close);
          // If timing differs from default, it's a custom event slot
          if (open != defaultOpen || close != defaultClose) {
            apiCustomSlots.add(t);
          }
        }
      }

      // Build time slots for UI
      final List<TimeSlot> slots = [
        TimeSlot(from: defaultOpen, to: defaultClose, isDefault: true),
        ...apiCustomSlots.map(
          (t) => TimeSlot(
            from: _normalizeTime(t.open),
            to: _normalizeTime(t.close),
            isDefault: false,
          ),
        ),
      ];

      // Check if this day has ONLY default timing (exactly 1 timing matching default)
      bool hasOnlyDefaultTiming = false;
      if (isDaySelected &&
          initialDay?.timings != null &&
          initialDay!.timings!.isNotEmpty) {
        hasOnlyDefaultTiming =
            initialDay.timings!.length == 1 &&
            _normalizeTime(initialDay.timings!.first.open) == defaultOpen &&
            _normalizeTime(initialDay.timings!.first.close) == defaultClose;

        if (hasOnlyDefaultTiming) {
          daysWithOnlyDefault++;
        }
      }

      // Determine if day should be expanded (has custom slots)
      final hasCustomSlots = apiCustomSlots.isNotEmpty;

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
    final allOpenDaysSelected = totalSelectedDays == openRegDays.length;
    final allHaveOnlyDefaults = daysWithOnlyDefault == totalSelectedDays;

    print(
      '🔍 _initializeDaySelections: totalSelected=$totalSelectedDays, openDays=${openRegDays.length}, onlyDefaults=$daysWithOnlyDefault',
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
          final existingSelection = daySelections[dayKey];

          // Default timings from availableDays (API)
          final defaultOpen = _normalizeTime(
            (day.timings?.isNotEmpty ?? false)
                ? day.timings!.first.open
                : "10:00:00",
          );
          final defaultClose = _normalizeTime(
            (day.timings?.isNotEmpty ?? false)
                ? day.timings!.first.close
                : "22:00:00",
          );

          // ✅ Update all days to have a single default slot (no custom events)
          daySelections[dayKey] = DaySelection(
            isSelected: true,
            isExpanded: false,
            cafeOpenTime: defaultOpen,
            cafeCloseTime: defaultClose,
            timeSlots: [
              TimeSlot(from: defaultOpen, to: defaultClose, isDefault: true),
            ],
          );

          print('  ✓ $dayKey → $defaultOpen - $defaultClose');
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
                        isDefault: true,
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
      daySelections[day]!.isSelected = !daySelections[day]!.isSelected;
      if (daySelections[day]!.isSelected) {
        daySelections[day]!.isExpanded = true;
      } else {
        daySelections[day]!.isExpanded = false;
        daySelections[day]!.timeSlots = [
          TimeSlot(
            from: daySelections[day]!.cafeOpenTime,
            to: daySelections[day]!.cafeCloseTime,
            isDefault: true,
          ),
        ];
      }

      if (!daySelections[day]!.isSelected && alwaysAvailable) {
        alwaysAvailable = false;
      }
    });
  }

  void _toggleExpand(String day) {
    if (daySelections[day]!.isSelected) {
      setState(() {
        daySelections[day]!.isExpanded = !daySelections[day]!.isExpanded;
      });
    }
  }

  void _addTimeSlot(String day) {
    final selection = daySelections[day]!;
    final openMins = _timeToMinutes(_normalizeTime(selection.cafeOpenTime));
    final closeMins = _timeToMinutes(_normalizeTime(selection.cafeCloseTime));

    // Get all existing custom slots sorted by start time
    final userSlots =
        selection.timeSlots.where((s) => !s.isDefault).toList()..sort(
          (a, b) => _timeToMinutes(a.from).compareTo(_timeToMinutes(b.from)),
        );

    // ✅ FIX: Find the latest end time among all custom slots
    int nextStartMin = openMins;
    for (final slot in userSlots) {
      final slotEnd = _timeToMinutes(slot.to);
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
        selection.timeSlots.add(
          TimeSlot(from: newStart, to: newEnd, isDefault: false),
        );
      });
    }
  }

  void _removeTimeSlot(String day, int index) {
    setState(() {
      daySelections[day]!.timeSlots.removeAt(index);
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
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child!,
        );
      },
    );

    if (picked != null) {
      final selectedMinutes = picked.hour * 60 + picked.minute;
      final minMinutes = _timeToMinutes(_normalizeTime(minTime));
      final maxMinutes = _timeToMinutes(_normalizeTime(maxTime));

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
    final newEndMins = _timeToMinutes(newEnd);
    final openMins = _timeToMinutes(open);
    final closeMins = _timeToMinutes(close);

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

    // ✅ FIX: Only check overlap with OTHER CUSTOM slots (skip default)
    // Adjacent slots are OK (one ends at 11:00 AM, next starts at 11:00 AM)
    for (final slot in selection.timeSlots) {
      if (slot.isDefault) continue; // Skip the default café hours slot

      final existingStart = _timeToMinutes(slot.from);
      final existingEnd = _timeToMinutes(slot.to);

      // ✅ TRUE OVERLAP: New slot must start STRICTLY BEFORE existing ends
      //    AND end STRICTLY AFTER existing starts (not equal)
      final overlaps =
          (newStartMins < existingEnd && newEndMins > existingStart);

      if (overlaps) {
        Fluttertoast.showToast(
          msg:
              'Time slot overlaps with an existing one (${slot.from} - ${slot.to})',
        );
        return false;
      }
    }

    // Prevent duplication
    final duplicateExists = selection.timeSlots.any(
      (s) =>
          !s.isDefault &&
          _normalizeTime(s.from) == newStart &&
          _normalizeTime(s.to) == newEnd,
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
    final newEndMins = _timeToMinutes(_normalizeTime(newEnd));
    final openMins = _timeToMinutes(open);
    final closeMins = _timeToMinutes(close);

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

    // ✅ FIX: Prevent overlap with other non-default slots (ignore self AND default)
    // Adjacent slots are OK
    for (int i = 0; i < selection.timeSlots.length; i++) {
      if (i == currentIndex) continue; // Skip self
      final s = selection.timeSlots[i];
      if (s.isDefault) continue; // Skip the default café hours slot

      final sStart = _timeToMinutes(_normalizeTime(s.from));
      final sEnd = _timeToMinutes(_normalizeTime(s.to));

      // ✅ TRUE OVERLAP check
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
      final closeMins = _timeToMinutes(close);

      for (int i = 0; i < selection.timeSlots.length; i++) {
        final slot = selection.timeSlots[i];
        if (slot.isDefault) continue; // Skip default slot validation

        final startMins = _timeToMinutes(_normalizeTime(slot.from));
        final endMins = _timeToMinutes(_normalizeTime(slot.to));

        // Invalid order
        if (endMins <= startMins) {
          Fluttertoast.showToast(
            msg:
                '${_capitalizeFirstLetter(entry.key)} has invalid time range (${slot.from} - ${slot.to})',
          );
          return false;
        }

        // Outside default café hours
        if (startMins < openMins || endMins > closeMins) {
          Fluttertoast.showToast(
            msg:
                '${_capitalizeFirstLetter(entry.key)} slot must be within café hours ($open - $close)',
          );
          return false;
        }

        // ✅ FIX: Overlap check - only compare with OTHER custom slots
        // Adjacent slots are OK
        for (int j = 0; j < selection.timeSlots.length; j++) {
          if (i == j) continue; // Skip self
          final other = selection.timeSlots[j];
          if (other.isDefault) continue; // Skip default slot

          final otherStart = _timeToMinutes(_normalizeTime(other.from));
          final otherEnd = _timeToMinutes(_normalizeTime(other.to));

          // ✅ TRUE OVERLAP check
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
      // CASE 2: Custom event days → send default + event-created slots
      else if (selection.isSelected && selection.timeSlots.isNotEmpty) {
        final List<Timing> timings = [];

        // Always include the default open–close slot first
        timings.add(
          Timing(
            open: _normalizeTime(defaultSlot.from),
            close: _normalizeTime(defaultSlot.to),
          ),
        );

        // Add all user-created custom event slots (non-default)
        for (final slot in selection.timeSlots.where((s) => !s.isDefault)) {
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

  // Add this helper
  String _fullDayName(String day) {
    switch (day.toLowerCase()) {
      case 'mon':
      case 'monday':
        return 'Monday';
      case 'tue':
      case 'tuesday':
        return 'Tuesday';
      case 'wed':
      case 'wednesday':
        return 'Wednesday';
      case 'thu':
      case 'thursday':
        return 'Thursday';
      case 'fri':
      case 'friday':
        return 'Friday';
      case 'sat':
      case 'saturday':
        return 'Saturday';
      case 'sun':
      case 'sunday':
        return 'Sunday';
      default:
        return day;
    }
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
                                activeColor: AppColors.primaryWhiteColor,
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
    final selection = daySelections[day]!;

    Future<void> _pickNewTime({required bool isFrom}) async {
      final newTime = await _selectTime(
        context,
        isFrom ? slot.from : slot.to,
        selection.cafeOpenTime,
        selection.cafeCloseTime,
      );

      if (newTime != null) {
        final tempSlots = List<TimeSlot>.from(selection.timeSlots);
        tempSlots[index] = TimeSlot(
          from: isFrom ? newTime : slot.from,
          to: isFrom ? slot.to : newTime,
          isDefault: slot.isDefault,
        );

        final newStart = tempSlots[index].from;
        final newEnd = tempSlots[index].to;

        if (_validateEditedSlot(day, newStart, newEnd, index)) {
          setState(() {
            if (isFrom) {
              selection.timeSlots[index].from = newTime;
            } else {
              selection.timeSlots[index].to = newTime;
            }
          });
        }
      }
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // FROM
          Expanded(
            flex: 1,
            child: GestureDetector(
              onTap: slot.isDefault ? null : () => _pickNewTime(isFrom: true),
              child: _buildTimeBox(slot.from, slot.isDefault),
            ),
          ),
          const SizedBox(width: 12),
          // TO
          Expanded(
            flex: 1,
            child: GestureDetector(
              onTap: slot.isDefault ? null : () => _pickNewTime(isFrom: false),
              child: _buildTimeBox(slot.to, slot.isDefault),
            ),
          ),
          const SizedBox(width: 10),
          // DELETE
          if (!slot.isDefault)
            InkWell(
              onTap: () => _removeTimeSlot(day, index),
              borderRadius: BorderRadius.circular(20),
              child: Padding(
                padding: const EdgeInsets.all(6),
                child: Image.asset(Assets.DELETE, fit: BoxFit.cover, scale: 3),
              ),
            )
          else
            const SizedBox(width: 28),
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
          Row(
            children: [
              const Icon(Icons.access_time, size: 16, color: Color(0xFF9E9E9E)),
              const SizedBox(width: 6),
              Text(
                _formatTime(time),
                style: GoogleFonts.montserrat(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF1A1A1A),
                ),
              ),
            ],
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
          InkWell(
            onTap: () => _toggleExpand(day),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => _toggleDay(day),
                    child: Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: AppColors.primaryWhiteColor,
                        border: Border.all(color: AppColors.primary, width: 2),
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
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _capitalizeFirstLetter(day),
                      style: GoogleFonts.montserrat(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF1A1A1A),
                      ),
                    ),
                  ),
                  if (selection.isSelected)
                    SvgPicture.asset(
                      selection.isExpanded
                          ? Assets.TAB_ARROW_UP
                          : Assets.TAB_ARROW_DOWN,
                      height: 10,
                    ),
                ],
              ),
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
  bool isSelected;
  bool isExpanded;
  String cafeOpenTime;
  String cafeCloseTime;
  List<TimeSlot> timeSlots;

  DaySelection({
    required this.isSelected,
    required this.isExpanded,
    required this.cafeOpenTime,
    required this.cafeCloseTime,
    required this.timeSlots,
  });
}

class TimeSlot {
  String from;
  String to;
  bool isDefault;

  TimeSlot({required this.from, required this.to, required this.isDefault});
}
