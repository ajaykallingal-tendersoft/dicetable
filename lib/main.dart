import 'package:dicetable/src/constants/app_colors.dart';
import 'package:dicetable/src/utils/data/object_factory.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

//
// Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message)async {
//   await Firebase.initializeApp();
// }
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(App());

  // FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);
  // FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
  // FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  ///Setting prefs
  final SharedPreferences sharedPreferences =
  await SharedPreferences.getInstance();
  ObjectFactory().setPrefs(sharedPreferences);

  ///setting Overlay
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
    ),
  );
}

void configLoading() {
  EasyLoading.instance
    ..displayDuration = const Duration(milliseconds: 2000)
    ..indicatorType = EasyLoadingIndicatorType.fadingCircle
    ..loadingStyle = EasyLoadingStyle.custom
    ..indicatorSize = 45.0
    ..radius = 10.0
    ..progressColor = AppColors.primaryWhiteColor
    ..backgroundColor = AppColors.primary
    ..indicatorColor = AppColors.primaryWhiteColor
    ..textColor = AppColors.primaryWhiteColor
    ..maskColor = AppColors.primary.withOpacity(0.9)
    ..userInteractions = false
    ..dismissOnTap = false
    ..toastPosition = EasyLoadingToastPosition.bottom;
}
