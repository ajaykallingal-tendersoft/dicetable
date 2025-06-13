import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'object_factory.dart';

class NotificationServices {
  // Singleton pattern
  static final NotificationServices _instance = NotificationServices._internal();
  factory NotificationServices() => _instance;
  NotificationServices._internal();

  // Initialize Firebase Messaging plugin
  final FirebaseMessaging messaging = FirebaseMessaging.instance;

  // Initialize Flutter local notifications plugin
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;

  // Initialize notifications without context (for app startup)
  Future<void> initializeWithoutContext() async {
    if (_isInitialized) return;

    try {
      // Request notification permissions
      await requestNotificationPermission();

      // Setup local notification channel
      setupNotificationChannel();

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

      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;

      if (notification != null && android != null) {
        showNotification(message);
      }
    });
  }

  // Setup Android notification channel
  void setupNotificationChannel() {
    if (Platform.isAndroid) {
      const AndroidNotificationChannel channel = AndroidNotificationChannel(
        'high_importance_channel',
        'High Importance Notifications',
        description: 'This channel is used for important notifications.',
        importance: Importance.high,
      );

      _flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
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
      } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
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
      AndroidNotificationChannel channel = AndroidNotificationChannel(
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
      );

      const DarwinNotificationDetails darwinNotificationDetails =
      DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      NotificationDetails notificationDetails = NotificationDetails(
        android: androidNotificationDetails,
        iOS: darwinNotificationDetails,
      );

      await _flutterLocalNotificationsPlugin.show(
        message.hashCode,
        message.notification?.title ?? 'Default Title',
        message.notification?.body ?? 'Default Body',
        notificationDetails,
        payload: message.data.toString(),
      );
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
      await FirebaseMessaging.instance
          .setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );
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
}