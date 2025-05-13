import 'package:fluttertoast/fluttertoast.dart';

import 'network_connectivity_bloc.dart';

class NetworkToastManager {
  static NetworkConnectivityState? _lastState;

  static void handleStateChange(NetworkConnectivityState state) {
    if (state != _lastState) {
      if (state is NetworkSuccess) {
        Fluttertoast.showToast(msg: "Back online");
      } else if (state is NetworkFailure) {
        Fluttertoast.showToast(msg: "No internet connection");
      }
      _lastState = state;
    }
  }
}
