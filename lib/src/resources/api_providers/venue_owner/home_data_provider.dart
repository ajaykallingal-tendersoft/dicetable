

import 'package:dicetable/src/model/cafe_owner/home/venue_owner_home_screen_response.dart';
import 'package:dicetable/src/model/state_model.dart';
import 'package:dicetable/src/utils/data/object_factory.dart';
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

      if (e.response!.statusCode == 500) {
        return StateModel.error(
            "The server isn't responding! Please try again later.");
        // return response!;
      } else if (e.response!.statusCode == 408) {
        return StateModel.error(
            "Hello there! It seems like your request took longer than expected to process. We apologize for the inconvenience. Please try again later or reach out to our support team for assistance. Thank you for your patience!");
        // Something happened in setting up or sending the request that triggered an Error
      } else if (e.type.name == "connectionError") {
        return StateModel.error(
            "Connection refused This indicates an error which most likely cannot be solved by the library.Please try again later or reach out to our support team for assistance. Thank you for your patience!");
        // Something happened in setting up or sending the request that triggered an Error
      }

    }
    return null;
  }

}