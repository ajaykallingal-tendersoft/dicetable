part of 'customer_home_bloc.dart';

sealed class CustomerHomeEvent extends Equatable {
  const CustomerHomeEvent();
}

class SearchCafesEvent extends CustomerHomeEvent {
  final CafeSearchRequest request;

  const SearchCafesEvent(this.request);

  @override
  List<Object?> get props => [request];
}

class FilterCafesEvent extends CustomerHomeEvent {
  final CafeSearchRequest filterRequest;

  const FilterCafesEvent(this.filterRequest);

  @override
  List<Object?> get props => [filterRequest];
}

class ResetSearchEvent extends CustomerHomeEvent {
  @override
  List<Object?> get props => [];
}