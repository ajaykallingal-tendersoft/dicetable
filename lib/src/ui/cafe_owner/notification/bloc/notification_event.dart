part of 'notification_bloc.dart';

@immutable
sealed class NotificationEvent extends Equatable {
  const NotificationEvent();

  @override
  List<Object?> get props => [];
}

final class FetchNotifications extends NotificationEvent {

  @override
  List<Object?> get props => [];
}

class ReadNotification extends NotificationEvent {
  final NotificationReadRequest notificationReadRequest;
  const ReadNotification({required this.notificationReadRequest});
  @override
  List<Object?> get props => [notificationReadRequest];
}
