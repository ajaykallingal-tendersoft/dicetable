

import 'dart:convert';

import 'package:soloseaters/src/model/cafe_owner/home/dice_table_type_update_response.dart';
import 'package:soloseaters/src/model/cafe_owner/home/dice_table_update_request.dart';
import 'package:soloseaters/src/model/cafe_owner/home/venue_owner_home_screen_response.dart';
import 'package:soloseaters/src/model/state_model.dart';
import 'package:soloseaters/src/utils/data/object_factory.dart';
import 'package:dio/dio.dart';

class HomeDataProvider {
  Future<StateModel?> getVenueOwnerHomeData() async {
    try {
      final response =
      await ObjectFactory().apiClient.getVenueOwnerHomeData();
      print(response.toString());
      if (response.statusCode == 200) {
        return StateModel<VenueOwnerHomeScreenResponse>.success(
            VenueOwnerHomeScreenResponse.fromJson(response.data));
      }
      return null;
    } on DioException catch (e) {

      if (e.response != null && e.response!.statusCode == 500) {
        return StateModel.error(
            "The server isn't responding! Please try again later.");
      } else if (e.response != null && e.response!.statusCode == 408) {
        return StateModel.error(
            "Hello there! It seems like your request took longer than expected to process. We apologize for the inconvenience. Please try again later or reach out to our support team for assistance. Thank you for your patience!");
      } else if (e.response != null && e.response!.statusCode == 401) {
        return StateModel.error(
            "UnAuthorized error");
      } else if (e.response == null) {
        if (e.message == "No internet connection") {
          return StateModel.error("No internet connection");
        }
        return StateModel.error("Unable to reach server. Try again later.");
      }
      else if (e.type.name == "connectionError") {
        if (e.message == "No internet connection") {
          return StateModel.error("No internet connection");
        }
        return StateModel.error("Unable to reach server. Try again later.");
      }

    }
    return null;
  }
  Future<StateModel?> updateDiceTableType(DiceTableTypeUpdateRequest diceTableUpdateRequest) async {
    try {
      final response =
      await ObjectFactory().apiClient.updateDiceTableType(diceTableUpdateRequest);
      print(response.toString());
      String jsonRequest = jsonEncode(diceTableUpdateRequest);
      print("Request Payload:");
      print(jsonRequest);
      if (response.statusCode == 200) {
        return StateModel<DiceTableTypeUpdateResponse>.success(
            DiceTableTypeUpdateResponse.fromJson(response.data));
      }
      return null;
    } on DioException catch (e) {

      if (e.response != null && e.response!.statusCode == 500) {
        return StateModel.error(
            "The server isn't responding! Please try again later.");
      } else if (e.response != null && e.response!.statusCode == 408) {
        return StateModel.error(
            "Hello there! It seems like your request took longer than expected to process. We apologize for the inconvenience. Please try again later or reach out to our support team for assistance. Thank you for your patience!");
      } else if (e.response != null && e.response!.statusCode == 401) {
        return StateModel.error(
            "UnAuthorized error");
      } else if (e.type.name == "connectionError" || e.response == null) {
        if (e.message == "No internet connection") {
          return StateModel.error("No internet connection");
        }
        return StateModel.error("Unable to reach server. Try again later.");
      }

    }
    return null;
  }

}