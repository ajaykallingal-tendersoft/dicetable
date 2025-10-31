import 'package:collection/collection.dart';
import 'package:go_router/go_router.dart';
import 'package:soloseaters/src/constants/app_colors.dart';
import 'package:soloseaters/src/model/cafe_owner/home/available_days.dart';
import 'package:soloseaters/src/model/cafe_owner/home/dice_table_update_request.dart'
    show DiceTableTypeUpdateRequest;
import 'package:soloseaters/src/ui/cafe_owner/home/bloc/home_bloc.dart';
import 'package:soloseaters/src/ui/cafe_owner/home/model/card_item.dart';
import 'package:soloseaters/src/ui/cafe_owner/home/widget/enhanced_available_days_dialog.dart';
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
  List<AvailableDay> selectedDays = []; // Local state for selected days
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
                            ? null // disable unchecking once event exists
                            : () {
                              context.read<HomeBloc>().add(
                                ToggleCheckEvent(widget.index),
                              );
                            },
                    // onTap: () {

                    // context.read<HomeBloc>().add(
                    //   ToggleCheckEvent(widget.index),
                    // );
                    // },
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
                      Text(
                        "Available",
                        style: GoogleFonts.roboto(
                          fontSize: 12,
                          fontWeight: FontWeight.normal,
                          color: AppColors.shadowColor,
                        ),
                      ),
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

                                  final sortedDays = [...selectedDays]..sort(
                                    (a, b) => dayOrder[a.day!.toLowerCase()]!
                                        .compareTo(
                                          dayOrder[b.day!.toLowerCase()]!,
                                        ),
                                  );
                                  return sortedDays.map((d) {
                                    final customTimings =
                                        (d.timings ?? []).where((t) {
                                          // Hide default slot if any custom slot exists
                                          final isDefault =
                                              t.open == "10:00:00" &&
                                              t.close == "22:00:00";
                                          final hasCustom = (d.timings ?? [])
                                              .any(
                                                (x) =>
                                                    !(x.open == "10:00:00" &&
                                                        x.close == "22:00:00"),
                                              );
                                          return hasCustom ? !isDefault : true;
                                        }).toList();
                                    // final firstTiming =
                                    //     (d.timings != null &&
                                    //             d.timings!.isNotEmpty)
                                    //         ? d.timings!.first
                                    //         : Timing(
                                    //           open: "10:00:00",
                                    //           close: "22:00:00",
                                    //         );

                                    // String open = firstTiming.open;
                                    // String close = firstTiming.close;
                                    return Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children:
                                          customTimings.map((t) {
                                            return Text(
                                              "${capitalizeFirstLetter(d.day ?? '')}: ${_formatTime(t.open)} - ${_formatTime(t.close)}",

                                              // "${capitalizeFirstLetter(d.day ?? '')}: ${t.open} - ${t.close}",
                                              style: GoogleFonts.roboto(
                                                fontSize: 10,
                                                fontWeight: FontWeight.w600,
                                                color: AppColors.shadowColor,
                                              ),
                                            );
                                          }).toList(),
                                    );

                                    // return Text(
                                    //   "${capitalizeFirstLetter(d.day ?? '')}: $open - $close",
                                    //   style: GoogleFonts.roboto(
                                    //     fontSize: 10,
                                    //     fontWeight: FontWeight.w600,
                                    //     color: AppColors.shadowColor,
                                    //   ),
                                    // );
                                  }).toList();
                                })(),
                          )
                          : const SizedBox.shrink(),
                    ],
                  ),
                  !card.isExpanded
                      ? ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(13),
                            side: const BorderSide(
                              color: Color(0xFF5B6369),
                              width: 1,
                            ),
                          ),
                        ),
                        onPressed: () {
                          context.read<HomeBloc>().add(
                            ToggleExpandEvent(widget.index),
                          );
                        },
                        label: const Text(
                          'Edit',
                          style: TextStyle(
                            fontSize: 9,
                            color: Color(0xFF5B6369),
                          ),
                        ),
                        icon: const Icon(
                          Icons.edit,
                          size: 15,
                          color: Color(0xFF5B6369),
                        ),
                      )
                      : const SizedBox(),
                ],
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
                        if (state is HomeLoading) {
                          EasyLoading.show();
                        }
                        if (state is HomeLoaded) {
                          EasyLoading.dismiss();
                          final card = state.cards[widget.index];
                          return AvailableDaysMultiSelectField(
                            tableTypeName: card.title,
                            availableDays: card.availableDays,
                            initialSelectedDays: card.selectedDays,
                            onChanged: (days) {
                              setState(() {
                                selectedDays = days;
                              });
                              context.read<HomeBloc>().add(
                                UpdateSelectedDaysEvent(widget.index, days),
                              );
                            },
                          );
                        }
                        return SizedBox();
                      },
                    ),
                    const Gap(10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildAttendeesButton(context),
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

  ///Attendees Button
  Widget _buildAttendeesButton(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        context.push('/attendees');
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      child: Text(
        'View Attendees',
        style: GoogleFonts.montserrat(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildSaveButton(BuildContext context, HomeState state) {
    final isPromoNotEmpty = _promoController.text.trim().isNotEmpty;
    final isDaysNotEmpty = selectedDays.isNotEmpty;

    return ElevatedButton.icon(
      onPressed:
          (state is DiceTableUpdateLoading ||
                  !isPromoNotEmpty ||
                  !isDaysNotEmpty)
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
                              final firstTiming =
                                  (d.timings != null && d.timings!.isNotEmpty)
                                      ? d.timings!.first
                                      : Timing(
                                        open: "10:00:00",
                                        close: "22:00:00",
                                      );
                              return "${d.day}: ${firstTiming.open}-${firstTiming.close}";
                            })
                            .join(', '),
                  ),
                );
                context.read<HomeBloc>().add(
                  UpdateSelectedDaysEvent(widget.index, selectedDays),
                );
                context.read<HomeBloc>().add(ToggleExpandEvent(widget.index));

                final diceTableIds = [widget.card.id];
                final moreInfos = [_promoController.text];
                //New chnage
                final List<AvailableDay> availableDaysSelectedForApi =
                    selectedDays.map((day) {
                      final timings =
                          (day.timings != null && day.timings!.isNotEmpty)
                              ? day.timings!
                              : [Timing(open: "10:00:00", close: "22:00:00")];

                      return AvailableDay(
                        id: day.id ?? 0,
                        day: day.day ?? '',
                        timings:
                            timings, // ✅ use full list (supports multiple slots)
                        isOpen: true,
                      );
                    }).toList();

                context.read<HomeBloc>().add(
                  DiceTableUpdateEvent(
                    diceTableTypeUpdateRequest: DiceTableTypeUpdateRequest(
                      cafeId: cafeId!,
                      diceTableId: diceTableIds,
                      moreInfo: moreInfos,
                      availableDays: availableDaysSelectedForApi,
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

  const AvailableDaysMultiSelectField({
    required this.availableDays,
    this.onChanged,
    this.initialSelectedDays,
    this.tableTypeName,
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

  String get selectedDaysText {
    if (selectedDays.isEmpty) return "";
    return selectedDays
        .map((d) {
          final firstTiming =
              (d.timings != null && d.timings!.isNotEmpty)
                  ? d.timings!.first
                  : Timing(open: "10:00:00", close: "22:00:00");

          final open = firstTiming.open;
          final close = firstTiming.close;

          return "${capitalizeFirstLetter(d.day!)}: $open-$close";
        })
        .join(', ');
  }

  String capitalizeFirstLetter(String text) {
    if (text.isEmpty) return text;
    return "${text[0].toUpperCase()}${text.substring(1).toLowerCase()}";
  }

  Future<void> _showEnhancedDialog() async {
    final result = await showDialog<List<AvailableDay>>(
      context: context,
      builder: (context) {
        return EnhancedAvailableDaysDialog(
          availableDays: widget.availableDays, // ✅ Pass your full week list
          initialSelectedDays: selectedDays, // ✅ Preload previously chosen days
          tableTypeName:
              widget.tableTypeName ?? "Business Networking", // optional
        );
      },
    );

    if (result != null && result.isNotEmpty) {
      setState(() {
        selectedDays = result; // ✅ Already includes timings list
      });

      // ✅ Notify parent (BLoC / callback)
      Future.microtask(() {
        widget.onChanged?.call(selectedDays);
      });
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
          children: [
            Expanded(
              child: Text(
                selectedDaysText,
                style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                  color: AppColors.timeTextColor,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const Icon(Icons.arrow_drop_down),
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
