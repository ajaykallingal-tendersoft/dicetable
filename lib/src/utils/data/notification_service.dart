import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:go_router/go_router.dart';
import 'package:soloseaters/main.dart';
import 'object_factory.dart';

class NotificationServices {
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
  bool _interactionHandlersRegistered = false;

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

        }
      } else {
        if (kDebugMode) {

        }
      }

      // Setup foreground message handling
      _setupForegroundMessageHandling();
      await _listenForNotificationInteractions();

      _isInitialized = true;
    } catch (e) {
      if (kDebugMode) {

      }
    }
  }

  Future<void> _listenForNotificationInteractions() async {
    if (_interactionHandlersRegistered) return;

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      if (kDebugMode) {

      }
      unawaited(
        _handleNotificationNavigation(
          payload: Map<String, dynamic>.from(message.data),
          persistIfNoContext: true,
        ),
      );
    });

    final RemoteMessage? initialMessage = await messaging.getInitialMessage();
    if (initialMessage != null) {
      if (kDebugMode) {

      }
      _persistPendingNavigation(Map<String, dynamic>.from(initialMessage.data));
    }

    _interactionHandlersRegistered = true;
  }

  Future<void> _handleNotificationNavigation({
    Map<String, dynamic>? payload,
    bool persistIfNoContext = true,
  }) async {
    final bool navigated = _navigateBasedOnUserType();
    if (navigated) {
      await ObjectFactory().prefs.clearPendingNotificationNavigation();
      return;
    }

    if (persistIfNoContext) {
      _persistPendingNavigation(payload);
    }
  }

  void _persistPendingNavigation(Map<String, dynamic>? payload) {
    ObjectFactory().prefs.setPendingNotificationNavigation(true);
    ObjectFactory().prefs.setPendingNotificationPayload(payload);
  }

  Future<bool> handlePendingNotificationNavigation() async {
    final shouldNavigate =
        ObjectFactory().prefs.getPendingNotificationNavigation() ?? false;

    if (!shouldNavigate) {
      return false;
    }

    final payload = ObjectFactory().prefs.getPendingNotificationPayload();
    final bool navigated = _navigateBasedOnUserType();

    if (navigated) {
      await ObjectFactory().prefs.clearPendingNotificationNavigation();
      return true;
    }

    _persistPendingNavigation(payload);
    return false;
  }

  Future<void> _handleNotificationTap(NotificationResponse response) async {
    if (kDebugMode) {

    }
    Map<String, dynamic>? payload;
    if (response.payload != null && response.payload!.isNotEmpty) {
      try {
        payload = Map<String, dynamic>.from(jsonDecode(response.payload!));
      } catch (e) {
        if (kDebugMode) {

        }
      }
    }
    await _handleNotificationNavigation(payload: payload);
  }

  bool _navigateBasedOnUserType() {
    final isLoggedIn = ObjectFactory().prefs.isLoggedIn() == true;
    final isCustomerLoggedIn =
        ObjectFactory().prefs.isCustomerLoggedIn() == true;
    ObjectFactory().prefs.setNavigationSource('notification_tap');

    final String route =
        (isLoggedIn || isCustomerLoggedIn) ? '/notification' : '/category';

    return _navigateToRoute(route);
  }

  bool _navigateToRoute(String route) {
    final context = navigatorKey.currentContext;
    if (context == null) {
      if (kDebugMode) {

      }
      return false;
    }

    final router = GoRouter.of(context);
    try {
      router.push(route);
    } catch (e) {
      if (kDebugMode) {

      }
      router.go(route);
    }
    return true;
  }

  // Initialize local notifications plugin
  Future<void> _initializeLocalNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/launcher_icon');

    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
          requestAlertPermission: true,
          requestSoundPermission: true,
          requestCriticalPermission: false,
          requestBadgePermission: false,
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
            badge: false,
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

      }
    } catch (e) {
      if (kDebugMode) {

      }
    }
  }

  // Setup foreground message handling
  void _setupForegroundMessageHandling() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (kDebugMode) {




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

    // Notification tap interactions handled in _listenForNotificationInteractions
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
        showBadge: false,
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
        badge: false,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        if (kDebugMode) {

        }
      } else if (settings.authorizationStatus ==
          AuthorizationStatus.provisional) {
        if (kDebugMode) {

        }
      } else {
        if (kDebugMode) {

        }
      }
    } catch (e) {
      if (kDebugMode) {

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
              styleInformation: BigTextStyleInformation(
                message.notification?.body ?? '',
                contentTitle: message.notification?.title,
              ),
            );

        NotificationDetails notificationDetails = NotificationDetails(
          android: androidNotificationDetails,
        );

        await _flutterLocalNotificationsPlugin.show(
          message.hashCode,
          message.notification?.title ?? 'New Notification',
          message.notification?.body ?? 'You have a new message',
          notificationDetails,
          payload: message.data.isEmpty ? null : jsonEncode(message.data),
        );
      } else if (Platform.isIOS) {
        // iOS specific notification details
        const DarwinNotificationDetails iOSNotificationDetails =
            DarwinNotificationDetails(
              presentAlert: true,
              presentBadge: false,
              presentSound: true,
              sound: 'default',
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
          payload: message.data.isEmpty ? null : jsonEncode(message.data),
        );
      }

      if (kDebugMode) {
        print(
          'Notification displayed successfully on ${Platform.operatingSystem}',
        );

      }
    } catch (e) {
      if (kDebugMode) {

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
              badge: false,
              sound: false, // Disable automatic sound
            );
      }
    } catch (e) {
      if (kDebugMode) {

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

        }
      }
    } catch (e) {
      if (kDebugMode) {

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
          ?.requestPermissions(alert: true, badge: false, sound: true);



      // Check FCM authorization status
      NotificationSettings settings = await messaging.getNotificationSettings();




    }
  }
}
