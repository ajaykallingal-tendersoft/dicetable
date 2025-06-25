import 'dart:async';
import 'package:dicetable/src/utils/data/object_factory.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../customer/home/bloc/customer_home_bloc.dart';

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
    _navigateAfterDelay();
    ObjectFactory().prefs.setIsGuestUser(false);
  }

  Future<void> _navigateAfterDelay() async {
    await Future.delayed(const Duration(seconds: splashDelay));
    _navigateToNextScreen();
  }

  void _navigateToNextScreen() {
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
        context.go('/customer_login');
      } else {
        context.go('/login');
      }
    } else {
      // First launch or no remembered category; show category selection
      context.go('/category');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/png/splash-screen.png'),
            fit: BoxFit.contain,
          ),
        ),
        child: const SizedBox.shrink(),
      ),
    );
  }
}
