part of 'cafe_details_bloc.dart';

sealed class CafeDetailsEvent extends Equatable {
  const CafeDetailsEvent();
}

class BookingRequestEvent extends CafeDetailsEvent {
  final BookingRequest bookingRequest;
  const BookingRequestEvent({required this.bookingRequest});
  @override
  List<Object?> get props => [bookingRequest];

}