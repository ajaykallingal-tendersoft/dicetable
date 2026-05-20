import 'package:collection/collection.dart';
import 'package:go_router/go_router.dart';
import 'package:soloseaters/src/constants/app_colors.dart';
import 'package:soloseaters/src/model/cafe_owner/home/available_days.dart';
import 'package:soloseaters/src/model/cafe_owner/home/dice_table_update_request.dart'
    show DiceTableTypeUpdateRequest;
import 'package:soloseaters/src/purchase/bloc/bloc/purchase_bloc.dart';
import 'package:soloseaters/src/purchase/bloc/bloc/purchase_state.dart';
import 'package:soloseaters/src/ui/cafe_owner/home/attendees_arguments.dart';
import 'package:soloseaters/src/ui/cafe_owner/home/bloc/home_bloc.dart';
import 'package:soloseaters/src/ui/cafe_owner/home/model/card_item.dart';
import 'package:soloseaters/src/ui/cafe_owner/home/widget/enhanced_available_days_dialog.dart';
import 'package:soloseaters/src/ui/cafe_owner/subscription/widget/subscription_upgrade_popup.dart';
import 'package:soloseaters/src/utils/data/object_factory.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';

class ExpandableCard extends StatefulWidget {
  final int index;
  final CardModel card;

  const ExpandableCard({super.key, required this.index, required this.card});

  @override
  State<ExpandableCard> createState() => _ExpandableCardState();
}

class _ExpandableCardState extends State<ExpandableCard> {
  late TextEditingController _promoController;
  List<AvailableDay> selectedDays = [];
  late int? cafeId;
  List<Color> iconColor = [
    AppColors.tableTypeLogoColor1,
    AppColors.tableTypeLogoColor2,
    AppColors.tableTypeLogoColor3,
    AppColors.tableTypeLogoColor4,
  ];

  @override
  void initState() {
    super.initState();
    cafeId = int.tryParse(ObjectFactory().prefs.getCafeId().toString());
    _promoController = TextEditingController(text: widget.card.moreInfo);
    selectedDays = List.from(widget.card.selectedDays);
  }

  String capitalizeFirstLetter(String text) {
    if (text.isEmpty) return text;
    return "${text[0].toUpperCase()}${text.substring(1).toLowerCase()}";
  }

  @override
  void didUpdateWidget(covariant ExpandableCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.card.promoText != oldWidget.card.promoText) {
      _promoController.text = widget.card.promoText;
    }
    if (!const DeepCollectionEquality().equals(
      widget.card.selectedDays,
      oldWidget.card.selectedDays,
    )) {
      setState(() {
        selectedDays = List.from(widget.card.selectedDays);
      });
    }
  }

  @override
  void dispose() {
    _promoController.dispose();
    super.dispose();
  }

  String _formatTime(String time) {
    final parsed = TimeOfDay(
      hour: int.parse(time.split(':')[0]),
      minute: int.parse(time.split(':')[1]),
    );
    final localizations = MaterialLocalizations.of(context);
    return localizations.formatTimeOfDay(parsed, alwaysUse24HourFormat: false);
  }

  Future<void> showUpgradePopup(BuildContext context) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const UpgradePopup(),
    );
  }

  Widget _buildCollapsedAttendeesButton(BuildContext context) {
    final card = widget.card;

    if (!card.hasBookings || card.attendees.isEmpty) {
      return const SizedBox.shrink();
    }

    return InkWell(
      onTap: () {
        context.push(
          '/attendees',
          extra: AttendeesArguments(
            tableId: card.id,
            tableTypeName: card.title,
            attendees: card.attendees,
            bookingDate: card.attendees.first.bookingDate?.toString(),
          ),
        );
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 14),
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          "View Attendees",
          style: GoogleFonts.montserrat(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final card = widget.card;

    return BlocBuilder<HomeBloc, HomeState>(
      builder: (context, state) {
        if (state is HomeLoaded) {
          EasyLoading.dismiss();
          final updatedCard = state.cards[widget.index];
          if (!const DeepCollectionEquality().equals(
            selectedDays,
            updatedCard.selectedDays,
          )) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                setState(() {
                  selectedDays = List<AvailableDay>.from(
                    updatedCard.selectedDays,
                  );
                });
              }
            });
          }
        }
        Widget content = AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.primaryWhiteColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                offset: Offset(0, 1),
                blurRadius: 1.0,
                spreadRadius: 1.0,
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: iconColor[widget.index],
                    radius: 30,
                    child: Image.asset('assets/png/solo_chair_3x.png'),
                  ),
                  const Gap(10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          card.title,
                          style: Theme.of(
                            context,
                          ).textTheme.labelMedium!.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                            fontSize: 18.sp,
                          ),
                        ),
                        if (card.subTitle != null)
                          Text(
                            card.subTitle!,
                            style: Theme.of(
                              context,
                            ).textTheme.labelMedium!.copyWith(
                              color: AppColors.shadowColor,
                              fontWeight: FontWeight.w500,
                              fontSize: 14.sp,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
              const Gap(10),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: Text(
                      card.description!.isNotEmpty
                          ? card.description!
                          : (card.description ?? 'No description available'),
                      style: Theme.of(context).textTheme.bodySmall!.copyWith(
                        color: AppColors.shadowColor,
                        fontWeight: FontWeight.w400,
                        fontSize: 11.sp,
                      ),
                      softWrap: true,
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap:
                        card.selectedDays.isNotEmpty
                            ? null
                            : () {
                              context.read<HomeBloc>().add(
                                ToggleCheckEvent(widget.index),
                              );
                            },
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.unSelectedColor,
                          width: 2,
                        ),
                        color: AppColors.unSelectedColor,
                      ),
                      child: Icon(
                        Icons.check,
                        size: 17,
                        color:
                            card.isSelected
                                ? AppColors.primary
                                : Colors.transparent,
                      ),
                    ),
                  ),
                ],
              ),
              const Gap(10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      card.isSelected && selectedDays.isNotEmpty
                          ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children:
                                (() {
                                  final dayOrder = {
                                    'mon': 1,
                                    'tue': 2,
                                    'wed': 3,
                                    'thu': 4,
                                    'fri': 5,
                                    'sat': 6,
                                    'sun': 7,
                                  };

                                  final sortedDays = [...selectedDays]..sort((
                                    a,
                                    b,
                                  ) {
                                    final orderA =
                                        dayOrder[a.day?.toLowerCase() ?? ''] ??
                                        99;
                                    final orderB =
                                        dayOrder[b.day?.toLowerCase() ?? ''] ??
                                        99;
                                    return orderA.compareTo(orderB);
                                  });

                                  List<Widget> displayWidgets = [];

                                  for (var d in sortedDays) {
                                    final timings = d.timings ?? [];
                                    // timings[0] = venue hours record (always present).
                                    // timings[1+] = user-configured event slots.
                                    // Show event slots only; fall back to timings[0]
                                    // if no event slots have been saved yet.
                                    final displayTimings =
                                        timings.length > 1
                                            ? timings.sublist(1)
                                            : timings;
                                    for (var t in displayTimings) {
                                      displayWidgets.add(
                                        Text(
                                          "${capitalizeFirstLetter(d.day ?? '')}: ${_formatTime(t.open)} - ${_formatTime(t.close)}",
                                          style: GoogleFonts.roboto(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w600,
                                            color: AppColors.shadowColor,
                                          ),
                                        ),
                                      );
                                    }
                                  }

                                  if (displayWidgets.isEmpty) {
                                    return [const SizedBox.shrink()];
                                  }

                                  return [
                                    Text(
                                      'Available',
                                      style: GoogleFonts.roboto(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    ...displayWidgets,
                                  ];
                                })(),
                          )
                          : const SizedBox.shrink(),
                    ],
                  ),
                ],
              ),
              if (!card.isExpanded)
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Gated View Attendees button
                      if (widget.card.hasBookings &&
                          widget.card.attendees.isNotEmpty)
                        BlocBuilder<PaymentPlanBloc, PaymentPlanState>(
                          builder: (context, paymentState) {
                            // ✅ Log debug info when building
                            print(paymentState.debugPremiumAccess());
                            // 🔑 KEY FIX: Premium users should NOT need upgrade
                            final bool hasPremiumAccess =
                                paymentState.premiumOverride ||
                                paymentState.canAccessPremiumFeatures;

                            // final bool needsUpgrade = !hasPremiumAccess;
                            final bool needsUpgrade = false;

                            return InkWell(
                              onTap: () {
                                if (needsUpgrade) {
                                  // Show upgrade popup
                                  showUpgradePopup(context);
                                } else {
                                  // Navigate to attendees
                                  context.push(
                                    '/attendees',
                                    extra: AttendeesArguments(
                                      tableId: widget.card.id,
                                      tableTypeName: widget.card.title,
                                      attendees: widget.card.attendees,
                                      bookingDate:
                                          widget
                                              .card
                                              .attendees
                                              .first
                                              .bookingDate
                                              ?.toString(),
                                    ),
                                  );
                                }
                              },
                              borderRadius: BorderRadius.circular(20),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 8,
                                  horizontal: 14,
                                ),
                                decoration: BoxDecoration(
                                  color:
                                      needsUpgrade
                                          ? AppColors.textPrimaryGrey
                                          : AppColors.primary,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    if (needsUpgrade)
                                      Padding(
                                        padding: const EdgeInsets.only(
                                          right: 6,
                                        ),
                                        child: Icon(
                                          Icons.lock_outline,
                                          size: 14,
                                          color: Colors.white,
                                        ),
                                      ),
                                    Text(
                                      "View Attendees",
                                      style: GoogleFonts.montserrat(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        )
                      else
                        const SizedBox.shrink(),

                      // Gated Edit button
                      BlocBuilder<PaymentPlanBloc, PaymentPlanState>(
                        builder: (context, paymentState) {
                          // ✅ Log debug info when building
                          print(paymentState.debugPremiumAccess());
                          // 🔑 KEY FIX: Premium users should NOT need upgrade
                          final bool hasPremiumAccess =
                              paymentState.premiumOverride ||
                              paymentState.canAccessPremiumFeatures;

                          final bool needsUpgrade = false; // TEMP: ungated for testing

                          // final bool needsUpgrade =
                          //    !hasPremiumAccess; // restore for production

                          return ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(13),
                                side: BorderSide(
                                  color:
                                      needsUpgrade
                                          ? AppColors.textPrimaryGrey
                                          : const Color(0xFF5B6369),
                                  width: 1,
                                ),
                              ),
                              backgroundColor:
                                  needsUpgrade
                                      ? AppColors.textPrimaryGrey.withOpacity(
                                        0.1,
                                      )
                                      : null,
                            ),
                            onPressed: () {
                              if (needsUpgrade) {
                                // Show upgrade popup
                                showUpgradePopup(context);
                              } else {
                                // Toggle expand as normal
                                context.read<HomeBloc>().add(
                                  ToggleExpandEvent(widget.index),
                                );
                              }
                            },
                            label: Text(
                              'Edit',
                              style: TextStyle(
                                fontSize: 9,
                                color:
                                    needsUpgrade
                                        ? AppColors.textPrimaryGrey
                                        : const Color(0xFF5B6369),
                              ),
                            ),
                            icon: Icon(
                              needsUpgrade ? Icons.lock_outline : Icons.edit,
                              size: 15,
                              color:
                                  needsUpgrade
                                      ? AppColors.textPrimaryGrey
                                      : const Color(0xFF5B6369),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              if (card.isExpanded) ...[
                Column(
                  children: [
                    const Gap(10),
                    TextField(
                      key: ValueKey('promoTextField_${card.id}'),
                      style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                        color: AppColors.timeTextColor,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                      controller: _promoController,
                      maxLines: 5,
                      keyboardType: TextInputType.text,
                      decoration: InputDecoration(
                        hintText: "Write your promo here",
                        filled: true,
                        fillColor: AppColors.primaryWhiteColor,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const Gap(10),
                    BlocBuilder<HomeBloc, HomeState>(
                      builder: (context, state) {
                        if (state is HomeLoaded) {
                          final card = state.cards[widget.index];
                          return AvailableDaysMultiSelectField(
                            tableTypeName: card.title,
                            availableDays: card.availableDays,
                            initialSelectedDays: card.selectedDays,
                            card: card,
                            cardIndex: widget.index,
                            onChanged: (days) {
                              setState(() => selectedDays = days);
                              context.read<HomeBloc>().add(
                                UpdateSelectedDaysEvent(widget.index, days),
                              );
                            },
                          );
                        }
                        return const SizedBox();
                      },
                    ),
                    const Gap(10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        if (widget.card.hasBookings &&
                            widget.card.attendees.isNotEmpty)
                          _buildAttendeesButton(context, state)
                        else
                          const SizedBox.shrink(),

                        _buildSaveButton(context, state),
                      ],
                    ),
                  ],
                ),
              ],
            ],
          ),
        );
        if (state is DiceTableUpdateLoading) {
          EasyLoading.show();
        }
        if (state is DiceTableUpdateLoaded &&
            state.response.message ==
                "Solo seater types updated successfully." &&
            state.response.status == true) {
          EasyLoading.dismiss();
          WidgetsBinding.instance.addPostFrameCallback((_) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Solo seater types updated successfully."),
                backgroundColor: AppColors.appGreenColor,
                duration: Duration(seconds: 2),
              ),
            );
          });
        }
        if (state is DiceTableUpdateError) {
          EasyLoading.dismiss();
          WidgetsBinding.instance.addPostFrameCallback((_) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage),
                backgroundColor: AppColors.appRedColor,
                duration: const Duration(seconds: 2),
              ),
            );
          });
        }

        return content;
      },
    );
  }

  Widget _buildAttendeesButton(BuildContext context, HomeState state) {
    if (state is! HomeLoaded) {
      return const SizedBox.shrink();
    }

    final currentCard = state.cards[widget.index];
    final hasAttendees =
        currentCard.hasBookings && currentCard.attendees.isNotEmpty;

    if (!hasAttendees) {
      return const SizedBox.shrink();
    }

    final firstAttendee = currentCard.attendees.first;

    return BlocBuilder<PaymentPlanBloc, PaymentPlanState>(
      builder: (context, paymentState) {
        // ✅ Log debug info when building
        print(paymentState.debugPremiumAccess());
        // 🔑 KEY FIX: Premium users should NOT need upgrade
        final bool hasPremiumAccess =
            paymentState.premiumOverride ||
            paymentState.canAccessPremiumFeatures;

        // final bool needsUpgrade = !hasPremiumAccess;
        final bool needsUpgrade = false;

        return InkWell(
          onTap: () {
            if (needsUpgrade) {
              showUpgradePopup(context);
            } else {
              context.push(
                '/attendees',
                extra: AttendeesArguments(
                  tableId: currentCard.id,
                  tableTypeName: currentCard.title,
                  attendees: currentCard.attendees,
                  bookingDate: firstAttendee.bookingDate?.toString(),
                ),
              );
            }
          },
          borderRadius: BorderRadius.circular(20),
          child: Container(
            height: 26.h,
            padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 9),
            decoration: BoxDecoration(
              color:
                  needsUpgrade ? AppColors.textPrimaryGrey : AppColors.primary,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color:
                      needsUpgrade
                          ? AppColors.textPrimaryGrey
                          : AppColors.primary,
                  blurRadius: 1,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (needsUpgrade)
                    Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: Icon(
                        Icons.lock_outline,
                        size: 12,
                        color: Colors.white,
                      ),
                    ),
                  Text(
                    'View Attendees',
                    style: GoogleFonts.montserrat(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSaveButton(BuildContext context, HomeState state) {
    final isDaysNotEmpty = selectedDays.isNotEmpty;

    return ElevatedButton.icon(
      onPressed:
          (state is DiceTableUpdateLoading || !isDaysNotEmpty)
              ? null
              : () {
                print('Selected days being sent: $selectedDays');

                context.read<HomeBloc>().add(
                  UpdatePromoTextEvent(widget.index, _promoController.text),
                );
                context.read<HomeBloc>().add(
                  UpdateAvailabilityTextEvent(
                    widget.index,
                    selectedDays.isEmpty
                        ? 'All Days'
                        : selectedDays
                            .map((d) {
                              final timings =
                                  (d.timings != null && d.timings!.isNotEmpty)
                                      ? d.timings!
                                      : [Timing(open: "10:00:00", close: "22:00:00")];
                              final displayTimings =
                                  timings.length > 1 ? timings.sublist(1) : timings;
                              final String slotsStr = displayTimings.map((t) {
                                String formatTime(String time) {
                                  try {
                                    final parsed = TimeOfDay(
                                      hour: int.parse(time.split(':')[0]),
                                      minute: int.parse(time.split(':')[1]),
                                    );
                                    final hour = parsed.hourOfPeriod == 0 ? 12 : parsed.hourOfPeriod;
                                    final period = parsed.period == DayPeriod.am ? 'AM' : 'PM';
                                    final minute = parsed.minute.toString().padLeft(2, '0');
                                    return '$hour:$minute $period';
                                  } catch (e) {
                                    return time;
                                  }
                                }
                                return "${formatTime(t.open)} - ${formatTime(t.close)}";
                              }).join(', ');
                              return "${capitalizeFirstLetter(d.day ?? '')}: $slotsStr";
                            })
                            .join(', '),
                  ),
                );
                context.read<HomeBloc>().add(
                  UpdateSelectedDaysEvent(widget.index, selectedDays),
                );
                context.read<HomeBloc>().add(ToggleExpandEvent(widget.index));

                final diceTableIds = [widget.card.id];
                final text = _promoController.text.trim();
                final moreInfos = (text.isNotEmpty) ? [text] : <String>[];

                final homeState = context.read<HomeBloc>().state;
                bool finalAlwaysAvailable = false;
                if (homeState is HomeLoaded) {
                  final updatedCard = homeState.cards[widget.index];
                  finalAlwaysAvailable = updatedCard.isAlwaysAvailable;
                }

                final allCafeDays = widget.card.availableDays;
                final selectedDayNames =
                    selectedDays.map((d) => d.day?.toLowerCase() ?? '').toSet();

                final List<AvailableDay> availableDaysForApi =
                    allCafeDays.map((cafeDay) {
                      final dayName = cafeDay.day?.toLowerCase() ?? '';
                      final isSelected = selectedDayNames.contains(dayName);

                      if (isSelected) {
                        final selectedDay = selectedDays.firstWhere(
                          (d) => d.day?.toLowerCase() == dayName,
                        );

                        final timings =
                            (selectedDay.timings != null &&
                                    selectedDay.timings!.isNotEmpty)
                                ? selectedDay.timings!
                                : [Timing(open: "10:00:00", close: "22:00:00")];

                        return AvailableDay(
                          id: cafeDay.id ?? 0,
                          day: cafeDay.day ?? '',
                          timings: timings,
                          isOpen: true,
                        );
                      } else {
                        final defaultTimings =
                            (cafeDay.timings != null &&
                                    cafeDay.timings!.isNotEmpty)
                                ? cafeDay.timings!
                                : [Timing(open: "10:00:00", close: "22:00:00")];

                        return AvailableDay(
                          id: cafeDay.id ?? 0,
                          day: cafeDay.day ?? '',
                          timings: defaultTimings,
                          isOpen: false,
                        );
                      }
                    }).toList();

                print('📤 Sending to API:');
                print('  always_available: $finalAlwaysAvailable');
                for (var day in availableDaysForApi) {
                  print(
                    '  ${day.day}: is_open=${day.isOpen}, timings=${day.timings?.length}',
                  );
                }

                context.read<HomeBloc>().add(
                  DiceTableUpdateEvent(
                    diceTableTypeUpdateRequest: DiceTableTypeUpdateRequest(
                      cafeId: cafeId!,
                      diceTableId: diceTableIds,
                      moreInfo: moreInfos,
                      availableDays: availableDaysForApi,
                      alwaysAvailable: finalAlwaysAvailable,
                    ),
                  ),
                );
              },
      label: const Text(
        'Save',
        style: TextStyle(fontSize: 9, color: Colors.blueGrey),
      ),
      icon: const Icon(Icons.save, size: 15),
    );
  }
}
// Replace your existing AvailableDaysMultiSelectField class with this updated version

class AvailableDaysMultiSelectField extends StatefulWidget {
  final List<AvailableDay> availableDays;
  final ValueChanged<List<AvailableDay>>? onChanged;
  final List<AvailableDay>? initialSelectedDays;
  final String? tableTypeName; // Add this for displaying table type
  final CardModel? card;
  final int cardIndex;

  const AvailableDaysMultiSelectField({
    required this.availableDays,
    this.onChanged,
    this.initialSelectedDays,
    this.tableTypeName,
    this.card,
    required this.cardIndex,
    super.key,
  });

  @override
  State<AvailableDaysMultiSelectField> createState() =>
      _AvailableDaysMultiSelectFieldState();
}

class _AvailableDaysMultiSelectFieldState
    extends State<AvailableDaysMultiSelectField> {
  List<AvailableDay> selectedDays = [];

  @override
  void initState() {
    super.initState();
    selectedDays = List<AvailableDay>.from(widget.initialSelectedDays ?? []);
  }

  @override
  void didUpdateWidget(covariant AvailableDaysMultiSelectField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialSelectedDays != oldWidget.initialSelectedDays) {
      setState(() {
        selectedDays = List<AvailableDay>.from(
          widget.initialSelectedDays ?? [],
        );
      });
    }
  }

  // Replace the selectedDaysText getter in _AvailableDaysMultiSelectFieldState class

  String _formatTime(String time) {
    try {
      final parsed = TimeOfDay(
        hour: int.parse(time.split(':')[0]),
        minute: int.parse(time.split(':')[1]),
      );
      // Simple 12-hour format
      final hour = parsed.hourOfPeriod == 0 ? 12 : parsed.hourOfPeriod;
      final period = parsed.period == DayPeriod.am ? 'AM' : 'PM';
      final minute = parsed.minute.toString().padLeft(2, '0');
      return '$hour:$minute $period';
    } catch (e) {
      return time;
    }
  }

  String get selectedDaysText {
    if (selectedDays.isEmpty) return "Select Available Days";

    final dayOrder = {
      'mon': 1,
      'tue': 2,
      'wed': 3,
      'thu': 4,
      'fri': 5,
      'sat': 6,
      'sun': 7,
    };

    final sortedDays = [...selectedDays]..sort((a, b) {
      final orderA = dayOrder[a.day?.toLowerCase() ?? ''] ?? 99;
      final orderB = dayOrder[b.day?.toLowerCase() ?? ''] ?? 99;
      return orderA.compareTo(orderB);
    });

    final List<String> lines = [];

    for (final d in sortedDays) {
      final timings =
          (d.timings != null && d.timings!.isNotEmpty)
              ? d.timings!
              : [Timing(open: "10:00:00", close: "22:00:00")];

      // ✅ Show event slots only; fall back to timings[0] if no event slots saved
      final displayTimings = timings.length > 1 ? timings.sublist(1) : timings;

      final slots = displayTimings
          .map((t) => "${_formatTime(t.open)} - ${_formatTime(t.close)}")
          .join(', ');

      lines.add("${capitalizeFirstLetter(d.day ?? '')}: $slots");
    }

    return lines.isEmpty ? "Select Available Days" : lines.join('\n');
  }

  String capitalizeFirstLetter(String text) {
    if (text.isEmpty) return text;
    return "${text[0].toUpperCase()}${text.substring(1).toLowerCase()}";
  }

  Future<void> _showEnhancedDialog() async {
    // ✅ Get the CURRENT card from BLoC using the index
    final homeState = context.read<HomeBloc>().state;
    bool currentAlwaysAvailable = false;
    CardModel? currentCard;

    if (homeState is HomeLoaded) {
      currentCard = homeState.cards[widget.cardIndex]; // ✅ Use index directly
      currentAlwaysAvailable = currentCard.isAlwaysAvailable;
      print(
        '🔍 Opening dialog for "${currentCard.title}" (index=${widget.cardIndex}): isAlwaysAvailable=$currentAlwaysAvailable',
      );
    }

    // ✅ Updated to expect a Map result instead of List<AvailableDay>
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) {
        return EnhancedAvailableDaysDialog(
          availableDays: widget.availableDays,
          initialSelectedDays: selectedDays,
          tableTypeName: widget.tableTypeName ?? "Business Networking",
          initiallyAlwaysAvailable: currentAlwaysAvailable,
        );
      },
    );

    if (result != null) {
      // ✅ Extract returned data safely
      final selectedDaysResult = (result['days'] as List<AvailableDay>?) ?? [];
      final isAlwaysAvailable = result['alwaysAvailable'] as bool? ?? false;

      setState(() {
        selectedDays = selectedDaysResult;
      });

      // Notify parent immediately (if any listener provided)
      Future.microtask(() {
        widget.onChanged?.call(selectedDays);
      });

      // ✅ Correct: using index for Bloc event
      if (currentCard != null) {
        print(
          '💾 Dispatching UpdateAlwaysAvailableEvent for card index=${widget.cardIndex}, value=$isAlwaysAvailable',
        );
        context.read<HomeBloc>().add(
          UpdateAlwaysAvailableEvent(widget.cardIndex, isAlwaysAvailable),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _showEnhancedDialog,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start, // ✅ Important
          children: [
            Expanded(
              child: Text(
                selectedDaysText,
                style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                  color: AppColors.timeTextColor,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
                softWrap: true,
                maxLines: null, // ✅ allow multiple lines
              ),
            ),
            Align(
              alignment: Alignment.topRight, // ✅ Fix position
              child: const Icon(Icons.arrow_drop_down),
            ),
          ],
        ),
      ),
    );
  }
}

String capitalizeFirstLetter(String text) {
  if (text.isEmpty) return text;
  return "${text[0].toUpperCase()}${text.substring(1).toLowerCase()}";
}
