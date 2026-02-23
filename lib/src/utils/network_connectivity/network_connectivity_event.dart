part of 'network_connectivity_bloc.dart';

@immutable
sealed class NetworkConnectivityEvent {}

class NetworkObserve extends NetworkConnectivityEvent {}

class NetworkNotify extends NetworkConnectivityEvent {
  final bool isConnected;

  NetworkNotify({this.isConnected = false});
}

class _DebounceNotify extends NetworkConnectivityEvent {
  final bool isConnected;

  _DebounceNotify({required this.isConnected});
}
