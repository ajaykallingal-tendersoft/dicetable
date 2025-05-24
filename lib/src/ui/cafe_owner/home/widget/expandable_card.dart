import 'package:collection/collection.dart';
import 'package:dicetable/src/constants/app_colors.dart';
import 'package:dicetable/src/model/cafe_owner/home/available_days.dart';
import 'package:dicetable/src/model/cafe_owner/home/dice_table_update_request.dart'
    show DiceTableTypeUpdateRequest;
import 'package:dicetable/src/ui/cafe_owner/home/bloc/home_bloc.dart';
import 'package:dicetable/src/ui/cafe_owner/home/model/card_item.dart';
import 'package:dicetable/src/utils/data/object_factory.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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

  @override
  void initState() {
    super.initState();
    cafeId = int.tryParse(ObjectFactory().prefs.getCafeId().toString());
    _promoController = TextEditingController(text: widget.card.promoText);
    // Initialize selectedDays with the CardModel's API-fetched selectedDays.
    // This is the starting point for the editable selection within this card.
    selectedDays = List.from(widget.card.selectedDays);
  }

  @override
  void didUpdateWidget(covariant ExpandableCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Update promo text controller if the card's promo text changes externally
    if (widget.card.promoText != oldWidget.card.promoText) {
      _promoController.text = widget.card.promoText;
    }
    // IMPORTANT: Update local selectedDays only if the underlying card data has changed
    // from the parent (which happens after an API refresh).
    // Since AvailableDay now has proper `==` and `hashCode`, List equality check is easier.
    // However, `List<T>.==` only checks reference. For content, use `const DeepCollectionEquality().equals`.
    // Or, simpler, just check if the lists are different lengths or contain different elements.
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

  @override
  Widget build(BuildContext context) {
    final card = widget.card;

    return BlocBuilder<HomeBloc, HomeState>(
      builder: (context, state) {
        // Update selectedDays when HomeLoaded state provides new CardModel data
        // This is necessary to reflect the API's latest selections after an update
        if (state is HomeLoaded) {
          final updatedCard = state.cards[widget.index];
          // After HomeLoaded, update the local selectedDays to reflect the API's current truth.
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
                    backgroundColor: Colors.blue.shade900,
                    radius: 30,
                    child: Image.asset('assets/png/dice-type.png'),
                  ),
                  const Gap(10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          card.title,
                          style: Theme
                              .of(
                            context,
                          )
                              .textTheme
                              .labelMedium!
                              .copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                            fontSize: 18.sp,
                          ),
                        ),
                        if (card.subTitle != null)
                          Text(
                            card.subTitle!,
                            style: Theme
                                .of(
                              context,
                            )
                                .textTheme
                                .labelMedium!
                                .copyWith(
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
                      card.promoText.isNotEmpty
                          ? card.promoText
                          : (card.description ?? 'No description available'),
                      style: Theme
                          .of(context)
                          .textTheme
                          .bodySmall!
                          .copyWith(
                        color: AppColors.shadowColor,
                        fontWeight: FontWeight.w400,
                        fontSize: 11.sp,
                      ),
                      softWrap: true,
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () {
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
                        card
                            .isSelected // Use card.isSelected from the model
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
                      // Conditional display based on card.isSelected
                      card.isSelected && selectedDays.isNotEmpty
                          ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children:
                        selectedDays.map((d) {
                          String? open =
                          d.openTime!.length >= 5
                              ? d.openTime!.substring(0, 5)
                              : d.openTime;
                          String? close =
                          d.closeTime!.length >= 5
                              ? d.closeTime!.substring(0, 5)
                              : d.closeTime;
                          return Text(
                            "${d.day}: $open - $close",
                            style: GoogleFonts.roboto(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: AppColors.shadowColor,
                            ),
                          );
                        }).toList(),
                      )
                          : Text(
                        'All days', // Display "All days" if not selected
                        style: GoogleFonts.roboto(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: AppColors.shadowColor,
                        ),
                      ),
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
                  // Wrap expanded content in a Column
                  children: [
                    const Gap(10),
                    TextField(

                      key: ValueKey('promoTextField_${card.id}'),
                      // <--- CRITICAL for focus
                      style: Theme
                          .of(context)
                          .textTheme
                          .bodyMedium!
                          .copyWith(
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
                            availableDays: card.availableDays,
                            initialSelectedDays: card.selectedDays,
                            onChanged: (days) {
                              setState(() {
                                selectedDays = days;
                              });
                              context.read<HomeBloc>().add(UpdateSelectedDaysEvent(widget.index, days));
                            },
                          );
                        }
                        return CircularProgressIndicator();
                      },
                    ),
                    const Gap(10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [_buildSaveButton(context, state)],
                    ),
                  ],
                ),
              ],
            ],
          ),
        );
        if (state is DiceTableUpdateLoading) {
          return Stack(
            children: [
              content,
              const Center(child: CircularProgressIndicator()),
            ],
          );
        }
        if (state is DiceTableUpdateLoaded &&
            state.response.message ==
                "Dice table types updated successfully." &&
            state.response.status == true) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Dice table updated successfully!"),
                backgroundColor: Colors.green,
                duration: Duration(seconds: 2),
              ),
            );
          });
        }
        if (state is DiceTableUpdateError) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage),
                backgroundColor: Colors.red,
                duration: const Duration(seconds: 2),
              ),
            );
          });
        }

        return content;
      },
    );
  }

  Widget _buildSaveButton(BuildContext context, HomeState state) {
    final isPromoNotEmpty = _promoController.text
        .trim()
        .isNotEmpty;
    final isDaysNotEmpty = selectedDays.isNotEmpty;

    return ElevatedButton.icon(
      onPressed: (state is DiceTableUpdateLoading || !isPromoNotEmpty ||
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
                ? 'All days'
                : selectedDays
                .map((d) => "${d.day}: ${d.openTime}-${d.closeTime}")
                .join(', '),
          ),
        );
        context.read<HomeBloc>().add(
          UpdateSelectedDaysEvent(widget.index, selectedDays),
        );
        context.read<HomeBloc>().add(ToggleExpandEvent(widget.index));

        final diceTableIds = [widget.card.id];
        final moreInfos = [_promoController.text];
        final availableDaysSelectedForApi = selectedDays;

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

class AvailableDaysMultiSelectField extends StatefulWidget {
  final List<AvailableDay> availableDays;
  final ValueChanged<List<AvailableDay>>? onChanged;
  final List<AvailableDay>? initialSelectedDays;

  const AvailableDaysMultiSelectField({
    required this.availableDays,
    this.onChanged,
    this.initialSelectedDays,
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
    // Only update if the reference changes (use DeepCollectionEquality for deep check if needed)
    if (widget.initialSelectedDays != oldWidget.initialSelectedDays) {
      setState(() {
        selectedDays = List<AvailableDay>.from(widget.initialSelectedDays ?? []);
      });
    }
  }

  String get selectedDaysText {
    if (selectedDays.isEmpty) return "Select Available Days";
    return selectedDays
        .map((d) {
      final open = d.openTime?.substring(0, 5) ?? "";
      final close = d.closeTime?.substring(0, 5) ?? "";
      return "${d.day}: $open-$close";
    })
        .join(', ');
  }

  Future<void> _showMultiSelectDialog() async {
    List<AvailableDay> tempSelected = List.from(selectedDays);

    final result = await showDialog<List<AvailableDay>>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.primaryWhiteColor,
          title: Text(
            'Select Available Days',
            style: Theme.of(context).textTheme.bodyMedium!.copyWith(
              color: AppColors.primary,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: StatefulBuilder(
              builder: (context, setModalState) {
                return SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ...widget.availableDays.map((day) {
                        final isChecked = tempSelected.any((d) => d.day == day.day);
                        return CheckboxListTile(
                          title: Text(
                            "${day.day}: ${day.openTime} - ${day.closeTime}",
                            style: Theme.of(context).textTheme.bodySmall!.copyWith(
                              color: AppColors.textPrimaryGrey,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          value: isChecked,
                          onChanged: (checked) {
                            setModalState(() {
                              if (checked == true) {
                                if (!tempSelected.any((d) => d.day == day.day)) {
                                  tempSelected.add(day);
                                }
                              } else {
                                tempSelected.removeWhere((d) => d.day == day.day);
                              }
                            });
                          },
                        );
                      }).toList(),
                    ],
                  ),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, null), // Cancel returns null
              child: Text(
                'Cancel',
                style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                  color: AppColors.primary,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, tempSelected); // Done returns selection
              },
              child: Text(
                'Done',
                style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                  color: AppColors.primary,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );

    if (result != null) {
      setState(() {
        selectedDays = result;
      });

      Future.microtask(() {
        if (widget.onChanged != null) {
          widget.onChanged!(selectedDays);
        }
      });
      // if (widget.onChanged != null) {
      //   widget.onChanged!(selectedDays);
      // }
    }
    // If result is null (Cancel), do nothing
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _showMultiSelectDialog,
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

