import 'dart:async';
import 'dart:io';

import 'network_connectivity_bloc.dart';

class NetworkHelper {
  static Timer? _pollingTimer;

  static void observeNetwork() {
    _pollingTimer?.cancel();

    // Check immediately on start
    _checkAndNotify();

    // Poll every 5 seconds for connectivity changes
    _pollingTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      _checkAndNotify();
    });
  }

  static Future<void> _checkAndNotify() async {
    final connected = await isConnected();
    NetworkConnectivityBloc().add(NetworkNotify(isConnected: connected));
  }

  static Future<bool> isConnected([List? results]) async {
    try {
      final result = await InternetAddress.lookup(
        'google.com',
      ).timeout(const Duration(seconds: 3));
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  static void dispose() {
    _pollingTimer?.cancel();
  }
}
