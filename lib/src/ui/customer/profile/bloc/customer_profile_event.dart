part of 'customer_profile_bloc.dart';

abstract class CustomerProfileEvent extends Equatable {
  const CustomerProfileEvent();

  @override
  List<Object?> get props => [];
}

class GetCustomerProfileEvent extends CustomerProfileEvent {}

class ToggleEditModeEvent extends CustomerProfileEvent {}

class UpdateProfileFieldEvent extends CustomerProfileEvent {
  final String field;
  final String value;

  const UpdateProfileFieldEvent({required this.field, required this.value});

  @override
  List<Object?> get props => [field, value];
}

class FetchLocationEvent extends CustomerProfileEvent {}

class SaveProfileEvent extends CustomerProfileEvent {
  const SaveProfileEvent();

  @override
  List<Object?> get props => [];
}

class CustomerProfileDeleteEvent extends CustomerProfileEvent {
  @override
  List<Object?> get props => [];
}
