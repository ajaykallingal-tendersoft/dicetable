part of 'customer_home_bloc.dart';

sealed class CustomerHomeState extends Equatable {
  const CustomerHomeState();
}

final class CustomerHomeInitial extends CustomerHomeState {
  @override
  List<Object> get props => [];
}
final class CafeSearchInitial extends CustomerHomeState {
  @override
  List<Object> get props => [];
}

class CafeSearchLoading extends CustomerHomeState {
  @override
  List<Object> get props => [];
}

class CafeSearchSuccess extends CustomerHomeState {
  final SearchRequestResponse response;
  final List<CafeLocation> cafeLocations;

  const CafeSearchSuccess({
    required this.response,
    required this.cafeLocations,
  });

  @override
  List<Object?> get props => [response, cafeLocations];
}

class CafeSearchError extends CustomerHomeState {
  final String message;

  const CafeSearchError(this.message);

  @override
  List<Object?> get props => [message];
}

// Helper class for cafe locations
class CafeLocation extends Equatable {
  final int id;
  final String name;
  final double latitude;
  final double longitude;
  final String? photo;
  final String? description;

  const CafeLocation({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    this.photo,
    this.description,
  });

  @override
  List<Object?> get props => [id, name, latitude, longitude, photo, description];
}