import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

import 'network_helper.dart';

part 'network_connectivity_event.dart';
part 'network_connectivity_state.dart';

class NetworkConnectivityBloc
    extends Bloc<NetworkConnectivityEvent, NetworkConnectivityState> {
  NetworkConnectivityBloc._() : super(NetworkConnectivityInitial()) {
    on<NetworkObserve>(_observe);
    on<NetworkNotify>(_notifyStatus);
    on<_DebounceNotify>(_onDebounceNotify);
  }

  Timer? _debounceTimer;
  bool? _lastReportedStatus;

  static final NetworkConnectivityBloc _instance = NetworkConnectivityBloc._();

  factory NetworkConnectivityBloc() => _instance;

  void _observe(event, emit) {
    NetworkHelper.observeNetwork();
  }

  void _notifyStatus(NetworkNotify event, emit) {
    if (_lastReportedStatus == event.isConnected) return;
    _lastReportedStatus = event.isConnected;

    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 700), () {
      if (!isClosed) {
        add(_DebounceNotify(isConnected: event.isConnected));
      }
    });
  }

  void _onDebounceNotify(_DebounceNotify event, emit) {
    emit(event.isConnected ? NetworkSuccess() : NetworkFailure());
  }
}
