import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:go_router/go_router.dart';
import 'package:soloseaters/main.dart';
import 'object_factory.dart';

class NotificationServices {
  // Singleton pattern
  static final NotificationServices _instance =
      NotificationServices._internal();
  factory NotificationServices() => _instance;
  NotificationServices._internal();

  // Initialize Firebase Messaging plugin
  final FirebaseMessaging messaging = FirebaseMessaging.instance;

  // Initialize Flutter local notifications plugin
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;

  // Set to track shown notifications and prevent duplicates
  final Set<String> _shownNotifications = <String>{};

  // Initialize notifications without context (for app startup)
  Future<void> initializeWithoutContext() async {
    if (_isInitialized) return;

    try {
      // Initialize local notifications first
      await _initializeLocalNotifications();

      // Request notification permissions
      await requestNotificationPermission();

      // Setup local notification channel
      setupNotificationChannel();

      // Configure foreground notification presentation
      await foregroundMessage();

      // Get and save FCM token
      final token = await getDeviceToken();
      if (token != null) {
        ObjectFactory().prefs.setFcmToken(token: token);
        if (kDebugMode) {
          print('FCM Token saved: $token');
        }
      } else {
        if (kDebugMode) {
          print('Warning: FCM token not retrieved');
        }
      }

      // Setup foreground message handling
      _setupForegroundMessageHandling();

      _isInitialized = true;
    } catch (e) {
      if (kDebugMode) {
        print('Notification initialization failed: $e');
      }
    }
  }

  void _handleNotificationTap(NotificationResponse response) {
    if (kDebugMode) {
      print('Notification tapped: ${response.payload}');
    }

    // Navigation logic based on user type and login status
    _navigateBasedOnUserType();
  }

  void _navigateBasedOnUserType() {
    final isLoggedIn = ObjectFactory().prefs.isLoggedIn() == true;
    final isCustomerLoggedIn = ObjectFactory().prefs.isCustomerLoggedIn() == true;
    final rememberDecision = ObjectFactory().prefs.getRememberDecision() ?? false;
    final userCategory = ObjectFactory().prefs.getUserDecisionName();

    ObjectFactory().prefs.setNavigationSource('notification_tap');

    if (isLoggedIn || isCustomerLoggedIn) {
      
      _navigateToRoute('/notification');
    } else {
      // First launch or no remembered category; show category selection
      _navigateToRoute('/category');
    }
  }

  void _navigateToRoute(String route) {
    final context = navigatorKey.currentContext;
    if (context != null) {
      context.go(route);
    } else {
      if (kDebugMode) {
        print('Navigation context not available for route: $route');
      }
    }
  }

  // Initialize local notifications plugin
  Future<void> _initializeLocalNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/launcher_icon');

    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestSoundPermission: true,
          requestCriticalPermission: false,
        );

    const InitializationSettings initializationSettings =
        InitializationSettings(
          android: initializationSettingsAndroid,
          iOS: initializationSettingsIOS,
        );

    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _handleNotificationTap,
      // (NotificationResponse response) {
      //   // Handle notification tap
      //   if (kDebugMode) {
      //     print('Notification tapped: ${response.payload}');
      //   }
      //   // You can navigate to specific screen here based on payload
      // },
    );

    // Request iOS permissions explicitly
    if (Platform.isIOS) {
      await _flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
            critical: false,
          );
    }
  }

  // Initialize notifications with context (for UI-specific operations)
  Future<void> initialize(BuildContext context) async {
    // First ensure basic initialization is done
    await initializeWithoutContext();

    try {
      // Any context-specific initialization can go here
      if (kDebugMode) {
        print('Notification service fully initialized with context');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Context-specific notification initialization failed: $e');
      }
    }
  }

  // Setup foreground message handling
  void _setupForegroundMessageHandling() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (kDebugMode) {
        print("Handling a foreground message: ${message.messageId}");
        print("Message data: ${message.data}");
        print("Message notification: ${message.notification?.title}");
        print("Message notification: ${message.notification?.body}");
      }

      // For iOS, we need to handle foreground notifications differently
      if (Platform.isIOS) {
        // On iOS, show notification immediately
        showNotification(message);
      } else {
        // Android handling
        showNotification(message);
      }
    });

    // iOS specific: Handle when notification is received while app is in foreground
    if (Platform.isIOS) {
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        if (kDebugMode) {
          print('A new onMessageOpenedApp event was published!');
        }
        // Handle notification tap when app is opened from background
      });
    }
  }

  // Setup Android notification channel
  void setupNotificationChannel() {
    if (Platform.isAndroid) {
      const AndroidNotificationChannel channel = AndroidNotificationChannel(
        'high_importance_channel',
        'High Importance Notifications',
        description: 'This channel is used for important notifications.',
        importance: Importance.high,
        playSound: true,
      );

      _flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.createNotificationChannel(channel);
    }
  }

  // Request notification permissions
  Future<void> requestNotificationPermission() async {
    try {
      NotificationSettings settings = await messaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        if (kDebugMode) {
          print('User granted permission');
        }
      } else if (settings.authorizationStatus ==
          AuthorizationStatus.provisional) {
        if (kDebugMode) {
          print('User granted provisional permission');
        }
      } else {
        if (kDebugMode) {
          print('User denied permission');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error requesting notification permission: $e');
      }
    }
  }

  // Show notification using local notifications plugin
  Future<void> showNotification(RemoteMessage message) async {
    try {
      // Create unique identifier for this notification
      final String notificationId =
          message.messageId ??
          '${message.notification?.title}_${message.notification?.body}_${DateTime.now().millisecondsSinceEpoch}';

      // Check if we've already shown this notification
      if (_shownNotifications.contains(notificationId)) {
        if (kDebugMode) {
          print('Notification already shown, skipping: $notificationId');
        }
        return;
      }

      // Add to shown notifications set
      _shownNotifications.add(notificationId);

      // Clean up old notifications (keep only last 50)
      if (_shownNotifications.length > 50) {
        final List<String> notificationsList = _shownNotifications.toList();
        _shownNotifications.clear();
        _shownNotifications.addAll(notificationsList.sublist(25));
      }

      if (Platform.isAndroid) {
        const AndroidNotificationChannel channel = AndroidNotificationChannel(
          'high_importance_channel',
          'High Importance Notifications',
          description: 'This channel is used for important notifications.',
          importance: Importance.high,
          playSound: true,
        );

        AndroidNotificationDetails androidNotificationDetails =
            AndroidNotificationDetails(
              channel.id,
              channel.name,
              channelDescription: channel.description,
              importance: Importance.high,
              priority: Priority.high,
              playSound: true,
              ticker: 'ticker',
              icon: '@mipmap/launcher_icon',
              styleInformation: BigTextStyleInformation(''),
            );

        NotificationDetails notificationDetails = NotificationDetails(
          android: androidNotificationDetails,
        );

        await _flutterLocalNotificationsPlugin.show(
          message.hashCode,
          message.notification?.title ?? 'New Notification',
          message.notification?.body ?? 'You have a new message',
          notificationDetails,
          payload: message.data.toString(),
        );
      } else if (Platform.isIOS) {
        // iOS specific notification details
        const DarwinNotificationDetails iOSNotificationDetails =
            DarwinNotificationDetails(
              presentAlert: true,
              presentBadge: true,
              presentSound: true,
              sound: 'default',
              badgeNumber: 1,
              subtitle: 'Solo Seaters',
              threadIdentifier: 'soloseaters_thread',
            );

        const NotificationDetails notificationDetails = NotificationDetails(
          iOS: iOSNotificationDetails,
        );

        await _flutterLocalNotificationsPlugin.show(
          message.hashCode,
          message.notification?.title ?? 'New Notification',
          message.notification?.body ?? 'You have a new message',
          notificationDetails,
          payload: message.data.toString(),
        );
      }

      if (kDebugMode) {
        print(
          'Notification displayed successfully on ${Platform.operatingSystem}',
        );
        print('Notification ID: $notificationId');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error showing notification: $e');
      }
    }
  }

  // Get device token for notifications
  Future<String?> getDeviceToken() async {
    try {
      String? token = await messaging.getToken();
      return token;
    } catch (e) {
      if (kDebugMode) {
        print('Error getting device token: $e');
      }
      return null;
    }
  }

  // Configure foreground notification presentation options
  Future<void> foregroundMessage() async {
    try {
      if (Platform.isIOS) {
        // iOS: Disable automatic presentation to prevent duplicates
        await FirebaseMessaging.instance
            .setForegroundNotificationPresentationOptions(
              alert: false, // Disable automatic alert
              badge: true,
              sound: false, // Disable automatic sound
            );
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error setting foreground message options: $e');
      }
    }
  }

  // Method to refresh token if needed
  Future<void> refreshToken() async {
    try {
      final token = await getDeviceToken();
      if (token != null) {
        ObjectFactory().prefs.setFcmToken(token: token);
        if (kDebugMode) {
          print('FCM Token refreshed: $token');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error refreshing token: $e');
      }
    }
  }

  // Debug method to check iOS notification permissions
  Future<void> checkIOSPermissions() async {
    if (Platform.isIOS && kDebugMode) {
      final bool? result = await _flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >()
          ?.requestPermissions(alert: true, badge: true, sound: true);

      print('iOS notification permissions granted: $result');

      // Check FCM authorization status
      NotificationSettings settings = await messaging.getNotificationSettings();
      print('FCM Authorization status: ${settings.authorizationStatus}');
      print('FCM Alert setting: ${settings.alert}');
      print('FCM Badge setting: ${settings.badge}');
      print('FCM Sound setting: ${settings.sound}');
    }
  }
}
