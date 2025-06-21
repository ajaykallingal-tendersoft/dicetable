part of 'notification_bloc.dart';

@immutable
sealed class NotificationState extends Equatable {
  const NotificationState();

  @override
  List<Object?> get props => [];
}


final class NotificationInitial extends NotificationState {
  const NotificationInitial();
}


final class NotificationLoading extends NotificationState {
  const NotificationLoading();
}


final class NotificationLoaded extends NotificationState {
  final NotificationItems notificationItems;

  const NotificationLoaded({required this.notificationItems});

  @override
  List<Object?> get props => [notificationItems];
}

class NotificationRead extends NotificationState {
  final NotificationReadResponse notificationReadResponse;
  const NotificationRead({required this.notificationReadResponse});
}


final class NotificationError extends NotificationState {
  final String errorMessage;

  const NotificationError({required this.errorMessage});

  @override
  List<Object?> get props => [errorMessage];
}

class NotificationStatusUpdated extends NotificationState {
  final NotificationStatusResponse notificationStatusResponse;

  const NotificationStatusUpdated({required this.notificationStatusResponse});

  @override
  List<Object?> get props => [notificationStatusResponse];
}
