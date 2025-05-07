import 'package:dicetable/src/constants/app_colors.dart';
import 'package:dicetable/src/ui/cafe_owner/home/home_page.dart';
import 'package:dicetable/src/ui/cafe_owner/home/widget/bottom_navigation_bar.dart';
import 'package:dicetable/src/ui/cafe_owner/profile/manage_profile_screen.dart';
import 'package:dicetable/src/ui/cafe_owner/subscription/subscription_overview_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  void _onTabSelected(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      appBar: _buildAppBar(_selectedIndex, context),
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

PreferredSizeWidget? _buildAppBar(int index, BuildContext context) {
  switch (index) {
    case 1:
      return AppBar(
        backgroundColor: AppColors.primary,
        leading: SizedBox(),
        titleSpacing: 28,
        centerTitle: false,
        leadingWidth: 0,
        title: Text(
          'Subscriptions Overview',
          style: TextTheme.of(context).labelLarge!.copyWith(
            color: AppColors.primaryWhiteColor,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          Stack(
            children: [
              const Icon(
                Icons.notifications_outlined,
                color: AppColors.primaryWhiteColor,
                size: 35,
              ),
              // if (count > 0)
              Positioned(
                right: 0,
                top: 0,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: AppColors.appRedColor,
                    shape: BoxShape.circle,
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 16,
                    minHeight: 16,
                  ),
                  child: Center(
                    child: Text(
                      '8',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),

        ],
        actionsPadding: EdgeInsets.only(right: 15),
      );
    default:
      return null; // No AppBar for HomePage
  }
}
