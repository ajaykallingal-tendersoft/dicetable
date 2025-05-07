import 'package:dicetable/src/constants/app_colors.dart' show AppColors;
import 'package:flutter/material.dart';

class DividerWithCenterText extends StatelessWidget {
  const DividerWithCenterText({
    super.key, required this.centerText,
  });
  final String centerText;
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const SizedBox(width: 16),
        Expanded(
          child: Divider(color: AppColors.primaryWhiteColor, thickness: 1),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 8),
          child: Text(
            centerText,
            style: TextTheme.of(context).bodySmall!.copyWith(
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
          ),
        ),
        const Expanded(
          child: Divider(color: AppColors.primaryWhiteColor, thickness: 1),
        ),
        const SizedBox(width: 16),
      ],
    );
  }
}
