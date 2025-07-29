import 'package:soloseaters/src/constants/app_colors.dart';
import 'package:soloseaters/src/ui/cafe_owner/notification/notification_item.dart';
import 'package:soloseaters/src/ui/cafe_owner/notification/tab_button.dart';
import 'package:soloseaters/src/utils/data/object_factory.dart';
import 'package:soloseaters/src/utils/data/sign_out.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'bloc/notification_bloc.dart';
import 'count_controller.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  String selectedTab = 'ALL';
  final ValueNotifier<bool> isNotificationEnabled = ValueNotifier<bool>(
    true,
  ); // Using ValueNotifier
  final CounterController controller = Get.find<CounterController>();

  @override
  void initState() {
    super.initState();
    _loadNotificationStatus();
    context.read<NotificationBloc>().add(FetchNotifications());
  }

  // Load notification status from SharedPreferences
  Future<bool> _loadNotificationStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final savedStatus = prefs.getBool('notification_status') ?? true;
    print('Loaded notification status: $savedStatus');
    isNotificationEnabled.value = savedStatus;
    return savedStatus;
  }

  // Save notification status to SharedPreferences
  void _saveNotificationStatus(bool status) async {
    final prefs = await SharedPreferences.getInstance();
    bool result = await prefs.setBool('notification_status', status);
    print('Saved notification status: $status, Result: $result');
  }

  @override
  void dispose() {
    isNotificationEnabled.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Scaffold(
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
          title: Text(
            'Notifications',
            style: TextTheme.of(context).labelLarge!.copyWith(
              color: AppColors.primaryWhiteColor,
              fontWeight: FontWeight.w600,
              fontSize: 18.sp,
            ),
          ),
          bottom: PreferredSize(
            preferredSize: Size(MediaQuery.of(context).size.width, 46),
            child: NotificationTabBar(
              unreadCount: controller.notificationBadgeAmount.value,
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
              if (state is NotificationLoaded) {
                if (state.notificationItems.status == true) {
                  final statusFromServer =
                      state.notificationItems.notificationStatus;
                  if (statusFromServer != null) {
                    isNotificationEnabled.value =
                        statusFromServer; // already a bool
                    _saveNotificationStatus(isNotificationEnabled.value);
                  }
                }
                if (state.notificationItems.status == false) {
                  if (state.notificationItems.message.contains(
                    "Unauthorized",
                  )) {
                    EasyLoading.dismiss();
                    SignOut().logout(context);
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      SignOut().logout(context);
                      Fluttertoast.showToast(
                        fontSize: 14.sp,
                        backgroundColor: AppColors.primaryWhiteColor,
                        textColor: AppColors.appRedColor,
                        gravity: ToastGravity.BOTTOM,
                        msg: "Your session has expired. Please sign in again.",
                      );
                    });
                  }
                }
              }
              if (state is NotificationLoading) {
                EasyLoading.show();
              } else {
                if (state is NotificationError) {
                  if (state.errorMessage.contains("Unauthorized") ||
                      state.errorMessage.contains("UnAuthorized") ||
                      state.errorMessage.contains("Session expired")) {
                    EasyLoading.dismiss();
                    SignOut().logout(context);
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      SignOut().logout(context);
                      Fluttertoast.showToast(
                        fontSize: 14.sp,
                        backgroundColor: AppColors.primaryWhiteColor,
                        textColor: AppColors.appRedColor,
                        gravity: ToastGravity.BOTTOM,
                        msg: "Your session has expired. Please sign in again.",
                      );
                    });
                  }
                }
              }
              if (state is NotificationRead) {
                context.read<NotificationBloc>().add(FetchNotifications());
              }
              if (state is NotificationStatusUpdated) {
                if (state.notificationStatusResponse.status == true) {
                  final notificationStatus =
                      state.notificationStatusResponse.notificationStatus;

                  if (notificationStatus != null) {
                    isNotificationEnabled.value = notificationStatus == 1;

                    // Persist the new status
                    _saveNotificationStatus(isNotificationEnabled.value);

                    Fluttertoast.showToast(
                      fontSize: 14.sp,
                      backgroundColor: AppColors.primaryWhiteColor,
                      textColor: AppColors.appGreenColor,
                      gravity: ToastGravity.BOTTOM,
                      msg: state.notificationStatusResponse.message ?? "",
                    );

                    context.read<NotificationBloc>().add(FetchNotifications());
                  }
                }
              }
            },
            builder: (context, state) {
              if (state is NotificationLoaded) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                   EasyLoading.dismiss();
                  controller.notificationBadgeAmount.value =
                      state.notificationItems.data.unread.length;
                });
               
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
                        ValueListenableBuilder<bool>(
                          valueListenable: isNotificationEnabled,
                          builder: (context, enabled, child) {
                            return GestureDetector(
                              onTap: () {
                                context.read<NotificationBloc>().add(
                                  UpdateNotificationStatus(
                                    notificationStatusRequest:
                                        NotificationStatusRequest(
                                          fcmToken:
                                              ObjectFactory().prefs
                                                  .getFcmToken() ??
                                              "",
                                          notificationStatus: enabled ? 0 : 1,
                                        ),
                                  ),
                                );
                                context.read<NotificationBloc>().add(
                                  FetchNotifications(),
                                );
                              },
                              child: Text(
                                enabled
                                    ? 'Turn Off Notifications'
                                    : 'Turn On Notifications',
                                textAlign: TextAlign.left,
                                style: TextTheme.of(
                                  context,
                                ).bodySmall!.copyWith(
                                  color: AppColors.primaryWhiteColor,
                                  decoration: TextDecoration.underline,
                                  decorationColor: AppColors.primaryWhiteColor,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12.sp,
                                ),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 10),
                        selectedTab == 'ALL'
                            ? Expanded(
                              child: ListView.builder(
                                
                                padding: const EdgeInsets.all(12),
                                itemCount:
                                    state.notificationItems.data.all.length,
                                itemBuilder: (context, index) {
                                  final item =
                                      state.notificationItems.data.all[index];
                                  return InkWell(
                                    onTap: () {
                                      if (item.readAt == null) {
                                        final notificationUpdateRequest =
                                            NotificationReadRequest(
                                              notificationId: item.id,
                                            );

                                        context.read<NotificationBloc>().add(
                                          ReadNotification(
                                            notificationReadRequest:
                                                notificationUpdateRequest,
                                          ),
                                        );
                                      }
                                    },
                                    child: Container(
                                      margin: const EdgeInsets.symmetric(
                                        vertical: 6,
                                      ),
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color:
                                            item.readAt != null
                                                ? AppColors
                                                    .readedNotifyContainerColor
                                                : AppColors.primaryWhiteColor,
                                        borderRadius: BorderRadius.circular(15),
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            item.title,
                                            style: TextTheme.of(
                                              context,
                                            ).bodySmall!.copyWith(
                                              color: AppColors.primary,
                                              fontWeight: FontWeight.w600,
                                              fontSize: 12.sp,
                                            ),
                                          ),
                                          const SizedBox(height: 6),
                                          Text(
                                            item.body,
                                            style: TextTheme.of(
                                              context,
                                            ).bodySmall!.copyWith(
                                              color: AppColors.primary,
                                              fontWeight: FontWeight.w600,
                                              fontSize: 12.sp,
                                            ),
                                          ),
                                          const SizedBox(height: 6),
                                          Align(
                                            alignment: Alignment.bottomRight,
                                            child: Text(
                                              item.createdAt,
                                              style: TextTheme.of(
                                                context,
                                              ).bodySmall!.copyWith(
                                                color:
                                                    AppColors.primaryBlackColor,
                                                fontWeight: FontWeight.w400,
                                                fontSize: 10.sp,
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
                                physics: const NeverScrollableScrollPhysics(),
                                shrinkWrap: true,
                                padding: const EdgeInsets.all(12),
                                itemCount:
                                    state.notificationItems.data.unread.length,
                                itemBuilder: (context, index) {
                                  final item =
                                      state
                                          .notificationItems
                                          .data
                                          .unread[index];
                                  return Material(
                                    color:
                                        item.readAt != null
                                            ? AppColors
                                                .readedNotifyContainerColor
                                            : Colors.transparent,
                                    child: InkWell(
                                      borderRadius: BorderRadius.circular(
                                        15,
                                      ), // for ripple to respect shape
                                      splashColor: Colors.white24,
                                      onTap: () {
                                        if (item.readAt == null) {
                                          final notificationUpdateRequest =
                                              NotificationReadRequest(
                                                notificationId: item.id,
                                              );

                                          context.read<NotificationBloc>().add(
                                            ReadNotification(
                                              notificationReadRequest:
                                                  notificationUpdateRequest,
                                            ),
                                          );
                                        }
                                      },
                                      child: Container(
                                        margin: const EdgeInsets.symmetric(
                                          vertical: 6,
                                        ),
                                        padding: const EdgeInsets.all(16),
                                        decoration: BoxDecoration(
                                          color:
                                              item.readAt != null
                                                  ? AppColors
                                                      .readedNotifyContainerColor
                                                  : AppColors.primaryWhiteColor,
                                          borderRadius: BorderRadius.circular(
                                            15,
                                          ),
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              item.title,
                                              style: TextTheme.of(
                                                context,
                                              ).bodySmall!.copyWith(
                                                color: AppColors.primary,
                                                fontWeight: FontWeight.w600,
                                                fontSize: 12.sp,
                                              ),
                                            ),
                                            const SizedBox(height: 6),
                                            Text(
                                              item.body,
                                              style: TextTheme.of(
                                                context,
                                              ).bodySmall!.copyWith(
                                                color: AppColors.primary,
                                                fontWeight: FontWeight.w600,
                                                fontSize: 12.sp,
                                              ),
                                            ),
                                            const SizedBox(height: 6),
                                            Align(
                                              alignment: Alignment.bottomRight,
                                              child: Text(
                                                item.createdAt,
                                                style: TextTheme.of(
                                                  context,
                                                ).bodySmall!.copyWith(
                                                  color:
                                                      AppColors
                                                          .primaryBlackColor,
                                                  fontWeight: FontWeight.w400,
                                                  fontSize: 10.sp,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                      ],
                    ),
                  ),
                );
              }
              return Container();
            },
          ),
        ),
      ),
    );
  }
}
