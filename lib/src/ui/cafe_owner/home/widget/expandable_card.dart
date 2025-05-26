import 'package:dicetable/src/constants/app_colors.dart';
import 'package:dicetable/src/model/cafe_owner/home/available_days.dart';
import 'package:dicetable/src/model/cafe_owner/home/dice_table_update_request.dart' show DiceTableTypeUpdateRequest;
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
  List<AvailableDay> selectedDays = [];
  late int? cafeId;

  @override
  void initState() {
    super.initState();
    cafeId = int.tryParse(ObjectFactory().prefs.getCafeId().toString());
    // Assign selectedDays with a List<AvailableDay>
    if (widget.card.selectedDays.isNotEmpty) {
      selectedDays = List<AvailableDay>.from(widget.card.selectedDays);
    } else if (widget.card.availableDays.isNotEmpty) {
      // Default to first available day if nothing is selected
      selectedDays = [widget.card.availableDays.first];
    } else {
      selectedDays = [];
    }

    final initialPromo = widget.card.promoText.isNotEmpty
        ? widget.card.promoText
        : (widget.card.description ?? '');
    _promoController = TextEditingController(text: initialPromo);
  }

  @override
  void didUpdateWidget(covariant ExpandableCard oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Update selectedDays if changed in the card
    if (widget.card.selectedDays != oldWidget.card.selectedDays) {
      setState(() {
        if (widget.card.selectedDays.isNotEmpty) {
          selectedDays = List<AvailableDay>.from(widget.card.selectedDays);
        } else if (widget.card.availableDays.isNotEmpty) {
          selectedDays = [widget.card.availableDays.first];
        } else {
          selectedDays = [];
        }
      });
    }

    // Update promo controller text if promo text changed
    if (widget.card.promoText != oldWidget.card.promoText ||
        widget.card.description != oldWidget.card.description) {
      _promoController.text = widget.card.promoText.isNotEmpty
          ? widget.card.promoText
          : (widget.card.description ?? '');
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
        if (state is HomeLoaded) {
          final updatedCard = state.cards[widget.index];
          if (updatedCard.selectedDays != selectedDays) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) { // Check if widget is still mounted
                setState(() {
                  selectedDays = List<AvailableDay>.from(updatedCard.selectedDays.isNotEmpty
                      ? updatedCard.selectedDays
                      : (updatedCard.availableDays.isNotEmpty
                      ? [updatedCard.availableDays.first]
                      : []));
                });
              }
            });
          }
        }

        // Default card content
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
                          style: TextTheme.of(context).labelMedium!.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                            fontSize: 18.sp,
                          ),
                        ),
                        if (card.subTitle != null)
                          Text(
                            card.subTitle!,
                            style: TextTheme.of(context).labelMedium!.copyWith(
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
                      style: TextTheme.of(context).bodySmall!.copyWith(
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
                      context.read<HomeBloc>().add(ToggleCheckEvent(widget.index));
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
                        color: card.isSelected ? AppColors.primary : Colors.transparent,
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
                      selectedDays.isEmpty
                          ? Text(
                        'Not selected',
                        style: GoogleFonts.roboto(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: AppColors.shadowColor,
                        ),
                      )
                          : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: selectedDays.map((d) {
                          String? open = d.openTime!.length >= 5
                              ? d.openTime!.substring(0, 5)
                              : d.openTime;
                          String? close = d.closeTime!.length >= 5
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
                      style: TextStyle(fontSize: 9, color: Color(0xFF5B6369)),
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
                const Gap(10),
                TextField(
                  style: TextTheme.of(context).bodyMedium!.copyWith(
                    color: AppColors.timeTextColor,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                  key: const ValueKey("expandedPromoTextField"),
                  controller: _promoController,
                  maxLines: 5,
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
                AvailableDaysMultiSelectField(
                  availableDays: widget.card.availableDays,
                  initialSelectedDays: selectedDays, // Pass updated selectedDays
                  onChanged: (days) {
                    setState(() {
                      selectedDays = days;
                    });
                  },
                ),
                const Gap(10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    _buildSaveButton(context, state),
                  ],
                ),
              ]
            ],
          ),
        );

        // Handle loading state
        if (state is DiceTableUpdateLoading) {
          return Stack(
            children: [
              content,
              const Center(
                child: CircularProgressIndicator(),
              ),
            ],
          );
        }

        // Handle success state
        if (state is DiceTableUpdateLoaded &&
            state.response.message == "Dice table types updated successfully." &&
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

        // Handle error state
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
    return ElevatedButton.icon(
      onPressed: state is DiceTableUpdateLoading
          ? null // Disable button during loading
          : () {
        context.read<HomeBloc>().add(
          UpdatePromoTextEvent(widget.index, _promoController.text),
        );
        context.read<HomeBloc>().add(
          UpdateAvailabilityTextEvent(
            widget.index,
            selectedDays
                .map((d) => "${d.day}: ${d.openTime}-${d.closeTime}")
                .join(', '),
          ),
        );
        context.read<HomeBloc>().add(
          UpdateSelectedDaysEvent(widget.index, selectedDays),
        );
        context.read<HomeBloc>().add(
          ToggleExpandEvent(widget.index),
        );
        final diceTableIds = [widget.card.id];
        final moreInfos = [_promoController.text];
        final availableDaysSelected = selectedDays;

        context.read<HomeBloc>().add(
          DiceTableUpdateEvent(
            diceTableTypeUpdateRequest: DiceTableTypeUpdateRequest(
              cafeId: cafeId!,
              diceTableId: diceTableIds,
              moreInfo: moreInfos,
              availableDays: availableDaysSelected,
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
  final List<AvailableDay>? initialSelectedDays; // Added to receive initial selection

  const AvailableDaysMultiSelectField({
    required this.availableDays,
    this.onChanged,
    this.initialSelectedDays, // Added parameter
    super.key,
  });

  @override
  State<AvailableDaysMultiSelectField> createState() => _AvailableDaysMultiSelectFieldState();
}

class _AvailableDaysMultiSelectFieldState extends State<AvailableDaysMultiSelectField> {
  List<AvailableDay> selectedDays = [];

  @override
  void initState() {
    super.initState();
    // Initialize selectedDays with initialSelectedDays if provided
    if (widget.initialSelectedDays != null && widget.initialSelectedDays!.isNotEmpty) {
      selectedDays = List<AvailableDay>.from(widget.initialSelectedDays!);
    }
  }

  String get selectedDaysText {
    if (selectedDays.isEmpty) return "Select Available Days";
    return selectedDays
        .map((d) {
      String? open = d.openTime!.length >= 5 ? d.openTime!.substring(0, 5) : d.openTime;
      String? close = d.closeTime!.length >= 5 ? d.closeTime!.substring(0, 5) : d.closeTime;
      return "${d.day}: $open-$close";
    })
        .join(', ');
  }

  Future<void> _showMultiSelectDialog() async {
    final List<AvailableDay> tempSelected = List.from(selectedDays);

    final result = await showDialog<List<AvailableDay>>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.primaryWhiteColor,
          title: Text(
            'Select Available Days',
            style: TextTheme.of(context).bodyMedium!.copyWith(
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
                        final isChecked = tempSelected.contains(day);
                        return CheckboxListTile(
                          title: Text(
                            "${day.day}: ${day.openTime} - ${day.closeTime}",
                            style: TextTheme.of(context).bodySmall!.copyWith(
                              color: AppColors.textPrimaryGrey,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          value: isChecked,
                          onChanged: (checked) {
                            setModalState(() {
                              if (checked == true) {
                                tempSelected.add(day);
                              } else {
                                tempSelected.remove(day);
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
              child: Text(
                'Cancel',
                style: TextTheme.of(context).bodyMedium!.copyWith(
                  color: AppColors.primary,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              onPressed: () => Navigator.pop(context, null),
            ),
            ElevatedButton(
              child: Text(
                'Done',
                style: TextTheme.of(context).bodyMedium!.copyWith(
                  color: AppColors.primary,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              onPressed: () => Navigator.pop(context, tempSelected),
            ),
          ],
        );
      },
    );

    if (result != null) {
      setState(() {
        selectedDays = result;
      });
      if (widget.onChanged != null) {
        widget.onChanged!(selectedDays);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      style: TextTheme.of(context).bodyMedium!.copyWith(
        color: AppColors.timeTextColor,
        fontSize: 13,
        fontWeight: FontWeight.w500,
      ),
      readOnly: true,
      controller: TextEditingController(text: selectedDaysText),
      decoration: InputDecoration(
        hintText: "Select Available Days",
        // filled: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        suffixIcon: const Icon(Icons.arrow_drop_down),
      ),
      onTap: _showMultiSelectDialog,
    );
  }
}

