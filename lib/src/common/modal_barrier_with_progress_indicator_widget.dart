import 'package:dicetable/src/constants/app_colors.dart';
import 'package:dicetable/src/constants/assets.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart' show GoogleFonts;
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
              Container(
                height: 90,
                width: 90,
                decoration:
                BoxDecoration(color: AppColors.tertiary),
                child: Lottie.asset(Assets.JUMBING_DOT,
                    height: 90, width: 90),
              ),
              Text(
                "pleasewait",
                style: GoogleFonts.openSans(
                  color: AppColors.primaryWhiteColor,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}