// card_item.dart
import 'dart:math';
import 'dart:ui';

import 'package:soloseaters/src/model/cafe_owner/home/venue_owner_home_screen_response.dart'
    show DiceTable, Attendee;

import '../../../../model/cafe_owner/home/available_days.dart';

class CardModel {
  final int id;
  final String title;
  final String? subTitle;
  final String? description;
  final String? iconImage;
  final String? moreInfo;

  final List<AvailableDay> availableDays;
  final bool isSelected;
  final bool isExpanded;
  final String availabilityText;
  final String promoText;
  final List<AvailableDay> selectedDays;
  final bool isAlwaysAvailable;

  /// ✅ Newly added fields
  final bool hasBookings;
  final List<Attendee> attendees;

  CardModel({
    required this.id,
    required this.title,
    this.subTitle,
    this.description,
    this.iconImage,
    this.moreInfo,
    required this.availableDays,
    this.isSelected = false,
    this.isExpanded = false,
    this.availabilityText = '',
    this.promoText = '',
    this.selectedDays = const [],
    this.isAlwaysAvailable = false,
    this.hasBookings = false, // <-- NEW
    this.attendees = const [], // <-- NEW
  });

  /// Normalize a time string into "HH:mm:ss".
  static String _norm(String time) {
    if (time.isEmpty) return '00:00:00';
    final parts = time.split(':').where((p) => p.isNotEmpty).toList();
    while (parts.length < 3) {
      parts.add('00');
    }
    final hh = int.tryParse(parts[0]) ?? 0;
    final mm = int.tryParse(parts[1]) ?? 0;
    final ss = int.tryParse(parts[2]) ?? 0;
    return '${hh.toString().padLeft(2, '0')}:${mm.toString().padLeft(2, '0')}:${ss.toString().padLeft(2, '0')}';
  }

  /// Returns true when:
  /// 1) All open (operating) registration days are selected;
  /// 2) Every selected day has exactly one timing;
  /// 3) That timing equals the default open/close for that same day.
  static bool _computeAlwaysAvailable({
    required List<AvailableDay> selectedDays,
    required List<AvailableDay> registrationDays,
  }) {
    if (selectedDays.isEmpty) return false;

    final openRegDays =
        registrationDays.where((d) => (d.isOpen ?? true)).toList();

    if (selectedDays.length != openRegDays.length) return false;

    final Map<String, (String open, String close)> defaultByDay = {
      for (final d in openRegDays)
        (d.day ?? '').toLowerCase(): (
          _norm((d.timings?.isNotEmpty ?? false)
              ? d.timings!.first.open
              : '10:00:00'),
          _norm((d.timings?.isNotEmpty ?? false)
              ? d.timings!.first.close
              : '22:00:00'),
        )
    };

    for (final sd in selectedDays) {
      final key = (sd.day ?? '').toLowerCase();
      if (!defaultByDay.containsKey(key)) return false;
      if ((sd.timings?.length ?? 0) != 1) return false;

      final t = sd.timings!.first;
      final (defOpen, defClose) = defaultByDay[key]!;
      if (_norm(t.open) != defOpen || _norm(t.close) != defClose) {
        return false;
      }
    }
    return true;
  }

  /// ✅ Updated factory constructor with booking & attendees support
factory CardModel.fromDiceTable(
  DiceTable diceTable, {
  required bool status,
}) {
  final List<AvailableDay> availableDaysList = diceTable.availableDays ?? [];
  
  final bool apiAlwaysAvailable = diceTable.alwaysAvailable ?? false;

  // ✅ Debug: Print each day's is_open value and boundaries BEFORE filtering
  print('🔍 DEBUG: Table "${diceTable.title}" (ID: ${diceTable.id})');
  for (var day in availableDaysList) {
    final venueHours = (day.timings?.isNotEmpty ?? false) 
        ? "${day.timings!.first.open} - ${day.timings!.first.close}" 
        : "MISSING";
    final userSlots = (day.timings?.length ?? 0) > 1 
        ? day.timings!.skip(1).map((t) => "${t.open}-${t.close}").join(", ") 
        : "NONE";
    
    print('  📅 ${day.day}: is_open=${day.isOpen} | VenueHours (timings[0]): $venueHours | Slots: $userSlots');
  }

  List<AvailableDay> initialSelectedDaysForCard;

  if (diceTable.selected ?? false) {
    // ✅ STRICT filtering: Only days where is_open is EXPLICITLY true
    initialSelectedDaysForCard = availableDaysList
        .where((day) {
          final selected = day.isOpen == true;  // Only true, not null or false
          if (selected) {
            print('  ✅ ${day.day} is selected (is_open=true)');
          } else {
            print('  ❌ ${day.day} is NOT selected (is_open=${day.isOpen})');
          }
          return selected;
        })
        .toList();

    if (apiAlwaysAvailable) {
      print('🔵 "${diceTable.title}" is ALWAYS AVAILABLE → ${initialSelectedDaysForCard.length} days');
    } else {
      print('🟡 "${diceTable.title}" has CUSTOM selection → ${initialSelectedDaysForCard.length} days selected');
    }
  } else {
    initialSelectedDaysForCard = <AvailableDay>[];
    print('⚪ "${diceTable.title}" is NOT selected (selected=false)');
  }

  final bool isAlwaysAvailable = apiAlwaysAvailable && (diceTable.selected ?? false);

  // ✅ Count days with is_open == true explicitly
  final daysExplicitlyOpen = availableDaysList.where((d) => d.isOpen == true).length;

  print('📊 CardModel for "${diceTable.title}": '
      'selected=${diceTable.selected}, '
      'apiAlwaysAvailable=$apiAlwaysAvailable, '
      'totalAvailableDays=${availableDaysList.length}, '
      'daysWithIsOpenTrue=$daysExplicitlyOpen, '
      'finalSelectedDays=${initialSelectedDaysForCard.length} '
      '(${initialSelectedDaysForCard.map((d) => d.day).join(", ")}), '
      'isAlwaysAvailable=$isAlwaysAvailable');

  return CardModel(
    id: diceTable.id ?? 0,
    title: diceTable.title ?? '',
    subTitle: diceTable.subTitle,
    description: diceTable.description,
    iconImage: diceTable.iconImage,
    moreInfo: diceTable.moreInfo,
    availableDays: availableDaysList,
    isSelected: diceTable.selected ?? false,
    selectedDays: initialSelectedDaysForCard,
    isAlwaysAvailable: isAlwaysAvailable,
    hasBookings: diceTable.hasBookings,
    attendees: diceTable.attendees,
  );
}

  CardModel copyWith({
    int? id,
    String? title,
    String? subTitle,
    String? description,
    String? iconImage,
    String? moreInfo,
    List<AvailableDay>? availableDays,
    bool? isSelected,
    bool? isExpanded,
    String? availabilityText,
    String? promoText,
    List<AvailableDay>? selectedDays,
    bool? isAlwaysAvailable,
    bool? hasBookings, // ✅ include in copy
    List<Attendee>? attendees, // ✅ include in copy
  }) {
    return CardModel(
      id: id ?? this.id,
      title: title ?? this.title,
      subTitle: subTitle ?? this.subTitle,
      description: description ?? this.description,
      iconImage: iconImage ?? this.iconImage,
      moreInfo: moreInfo ?? this.moreInfo,
      availableDays: availableDays ?? this.availableDays,
      isSelected: isSelected ?? this.isSelected,
      isExpanded: isExpanded ?? this.isExpanded,
      availabilityText: availabilityText ?? this.availabilityText,
      promoText: promoText ?? this.promoText,
      selectedDays: selectedDays ?? this.selectedDays,
      isAlwaysAvailable: isAlwaysAvailable ?? this.isAlwaysAvailable,
      hasBookings: hasBookings ?? this.hasBookings,
      attendees: attendees ?? this.attendees,
    );
  }
}
