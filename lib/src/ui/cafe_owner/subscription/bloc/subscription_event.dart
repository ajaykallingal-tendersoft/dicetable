part of 'subscription_bloc.dart';

sealed class SubscriptionEvent extends Equatable {
  const SubscriptionEvent();
}


class FetchInitialSubscription extends SubscriptionEvent{
  @override
  List<Object?> get props => [];

}

class StartSubscriptionEvent extends SubscriptionEvent {
  final SubscriptionStartRequest subscriptionStartRequest;
  const StartSubscriptionEvent({required this.subscriptionStartRequest});
  @override
  List<Object?> get props => [subscriptionStartRequest];
}