import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';

import 'network_connectivity_bloc.dart';

class NetworkHelper {
  static StreamSubscription<List<ConnectivityResult>>? _subscription;

  static void observeNetwork() {
    _subscription?.cancel();

    _subscription = Connectivity().onConnectivityChanged.listen((results) {
      final connected = isConnected(results);
      NetworkConnectivityBloc().add(NetworkNotify(isConnected: connected));
    });

    Connectivity().checkConnectivity().then((results) {
      final connected = isConnected(results);
      NetworkConnectivityBloc().add(NetworkNotify(isConnected: connected));
    });
  }

  static bool isConnected(List<ConnectivityResult> results) {
    return results.isNotEmpty && results.any((r) => r != ConnectivityResult.none);
  }

  static void dispose() {
    _subscription?.cancel();
  }
}


