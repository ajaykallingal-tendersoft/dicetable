part of 'customer_home_bloc.dart';

sealed class CustomerHomeState extends Equatable {
  const CustomerHomeState();
}

final class CustomerHomeInitial extends CustomerHomeState {
  @override
  List<Object> get props => [];
}

final class CustomerHomeLoading extends CustomerHomeState {
  @override
  List<Object> get props => [];
}

final class CustomerHomeLoaded extends CustomerHomeState {
 final CafeSearchResponse cafeSearchResponse;
 const CustomerHomeLoaded({required this.cafeSearchResponse});
  @override
  List<Object> get props => [cafeSearchResponse];
}

final class CustomerHomeError extends CustomerHomeState {
  final String errorMessage;
  const CustomerHomeError({required this.errorMessage});
  @override
  List<Object> get props => [errorMessage];
}