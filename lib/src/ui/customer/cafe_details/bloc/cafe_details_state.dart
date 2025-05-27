part of 'cafe_details_bloc.dart';

sealed class CafeDetailsState extends Equatable {
  const CafeDetailsState();
}

final class CafeDetailsInitial extends CafeDetailsState {
  @override
  List<Object> get props => [];
}

final class CafeBookingLoading extends CafeDetailsState {
  @override
  List<Object> get props => [];
}

final class CafeBookingLoaded extends CafeDetailsState {
  final BookingRequestResponse bookingRequestResponse;
  const CafeBookingLoaded({required this.bookingRequestResponse});
  @override
  List<Object> get props => [bookingRequestResponse];
}

final class CafeBookingError extends CafeDetailsState {
  final String errorMessage;
 const CafeBookingError({required this.errorMessage});
  @override
  List<Object> get props => [errorMessage];
}