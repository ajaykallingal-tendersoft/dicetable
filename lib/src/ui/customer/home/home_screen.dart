import 'package:soloseaters/src/ui/cafe_owner/notification/bloc/notification_bloc.dart';
import 'package:soloseaters/src/ui/cafe_owner/notification/count_controller.dart';
import 'package:soloseaters/src/utils/data/object_factory.dart';
import 'package:flutter/services.dart';
import 'package:soloseaters/src/constants/app_colors.dart';
import 'package:soloseaters/src/ui/customer/cafe_list/cafe_list_screen.dart';
import 'package:soloseaters/src/ui/customer/favourites/favourites_screen.dart';
import 'package:soloseaters/src/ui/customer/history/history_screen.dart';
import 'package:soloseaters/src/ui/customer/home/home_page.dart';
import 'package:soloseaters/src/ui/customer/home/widget/bottom_navigation_bar.dart';
import 'package:soloseaters/src/ui/customer/profile/customer_profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'bloc/customer_home_bloc.dart';

class CustomerHomeScreen extends StatefulWidget {
  const CustomerHomeScreen({super.key});

  @override
  State<CustomerHomeScreen> createState() => _CustomerHomeScreenState();
}

class _CustomerHomeScreenState extends State<CustomerHomeScreen> {
  int _selectedIndex = 0;
  DateTime? currentBackPressTime;
  final CounterController controller = Get.find<CounterController>();

  void _onTabSelected(int index) {
    final isGuest = ObjectFactory().prefs.isGuestUser() == true;
    final maxIndex = isGuest ? 1 : 4;
    setState(() {
      _selectedIndex = index > maxIndex ? 0 : index;
    });
  }

  Future<bool> onWillPop() async {
    DateTime now = DateTime.now();
    if (currentBackPressTime == null ||
        now.difference(currentBackPressTime!) > const Duration(seconds: 3)) {
      currentBackPressTime = now;
      Fluttertoast.showToast(
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
      context.read<CustomerHomeBloc>().add(FetchLocationEvent(context: context));
      context.read<NotificationBloc>().add(FetchNotifications());
    });
  }

  @override
  Widget build(BuildContext context) {
    final isGuest = ObjectFactory().prefs.isGuestUser() == true;

    return WillPopScope(
      onWillPop: onWillPop,
      child: Scaffold(
        extendBody: true,

        body: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          transitionBuilder: (Widget child, Animation<double> animation) {
            return FadeTransition(opacity: animation, child: child);
          },
          child: BlocConsumer<NotificationBloc, NotificationState>(
            listener: (context, state) async {
              if (state is NotificationLoaded) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  controller.notificationBadgeAmount.value = state.notificationItems.data.unread.length;
                });
              }
            },
            builder: (context, state) {
              return _buildPage(_selectedIndex, isGuest);
            },
          ),
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
                  fit: BoxFit.scaleDown,
                ),
                text: 'HOME',
              ),
              FABBottomAppBarItem(
                iconData: SvgPicture.asset(
                  'assets/svg/cafe-list.svg',
                  fit: BoxFit.contain,
                ),
                text: 'CAFE LIST',
              ),
              if (!isGuest)
              FABBottomAppBarItem(
                iconData: SvgPicture.asset(
                  'assets/svg/favourites.svg',
                  fit: BoxFit.scaleDown,
                ),
                text: 'FAVOURITES',
              ),
              if (!isGuest)
                FABBottomAppBarItem(
                  iconData: SvgPicture.asset(
                    'assets/svg/history.svg',
                    fit: BoxFit.scaleDown,
                  ),
                  text: 'HISTORY',
                ),
              if (!isGuest)
                FABBottomAppBarItem(
                  iconData: SvgPicture.asset(
                    'assets/svg/profile.svg',
                    fit: BoxFit.scaleDown,
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

  Widget _buildPage(int index, bool isGuest) {
    switch (index) {
      case 0:
        return const CustomerHomePage(key: ValueKey('customer_home'));
      case 1:
        return CafeListScreen(key: ValueKey('cafe_list'));
      case 2:
        return isGuest
          ? CustomerHomePage()
          : FavouritesScreen(key: ValueKey('fav'));
      case 3:
        return isGuest
            ? const CustomerHomePage()
            : HistoryScreen(key: ValueKey('history'));
      case 4:
        return isGuest
            ? const CustomerHomePage()
            : CustomerProfileScreen(key: ValueKey('customer_profile'));
      default:
        return const CustomerHomePage();
    }
  }
}


