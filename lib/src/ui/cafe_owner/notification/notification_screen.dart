import 'package:dicetable/src/constants/app_colors.dart';
import 'package:dicetable/src/ui/cafe_owner/notification/tab_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import 'notification_item.dart';

class NotificationScreen extends StatefulWidget {
  NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  String selectedTab = 'ALL';

  final List<NotificationItem> notifications = [
    NotificationItem(
      message: 'John has shown an interest in a Social Solo table.',
      date: '18 March, 2025 | 12:00 PM',
      isUnread: true,
    ),
    NotificationItem(
      message: 'Your subscription expires in 7 days',
      date: '18 March, 2025 | 12:00 PM',
      isUnread: true,
    ),
    NotificationItem(
      message: 'Danny has shown an interest in a Prime Time dice table.',
      date: '18 March, 2025 | 12:00 PM',
      isUnread: false,
    ),
    NotificationItem(
      message: 'Will Baker has shown an interest in a Social Solo dice table.',
      date: '16 March, 2025 | 12:00 PM',
      isUnread: false,
    ),
  ];
  List<NotificationItem> get filteredNotifications {
    if (selectedTab == 'ALL') return notifications;
    return notifications.where((n) => n.isUnread).toList();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      extendBody: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: SvgPicture.asset(
            'assets/svg/back.svg',
            fit: BoxFit.scaleDown,
            color: AppColors.primaryWhiteColor,
          ),
          onPressed: () => context.pop(),
        ),

        title:  Text(
          'Notifications',
          style: TextTheme.of(context).labelLarge!.copyWith(
              color: AppColors.primaryWhiteColor,
              fontWeight: FontWeight.w600,
              fontSize: 18.sp
          ),
        ),
        bottom: PreferredSize(
          preferredSize: Size(MediaQuery.of(context).size.width, 46),
          child: NotificationTabBar(
            unreadCount: notifications.where((n) => n.isUnread).length,
            selectedTab: selectedTab,
            onTabSelected: (tab) {
              setState(() {
                selectedTab = tab;
              });
            },
          ),
        ),
        actions: [SvgPicture.asset('assets/svg/notify.svg')],
        actionsPadding: EdgeInsets.only(right: 15),
      ),
      body: SafeArea(
        child: Container(
          width: double.infinity,
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
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              children: [
                const SizedBox(height: 10),
                GestureDetector(
                  onTap: () {},
                  child:  Text(
                    'Turn Off Notifications',
                    textAlign: TextAlign.left,
                    style: TextTheme.of(context).bodySmall!.copyWith(
                        color: AppColors.primaryWhiteColor,
                        decoration: TextDecoration.underline,
                        decorationColor: AppColors.primaryWhiteColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 12.sp,
                    ),
        
                  ),
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: filteredNotifications.length,
                    itemBuilder: (context, index) {
                      final item = filteredNotifications[index];
                      return Container(
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: item.isUnread
                              ? AppColors.primaryWhiteColor
                              : AppColors.readedNotifyContainerColor,
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.message,
                              style: TextTheme.of(context).bodySmall!.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600,
                                fontSize: 12.sp
                              ),
                            ),
                            const SizedBox(height: 6),
                            Align(
                              alignment: Alignment.bottomRight,
                              child: Text(
                                item.date,
                                style: TextTheme.of(context).bodySmall!.copyWith(
                                    color: AppColors.primaryBlackColor,
                                    fontWeight: FontWeight.w400,
                                    fontSize: 10.sp
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
