import 'dart:async';
import 'package:dicetable/src/utils/data/object_factory.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  static const int splashDelay = 3;

  @override
  void initState() {
    super.initState();
    _navigateAfterDelay();
  }

  Future<void> _navigateAfterDelay() async {
    await Future.delayed(const Duration(seconds: splashDelay));
    _navigateToNextScreen();
  }

  void _navigateToNextScreen() {
    if (!mounted) return;
    final isLoggedIn = ObjectFactory().prefs.isLoggedIn() == true;
    final isCustomerLoggedIn = ObjectFactory().prefs.isCustomerLoggedIn() == true;
    final rememberDecision = ObjectFactory().prefs.getRememberDecision() ?? false;
    final userCategory = ObjectFactory().prefs.getUserDecisionName();
    final isGoogleSignIn = ObjectFactory().prefs.isGoogle() == true;
    final isEmailVerified = ObjectFactory().prefs.isEmailVerified() == true;

    ObjectFactory().prefs.setNavigationSource('splash_screen');

    if (isLoggedIn) {
      if (isGoogleSignIn || isEmailVerified) {
        context.go('/home');
      } else {
        context.go('/login');
      }
    } else if (isCustomerLoggedIn) {
      context.go('/customer_home');
    } else if (rememberDecision && userCategory != null) {
      if (userCategory == 'PUBLIC_USER') {
        context.go('/customer_login');
      } else {
        context.go('/login');
      }
    } else {
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
            fit: BoxFit.cover,
          ),
        ),
        child: const SizedBox.shrink(),
      ),
    );
  }
}
