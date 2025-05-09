import 'package:flutter/services.dart';
import 'package:dicetable/src/constants/app_colors.dart';
import 'package:dicetable/src/ui/customer/cafe_list/cafe_list_screen.dart';
import 'package:dicetable/src/ui/customer/favourites/favourites_screen.dart';
import 'package:dicetable/src/ui/customer/history/history_screen.dart';
import 'package:dicetable/src/ui/customer/home/home_page.dart';
import 'package:dicetable/src/ui/customer/home/widget/bottom_navigation_bar.dart';
import 'package:dicetable/src/ui/customer/profile/customer_profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';

class CustomerHomeScreen extends StatefulWidget {
  const CustomerHomeScreen({super.key});

  @override
  State<CustomerHomeScreen> createState() => _CustomerHomeScreenState();
}

class _CustomerHomeScreenState extends State<CustomerHomeScreen> {
  int _selectedIndex = 0;
  DateTime? currentBackPressTime;


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
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: onWillPop,
      child: Scaffold(
        extendBody: true,
        // appBar: _buildAppBar(_selectedIndex, context),
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
              FABBottomAppBarItem(
                iconData: SvgPicture.asset(
                  'assets/svg/favourites.svg',
                  fit: BoxFit.scaleDown,
                ),
                text: 'FAVOURITES',
              ),
              FABBottomAppBarItem(
                iconData: SvgPicture.asset(
                  'assets/svg/history.svg',
                  fit: BoxFit.scaleDown,
                ),
                text: 'HISTORY',
              ),
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
}

Widget _buildPage(int index) {
  switch (index) {
    case 0:
      return const CustomerHomePage(key: ValueKey('customer_home'));
    case 1:
      return CafeListScreen(key: ValueKey('cafe_list'));
    case 2:
      return FavouritesScreen(key: ValueKey('fav'));
    case 3:
      return HistoryScreen(key: ValueKey('history'));
    case 4:
      return CustomerProfileScreen(key: ValueKey('customer_profile'));

    default:
      return const CustomerHomePage();
  }
}

