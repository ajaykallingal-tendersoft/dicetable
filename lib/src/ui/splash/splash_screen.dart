import 'dart:async';
import 'package:soloseaters/src/utils/data/object_factory.dart';
import 'package:soloseaters/src/utils/data/notification_service.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  static const int splashDelay = 2;

  @override
  void initState() {
    super.initState();
    ObjectFactory().prefs.setIsGuestUser(false);
    _bootstrapNavigationDecision();
  }

  Future<void> _bootstrapNavigationDecision() async {
    final notificationService = NotificationServices();
    final hasPendingNotification =
        ObjectFactory().prefs.getPendingNotificationNavigation() ?? false;

    if (hasPendingNotification) {
      await _navigateToNextScreen();
      await Future.delayed(const Duration(milliseconds: 150));
      await notificationService.handlePendingNotificationNavigation();
      return;
    }

    await _navigateAfterDelay();
  }

  Future<void> _navigateAfterDelay() async {
    await Future.delayed(const Duration(seconds: splashDelay));
    await _navigateToNextScreen();
  }

  Future<void> _navigateToNextScreen() async {
    if (!mounted) return;
    final isLoggedIn = ObjectFactory().prefs.isLoggedIn() == true;
    final isCustomerLoggedIn =
        ObjectFactory().prefs.isCustomerLoggedIn() == true;
    final rememberDecision =
        ObjectFactory().prefs.getRememberDecision() ?? false;
    final userCategory = ObjectFactory().prefs.getUserDecisionName();

    ObjectFactory().prefs.setNavigationSource('splash_screen');

    if (isLoggedIn) {
      // User is a venue owner and logged in
      context.go('/home');
    } else if (isCustomerLoggedIn) {
      // User is a public user and logged in
      context.go('/customer_home');
    } else if (rememberDecision && userCategory != null) {
      // User has selected a category and wants to remember it
      if (userCategory == 'PUBLIC_USER') {
        context.go('/category');
      } else {
        context.go('/category');
      }
    } else {
      // First launch or no remembered category; show category selection
      context.go('/category');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/png/Splash.png'),
          fit: BoxFit.fill,
        ),
      ),
      child: const SizedBox.shrink(),
    );
  }
}
