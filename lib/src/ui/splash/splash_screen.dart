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
  final splashDelay = 3;

  _loadWidget() async {
    var duration = Duration(seconds: splashDelay);
    return Timer(duration, navigationPage);
  }

  void navigationPage() {
    if (mounted) {
      if (mounted) {
        ObjectFactory().prefs.isLoggedIn()!
            ? context.go('/home')
            : context.go('/category');
      }
    }
  }
  // void navigationPage() {
  //   if (mounted) {
  //     context.go('/home');
  //   }else {
  //     context.go('/login');
  //   }
  // }

  @override
  void initState() {
    super.initState();
    _loadWidget();
  }

  @override
  Widget build(BuildContext context) {
    return const Material(
        type: MaterialType.canvas,
        child: DecoratedBox(
          decoration: BoxDecoration(
              image: DecorationImage(
                  image: AssetImage('assets/png/splash-screen.png'),fit: BoxFit.fill)),
        ),
    );
  }
}
