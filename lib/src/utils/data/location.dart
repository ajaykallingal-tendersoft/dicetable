import 'dart:io';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class LocationUtils {
  /// Opens the app settings page for the user to manually enable location permission
  static Future<void> openAppSettings() async {
    await openAppSettings();
  }

  /// Opens location settings (Android) or app settings (iOS)
  static Future<void> openLocationSettings() async {
    if (Platform.isAndroid) {
      // For Android, try to open location settings first
      await Permission.location.request();
      if (await Permission.location.isPermanentlyDenied) {
        await openAppSettings();
      }
    } else if (Platform.isIOS) {
      // For iOS, directly open app settings
      await openAppSettings();
    }
  }

  /// Show a dialog explaining why location permission is needed
  static void showLocationPermissionDialog({
    required BuildContext context,
    required VoidCallback onSettingsPressed,
    required VoidCallback onCancelPressed,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Location Permission Required'),
          content: const Text(
            'This app needs location access to show nearby cafes. Please enable location permission in your device settings.',
          ),
          actions: [
            TextButton(
              onPressed: onCancelPressed,
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: onSettingsPressed,
              child: const Text('Open Settings'),
            ),
          ],
        );
      },
    );
  }

  /// Show a dialog for when location services are disabled
  static void showLocationServiceDialog({
    required BuildContext context,
    required VoidCallback onEnablePressed,
    required VoidCallback onCancelPressed,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Location Services Disabled'),
          content: const Text(
            'Location services are currently disabled. Please enable location services to find nearby cafes.',
          ),
          actions: [
            TextButton(
              onPressed: onCancelPressed,
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: onEnablePressed,
              child: const Text('Enable Location'),
            ),
          ],
        );
      },
    );
  }
}