import 'dart:async';
import 'dart:isolate';
import 'package:dicetable/src/constants/app_colors.dart';
import 'package:dicetable/src/ui/cafe_owner/notification/count_controller.dart';
import 'package:dicetable/src/utils/data/notification_service.dart';
import 'package:dicetable/src/utils/data/object_factory.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'app.dart';
import 'app_bloc_observer.dart';
import 'package:get/get.dart';
import 'package:flutter_bloc/flutter_bloc.dart';


@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
}

Future<void> main() async {
  await runZonedGuarded<Future<void>>(() async {
    WidgetsFlutterBinding.ensureInitialized();
    Get.put(CounterController());
    Bloc.observer = AppBlocObserver();

    // Set custom error widget to prevent red screen
    ErrorWidget.builder = (FlutterErrorDetails details) {
      return Material(
        color: AppColors.primary,
        child: Center(
          child: Text(
            'Oops! Something went wrong.',
            style: TextStyle(color: AppColors.appRedColor, fontSize: 18),
            textAlign: TextAlign.center,
          ),
        ),
      );
    };

    await _initializeApp();

    ///setting device orientation as portrait, then calling the runApp method
    SystemChrome.setPreferredOrientations(
        <DeviceOrientation>[
          DeviceOrientation.portraitUp,
          DeviceOrientation.portraitDown
        ]).then((_) {
      runApp(App());
    });
  }, _handleUncaughtError);
}

Future<void> _initializeApp() async {
  try {
    // Firebase init
    await Firebase.initializeApp();

    // Error handlers (Flutter, PlatformDispatcher, Isolate)
    await _setupErrorHandlers();

    // App dependencies (prefs, system UI)
    await _initializeAppDependencies();

    // Initialize notifications after dependencies are set up
    await _initializeNotifications();

    // Loading configuration
    configLoading();

    // Register background handler
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  } catch (e, st) {
    _handleInitializationError(e, st);
    rethrow;
  }
}

Future<void> handleAutoBackupOnFreshInstall() async {
  final prefs = await SharedPreferences.getInstance();
  const String installKey = 'hasBeenInitialized';

  final isInitialized = prefs.getBool(installKey) ?? false;

  if (!isInitialized) {
    // This means it's a fresh install or first time launch
    await prefs.clear(); // clear auto-restored values
    await prefs.setBool(installKey, true); // set flag
  }
}

Future<void> _initializeNotifications() async {
  try {
    final notificationService = NotificationServices();
    await notificationService.initializeWithoutContext();

    if (kDebugMode) {
      print('Notifications initialized successfully');
    }
  } catch (e) {
    if (kDebugMode) {
      print('Failed to initialize notifications: $e');
    }
    // Don't rethrow - notifications are not critical for app startup
  }
}

Future<void> _setupErrorHandlers() async {
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    _logError(details.exception, details.stack);
  };

  PlatformDispatcher.instance.onError = (error, stack) {
    _logError(error, stack);
    return true;
  };

  Isolate.current.addErrorListener(RawReceivePort((pair) {
    final List<dynamic> errorAndStacktrace = pair;
    final error = errorAndStacktrace[0];
    final stackTrace = errorAndStacktrace[1];
    _logError(error, stackTrace);
  }).sendPort);
}

Future<void> _initializeAppDependencies() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();

  const String installKey = 'hasBeenInitialized';
  final isInitialized = prefs.getBool(installKey) ?? false;

  if (!isInitialized) {
    await prefs.clear();

    prefs = await SharedPreferences.getInstance();
    await prefs.setBool(installKey, true);

    print("Fresh install detected. Preferences cleared.");
  }

  ObjectFactory().setPrefs(prefs);

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
    ),
  );
}


void _handleUncaughtError(Object error, StackTrace stackTrace) {
  _logError(error, stackTrace);
}

void _handleInitializationError(Object error, StackTrace stackTrace) {
  _logError(error, stackTrace);
}

void _logError(Object error, StackTrace? stackTrace) {
  try {
    if (kDebugMode) {
      debugPrint('ERROR: $error');
      if (stackTrace != null) debugPrintStack(stackTrace: stackTrace);
    }

    // Future integration: FirebaseCrashlytics.instance.recordError(...);
    _storeErrorLocally(error, stackTrace);
  } catch (_) {
    debugPrint('Failed to log error');
  }
}

void _storeErrorLocally(Object error, StackTrace? stackTrace) {
  final errorLog = {
    'timestamp': DateTime.now().toIso8601String(),
    'error': error.toString(),
    'stackTrace': stackTrace?.toString(),
  };

  // Save to disk, DB, shared prefs etc.
  debugPrint('🪵 Stored error: $errorLog');
}

void configLoading() {
  EasyLoading.instance
    ..displayDuration = const Duration(milliseconds: 2000)
    ..indicatorType = EasyLoadingIndicatorType.fadingCircle
    ..loadingStyle = EasyLoadingStyle.custom
    ..indicatorSize = 40.0
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