import 'package:auto_size_text/auto_size_text.dart';
import 'package:badges/badges.dart' as badges;
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:soloseaters/src/purchase/bloc/bloc/purchase_bloc.dart';
import 'package:soloseaters/src/purchase/bloc/bloc/purchase_event.dart';
import 'package:soloseaters/src/ui/cafe_owner/home/bloc/home_bloc.dart';
import 'package:soloseaters/src/ui/cafe_owner/notification/bloc/notification_bloc.dart';
import 'package:soloseaters/src/ui/cafe_owner/notification/count_controller.dart';
import 'package:flutter/services.dart';
import 'package:soloseaters/src/constants/app_colors.dart';
import 'package:soloseaters/src/ui/cafe_owner/home/home_page.dart';
import 'package:soloseaters/src/ui/cafe_owner/home/widget/bottom_navigation_bar.dart';
import 'package:soloseaters/src/ui/cafe_owner/profile/manage_profile_screen.dart';
import 'package:soloseaters/src/ui/cafe_owner/subscription/subscription_overview_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  DateTime? currentBackPressTime;
  final CounterController controller = Get.find<CounterController>();

  void _onTabSelected(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<bool> onWillPop() async {
    DateTime now = DateTime.now();
    if (currentBackPressTime == null ||
        now.difference(currentBackPressTime!) > const Duration(seconds: 3)) {
      currentBackPressTime = now;
      Fluttertoast.showToast(
        fontSize: 14.sp,
        backgroundColor: AppColors.secondary,
        textColor: AppColors.primaryWhiteColor,
        gravity: ToastGravity.BOTTOM,
        msg: "Press again to exit",
      );
      return Future.value(false);
    }
    if (Theme.of(context).platform == TargetPlatform.android) {
      SystemNavigator.pop();
      return false;
    }
    return true;
  }

  @override
  void initState() {
    super.initState();
   

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NotificationBloc>().add(FetchNotifications());
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PaymentPlanBloc>().add(InitializePaymentEvent());
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: onWillPop,
      child: Scaffold(
        extendBody: true,
        appBar: _buildAppBar(_selectedIndex, context, controller),
        body: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          transitionBuilder: (Widget child, Animation<double> animation) {
            return FadeTransition(opacity: animation, child: child);
          },
          child: _buildPage(_selectedIndex),
        ),

        bottomNavigationBar: PhysicalShape(
          elevation: 8,
          clipper: const ShapeBorderClipper(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
            ),
          ),
          color: AppColors.primaryWhiteColor,
          child: BottomNavigationAppBar(
            items: [
              FABBottomAppBarItem(
                iconData: SvgPicture.asset(
                  'assets/svg/home.svg',
                  fit: BoxFit.contain,
                ),
                text: 'HOME',
              ),
              FABBottomAppBarItem(
                iconData: SvgPicture.asset(
                  'assets/svg/subscriptions.svg',
                  fit: BoxFit.contain,
                ),
                text: 'SUBSCRIPTIONS',
              ),
              FABBottomAppBarItem(
                iconData: SvgPicture.asset(
                  'assets/svg/profile.svg',
                  fit: BoxFit.contain,
                ),
                text: 'PROFILE',
              ),
            ],
            backgroundColor: Colors.transparent,
            color: AppColors.textPrimaryGrey,
            selectedColor: AppColors.primary,
            onTabSelected: _onTabSelected,
          ),
        ),
      ),
    );
  }
}

Widget _buildPage(int index) {
  switch (index) {
    case 0:
      return const HomePage(key: ValueKey('home'));
    case 1:
      return SubscriptionOverviewScreen(key: ValueKey('subscription'));
    case 2:
      return ManageProfileScreen(key: ValueKey('profile'));

    default:
      return const HomePage();
  }
}

PreferredSizeWidget? _buildAppBar(
  int index,
  BuildContext context,
  CounterController controller,
) {
  switch (index) {
    case 1:
      return AppBar(
        backgroundColor: AppColors.primary,
        leading: SizedBox(),
        titleSpacing: 28,
        centerTitle: false,
        leadingWidth: 0,
        title: AutoSizeText(
          'Subscriptions Overview',
          style: TextTheme.of(context).labelLarge!.copyWith(
            color: AppColors.primaryWhiteColor,
            fontWeight: FontWeight.w600,
            fontSize: 18.sp,
          ),
        ),
        actions: [
          BlocConsumer<NotificationBloc, NotificationState>(
            listener: (context, state) async {
              if (state is NotificationLoaded) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  controller.notificationBadgeAmount.value =
                      state.notificationItems.data.unread.length;
                });
              }
            },
            builder: (context, state) {
              return InkWell(
                onTap: () {
                  GoRouter.of(context).push('/notification');
                },
                child: Obx(() {
                  return controller.notificationBadgeAmount.value > 0
                      ? badges.Badge(
                        position: badges.BadgePosition.topEnd(
                          top: 0,
                          end:
                              int.parse(
                                        controller.notificationBadgeAmount.value
                                            .toString(),
                                      ) >
                                      99
                                  ? -12
                                  : -2,
                        ),
                        badgeAnimation: badges.BadgeAnimation.slide(),
                        showBadge: true,
                        badgeStyle: badges.BadgeStyle(
                          shape: badges.BadgeShape.circle,
                          badgeColor: Colors.red,
                          padding: EdgeInsets.all(6),
                        ),
                        badgeContent: Text(
                          // Logic: If greater than 99, show "99+", otherwise show number
                          int.parse(
                                    controller.notificationBadgeAmount.value
                                        .toString(),
                                  ) >
                                  99
                              ? "99+"
                              : controller.notificationBadgeAmount.value
                                  .toString(),
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        child: Icon(
                          Icons.notifications_outlined,
                          color: AppColors.primaryWhiteColor,
                          size: 28.w,
                        ),
                      )
                      : Icon(
                        Icons.notifications_outlined,
                        color: AppColors.primaryWhiteColor,
                        size: 28.w,
                      );
                }),
              );
            },
          ),
        ],
        actionsPadding: EdgeInsets.only(right: 15),
      );
    default:
      return null; // No AppBar for HomePage
  }
}
