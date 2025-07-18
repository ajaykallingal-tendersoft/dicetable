import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'network_connectivity_bloc.dart';

class NetworkToastManager {
  static NetworkConnectivityState? _lastState;

  static void handleStateChange(NetworkConnectivityState state) {
    if (state != _lastState) {
      if (state is NetworkSuccess) {
        // Fluttertoast.showToast(msg: "Back online");
      } else if (state is NetworkFailure) {
        Fluttertoast.showToast(msg: "No internet connection",fontSize: 14.sp,);
      }
      _lastState = state;
    }
  }
}
