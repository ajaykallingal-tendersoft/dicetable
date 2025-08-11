import 'package:flutter/material.dart';
import 'package:soloseaters/src/constants/app_colors.dart';

class GradientBackGround extends StatelessWidget {
  const GradientBackGround({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary,
            AppColors.primary,
            AppColors.secondary,
            AppColors.tertiary,
          ],
          stops: [0.0, 0.5, 0.75, 1.0],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
    );
  }
}
