import 'package:dicetable/src/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class NotificationTabBar extends StatelessWidget {
  final int unreadCount;
  final String selectedTab;
  final Function(String) onTabSelected;

  const NotificationTabBar({
    super.key,
    required this.unreadCount,
    required this.selectedTab,
    required this.onTabSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.primary,
      child: Row(
        children: [
          _buildTab('ALL',context, isSelected: selectedTab == 'ALL',),
          Container(
            width: 1,
            height: 35,
            color: AppColors.profileTextFiledBorderColor,
          ),
          _buildTab('UNREAD',context,
              isSelected: selectedTab == 'UNREAD', showDot: true,),
        ],
      ),
    );
  }

  Widget _buildTab(String title, BuildContext context,
      {required bool isSelected, bool showDot = false,}) {
    return Expanded(
      child: InkWell(
        onTap: () => onTabSelected(title),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 10),
            Stack(
              clipBehavior: Clip.none,
              children: [
                Center(
                  child: Text(
                    title,
                    style: TextTheme.of(context).bodyMedium!.copyWith(
                        color: AppColors.primaryWhiteColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 14.sp
                    ),
                  ),
                ),
                if (showDot && unreadCount > 0)
                  Positioned(
                    right: 60.w,
                    top: -6.h,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                      decoration: const BoxDecoration(
                        color: AppColors.appRedColor,
                        shape: BoxShape.rectangle,
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                      ),
                      child: Text(
                        '$unreadCount',
                        style: TextTheme.of(context).bodySmall!.copyWith(
                            color: AppColors.primaryWhiteColor,
                            fontWeight: FontWeight.w600,
                            fontSize: 10.sp
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              height: 2,
              color: AppColors.profileTextFiledBorderColor,
              width: double.infinity,
            ),
          ],
        ),
      ),
    );
  }

}