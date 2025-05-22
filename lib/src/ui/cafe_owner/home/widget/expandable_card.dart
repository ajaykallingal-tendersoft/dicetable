// import 'package:dicetable/src/constants/app_colors.dart';
// import 'package:dicetable/src/ui/cafe_owner/home/bloc/home_bloc.dart';
// import 'package:dicetable/src/ui/cafe_owner/home/model/card_item.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:gap/gap.dart';
// import 'package:google_fonts/google_fonts.dart';
//
// class ExpandableCard extends StatefulWidget {
//   final int index;
//   final CardModel card;
//
//   const ExpandableCard({super.key, required this.index, required this.card});
//
//   @override
//   State<ExpandableCard> createState() => _ExpandableCardState();
// }
//
// class _ExpandableCardState extends State<ExpandableCard> {
//   late String? selectedDay;
//   late TextEditingController _promoController;
//
//   @override
//   void initState() {
//     super.initState();
//     // Initialize selectedDay from edited value or first available day
//     selectedDay = widget.card.editedAvailabilityText.isNotEmpty
//         ? widget.card.editedAvailabilityText
//         : (widget.card.dice.availableDays != null && widget.card.dice.availableDays!.isNotEmpty
//         ? widget.card.dice.availableDays!.first.day
//         : null);
//
//     final initialPromo = widget.card.editedPromoText.isNotEmpty
//         ? widget.card.editedPromoText
//         : (widget.card.dice.description ?? '');
//     _promoController = TextEditingController(text: initialPromo);
//   }
//
//   @override
//   void didUpdateWidget(covariant ExpandableCard oldWidget) {
//     super.didUpdateWidget(oldWidget);
//
//     // Update selectedDay if editedAvailabilityText or availableDays changed
//     if (widget.card.editedAvailabilityText != oldWidget.card.editedAvailabilityText ||
//         widget.card.dice.availableDays != oldWidget.card.dice.availableDays) {
//       setState(() {
//         selectedDay = widget.card.editedAvailabilityText.isNotEmpty
//             ? widget.card.editedAvailabilityText
//             : (widget.card.dice.availableDays != null && widget.card.dice.availableDays!.isNotEmpty
//             ? widget.card.dice.availableDays!.first.day
//             : null);
//       });
//     }
//
//     // Update promo controller text if promo text changed
//     if (widget.card.editedPromoText != oldWidget.card.editedPromoText ||
//         widget.card.dice.description != oldWidget.card.dice.description) {
//       _promoController.text = widget.card.editedPromoText.isNotEmpty
//           ? widget.card.editedPromoText
//           : (widget.card.dice.description ?? '');
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final card = widget.card;
//
//     return AnimatedContainer(
//       duration: const Duration(milliseconds: 300),
//       margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: AppColors.primaryWhiteColor,
//         borderRadius: BorderRadius.circular(16),
//         boxShadow: const [
//           BoxShadow(
//             color: Colors.black26,
//             offset: Offset(0, 1),
//             blurRadius: 1.0,
//             spreadRadius: 1.0,
//           ),
//         ],
//       ),
//       child: Column(
//         children: [
//           Row(
//             children: [
//               CircleAvatar(
//                 backgroundColor: Colors.blue.shade900,
//                 radius: 30,
//                 child: Image.asset('assets/png/dice-type.png'),
//               ),
//               const Gap(10),
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       card.title,
//                       style: TextTheme.of(context).labelMedium!.copyWith(
//                         color: AppColors.primary,
//                         fontWeight: FontWeight.bold,
//                         fontSize: 18.sp,
//                       ),
//                     ),
//                     Text(
//                       card.dice.subTitle!,
//                       style: TextTheme.of(context).labelMedium!.copyWith(
//                         color: AppColors.shadowColor,
//                         fontWeight: FontWeight.w500,
//                         fontSize: 14.sp,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//           const Gap(10),
//           Row(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//             children: [
//               Expanded(
//                 child: Text(
//                   card.editedPromoText.isNotEmpty
//                       ? card.editedPromoText
//                       : card.dice.description!,
//                   style: TextTheme.of(context).bodySmall!.copyWith(
//                     color: AppColors.shadowColor,
//                     fontWeight: FontWeight.w400,
//                     fontSize: 11.sp,
//                   ),
//                   softWrap: true,
//                 ),
//               ),
//               const SizedBox(width: 8),
//               GestureDetector(
//                 onTap: () {
//                   context.read<HomeBloc>().add(ToggleCheckEvent(widget.index));
//                 },
//                 child: Container(
//                   padding: const EdgeInsets.all(4),
//                   decoration: BoxDecoration(
//                     shape: BoxShape.circle,
//                     border: Border.all(
//                       color: AppColors.unSelectedColor,
//                       width: 2,
//                     ),
//                     color: AppColors.unSelectedColor,
//                   ),
//                   child: Icon(
//                     Icons.check,
//                     size: 17,
//                     color: card.isChecked
//                         ? AppColors.primary
//                         : Colors.transparent,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//           const Gap(10),
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     "Available",
//                     style: GoogleFonts.roboto(
//                       fontSize: 10,
//                       fontWeight: FontWeight.normal,
//                       color: AppColors.shadowColor,
//                     ),
//                   ),
//                   Text(
//                     selectedDay!,
//                     style: GoogleFonts.roboto(
//                       fontSize: 12,
//                       fontWeight: FontWeight.w600,
//                       color: AppColors.shadowColor,
//                     ),
//                   ),
//                 ],
//               ),
//               !card.isExpanded
//                   ? ElevatedButton.icon(
//                 style: ElevatedButton.styleFrom(
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(13),
//                     side: const BorderSide(
//                       color: Color(0xFF5B6369),
//                       width: 1,
//                     ),
//                   ),
//                 ),
//                 onPressed: () {
//                   context
//                       .read<HomeBloc>().add(ToggleExpandEvent(widget.index));
//                 },
//                 label: const Text(
//                   'Edit',
//                   style:
//                   TextStyle(fontSize: 9, color: Color(0xFF5B6369)),
//                 ),
//                 icon: const Icon(
//                   Icons.edit,
//                   size: 15,
//                   color: Color(0xFF5B6369),
//                 ),
//               )
//                   : const SizedBox(),
//             ],
//           ),
//           if (card.isExpanded) ...[
//             const Gap(10),
//             TextField(
//               key: const ValueKey("expandedPromoTextField"),
//               controller: _promoController,
//               maxLines: 5,
//               decoration: InputDecoration(
//                 hintText: "Write your promo here",
//                 filled: true,
//                 fillColor: AppColors.primaryWhiteColor,
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//               ),
//             ),
//             const Gap(10),
//             DropdownButtonFormField<String>(
//               key: const ValueKey("expandedAvailabilityDropdown"),
//               value: selectedDay,
//               decoration: InputDecoration(
//                 hintText: "Select Available Day",
//                 filled: true,
//                 fillColor: AppColors.primaryWhiteColor,
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//               ),
//               items: widget.card.dice.availableDays!
//                   .map((day) => DropdownMenuItem<String>(
//                 value: day.day,
//                 child: Text(day.day ?? ''),
//               ))
//                   .toList(),
//               onChanged: (value) {
//                 setState(() {
//                   selectedDay = value;
//                 });
//               },
//             ),
//             const Gap(10),
//             Align(
//               alignment: Alignment.bottomRight,
//               child: ElevatedButton.icon(
//                 onPressed: () {
//                   context.read<HomeBloc>().add(UpdatePromoTextEvent(widget.index, _promoController.text));
//                   context.read<HomeBloc>().add(UpdateAvailabilityTextEvent(widget.index, selectedDay ?? ''));
//                 },
//                 label: const Text(
//                   'Save',
//                   style: TextStyle(fontSize: 9, color: Colors.blueGrey),
//                 ),
//                 icon: const Icon(Icons.edit, size: 15),
//               ),
//             ),
//           ],
//
//         ],
//       ),
//     );
//   }
// }
//
//
