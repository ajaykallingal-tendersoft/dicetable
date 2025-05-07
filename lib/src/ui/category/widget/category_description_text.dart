import 'package:flutter/material.dart';

class CategoryDescriptionText extends StatelessWidget {
  const CategoryDescriptionText({super.key, required this.description, required this.subDescription});
final String description;
  final String subDescription;
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          description,
          textAlign: TextAlign.center,
          style: TextTheme.of(context).bodyMedium!.copyWith(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 4),
        Text(
          subDescription,
          textAlign: TextAlign.center,
          style: TextTheme.of(context).bodyMedium!.copyWith(
            fontSize: 13,
            fontWeight: FontWeight.normal,
          ),
        ),
      ],
    );
  }
}
