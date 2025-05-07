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

    if (ObjectFactory().prefs.isLoggedIn() == true) {
      context.go('/home');
    } else if (ObjectFactory().prefs.isCustomerLoggedIn() == true) {
      context.go('/customer_home');
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