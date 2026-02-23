import 'dart:async';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';

import 'network_connectivity_bloc.dart';

class NetworkHelper {
  static StreamSubscription<List<ConnectivityResult>>? _subscription;

  static void observeNetwork() {
    _subscription?.cancel();

    _subscription = Connectivity().onConnectivityChanged.listen((
      results,
    ) async {
      final connected = await isConnected(results);
      NetworkConnectivityBloc().add(NetworkNotify(isConnected: connected));
    });

    Connectivity().checkConnectivity().then((results) async {
      final connected = await isConnected(results);
      NetworkConnectivityBloc().add(NetworkNotify(isConnected: connected));
    });
  }

  static Future<bool> isConnected(List<ConnectivityResult> results) async {
    if (results.isEmpty || results.every((r) => r == ConnectivityResult.none)) {
      return false;
    }

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
    _subscription?.cancel();
  }
}
