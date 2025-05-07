import 'package:dicetable/src/constants/app_colors.dart';
import 'package:dicetable/src/constants/assets.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class ModalBarrierWithProgressIndicatorWidget extends StatelessWidget {
  const ModalBarrierWithProgressIndicatorWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const Scaffold(backgroundColor: Colors.transparent),
        const ModalBarrier(dismissible: false, color: Colors.transparent),
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                height: 90,
                width: 90,
                child: Lottie.asset(Assets.JUMBING_DOT),
              ),
              Text(
                "Please Wait",
                style: TextTheme.of(context).bodySmall!.copyWith(
                  fontSize: 12,
                  color: AppColors.primaryWhiteColor
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}