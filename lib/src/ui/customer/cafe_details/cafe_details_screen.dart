import 'package:dicetable/src/common/elevated_button_widget.dart';
import 'package:dicetable/src/constants/app_colors.dart';
import 'package:dicetable/src/ui/customer/cafe_details/widget/cafe_details_card.dart';
import 'package:dicetable/src/ui/customer/cafe_list/components/cafe_details_arguments.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

class CafeDetailsScreen extends StatelessWidget {
  final CafeDetailsArguments cafeDetailsArguments;

  const CafeDetailsScreen({super.key, required this.cafeDetailsArguments});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.primary,
        leading: IconButton(
          icon: SvgPicture.asset(
            'assets/svg/back.svg',
            fit: BoxFit.scaleDown,
            color: AppColors.primaryWhiteColor,
          ),
          onPressed: () => context.pop(),
        ),



        actions: [SvgPicture.asset('assets/svg/notify.svg')],
        actionsPadding: EdgeInsets.only(right: 15),
      ),
      body: Container(
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
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(26.0),
            child: Column(
              children: [
                CafeDetailsCard(
                  name: cafeDetailsArguments.name,
                  tableType: cafeDetailsArguments.tableType,
                  description: cafeDetailsArguments.description,
                  image: cafeDetailsArguments.image,
                  openingHours: cafeDetailsArguments.openingHours,
                  id: cafeDetailsArguments.id,
                ),
                Gap(40),
                ElevatedButtonWidget(
                  height: 70.h,
                  width: double.infinity,
                  iconEnabled: false,
                  iconLabel: 'SHOW INTEREST',
                  color: AppColors.primary,
                  textColor: AppColors.primaryWhiteColor,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
