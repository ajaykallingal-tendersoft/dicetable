import 'package:dicetable/src/constants/app_colors.dart';
import 'package:dicetable/src/ui/cafe_owner/notification/notification_item.dart';
import 'package:dicetable/src/ui/cafe_owner/notification/tab_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'bloc/notification_bloc.dart';

class NotificationScreen extends StatefulWidget {
  NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  String selectedTab = 'ALL';

  @override
  void initState() {
    super.initState();
    context.read<NotificationBloc>().add(FetchNotifications());
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
            unreadCount: 0,
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
        child: BlocConsumer<NotificationBloc, NotificationState>(
          listener: (context, state) async {
            if (state is NotificationLoading) {
              await EasyLoading.show();
            } else {
              await EasyLoading.dismiss();
              if (state is NotificationError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(state.errorMessage)),
                );
              }
            }
            },
          builder: (context, state) {
            if (state is NotificationLoaded) {
            EasyLoading.dismiss();
            return Container(
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
                    selectedTab == 'ALL'
                        ? Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.all(12),
                        itemCount: state.notificationItems.data.all.length,
                        itemBuilder: (context, index) {
                          final item = state.notificationItems.data.all[index];
                          return InkWell(
                            onTap:  () {
                              final notificationUpdateRequest = NotificationReadRequest(
                                notificationId: item.id,
                              );
                              context.read<NotificationBloc>().add(
                                ReadNotification(notificationReadRequest: notificationUpdateRequest),
                              );
                              context.read<NotificationBloc>().add(FetchNotifications());
                            },
                            child: Container(
                              margin: const EdgeInsets.symmetric(vertical: 6),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: item.readAt ?? false
                                    ? AppColors.readedNotifyContainerColor
                                    : AppColors.primaryWhiteColor,
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.title,
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
                                      item.createdAt,
                                      style: TextTheme.of(context).bodySmall!.copyWith(
                                          color: AppColors.primaryBlackColor,
                                          fontWeight: FontWeight.w400,
                                          fontSize: 10.sp
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    )
                        : Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.all(12),
                        itemCount: state.notificationItems.data.unread.length,
                        itemBuilder: (context, index) {
                          final item = state.notificationItems.data.unread[index];
                          return InkWell(
                            onTap:  () {
                              final notificationUpdateRequest = NotificationReadRequest(
                                notificationId: item.id,
                              );
                              context.read<NotificationBloc>().add(
                                ReadNotification(notificationReadRequest: notificationUpdateRequest),
                              );
                              context.read<NotificationBloc>().add(FetchNotifications());
                            },
                            child: Container(
                              margin: const EdgeInsets.symmetric(vertical: 6),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: item.readAt ?? false
                                    ? AppColors.readedNotifyContainerColor
                                    : AppColors.primaryWhiteColor,
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.title,
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
                                      "item.createdAt",
                                      style: TextTheme.of(context).bodySmall!.copyWith(
                                          color: AppColors.primaryBlackColor,
                                          fontWeight: FontWeight.w400,
                                          fontSize: 10.sp
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    )
                  ],
                ),
              ),
            );
            }
            return Container();
            },
      ),


      ),
    );
  }
}
