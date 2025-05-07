import 'package:dicetable/src/constants/app_colors.dart';
import 'package:flutter/material.dart';

class HistoryCard extends StatelessWidget {
  final String actionText;
  final String cafeName;
  final String tableType;
  final String dateTime;

  const HistoryCard({
    super.key,
    required this.actionText,
    required this.cafeName,
    required this.tableType,
    required this.dateTime,
  });

  @override
  // Widget build(BuildContext context) {
  //   return Container(
  //     decoration: BoxDecoration(
  //       color: AppColors.primaryWhiteColor,
  //       borderRadius: BorderRadius.circular(15),
  //       boxShadow: const [
  //         BoxShadow(
  //           color: Colors.black26,
  //           offset: Offset(0, 1), // Horizontal and vertical offsets
  //           blurRadius: 1.0, // Softness of the shadow
  //           spreadRadius: 1.0, // Extent of the shadow
  //         ),
  //       ],
  //     ),
  //     child: Column(children: []),
  //   );
  // }
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Timeline vertical line with dot
        Column(
          children: [
            Container(width: 2, height: 20, color: Colors.purpleAccent),
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: Colors.purpleAccent,
                shape: BoxShape.circle,
              ),
            ),
            Container(width: 2, height: 100, color: Colors.purpleAccent),
          ],
        ),
        const SizedBox(width: 10),

        // Card content
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.primaryWhiteColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    style: const TextStyle(color: Colors.black),
                    children: [
                      TextSpan(text: '$actionText '),
                      TextSpan(
                        text: cafeName,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 6),
                Text("Table Type: $tableType"),
                const SizedBox(height: 4),
                Text("Date/Time: $dateTime"),
              ],
            ),
          ),
        )
      ],
    );
  }
}
