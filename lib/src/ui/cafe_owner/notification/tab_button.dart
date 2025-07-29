import 'package:soloseaters/src/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:badges/badges.dart' as badges;

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
          _buildTab('ALL',context, isSelected: selectedTab == 'ALL'),
          Container(
            width: 1,
            height: 35,
            color: AppColors.profileTextFiledBorderColor,
          ),
          _buildTab('UNREAD',context, isSelected: selectedTab == 'UNREAD'),
        ],
      ),
    );
  }

  Widget _buildTab(String title, BuildContext context, {required bool isSelected}) {
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
            splashColor: Colors.white24,
          onTap: () => onTabSelected(title),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 10),
        
              if(title == "ALL" || unreadCount < 1)
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
        
              if(title == "UNREAD" && unreadCount > 0)
                badges.Badge(
                  position: badges.BadgePosition.topEnd(top: -12, end: 50),
                  badgeAnimation: badges.BadgeAnimation.slide(),
                  showBadge: true,
                  badgeStyle: badges.BadgeStyle(
                    shape: badges.BadgeShape.square,
                    borderRadius: BorderRadius.circular(10),
                    badgeColor: Colors.red,
                    padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  ),
                  badgeContent: Text(
                    unreadCount.toString(),
                    style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                  child: Center(
                    child: Text(
                      title,
                      style: TextTheme.of(context).bodyMedium!.copyWith(
                          color: AppColors.primaryWhiteColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 14.sp
                      ),
                    ),
                  ),
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
      ),
    );
  }

}