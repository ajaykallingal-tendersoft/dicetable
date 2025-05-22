part of 'subscription_bloc.dart';

sealed class SubscriptionState extends Equatable {
  const SubscriptionState();
}

final class SubscriptionInitial extends SubscriptionState {
  @override
  List<Object> get props => [];
}
/// Initial subscription
final class InitialSubscriptionLoading extends SubscriptionState {
  @override
  List<Object?> get props => [];
}

final class InitialSubscriptionLoaded extends SubscriptionState {
  final InitialSubscriptionPlanResponse initialSubscriptionPlanResponse;
  const InitialSubscriptionLoaded({required this.initialSubscriptionPlanResponse});

  @override
  List<Object?> get props => [initialSubscriptionPlanResponse];
}

final class InitialSubscriptionError extends SubscriptionState {
  final String errorMessage;
  const InitialSubscriptionError({required this.errorMessage});

  @override
  List<Object?> get props => [errorMessage];
}

///Subscription start
final class StartSubscriptionLoading extends SubscriptionState {
  @override
  List<Object> get props => [];
}
final class StartSubscriptionLoaded extends SubscriptionState {
  final SubscriptionStartResponse subscriptionStartResponse;
 const StartSubscriptionLoaded({required this.subscriptionStartResponse});
  @override
  List<Object> get props => [subscriptionStartResponse];
}

final class StartSubscriptionError extends SubscriptionState {
  final String errorMessage;
  const StartSubscriptionError({required this.errorMessage});
  @override
  List<Object> get props => [errorMessage];
}

///Subscription Overview
final class SubscriptionOverviewLoading extends SubscriptionState {
  @override
  List<Object> get props => [];
}
final class SubscriptionOverviewLoaded extends SubscriptionState {
  final SubscriptionOverviewResponse subscriptionOverviewResponse;
  const SubscriptionOverviewLoaded({required this.subscriptionOverviewResponse});
  @override
  List<Object> get props => [subscriptionOverviewResponse];
}

final class SubscriptionOverviewError extends SubscriptionState {
  final String errorMessage;
  const SubscriptionOverviewError({required this.errorMessage});
  @override
  List<Object> get props => [errorMessage];
}