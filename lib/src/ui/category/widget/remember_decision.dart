import 'package:dicetable/src/constants/app_colors.dart';
import 'package:dicetable/src/utils/data/object_factory.dart';
import 'package:flutter/material.dart';

class RememberDecisionWidget extends StatefulWidget {
  const RememberDecisionWidget({super.key});

  @override
  RememberDecisionWidgetState createState() => RememberDecisionWidgetState();
}

class RememberDecisionWidgetState extends State<RememberDecisionWidget> {
  bool isChecked = false;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Checkbox(
          value: isChecked,
          onChanged: (value) {
            setState(() {
              isChecked = value ?? false;
              ObjectFactory().prefs.setRememberDecision(isChecked);
            });
          },
          checkColor: AppColors.primary,
          activeColor: AppColors.primaryWhiteColor,

          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        SizedBox(width: 8),
        Text(
          'Remember this decision',
          style: TextStyle(
            color: AppColors.primaryWhiteColor,
            fontSize: 16,
          ),
        ),
      ],
    );
  }
}
