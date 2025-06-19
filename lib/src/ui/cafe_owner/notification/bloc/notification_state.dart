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


final class NotificationError extends NotificationState {
  final String errorMessage;

  const NotificationError({required this.errorMessage});

  @override
  List<Object?> get props => [errorMessage];
}
