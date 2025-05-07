import 'package:dicetable/src/constants/app_colors.dart';
import 'package:dicetable/src/ui/cafe_owner/home/bloc/card_cubit.dart';
import 'package:dicetable/src/ui/cafe_owner/home/model/card_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';

class ExpandableCard extends StatefulWidget {
  final int index;
  final CardItem card;

  const ExpandableCard({super.key, required this.index, required this.card});

  @override
  State<ExpandableCard> createState() => _ExpandableCardState();
}

class _ExpandableCardState extends State<ExpandableCard> {
  late TextEditingController _promoController;
  late TextEditingController _availabilityController;

  @override
  void initState() {
    super.initState();
    final initialAvailability =
        widget.card.editedAvailabilityText.isNotEmpty
            ? widget.card.editedAvailabilityText
            : widget.card.initialAvailabilityText;
    _availabilityController = TextEditingController(text: initialAvailability);
    final initialPromo =
        widget.card.editedPromoText.isNotEmpty
            ? widget.card.editedPromoText
            : widget.card.initialPromoText;
    _promoController = TextEditingController(text: initialPromo);
  }

  @override
  void didUpdateWidget(covariant ExpandableCard oldWidget) {
    if (widget.card.editedAvailabilityText !=
            oldWidget.card.editedAvailabilityText ||
        widget.card.initialAvailabilityText !=
            oldWidget.card.initialAvailabilityText) {
      _availabilityController.text =
          widget.card.editedAvailabilityText.isNotEmpty
              ? widget.card.editedAvailabilityText
              : widget.card.initialAvailabilityText;
    }
    if (widget.card.editedPromoText != oldWidget.card.editedPromoText ||
        widget.card.initialPromoText != oldWidget.card.initialPromoText) {
      _promoController.text =
          widget.card.editedPromoText.isNotEmpty
              ? widget.card.editedPromoText
              : widget.card.initialPromoText;
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    final card = widget.card;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primaryWhiteColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            offset: Offset(0, 1), // Horizontal and vertical offsets
            blurRadius: 1.0, // Softness of the shadow
            spreadRadius: 1.0, // Extent of the shadow
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
                    Text(
                      card.subtitle,
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
                  card.editedPromoText.isNotEmpty
                      ? card.editedPromoText
                      : card.initialPromoText,
                  style: TextTheme.of(context).bodySmall!.copyWith(
                    color: AppColors.shadowColor,
                    fontWeight: FontWeight.w400,
                    fontSize: 11.sp,
                  ),
                  softWrap: true,
                ),
              ),

              const SizedBox(width: 8), // spacing between text and checkbox

              GestureDetector(
                onTap: () {
                  context.read<CardCubit>().toggleCheck(widget.index);
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
                        card.isChecked ? AppColors.primary : Colors.transparent,
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
                    textAlign: TextAlign.left,
                    style: GoogleFonts.roboto(
                      fontSize: 10,
                      fontWeight: FontWeight.normal,
                      color: AppColors.shadowColor,
                    ),
                  ),
                  Text(
                    card.editedAvailabilityText.isNotEmpty
                        ? card.editedAvailabilityText
                        : card.initialAvailabilityText,
                    style: GoogleFonts.roboto(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.shadowColor,
                    ),
                  ),
                ],
              ),
              !card.isExpanded
                  ? ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      // fixedSize: const Size(65, 26),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(13),
                        side: const BorderSide(
                          color: Color(0xFF5B6369),
                          width: 1,
                        ),
                      ),
                    ),
                    onPressed: () {
                      if (card.isExpanded) {
                        context.read<CardCubit>().updatePromoText(
                          widget.index,
                          _promoController.text,
                        );
                        context.read<CardCubit>().updateText(
                          widget.index,
                          _availabilityController.text,
                        );
                      } else {
                        context.read<CardCubit>().toggleExpand(widget.index);
                      }
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
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                switchInCurve: Curves.easeIn,
                switchOutCurve: Curves.easeOut,
                transitionBuilder: (Widget child, Animation<double> animation) {
                  return FadeTransition(
                    opacity: animation,
                    child: SizeTransition(
                      sizeFactor: animation,
                      axisAlignment: -1.0,
                      child: child,
                    ),
                  );
                },
                child:
                    card.isExpanded
                        ? Padding(
                          key: const ValueKey("expandedPromoTextField"),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 0,
                            vertical: 8,
                          ),
                          child: TextField(
                            style: TextTheme.of(context).bodySmall!.copyWith(
                              color: AppColors.shadowColor,
                              fontWeight: FontWeight.w400,
                              fontSize: 14.sp,
                            ),
                            maxLines: 5,
                            controller: _promoController,
                            decoration: InputDecoration(
                              labelStyle: TextTheme.of(
                                context,
                              ).bodySmall!.copyWith(
                                color: AppColors.shadowColor,
                                fontWeight: FontWeight.w400,
                                fontSize: 14.sp,
                              ),
                              hintText: "Write your promo here",
                              hintStyle: TextTheme.of(
                                context,
                              ).bodySmall!.copyWith(
                                color: AppColors.shadowColor,
                                fontWeight: FontWeight.w400,
                                fontSize: 14.sp,
                              ),
                              filled: true,
                              fillColor: AppColors.primaryWhiteColor,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        )
                        : const SizedBox.shrink(
                          key: ValueKey("hiddenPromoTextField"),
                        ),
              ),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                switchInCurve: Curves.easeIn,
                switchOutCurve: Curves.easeOut,
                transitionBuilder: (Widget child, Animation<double> animation) {
                  return FadeTransition(
                    opacity: animation,
                    child: SizeTransition(
                      sizeFactor: animation,
                      axisAlignment: -1.0,
                      child: child,
                    ),
                  );
                },
                child:
                    card.isExpanded
                        ? Padding(
                          key: const ValueKey("expandedAvailabilityTextField"),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 0,
                            vertical: 8,
                          ),
                          child: TextField(
                            style: TextTheme.of(context).bodySmall!.copyWith(
                              color: AppColors.shadowColor,
                              fontWeight: FontWeight.w400,
                              fontSize: 14.sp,
                            ),
                            controller: _availabilityController,
                            decoration: InputDecoration(
                              hintText: "Edit Text",
                              hintStyle: TextTheme.of(
                                context,
                              ).bodySmall!.copyWith(
                                color: AppColors.shadowColor,
                                fontWeight: FontWeight.w600,
                                fontSize: 14.sp,
                              ),
                              labelStyle: TextTheme.of(
                                context,
                              ).bodySmall!.copyWith(
                                color: AppColors.shadowColor,
                                fontWeight: FontWeight.w400,
                                fontSize: 14.sp,
                              ),
                              filled: true,
                              fillColor: AppColors.primaryWhiteColor,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        )
                        : const SizedBox.shrink(
                          key: ValueKey("hiddenAvailabilityTextField"),
                        ),
              ),
            ],
          ),
          const Gap(10),
          card.isExpanded
              ? Align(
                alignment: Alignment.bottomRight,
                child: ElevatedButton.icon(
                  onPressed: () {
                    if (card.isExpanded) {
                      context.read<CardCubit>().updatePromoText(
                        widget.index,
                        _promoController.text,
                      );
                      context.read<CardCubit>().updateText(
                        widget.index,
                        _availabilityController.text,
                      );
                    } else {
                      context.read<CardCubit>().toggleExpand(widget.index);
                    }
                  },
                  label: const Text(
                    'Save',
                    style: TextStyle(fontSize: 9, color: Colors.blueGrey),
                  ),
                  icon: const Icon(Icons.edit, size: 15),
                ),
              )
              : const SizedBox(),
        ],
      ),
    );
  }
}
