import 'dart:convert';
import 'package:dicetable/src/model/customer/booking/booking_request.dart';
import 'package:dicetable/src/model/customer/booking/booking_request_response.dart';
import 'package:dicetable/src/model/customer/booking/withdraw_booking_request.dart';
import 'package:dicetable/src/model/customer/booking/withdraw_booking_response.dart';
import 'package:dicetable/src/model/state_model.dart';
import 'package:dicetable/src/utils/data/object_factory.dart';
import 'package:dio/dio.dart';

class BookingDataProvider {


  Future<StateModel?> booking(BookingRequest bookingRequest) async {
    try {
      final response =
      await ObjectFactory().apiClient.booking(bookingRequest);
      print(response.toString());
      String jsonRequest = jsonEncode(bookingRequest);
      print("Request Payload:");
      print(jsonRequest);
      if (response.statusCode == 200) {
        return StateModel<BookingRequestResponse>.success(
            BookingRequestResponse.fromJson(response.data));
      }
      return null;
    } on DioException catch (e) {

      if (e.response!.statusCode == 500) {
        return StateModel.error(
            "The server isn't responding! Please try again later.");
      } else if (e.response!.statusCode == 408) {
        return StateModel.error(
            "Hello there! It seems like your request took longer than expected to process. We apologize for the inconvenience. Please try again later or reach out to our support team for assistance. Thank you for your patience!");
      } else if (e.type.name == "connectionError") {
        return StateModel.error(
            "Connection refused This indicates an error which most likely cannot be solved by the library.Please try again later or reach out to our support team for assistance. Thank you for your patience!");
      }

    }
    return null;
  }

  Future<StateModel?> withdrawBooking( WithdrawBookingRequest request) async {
    try {
      final response =
      await ObjectFactory().apiClient.withdrawBooking(request);
      print(response.toString());
      String jsonRequest = jsonEncode(request);
      print("Request Payload:");
      print(jsonRequest);
      if (response.statusCode == 200) {
        return StateModel<WithdrawBookingResponse>.success(
            WithdrawBookingResponse.fromJson(response.data));
      }
      return null;
    } on DioException catch (e) {

      if (e.response!.statusCode == 500) {
        return StateModel.error(
            "The server isn't responding! Please try again later.");
      } else if (e.response!.statusCode == 408) {
        return StateModel.error(
            "Hello there! It seems like your request took longer than expected to process. We apologize for the inconvenience. Please try again later or reach out to our support team for assistance. Thank you for your patience!");
      } else if (e.type.name == "connectionError") {
        return StateModel.error(
            "Connection refused This indicates an error which most likely cannot be solved by the library.Please try again later or reach out to our support team for assistance. Thank you for your patience!");
      }

    }
    return null;
  }

}