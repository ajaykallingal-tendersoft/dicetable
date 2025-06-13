import 'package:bloc/bloc.dart';
import 'package:dicetable/src/model/customer/booking/booking_request.dart';
import 'package:dicetable/src/model/customer/booking/booking_request_response.dart';
import 'package:dicetable/src/model/customer/booking/withdraw_booking_request.dart';
import 'package:dicetable/src/model/customer/booking/withdraw_booking_response.dart';
import 'package:dicetable/src/model/state_model.dart';
import 'package:dicetable/src/resources/api_providers/customer/booking_data_provider.dart';
import 'package:equatable/equatable.dart';

part 'cafe_details_event.dart';
part 'cafe_details_state.dart';

class CafeDetailsBloc extends Bloc<CafeDetailsEvent, CafeDetailsState> {
  BookingDataProvider bookingDataProvider;
  CafeDetailsBloc({required this.bookingDataProvider}) : super(CafeDetailsInitial()) {
    on<BookingRequestEvent>(_onBookingRequest);
    on<WithdrawBookingRequestEvent> (_onWithdrawRequest);
  }



  Future<void> _onBookingRequest(
      BookingRequestEvent event,
      Emitter<CafeDetailsState> emit,
      ) async {
    emit(CafeBookingLoading());
    try {
      final StateModel? stateModel =
      await bookingDataProvider.booking(event.bookingRequest);

      if (stateModel is SuccessState) {
        final response = stateModel.value as BookingRequestResponse;
        emit(CafeBookingLoaded(bookingRequestResponse: response));
      } else if (stateModel is ErrorState) {
        emit(CafeBookingError(errorMessage: stateModel.msg));
      }
    } catch (e, stackTrace) {
      print('CafeDetailsBloc Error: $e');
      print('StackTrace: $stackTrace');
      emit(CafeBookingError(errorMessage: e.toString()));
    }
  }

  Future<void> _onWithdrawRequest(
      WithdrawBookingRequestEvent event,
      Emitter<CafeDetailsState> emit,
      ) async {
    emit(WithdrawBookingLoading());
    try {
      final StateModel? stateModel =
      await bookingDataProvider.withdrawBooking(event.withdrawBookingRequest);

      if (stateModel is SuccessState) {
        final response = stateModel.value as WithdrawBookingResponse;
        emit(WithdrawBookingLoaded(withdrawBookingResponse: response));
      } else if (stateModel is ErrorState) {
        emit(WithdrawBookingError(errorMessage: stateModel.msg));
      }
    } catch (e, stackTrace) {
      print('Withdraw Error: $e');
      print('StackTrace: $stackTrace');
      emit(WithdrawBookingError(errorMessage: e.toString()));
    }
  }

}
