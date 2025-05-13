part of 'network_connectivity_bloc.dart';

@immutable
sealed class NetworkConnectivityState {}

final class NetworkConnectivityInitial extends NetworkConnectivityState {}

class NetworkInitial extends NetworkConnectivityState {}

class NetworkSuccess extends NetworkConnectivityState {}

class NetworkFailure extends NetworkConnectivityState {}
